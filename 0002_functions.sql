-- ClassTix — business rules. Every function is atomic (one transaction) and checks who is calling.

-- ================================================================ sign-in bookkeeping
create or replace function public.touch_login() returns void
language sql security definer set search_path = public as $$
  update profiles set last_login = now(),
         status = case when status = 'Invited' then 'Active' else status end
  where id = auth.uid() and status <> 'Deactivated'
$$;

-- ================================================================ district: requests
create or replace function public.submit_request(p_type uuid, p_qty int, p_note text) returns text
language plpgsql security definer set search_path = public as $$
declare
  v_did uuid := my_district();
  t ticket_types; e events; d districts;
  v_cost int; v_avail int; v_code text; v_id uuid;
begin
  if v_did is null then raise exception 'Your account isn''t linked to an active district.'; end if;
  select * into d from districts where id = v_did for update;            -- serialises spending per district
  select * into t from ticket_types where id = p_type for update;
  if not found then raise exception 'That ticket type no longer exists.'; end if;
  select * into e from events where id = t.event_id;
  if e.status <> 'Published' then raise exception 'This listing isn''t open for requests.'; end if;
  if e.dated and e.deadline is not null and e.deadline < az_today() then raise exception 'The request deadline has passed.'; end if;
  if p_qty is null or p_qty < 1 then raise exception 'Choose how many tickets you need.'; end if;
  if p_qty > t.qty - t.approved then raise exception 'Only % left for %.', t.qty - t.approved, t.name; end if;
  if e.max_per_request is not null and p_qty > e.max_per_request then
    raise exception 'The most you can request for this listing is %.', e.max_per_request; end if;
  v_cost := p_qty * t.points;
  v_avail := available(v_did);
  if v_cost > v_avail then raise exception 'This costs % and you have % available.', fmt_pts(v_cost), fmt_pts(v_avail); end if;

  v_code := 'R-' || upper(substr(md5(gen_random_uuid()::text), 1, 6));
  insert into requests (code, district_id, event_id, type_id, qty, points_each, note, created_by)
  values (v_code, v_did, e.id, t.id, p_qty, t.points, left(coalesce(trim(p_note), ''), 300), auth.uid())
  returning id into v_id;
  insert into ledger (district_id, entry, amount, ref) values (v_did, 'Held for request', -v_cost, v_code);
  perform notify_admins(
    'New request ' || v_code || ' from ' || d.name,
    d.name || ' requested ' || p_qty || ' × ' || t.name || ' for ' || e.title || ' (' || event_when(e) || ').' || E'\n'
      || 'Points: ' || fmt_pts(v_cost) || E'\nNote: ' || coalesce(nullif(trim(p_note), ''), '—')
      || E'\n\nReview it in the request queue.', 'new');
  return v_code;
end $$;

create or replace function public.cancel_request(p_id uuid) returns void
language plpgsql security definer set search_path = public as $$
declare r requests; e events; d districts;
begin
  select * into r from requests where id = p_id for update;
  if not found then raise exception 'Request not found.'; end if;
  if not (is_admin() or r.district_id = my_district()) then raise exception 'You can''t change this request.'; end if;
  if r.status <> 'Pending' then raise exception 'Only pending requests can be cancelled.'; end if;
  select * into e from events where id = r.event_id;
  select * into d from districts where id = r.district_id;
  update requests set status = 'Cancelled', decided_at = now() where id = p_id;
  insert into ledger (district_id, entry, amount, ref) values (r.district_id, 'Cancelled, points released', r.qty * r.points_each, r.code);
  perform notify_admins(r.code || ' cancelled by ' || d.name,
    d.name || ' cancelled its pending request for ' || e.title || ' (' || r.qty || ' tickets).', 'cancelled');
end $$;

