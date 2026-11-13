-- ClassTix — Families · Access ASU.
-- Free programs Access ASU donates for award winners' families (Family Hub, Family Fusion newsletter,
-- College Prep, Get to College, WeGrad Digital, and 20 summer camp spots). Districts request them like
-- any reward (school + merit type), they cost no points, and ClassTix sends the sign-up link in My Tickets.
-- Also: listings can be limited to certain districts (empty = everyone), ticket types can be free (0 points),
-- and a sponsor account can cover more than one partner ("ASU Athletics, Access ASU").
-- Run once in the Supabase SQL editor.

-- new category
do $$ declare c record; begin
  for c in select conname from pg_constraint where conrelid = 'public.events'::regclass and contype = 'c'
           and pg_get_constraintdef(oid) ~ 'cat' loop
    execute format('alter table public.events drop constraint %I', c.conname);
  end loop;
end $$;
alter table public.events add constraint events_cat_check check (cat in ('sports','arts','music','dining','retail','families','other'));

-- listings for some districts only (empty = every district)
alter table public.events add column if not exists districts uuid[] not null default '{}';

-- free ticket types
alter table public.ticket_types drop constraint if exists ticket_types_points_check;
alter table public.ticket_types add constraint ticket_types_points_check check (points >= 0);

-- does this listing's partner belong to the signed-in sponsor? (partner can be a comma-separated list)
create or replace function public.is_my_partner(p text) returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce(lower(trim(p)) = any(select lower(trim(x)) from unnest(string_to_array(my_partner(), ',')) x), false)
$$;

drop policy if exists events_read on public.events;
create policy events_read on public.events for select to authenticated using (
  is_admin()
  or (is_sponsor() and status = 'Published')
  or (my_district() is not null and (
      (status = 'Published' and (cardinality(districts) = 0 or my_district() = any(districts)))
      or id in (select event_id from requests where district_id = my_district()))));

-- impact covers every partner on the sponsor's account
create or replace function public.sponsor_impact()
returns table (event_id uuid, title text, date date, dated boolean, venue text, status text, seats int,
               requests int, requested int, approved int, fulfilled int,
               districts text[], schools int, merits jsonb)
language sql stable security definer set search_path = public as $$
  with mine as (
    select e.* from events e
    where my_partner() is not null and is_my_partner(e.partner)
  ), rq as (
    select r.*, d.name as district from requests r join mine m on m.id = r.event_id join districts d on d.id = r.district_id
    where r.status in ('Pending', 'Approved', 'Fulfilled')
  )
  select m.id, m.title, m.date, m.dated, m.venue, m.status,
         coalesce((select max(t.seats) from ticket_types t where t.event_id = m.id), 1),
         count(rq.id)::int,
         coalesce(sum(rq.qty), 0)::int,
         coalesce(sum(case when rq.status in ('Approved', 'Fulfilled') then rq.approved_qty end), 0)::int,
         coalesce(sum(case when rq.status = 'Fulfilled' then rq.approved_qty end), 0)::int,
         coalesce(array_agg(distinct rq.district) filter (where rq.district is not null), '{}'),
         count(distinct rq.school) filter (where rq.school <> '')::int,
         coalesce((select jsonb_object_agg(x.merit, x.n) from (
            select r2.merit, sum(r2.approved_qty)::int n from rq r2
            where r2.event_id = m.id and r2.merit <> '' and r2.status in ('Approved', 'Fulfilled') group by r2.merit) x), '{}'::jsonb)
  from mine m left join rq on rq.event_id = m.id
  where m.status in ('Published', 'Archived', 'Cancelled')
  group by m.id, m.title, m.date, m.dated, m.venue, m.status
  order by m.dated desc, m.date nulls last, m.title
$$;

-- admins can set 0 points (free)
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
    if (ty->>'points') is null or (ty->>'points')::int < 0 then raise exception 'Set the points for % (0 makes it free).', ty->>'name'; end if;
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


create or replace function public.submit_request(p_type uuid, p_qty int, p_school text, p_merit text) returns text
language plpgsql security definer set search_path = public as $$
declare
  v_did uuid := my_district();
  t ticket_types; e events; d districts; al district_allowances;
  v_cost int; v_avail int; v_code text; v_id uuid; v_left int; v_each int; v_donated boolean := false; v_used int;
  v_school text := trim(coalesce(p_school, '')); v_merit text := trim(coalesce(p_merit, ''));
