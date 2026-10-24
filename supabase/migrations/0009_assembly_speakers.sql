-- ClassTix — Assembly Giveaway: districts request a speaker (ASU Athletics, Suns, Cardinals, Diamondbacks…)
-- for a school assembly on a day and time; ClassTix confirms or declines. Speaker visits don't use points.
-- Run once in the Supabase SQL editor.

create table if not exists public.speakers (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (length(trim(name)) > 0),
  org         text not null default '',
  description text not null default '',
  active      boolean not null default true,
  sort        int not null default 0,
  created_at  timestamptz not null default now()
);

create table if not exists public.assembly_requests (
  id           uuid primary key default gen_random_uuid(),
  code         text not null unique,
  district_id  uuid not null references public.districts (id),
  speaker_id   uuid not null references public.speakers (id),
  school       text not null,
  date         date not null,
  start_time   time not null,
  audience     int not null default 0 check (audience >= 0),
  grades       text not null default '',
  note         text not null default '',
  status       text not null default 'Requested' check (status in ('Requested', 'Confirmed', 'Declined', 'Cancelled')),
  admin_note   text not null default '',
  created_by   uuid references auth.users (id),
  created_at   timestamptz not null default now(),
  decided_at   timestamptz
);
create index if not exists assembly_requests_district on public.assembly_requests (district_id, date);
create index if not exists assembly_requests_date on public.assembly_requests (date, status);

alter table public.speakers enable row level security;
alter table public.assembly_requests enable row level security;
drop policy if exists speakers_read on public.speakers;
create policy speakers_read on public.speakers for select to authenticated using (true);
drop policy if exists assembly_read on public.assembly_requests;
create policy assembly_read on public.assembly_requests for select to authenticated using (is_admin() or district_id = my_district());
revoke insert, update, delete on public.speakers, public.assembly_requests from anon, authenticated;
revoke all on public.speakers, public.assembly_requests from anon;
grant select on public.speakers, public.assembly_requests to authenticated;
grant all on public.speakers, public.assembly_requests to service_role;

insert into public.speakers (name, org, description, sort)
select v.* from (values
  ('ASU Athletics', 'Arizona State University', 'A Sun Devil student-athlete or coach talks about effort, academics and showing up every day.', 1),
  ('Phoenix Suns', 'Phoenix Suns', 'A Suns community team member, alumni player or mascot appearance.', 2),
  ('Arizona Cardinals', 'Arizona Cardinals', 'A Cardinals community team member, alumni player or mascot appearance.', 3),
  ('Arizona Diamondbacks', 'Arizona Diamondbacks', 'A D-backs community team member, alumni player or mascot appearance.', 4)
) as v(name, org, description, sort)
where not exists (select 1 from public.speakers s where s.name = v.name);

create or replace function public.fmt_assembly(r public.assembly_requests) returns text
language sql stable set search_path = public as $$
  select to_char(r.date, 'Dy, Mon FMDD, YYYY') || ' at ' || to_char(r.start_time, 'FMHH12:MI AM')
$$;

create or replace function public.request_assembly(p_speaker uuid, p_school text, p_date date, p_time time,
  p_audience int, p_grades text, p_note text) returns text
language plpgsql security definer set search_path = public as $$
declare v_did uuid := my_district(); d districts; sp speakers; v_code text; r assembly_requests;
begin
  if v_did is null then raise exception 'Your account isn''t linked to an active district.'; end if;
  select * into d from districts where id = v_did;
  select * into sp from speakers where id = p_speaker and active;
  if not found then raise exception 'Choose a speaker.'; end if;
  if cardinality(d.schools) > 0 and not (trim(coalesce(p_school, '')) = any(d.schools)) then
    raise exception 'Choose one of your district''s schools.'; end if;
  if coalesce(trim(p_school), '') = '' then raise exception 'Choose a school.'; end if;
  if p_date is null or p_time is null then raise exception 'Choose a day and a start time.'; end if;
  if p_date < az_today() + 14 then raise exception 'Request at least two weeks ahead, so ClassTix can book the speaker.'; end if;
  if extract(isodow from p_date) > 5 then raise exception 'Assemblies are on school days (Monday to Friday).'; end if;
  if p_time < time '07:00' or p_time > time '17:00' then raise exception 'Pick a start time between 7:00 AM and 5:00 PM.'; end if;
  if exists (select 1 from assembly_requests where district_id = v_did and school = trim(p_school) and date = p_date
             and status in ('Requested', 'Confirmed')) then
    raise exception 'That school already has an assembly request on this day.'; end if;

  v_code := 'A-' || upper(substr(md5(gen_random_uuid()::text), 1, 6));
  insert into assembly_requests (code, district_id, speaker_id, school, date, start_time, audience, grades, note, created_by)
  values (v_code, v_did, sp.id, trim(p_school), p_date, p_time, greatest(coalesce(p_audience, 0), 0),
          left(trim(coalesce(p_grades, '')), 60), left(trim(coalesce(p_note, '')), 500), auth.uid())
  returning * into r;
  perform notify_admins('Assembly request ' || v_code || ': ' || sp.name || ' at ' || r.school,
    d.name || ' asked for ' || sp.name || ' at ' || r.school || ' on ' || fmt_assembly(r) || '.' || E'\n'
    || 'Expected students: ' || r.audience || coalesce(nullif(' (' || r.grades || ')', ' ()'), '') || E'\n'
    || 'Note: ' || coalesce(nullif(r.note, ''), '—') || E'\n\nConfirm or decline it under Assemblies in the admin.', 'assembly');
  return v_code;