-- ================================================================ admin: decisions
create or replace function public.approve_request(p_id uuid, p_qty int default null) returns void
language plpgsql security definer set search_path = public as $$
declare r requests; t ticket_types; e events; q int;
begin
  perform require_admin();
  select * into r from requests where id = p_id for update;
  if not found or r.status <> 'Pending' then raise exception 'This request was already handled.'; end if;
  select * into t from ticket_types where id = r.type_id for update;
  select * into e from events where id = r.event_id;
  q := coalesce(p_qty, r.qty);
  if q < 1 or q > r.qty then raise exception 'Approve between 1 and % tickets.', r.qty; end if;
  if q > t.qty - t.approved then raise exception 'Only % left for %.', t.qty - t.approved, t.name; end if;
  update ticket_types set approved = approved + q where id = t.id;
  update requests set status = 'Approved', approved_qty = q, decided_at = now() where id = p_id;
  if q = r.qty then
    insert into ledger (district_id, entry, amount, ref) values (r.district_id, 'Approved, points spent', 0, r.code);
  else
    insert into ledger (district_id, entry, amount, ref)
    values (r.district_id, 'Approved ' || q || ' of ' || r.qty || ', unused points released', (r.qty - q) * r.points_each, r.code);
  end if;
  perform notify_district(r.district_id,
    'Request ' || r.code || ' approved' || case when q < r.qty then ' in part' else '' end,
    'ClassTix approved ' || q || case when q < r.qty then ' of ' || r.qty else '' end || ' × ' || t.name
      || ' for ' || e.title || ' (' || event_when(e) || ').' || E'\n'
      || case when q < r.qty then 'The ' || fmt_pts((r.qty - q) * r.points_each) || ' for the tickets we couldn''t approve are back in your balance.' || E'\n' else '' end
      || E'\nWe''ll send the tickets by email or text before the event.\n\nThe ClassTix team', 'approved');
end $$;

create or replace function public.reject_request(p_id uuid, p_reason text) returns void
language plpgsql security definer set search_path = public as $$
declare r requests; e events;
begin
  perform require_admin();
  if coalesce(trim(p_reason), '') = '' then raise exception 'Give the district a reason.'; end if;
  select * into r from requests where id = p_id for update;
  if not found or r.status <> 'Pending' then raise exception 'This request was already handled.'; end if;
  select * into e from events where id = r.event_id;
  update requests set status = 'Rejected', reason = left(trim(p_reason), 200), decided_at = now() where id = p_id;
  insert into ledger (district_id, entry, amount, ref) values (r.district_id, 'Rejected, points released', r.qty * r.points_each, r.code);
  perform notify_district(r.district_id, 'Request ' || r.code || ' wasn''t approved',
    'ClassTix couldn''t approve your request for ' || e.title || '.' || E'\nReason: ' || trim(p_reason)
      || E'\n\nYour ' || fmt_pts(r.qty * r.points_each) || E' are back in your balance.\n\nThe ClassTix team', 'rejected');
end $$;

create or replace function public.fulfil_request(p_id uuid) returns void
language plpgsql security definer set search_path = public as $$
declare r requests; e events;
begin
  perform require_admin();
  select * into r from requests where id = p_id for update;
  if not found or r.status <> 'Approved' then raise exception 'Only approved requests can be marked fulfilled.'; end if;
  select * into e from events where id = r.event_id;
  update requests set status = 'Fulfilled', fulfilled_at = now() where id = p_id;
  perform notify_district(r.district_id, 'Tickets on the way: ' || e.title,
    'Your ' || r.approved_qty || ' tickets for ' || e.title || ' (' || event_when(e) || E') have been sent. Look out for them by email or text.\n\nThe ClassTix team', 'fulfilled');
end $$;

