-- ClassTix — Restaurant & Retail requests can be any whole number of cards (1, 2, 3…).
-- Tickets for events still come in multiples of 2. Run once in the Supabase SQL editor.

create or replace function public.submit_request(p_type uuid, p_qty int, p_school text, p_merit text) returns text
language plpgsql security definer set search_path = public as $$
declare
  v_did uuid := my_district();
  t ticket_types; e events; d districts;
  v_cost int; v_avail int; v_code text; v_id uuid; v_left int;
  v_school text := trim(coalesce(p_school, '')); v_merit text := trim(coalesce(p_merit, ''));
begin
  if v_did is null then raise exception 'Your account isn''t linked to an active district.'; end if;
  select * into d from districts where id = v_did for update;            -- serialises spending per district
  select * into t from ticket_types where id = p_type for update;
  if not found then raise exception 'That ticket type no longer exists.'; end if;
  select * into e from events where id = t.event_id;
  if e.status <> 'Published' then raise exception 'This listing isn''t open for requests.'; end if;
  if e.dated and e.deadline is not null and e.deadline < az_today() then raise exception 'The request deadline has passed.'; end if;
  v_left := t.qty - t.approved;
  if p_qty is null or p_qty < 1 then raise exception 'Choose how many you need.'; end if;
  if p_qty > v_left then raise exception 'Only % left for %.', v_left, t.name; end if;
  if e.cat <> 'retail' and p_qty % 2 <> 0 and p_qty <> v_left then raise exception 'Choose an amount in multiples of 2.'; end if;
  if e.max_per_request is not null and p_qty > e.max_per_request then
    raise exception 'The most you can request for this listing is %.', e.max_per_request; end if;
  if cardinality(d.schools) > 0 then
    if not (v_school = any(d.schools)) then raise exception 'Choose one of your district''s schools.'; end if;
  elsif v_school <> 'District-wide' then raise exception 'Choose a school.'; end if;
  if not (v_merit = any(merit_types())) then raise exception 'Choose a merit type.'; end if;

  v_cost := p_qty * t.points;
  v_avail := available(v_did);
  if v_cost > v_avail then raise exception 'This costs % and you have % available.', fmt_pts(v_cost), fmt_pts(v_avail); end if;

  v_code := 'R-' || upper(substr(md5(gen_random_uuid()::text), 1, 6));
  insert into requests (code, district_id, event_id, type_id, qty, points_each, note, school, merit, created_by)
  values (v_code, v_did, e.id, t.id, p_qty, t.points, v_school || ' · ' || v_merit, v_school, v_merit, auth.uid())
  returning id into v_id;
  insert into ledger (district_id, entry, amount, ref) values (v_did, 'Held for request', -v_cost, v_code);
  perform notify_admins(
    'New request ' || v_code || ' from ' || d.name,
    d.name || ' requested ' || p_qty || ' × ' || t.name || ' for ' || e.title || ' (' || event_when(e) || ').' || E'\n'
      || 'Points: ' || fmt_pts(v_cost) || E'\nMerit awarded for: ' || v_merit || ', ' || v_school
      || E'\n\nReview it in the request queue.', 'new');
  return v_code;
end $$;