end $$;

create or replace function public.cancel_assembly(p_id uuid) returns void
language plpgsql security definer set search_path = public as $$
declare r assembly_requests; d districts;
begin
  select * into r from assembly_requests where id = p_id for update;
  if not found or (r.district_id <> coalesce(my_district(), '00000000-0000-0000-0000-000000000000'::uuid) and not is_admin()) then
    raise exception 'Request not found.'; end if;
  if r.status not in ('Requested', 'Confirmed') then raise exception 'This request is already closed.'; end if;
  update assembly_requests set status = 'Cancelled', decided_at = now() where id = p_id;
  select * into d from districts where id = r.district_id;
  perform notify_admins('Assembly cancelled: ' || r.code, d.name || ' cancelled ' || r.code || ' (' || r.school || ', ' || fmt_assembly(r) || ').', 'assembly');
end $$;

create or replace function public.decide_assembly(p_id uuid, p_status text, p_note text) returns void
language plpgsql security definer set search_path = public as $$
declare r assembly_requests; sp speakers;
begin
  perform require_admin();
  if p_status not in ('Confirmed', 'Declined') then raise exception 'Choose confirm or decline.'; end if;
  select * into r from assembly_requests where id = p_id for update;
  if not found then raise exception 'Request not found.'; end if;
  if r.status not in ('Requested', 'Confirmed') then raise exception 'This request is already closed.'; end if;
  if p_status = 'Declined' and coalesce(trim(p_note), '') = '' then raise exception 'Add a reason the district will see.'; end if;
  update assembly_requests set status = p_status, admin_note = left(coalesce(trim(p_note), ''), 500), decided_at = now() where id = p_id;
  select * into sp from speakers where id = r.speaker_id;
  if p_status = 'Confirmed' then
    perform notify_district(r.district_id, 'Assembly confirmed: ' || sp.name || ' at ' || r.school,
      sp.name || ' is confirmed for ' || r.school || ' on ' || fmt_assembly(r) || '.'
      || coalesce(nullif(E'\n\n' || trim(coalesce(p_note, '')), E'\n\n'), '') || E'\n\nThe ClassTix team', 'assembly');
  else
    perform notify_district(r.district_id, 'Assembly request update: ' || sp.name || ' at ' || r.school,
      'We couldn''t book ' || sp.name || ' for ' || r.school || ' on ' || fmt_assembly(r) || '.' || E'\nReason: ' || trim(p_note)
      || E'\n\nYou can request another day or speaker in the portal.\n\nThe ClassTix team', 'assembly');
  end if;
end $$;

create or replace function public.save_speaker(p_id uuid, p_name text, p_org text, p_description text, p_active boolean) returns uuid
language plpgsql security definer set search_path = public as $$
declare v_id uuid;
begin
  perform require_admin();
  if coalesce(trim(p_name), '') = '' then raise exception 'Add the speaker''s name.'; end if;
  if p_id is null then
    insert into speakers (name, org, description, active, sort)
    values (trim(p_name), coalesce(trim(p_org), ''), coalesce(trim(p_description), ''), coalesce(p_active, true),
            coalesce((select max(sort) + 1 from speakers), 1))
    returning id into v_id;
  else
    update speakers set name = trim(p_name), org = coalesce(trim(p_org), org), description = coalesce(trim(p_description), description),
      active = coalesce(p_active, active) where id = p_id returning id into v_id;
    if v_id is null then raise exception 'Speaker not found.'; end if;
  end if;
  return v_id;
end $$;

grant execute on function public.request_assembly(uuid, text, date, time, int, text, text), public.cancel_assembly(uuid),
  public.decide_assembly(uuid, text, text), public.save_speaker(uuid, text, text, text, boolean),
  public.fmt_assembly(public.assembly_requests) to authenticated;