create or replace function public.set_internal_note(p_id uuid, p_note text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform require_admin();
  insert into request_notes (request_id, note) values (p_id, left(coalesce(p_note, ''), 1000))
  on conflict (request_id) do update set note = excluded.note, updated_at = now();
end $$;

-- ================================================================ admin: events
-- p: {id?, title, cat, partner, description, dated, date, time, venue, deadline, max_per_request, status,
--     types:[{id?, name, qty, points, seats}]}
create or replace function public.save_event(p jsonb) returns uuid
language plpgsql security definer set search_path = public as $$
declare
  v_id uuid := nullif(p->>'id', '')::uuid;
  v_old events; v_new events; ty jsonb; v_tid uuid; i int := 0; keep uuid[] := '{}'; d record;
  v_dated boolean := coalesce((p->>'dated')::boolean, true);
begin
  perform require_admin();
  if coalesce(trim(p->>'title'), '') = '' then raise exception 'Add a title.'; end if;
  if v_dated and nullif(p->>'date', '') is null then raise exception 'Pick the event date, or make it an undated item.'; end if;
  if jsonb_array_length(coalesce(p->'types', '[]')) = 0 then raise exception 'Add at least one ticket type.'; end if;

  if v_id is not null then
    select * into v_old from events where id = v_id for update;
    if not found then raise exception 'Listing not found.'; end if;
    update events set
      title = trim(p->>'title'), cat = coalesce(nullif(p->>'cat', ''), 'other'), partner = coalesce(trim(p->>'partner'), ''),
      description = coalesce(trim(p->>'description'), ''), dated = v_dated,
      date = case when v_dated then (p->>'date')::date end, time = case when v_dated then coalesce(p->>'time', '') else '' end,
      venue = case when v_dated then coalesce(trim(p->>'venue'), '') else '' end,
      deadline = case when v_dated then coalesce(nullif(p->>'deadline', '')::date, (p->>'date')::date) end,
      max_per_request = nullif(nullif(p->>'max_per_request', ''), '0')::int,
      status = coalesce(nullif(p->>'status', ''), v_old.status), updated_at = now()
    where id = v_id returning * into v_new;
  else
    insert into events (title, cat, partner, description, dated, date, time, venue, deadline, max_per_request, status)
    values (trim(p->>'title'), coalesce(nullif(p->>'cat', ''), 'other'), coalesce(trim(p->>'partner'), ''),
      coalesce(trim(p->>'description'), ''), v_dated,
      case when v_dated then (p->>'date')::date end, case when v_dated then coalesce(p->>'time', '') else '' end,
      case when v_dated then coalesce(trim(p->>'venue'), '') else '' end,
      case when v_dated then coalesce(nullif(p->>'deadline', '')::date, (p->>'date')::date) end,
      nullif(nullif(p->>'max_per_request', ''), '0')::int, coalesce(nullif(p->>'status', ''), 'Published'))
    returning * into v_new;
    v_id := v_new.id;
  end if;

  for ty in select * from jsonb_array_elements(p->'types') loop
    i := i + 1;
    if coalesce(trim(ty->>'name'), '') = '' then raise exception 'Give every ticket type a name.'; end if;
    if coalesce((ty->>'qty')::int, 0) < 1 then raise exception 'Set a quantity for %.', ty->>'name'; end if;
    if coalesce((ty->>'points')::int, 0) < 1 then raise exception 'Set the points for %.', ty->>'name'; end if;
    v_tid := nullif(ty->>'id', '')::uuid;
    if v_tid is not null and exists (select 1 from ticket_types where id = v_tid and event_id = v_id) then
      if (select approved from ticket_types where id = v_tid) > (ty->>'qty')::int then
        raise exception '% already has % approved tickets. Quantity can''t go below that.',
          ty->>'name', (select approved from ticket_types where id = v_tid);
      end if;
      update ticket_types set name = trim(ty->>'name'), qty = (ty->>'qty')::int, points = (ty->>'points')::int,
        seats = greatest(coalesce((ty->>'seats')::int, 1), 1), sort = i where id = v_tid;
    else
      insert into ticket_types (event_id, name, qty, points, seats, sort)
      values (v_id, trim(ty->>'name'), (ty->>'qty')::int, (ty->>'points')::int, greatest(coalesce((ty->>'seats')::int, 1), 1), i)
      returning id into v_tid;
    end if;
    keep := keep || v_tid;
  end loop;
  if exists (select 1 from ticket_types t where t.event_id = v_id and not (t.id = any(keep))
             and (t.approved > 0 or exists (select 1 from requests r where r.type_id = t.id))) then
    raise exception 'A ticket type with requests can''t be removed. Set its quantity instead.';
  end if;
  delete from ticket_types where event_id = v_id and not (id = any(keep));

  -- tell districts with live requests when the when/where changes
  if v_old.id is not null and v_old.dated and v_new.dated
     and (v_old.date is distinct from v_new.date or v_old.time is distinct from v_new.time or v_old.venue is distinct from v_new.venue) then
    for d in select distinct district_id from requests where event_id = v_id and status in ('Pending','Approved','Fulfilled') loop
      perform notify_district(d.district_id, 'Updated details: ' || v_new.title,
        v_new.title || E' has changed.\n\nNow: ' || event_when(v_new) || case when v_new.venue <> '' then ', ' || v_new.venue else '' end
        || E'\nWas: ' || event_when(v_old) || case when v_old.venue <> '' then ', ' || v_old.venue else '' end
        || E'\n\nYour request still stands. If the new date doesn''t work, cancel a pending request in the portal or reply to ClassTix.\n\nThe ClassTix team', 'changed');
    end loop;
  end if;
  return v_id;
end $$;

create or replace function public.set_event_status(p_id uuid, p_status text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform require_admin();
  if p_status not in ('Published','Draft','Archived') then raise exception 'Use Cancel event to cancel a listing.'; end if;
  update events set status = p_status, updated_at = now() where id = p_id;
end $$;

create or replace function public.cancel_event(p_id uuid) returns int
language plpgsql security definer set search_path = public as $$
declare e events; r requests; back int; n int := 0;
begin
  perform require_admin();
  select * into e from events where id = p_id for update;
  if not found then raise exception 'Listing not found.'; end if;
  update events set status = 'Cancelled', updated_at = now() where id = p_id;
  for r in select * from requests where event_id = p_id and status in ('Pending','Approved') for update loop
    n := n + 1;
    if r.status = 'Pending' then
      back := r.qty * r.points_each;
      update requests set status = 'Rejected', reason = 'Event cancelled', decided_at = now() where id = r.id;
    else
      back := r.approved_qty * r.points_each;
      update requests set status = 'Cancelled', reason = 'Event cancelled' where id = r.id;
      update ticket_types set approved = approved - r.approved_qty where id = r.type_id;
    end if;
    insert into ledger (district_id, entry, amount, ref) values (r.district_id, 'Event cancelled, points released', back, r.code);
    perform notify_district(r.district_id, 'Cancelled: ' || e.title,
      e.title || ' (' || event_when(e) || E') has been cancelled.\nYour request ' || r.code || ' is closed and '
      || fmt_pts(back) || E' are back in your balance.\n\nWe''re sorry for the change.\nThe ClassTix team', 'evcancel');
  end loop;
  return n;
end $$;

-- ================================================================ admin: districts
create or replace function public.create_district(p_name text, p_state text, p_students int, p_tier text, p_monthly int, p_contact text)
returns uuid language plpgsql security definer set search_path = public as $$
declare v_id uuid; m text;
begin
  perform require_admin();
  if coalesce(trim(p_name), '') = '' then raise exception 'Add the district''s name.'; end if;
  if p_monthly is null or p_monthly < 0 then raise exception 'Enter monthly points of 0 or more.'; end if;
  insert into districts (name, state, students, tier, monthly, contact)
  values (trim(p_name), upper(coalesce(nullif(trim(p_state), ''), 'AZ')), coalesce(p_students, 0), coalesce(p_tier, 't1'), p_monthly, coalesce(trim(p_contact), ''))
  returning id into v_id;
  select current_month into m from settings;
  if p_monthly > 0 then
    insert into ledger (district_id, entry, amount)
    values (v_id, 'Monthly allocation, ' || month_label(m) || case when p_tier = 'sub' then ' (manual)' else '' end, p_monthly);
  end if;
  return v_id;
end $$;

create or replace function public.update_district(p_id uuid, p_name text, p_students int, p_contact text, p_monthly int, p_tier text)
returns void language plpgsql security definer set search_path = public as $$
declare d districts;
begin
  perform require_admin();
  select * into d from districts where id = p_id for update;
  if not found then raise exception 'District not found.'; end if;
  if p_monthly is null or p_monthly < 0 then raise exception 'Enter monthly points of 0 or more.'; end if;
  update districts set
    name = coalesce(nullif(trim(p_name), ''), name), students = coalesce(p_students, students),
    contact = coalesce(trim(p_contact), contact), monthly = p_monthly,
    next_tier = case when p_tier is null or p_tier = tier then null else p_tier end
  where id = p_id;
end $$;

create or replace function public.adjust_points(p_district uuid, p_amount int, p_reason text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform require_admin();
  if coalesce(p_amount, 0) = 0 then raise exception 'Enter a positive or negative number of points.'; end if;
  if coalesce(trim(p_reason), '') = '' then raise exception 'Add a reason. The district sees it in its points history.'; end if;
  insert into ledger (district_id, entry, amount) values (p_district, 'Adjustment: ' || left(trim(p_reason), 120), p_amount);
end $$;

-- returns the auth user ids that should be signed out (the app bans them)
create or replace function public.set_district_status(p_id uuid, p_status text) returns setof uuid
language plpgsql security definer set search_path = public as $$
declare r requests;
begin
  perform require_admin();
  if p_status not in ('Active','Inactive') then raise exception 'Unknown status.'; end if;
  update districts set status = p_status where id = p_id;
  if p_status = 'Inactive' then
    for r in select * from requests where district_id = p_id and status = 'Pending' for update loop
      update requests set status = 'Cancelled', reason = 'District deactivated', decided_at = now() where id = r.id;
      insert into ledger (district_id, entry, amount, ref) values (p_id, 'District deactivated, points released', r.qty * r.points_each, r.code);
    end loop;
    return query update profiles set status = 'Deactivated' where district_id = p_id and status <> 'Deactivated' returning id;
  end if;
end $$;

-- ================================================================ admin: users (the app creates the auth user, then calls this)
create or replace function public.admin_set_profile(p_user uuid, p_name text, p_email text, p_role text, p_district uuid, p_status text)
returns void language plpgsql security definer set search_path = public as $$
begin
  perform require_admin();
  if p_role not in ('admin','district') then raise exception 'Unknown role.'; end if;
  if p_role = 'district' and p_district is null then raise exception 'Choose their district.'; end if;
  insert into profiles (id, name, email, role, district_id, status)
  values (p_user, trim(p_name), lower(trim(p_email)), p_role, case when p_role = 'district' then p_district end, coalesce(p_status, 'Invited'))
  on conflict (id) do update set name = excluded.name, email = excluded.email, role = excluded.role,
    district_id = excluded.district_id, status = excluded.status,
    invited_at = case when excluded.status = 'Invited' then now() else profiles.invited_at end;
end $$;

create or replace function public.set_user_status(p_user uuid, p_status text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform require_admin();
  if p_user = auth.uid() and p_status = 'Deactivated' then raise exception 'You can''t deactivate yourself.'; end if;
  if p_status not in ('Active','Deactivated','Invited') then raise exception 'Unknown status.'; end if;
  update profiles set status = p_status where id = p_user;
end $$;

-- ================================================================ program: retail drops and the monthly cycle
create or replace function public.ensure_retail(p_month text) returns int
language plpgsql security definer set search_path = public as $$
declare cfg jsonb; v_day int; v_date date; v_id uuid; n int := 0; r text; den jsonb; i int;
begin
  if auth.uid() is not null then perform require_admin(); end if;      -- cron runs as service role (no uid)
  select retail into cfg from settings;
  if jsonb_array_length(coalesce(cfg->'retailers', '[]')) = 0 or jsonb_array_length(coalesce(cfg->'denoms', '[]')) = 0 then return 0; end if;
  for v_day in select (jsonb_array_elements_text(cfg->'days'))::int loop
    v_date := to_date(p_month || '-' || lpad(v_day::text, 2, '0'), 'YYYY-MM-DD');
    continue when v_date - 1 < az_today();                                   -- deadline already passed
    continue when exists (select 1 from events where series = 'retail' and date = v_date);
    insert into events (title, cat, partner, description, dated, date, venue, deadline, status, series)
    values ('Retail gift card drop', 'retail', 'Retail partners',
      'Gift cards students can pick from: ' || (select string_agg(x, ', ') from jsonb_array_elements_text(cfg->'retailers') x)
        || '. Each comes in ' || (select string_agg(y->>'label', ' or ') from jsonb_array_elements(cfg->'denoms') y)
        || '. Request by the day before; cards go out on the drop date.',
      true, v_date, 'Delivered digitally', v_date - 1, 'Published', 'retail')
    returning id into v_id;
    i := 0;
    for r in select jsonb_array_elements_text(cfg->'retailers') loop
      for den in select * from jsonb_array_elements(cfg->'denoms') loop
        i := i + 1;
        insert into ticket_types (event_id, name, qty, points, seats, sort)
        values (v_id, r || ' · ' || (den->>'label'), (den->>'qty')::int, (den->>'points')::int, 1, i);
      end loop;
    end loop;
    n := n + 1;
  end loop;
  return n;
end $$;

-- Starts the next month: expire (or roll over) unused points, apply tier changes, credit allocations, email districts.
create or replace function public.run_monthly_reset() returns text
language plpgsql security definer set search_path = public as $$
declare s settings; nk text; d districts; a int; bal int; h int;
begin
  if auth.uid() is not null then perform require_admin(); end if;
  select * into s from settings for update;
  nk := next_month(s.current_month);
  if nk > az_month() then raise exception '% hasn''t started yet. The reset runs on the 1st.', month_label(nk); end if;
  for d in select * from districts where status = 'Active' for update loop
    a := available(d.id);
    if not s.rollover and a > 0 then
      insert into ledger (district_id, entry, amount) values (d.id, 'Unused ' || month_label(s.current_month) || ' points expired', -a);
    end if;
    if d.next_tier is not null then update districts set tier = next_tier, next_tier = null where id = d.id; end if;
    insert into ledger (district_id, entry, amount)
    values (d.id, 'Monthly allocation, ' || month_label(nk) || case when coalesce(d.next_tier, d.tier) = 'sub' then ' (manual)' else '' end, d.monthly);
    bal := available(d.id); h := held(d.id);
    perform notify_district(d.id, 'Your ClassTix points for ' || month_label(nk),
      'Hi ' || d.name || E',\n\nYour ' || month_label(nk) || ' points are in: ' || fmt_pts(bal) || ' available.'
      || case when h > 0 then E'\n' || fmt_pts(h) || ' are still on hold for pending requests.' else '' end
      || E'\n\nBrowse the event calendar to request tickets: ' || s.portal_url || E'\n\nThe ClassTix team', 'reset');
  end loop;
  update settings set current_month = nk, last_reset_at = now();
  perform ensure_retail(nk);
  perform ensure_retail(next_month(nk));
  return nk;
end $$;

-- Daily job: catch up any missed months, keep two months of retail drops on the calendar.
create or replace function public.cron_tick() returns jsonb
language plpgsql security definer set search_path = public as $$
declare started text[] := '{}'; drops int := 0;
begin
  while (select current_month from settings) < az_month() loop
    started := started || run_monthly_reset();
  end loop;
  drops := ensure_retail(az_month()) + ensure_retail(next_month(az_month()));
  return jsonb_build_object('months_started', to_jsonb(started), 'retail_drops_added', drops);
end $$;

create or replace function public.update_settings(p_rollover boolean, p_retail jsonb) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform require_admin();
  update settings set rollover = coalesce(p_rollover, rollover), retail = coalesce(p_retail, retail);
end $$;

-- ---------------------------------------------------------------- who may call what
revoke execute on all functions in schema public from public, anon;
grant execute on function public.touch_login(), public.submit_request(uuid, int, text), public.cancel_request(uuid),
  public.approve_request(uuid, int), public.reject_request(uuid, text), public.fulfil_request(uuid),
  public.set_internal_note(uuid, text), public.save_event(jsonb), public.set_event_status(uuid, text), public.cancel_event(uuid),
  public.create_district(text, text, int, text, int, text), public.update_district(uuid, text, int, text, int, text),
  public.adjust_points(uuid, int, text), public.set_district_status(uuid, text),
  public.admin_set_profile(uuid, text, text, text, uuid, text), public.set_user_status(uuid, text),
  public.ensure_retail(text), public.run_monthly_reset(), public.update_settings(boolean, jsonb),
  public.available(uuid), public.held(uuid), public.is_admin(), public.my_district(),
  public.az_today(), public.az_month(), public.month_label(text), public.next_month(text)
  to authenticated;
grant execute on all functions in schema public to service_role;
