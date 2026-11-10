-- ClassTix — Sponsor accounts (e.g. Access ASU for ASU Athletics).
-- A sponsor can browse the published catalog read-only and see the impact of their own donated rewards
-- (requests, approvals, districts and schools reached, merit types). They can't request, spend points,
-- or see balances, users, emails or other sponsors' numbers.
-- Run once in the Supabase SQL editor.

alter table public.profiles add column if not exists partner text not null default '';

-- allow the new role (replaces the two role checks on profiles)
do $$ declare c record; begin
  for c in select conname from pg_constraint where conrelid = 'public.profiles'::regclass and contype = 'c'
           and pg_get_constraintdef(oid) ~ 'role' loop
    execute format('alter table public.profiles drop constraint %I', c.conname);
  end loop;
end $$;
alter table public.profiles add constraint profiles_role_check check (role in ('admin', 'district', 'sponsor'));
alter table public.profiles add constraint profiles_role_district_check check (role <> 'district' or district_id is not null);
alter table public.profiles add constraint profiles_sponsor_partner_check check (role <> 'sponsor' or length(trim(partner)) > 0);

create or replace function public.my_partner() returns text
language sql stable security definer set search_path = public as $$
  select partner from profiles where id = auth.uid() and role = 'sponsor' and status = 'Active'
$$;

create or replace function public.is_sponsor() returns boolean
language sql stable security definer set search_path = public as $$
  select my_partner() is not null
$$;

-- sponsors can read the published catalog (ticket types follow events)
drop policy if exists events_read on public.events;
create policy events_read on public.events for select to authenticated using (
  is_admin()
  or (is_sponsor() and status = 'Published')
  or (my_district() is not null and (status = 'Published'
      or id in (select event_id from requests where district_id = my_district()))));

-- one row per listing the sponsor provides; no student data exists in the portal, only district and school names
drop function if exists public.sponsor_impact();
create or replace function public.sponsor_impact()
returns table (event_id uuid, title text, date date, dated boolean, venue text, status text, seats int,
               requests int, requested int, approved int, fulfilled int,
               districts text[], schools int, merits jsonb)
language sql stable security definer set search_path = public as $$
  with mine as (
    select e.* from events e
    where my_partner() is not null and lower(e.partner) = lower(my_partner())
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

-- admin: create or update a profile including sponsor partner (new 7-argument version)
create or replace function public.admin_set_profile(p_user uuid, p_name text, p_email text, p_role text, p_district uuid, p_status text, p_partner text)
returns void language plpgsql security definer set search_path = public as $$
begin
  perform require_admin();
  if p_role not in ('admin', 'district', 'sponsor') then raise exception 'Unknown role.'; end if;
  if p_role = 'district' and p_district is null then raise exception 'Choose their district.'; end if;
  if p_role = 'sponsor' and coalesce(trim(p_partner), '') = '' then raise exception 'Choose which partner they sponsor.'; end if;
  insert into profiles (id, name, email, role, district_id, status, partner)
  values (p_user, trim(p_name), lower(trim(p_email)), p_role, case when p_role = 'district' then p_district end,
          coalesce(p_status, 'Invited'), case when p_role = 'sponsor' then trim(p_partner) else '' end)
  on conflict (id) do update set name = excluded.name, email = excluded.email, role = excluded.role,
    district_id = excluded.district_id, status = excluded.status, partner = excluded.partner,
    invited_at = case when excluded.status = 'Invited' then now() else profiles.invited_at end;
end $$;

grant execute on function public.my_partner(), public.is_sponsor(), public.sponsor_impact(),
  public.admin_set_profile(uuid, text, text, text, uuid, text, text) to authenticated;
