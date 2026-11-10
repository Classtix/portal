-- ClassTix — donated ticket allowances.
-- A sponsor can donate a set number of tickets to a district (e.g. Access ASU: 10 ASU Athletics tickets to Osborn).
-- While a district has any allowance, it can only request listings from those partners; requests cost no points
-- and stop once the donated tickets are used (pending + approved + sent all count). Other districts are unchanged.
-- Run once in the Supabase SQL editor.

create table if not exists public.district_allowances (
  id          uuid primary key default gen_random_uuid(),
  district_id uuid not null references public.districts (id) on delete cascade,
  partner     text not null check (length(trim(partner)) > 0),
  tickets     int  not null check (tickets >= 0),
  note        text not null default '',
  created_at  timestamptz not null default now(),
  unique (district_id, partner)
);
alter table public.district_allowances enable row level security;
drop policy if exists allowances_read on public.district_allowances;
create policy allowances_read on public.district_allowances for select to authenticated using (is_admin() or district_id = my_district());
revoke insert, update, delete on public.district_allowances from anon, authenticated;
revoke all on public.district_allowances from anon;
grant select on public.district_allowances to authenticated;
grant all on public.district_allowances to service_role;

-- donated requests cost nothing
alter table public.requests drop constraint if exists requests_points_each_check;
alter table public.requests add constraint requests_points_each_check check (points_each >= 0);

-- tickets used against an allowance: pending requests count what was asked, approved/sent count what was approved
create or replace function public.allowance_used(p_district uuid, p_partner text) returns int
language sql stable security definer set search_path = public as $$
  select coalesce(sum(case when r.status = 'Pending' then r.qty else r.approved_qty end * t.seats), 0)::int
  from requests r join ticket_types t on t.id = r.type_id join events e on e.id = r.event_id
  where r.district_id = p_district and lower(e.partner) = lower(p_partner)
    and r.status in ('Pending', 'Approved', 'Fulfilled') and r.points_each = 0
$$;

-- for the signed-in district (or any district, for admins)
create or replace function public.district_allowance_status(p_district uuid default null)
returns table (partner text, tickets int, used int, remaining int, note text)
language sql stable security definer set search_path = public as $$
  select a.partner, a.tickets, allowance_used(a.district_id, a.partner),
         greatest(a.tickets - allowance_used(a.district_id, a.partner), 0), a.note
  from district_allowances a
  where a.district_id = case when is_admin() then coalesce(p_district, my_district()) else my_district() end
  order by a.partner
$$;

create or replace function public.set_allowance(p_district uuid, p_partner text, p_tickets int, p_note text) returns void
language plpgsql security definer set search_path = public as $$
begin
  perform require_admin();
  if coalesce(trim(p_partner), '') = '' then raise exception 'Choose the partner.'; end if;
  if p_tickets is null then
    delete from district_allowances where district_id = p_district and lower(partner) = lower(trim(p_partner));
    return;
  end if;
  if p_tickets < 0 then raise exception 'Tickets can''t be negative.'; end if;
  insert into district_allowances (district_id, partner, tickets, note)
  values (p_district, trim(p_partner), p_tickets, coalesce(trim(p_note), ''))
  on conflict (district_id, partner) do update set tickets = excluded.tickets, note = excluded.note;
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

  -- districts with donated allowances can only use those
  if exists (select 1 from district_allowances where district_id = v_did) then
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
  if not v_donated and e.cat <> 'retail' and p_qty % 2 <> 0 and p_qty <> v_left then raise exception 'Choose an amount in multiples of 2.'; end if;
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
              else 'Points: ' || fmt_pts(v_cost) end
      || E'\nMerit awarded for: ' || v_merit || ', ' || v_school
      || E'\n\nReview it in the request queue.', 'new');
  return v_code;
end $$;

grant execute on function public.allowance_used(uuid, text), public.district_allowance_status(uuid),
  public.set_allowance(uuid, text, int, text) to authenticated;

-- Osborn: 10 donated ASU Athletics tickets from Access ASU (5 pairs)
insert into district_allowances (district_id, partner, tickets, note)
select id, 'ASU Athletics', 10, 'Donated by Access ASU' from districts where name = 'Osborn School District'
on conflict (district_id, partner) do nothing;