begin
  if v_did is null then raise exception 'Your account isn''t linked to an active district.'; end if;
  select * into d from districts where id = v_did for update;            -- serialises spending per district
  select * into t from ticket_types where id = p_type for update;
  if not found then raise exception 'That ticket type no longer exists.'; end if;
  select * into e from events where id = t.event_id;
  if e.status <> 'Published' then raise exception 'This listing isn''t open for requests.'; end if;
  if e.dated and e.deadline is not null and e.deadline < az_today() then raise exception 'The request deadline has passed.'; end if;
  if cardinality(e.districts) > 0 and not (v_did = any(e.districts)) then raise exception 'This listing isn''t open to your district.'; end if;

  -- districts with donated allowances can only use those (free listings stay open)
  if t.points > 0 and exists (select 1 from district_allowances where district_id = v_did) then
    select * into al from district_allowances where district_id = v_did and lower(partner) = lower(e.partner);
    if not found then
      raise exception 'Right now your district can request % only.',
        (select string_agg(partner, ', ' order by partner) from district_allowances where district_id = v_did);
    end if;
    v_donated := true;
  end if;

  v_left := t.qty - t.approved;
  if p_qty is null or p_qty < 1 then raise exception 'Choose how many you need.'; end if;
  if p_qty > v_left then raise exception 'Only % left for %.', v_left, t.name; end if;
  if not v_donated and e.cat not in ('retail', 'families') and p_qty % 2 <> 0 and p_qty <> v_left then raise exception 'Choose an amount in multiples of 2.'; end if;
  if e.max_per_request is not null and p_qty > e.max_per_request then
    raise exception 'The most you can request for this listing is %.', e.max_per_request; end if;
  if cardinality(d.schools) > 0 then
    if not (v_school = any(d.schools)) then raise exception 'Choose one of your district''s schools.'; end if;
  elsif v_school <> 'District-wide' then raise exception 'Choose a school.'; end if;
  if not (v_merit = any(merit_types())) then raise exception 'Choose a merit type.'; end if;

  if v_donated then
    v_used := allowance_used(v_did, al.partner);
    if v_used + p_qty * t.seats > al.tickets then
      raise exception 'Your district has % donated % tickets left.', greatest(al.tickets - v_used, 0), al.partner;
    end if;
    v_each := 0; v_cost := 0;
  else
    v_each := t.points; v_cost := p_qty * t.points;
    v_avail := available(v_did);
    if v_cost > v_avail then raise exception 'This costs % and you have % available.', fmt_pts(v_cost), fmt_pts(v_avail); end if;
  end if;

  v_code := 'R-' || upper(substr(md5(gen_random_uuid()::text), 1, 6));
  insert into requests (code, district_id, event_id, type_id, qty, points_each, note, school, merit, created_by)
  values (v_code, v_did, e.id, t.id, p_qty, v_each, v_school || ' · ' || v_merit, v_school, v_merit, auth.uid())
  returning id into v_id;
  if v_cost > 0 then
    insert into ledger (district_id, entry, amount, ref) values (v_did, 'Held for request', -v_cost, v_code);
  end if;
  perform notify_admins(
    'New request ' || v_code || ' from ' || d.name,
    d.name || ' requested ' || p_qty || ' × ' || t.name || ' for ' || e.title || ' (' || event_when(e) || ').' || E'\n'
      || case when v_donated then 'Donated tickets (' || al.partner || '): ' || (v_used + p_qty * t.seats) || ' of ' || al.tickets || ' now used.'
              when v_cost = 0 then 'Free (' || coalesce(nullif(e.partner, ''), 'no points') || ')' else 'Points: ' || fmt_pts(v_cost) end
      || E'\nMerit awarded for: ' || v_merit || ', ' || v_school
      || E'\n\nReview it in the request queue.', 'new');
  return v_code;
end $$;


grant execute on function public.is_my_partner(text) to authenticated;

-- Osborn: Families · Access ASU listings
do $$
declare v_osborn uuid; r record; v_id uuid;
begin
  select id into v_osborn from districts where name = 'Osborn School District';
  if v_osborn is null then return; end if;
  for r in select * from (values
    ('families-camp', 'Access ASU Summer Camp', 'Camp spot (1 student)', 20, 20,
     'A free Access ASU summer camp at ASU in July, open to students in all grades. Request one spot per student you''re recognizing. ClassTix sends the sign-up link once your request is approved. 20 spots donated by Access ASU.'),
    ('families-hub', 'ASU Family Hub', 'Family access', 500, 50,
     'ASU''s online hub for families: events, campus news and ways for parents to get involved. Request one per family; ClassTix sends the sign-up link once approved.'),
    ('families-fusion', 'Family Fusion Newsletter', 'Family subscription', 500, 50,
     'Access ASU''s newsletter and blog for families, with college-going tips, events and opportunities. Request one per family; ClassTix sends the sign-up link once approved.'),
    ('families-prep', 'College Prep', 'Family access', 500, 50,
     'Access ASU college-prep programs and resources that help students plan for high school, college and careers. Request one per family; ClassTix sends the sign-up link once approved.'),
    ('families-getcollege', 'Get to College', 'Family access', 500, 50,
     'Step-by-step help from Access ASU on applying to college, admission, financial aid and scholarships. Request one per family; ClassTix sends the sign-up link once approved.'),
    ('families-wegrad', 'WeGrad Digital', 'Parent enrollment', 500, 50,
     'Supporting your student for college readiness: Access ASU''s free online program for parents and families of middle and high school students. Request one per family; ClassTix sends the sign-up link once approved.')
  ) v(series, title, tname, qty, maxq, descr) loop
    if exists (select 1 from events where series = r.series) then continue; end if;
    insert into events (title, cat, partner, description, dated, status, series, max_per_request, districts)
    values (r.title, 'families', 'Access ASU', r.descr, false, 'Published', r.series, r.maxq, array[v_osborn])
    returning id into v_id;
    insert into ticket_types (event_id, name, qty, points, seats) values (v_id, r.tname, r.qty, 0, 1);
  end loop;
end $$;
