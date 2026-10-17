-- ClassTix District Rewards Portal — database schema
-- Run once in the Supabase SQL editor (or `supabase db push`).
-- All business rules live in SECURITY DEFINER functions so every change is atomic
-- and districts can only ever see and touch their own data (row-level security).

create extension if not exists pgcrypto;

-- ---------------------------------------------------------------- helpers
create or replace function public.az_today() returns date
language sql stable as $$ select (now() at time zone 'America/Phoenix')::date $$;

create or replace function public.az_month() returns text
language sql stable as $$ select to_char(now() at time zone 'America/Phoenix', 'YYYY-MM') $$;

create or replace function public.month_label(m text) returns text
language sql immutable as $$ select trim(to_char(to_date(m || '-01', 'YYYY-MM-DD'), 'FMMonth YYYY')) $$;

create or replace function public.next_month(m text) returns text
language sql immutable as $$ select to_char(to_date(m || '-01', 'YYYY-MM-DD') + interval '1 month', 'YYYY-MM') $$;

create or replace function public.fmt_pts(n int) returns text
language sql immutable as $$ select to_char(n, 'FM999,999,990') || ' pts' $$;

-- ---------------------------------------------------------------- tables
create table public.settings (
  id            int primary key default 1 check (id = 1),
  current_month text not null default to_char(now() at time zone 'America/Phoenix', 'YYYY-MM'),
  rollover      boolean not null default false,
  last_reset_at timestamptz,
  retail        jsonb not null default '{"days":[1,15],"retailers":[],"denoms":[]}'::jsonb,
  portal_url    text not null default 'https://portal.classtix.org'
);
insert into public.settings (id) values (1) on conflict do nothing;

create table public.districts (
  id         uuid primary key default gen_random_uuid(),
  name       text not null check (length(trim(name)) > 0),
  state      text not null default 'AZ',
  students   int  not null default 0 check (students >= 0),
  tier       text not null default 't1' check (tier in ('t1','t2','sub')),
  next_tier  text check (next_tier in ('t1','t2','sub')),
  monthly    int  not null default 0 check (monthly >= 0),
  contact    text not null default '',
  status     text not null default 'Active' check (status in ('Active','Inactive')),
  created_at timestamptz not null default now()
);

create table public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  name        text not null default '',
  email       text not null,
  role        text not null check (role in ('admin','district')),
  district_id uuid references public.districts (id),
  status      text not null default 'Invited' check (status in ('Invited','Active','Deactivated')),
  invited_at  timestamptz not null default now(),
  last_login  timestamptz,
  check (role = 'admin' or district_id is not null)
);
create index on public.profiles (district_id);

create table public.events (
  id          uuid primary key default gen_random_uuid(),
  title       text not null check (length(trim(title)) > 0),
  cat         text not null default 'other' check (cat in ('sports','arts','music','dining','retail','other')),
  partner     text not null default '',
  description text not null default '',
  dated       boolean not null default true,
  date        date,
  time        text not null default '',
  venue       text not null default '',
  deadline    date,
  max_per_request int check (max_per_request is null or max_per_request > 0),
  status      text not null default 'Published' check (status in ('Published','Draft','Cancelled','Archived')),
  series      text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now(),
  check (not dated or date is not null),
  check (deadline is null or date is null or deadline <= date)
);
create unique index events_series_date on public.events (series, date) where series is not null;
create index on public.events (status, date);

create table public.ticket_types (
  id       uuid primary key default gen_random_uuid(),
  event_id uuid not null references public.events (id) on delete cascade,
  name     text not null check (length(trim(name)) > 0),
  qty      int  not null check (qty > 0),
  points   int  not null check (points > 0),
  seats    int  not null default 1 check (seats > 0),
  approved int  not null default 0 check (approved >= 0),
  sort     int  not null default 0,
  check (approved <= qty)
);
create index on public.ticket_types (event_id);

create table public.requests (
  id           uuid primary key default gen_random_uuid(),
  code         text not null unique,
  district_id  uuid not null references public.districts (id),
  event_id     uuid not null references public.events (id),
  type_id      uuid not null references public.ticket_types (id),
  qty          int  not null check (qty > 0),
  points_each  int  not null check (points_each > 0),
  approved_qty int  not null default 0 check (approved_qty >= 0 and approved_qty <= qty),
  status       text not null default 'Pending' check (status in ('Pending','Approved','Rejected','Fulfilled','Cancelled')),
  note         text not null default '',
  reason       text not null default '',
  created_by   uuid references auth.users (id),
  created_at   timestamptz not null default now(),
  decided_at   timestamptz,
  fulfilled_at timestamptz
);
create index on public.requests (district_id, status);
create index on public.requests (event_id, status);

-- internal notes live apart so district users can never read them
create table public.request_notes (
  request_id uuid primary key references public.requests (id) on delete cascade,
  note       text not null default '',
  updated_at timestamptz not null default now()
);

create table public.ledger (
  id          bigserial primary key,
  district_id uuid not null references public.districts (id),
  at          timestamptz not null default now(),
  entry       text not null,
  amount      int  not null,
  ref         text not null default ''
);
create index on public.ledger (district_id, at);

create table public.outbox (
  id       bigserial primary key,
  at       timestamptz not null default now(),
  to_email text not null,
  to_name  text not null default '',
  subject  text not null,
  body     text not null,
  kind     text not null default '',
  sent_at  timestamptz,
  attempts int not null default 0,
  error    text
);
create index outbox_unsent on public.outbox (id) where sent_at is null;

-- ---------------------------------------------------------------- identity helpers
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select exists (select 1 from profiles where id = auth.uid() and role = 'admin' and status = 'Active')
$$;

create or replace function public.my_district() returns uuid
language sql stable security definer set search_path = public as $$
  select p.district_id from profiles p join districts d on d.id = p.district_id
  where p.id = auth.uid() and p.role = 'district' and p.status = 'Active' and d.status = 'Active'
$$;

create or replace function public.require_admin() returns void
language plpgsql stable security definer set search_path = public as $$
begin
  if not is_admin() then raise exception 'Only ClassTix admins can do that.' using errcode = '42501'; end if;
end $$;

-- service role (no uid), admins, or the district itself may read a balance
create or replace function public.can_see_district(p_district uuid) returns boolean
language sql stable security definer set search_path = public as $$
  select auth.uid() is null or is_admin() or p_district = my_district()
$$;

create or replace function public.available(p_district uuid) returns int
language sql stable security definer set search_path = public as $$
  select case when can_see_district(p_district) then
    (select coalesce(sum(amount), 0)::int from ledger where district_id = p_district) end
$$;

create or replace function public.held(p_district uuid) returns int
language sql stable security definer set search_path = public as $$
  select case when can_see_district(p_district) then
    (select coalesce(sum(qty * points_each), 0)::int from requests where district_id = p_district and status = 'Pending') end
$$;

-- ---------------------------------------------------------------- email helpers (queue only; the app delivers)
create or replace function public.notify_district(p_district uuid, p_subject text, p_body text, p_kind text) returns void
language plpgsql security definer set search_path = public as $$
declare n int;
begin
  insert into outbox (to_email, to_name, subject, body, kind)
  select p.email, p.name, p_subject, p_body, p_kind
  from profiles p where p.district_id = p_district and p.status = 'Active';
  get diagnostics n = row_count;
  if n = 0 then  -- nobody signed in yet: fall back to the district contact
    insert into outbox (to_email, to_name, subject, body, kind)
    select d.contact, d.name, p_subject, p_body, p_kind from districts d
    where d.id = p_district and d.contact like '%@%';
  end if;
end $$;

create or replace function public.notify_admins(p_subject text, p_body text, p_kind text) returns void
language sql security definer set search_path = public as $$
  insert into outbox (to_email, to_name, subject, body, kind)
  select email, name, p_subject, p_body, p_kind from profiles where role = 'admin' and status = 'Active'
$$;

create or replace function public.event_when(e public.events) returns text
language sql stable as $$
  select case when e.dated then to_char(e.date, 'Dy, Mon FMDD') || case when e.time <> '' then ' at ' || e.time else '' end
              else 'Anytime' end
$$;

-- ---------------------------------------------------------------- row-level security
alter table public.settings      enable row level security;
alter table public.districts     enable row level security;
alter table public.profiles      enable row level security;
alter table public.events        enable row level security;
alter table public.ticket_types  enable row level security;
alter table public.requests      enable row level security;
alter table public.request_notes enable row level security;
alter table public.ledger        enable row level security;
alter table public.outbox        enable row level security;

-- reads only; every write goes through the functions below
create policy settings_read  on public.settings     for select to authenticated using (true);
create policy districts_read on public.districts    for select to authenticated using (is_admin() or id = my_district());
create policy profiles_read  on public.profiles     for select to authenticated using (is_admin() or id = auth.uid());
create policy events_read    on public.events       for select to authenticated using (
  is_admin()
  or (my_district() is not null and (status = 'Published'
      or id in (select event_id from requests where district_id = my_district()))));
create policy types_read     on public.ticket_types for select to authenticated using (
  exists (select 1 from events e where e.id = event_id));   -- inherits events visibility
create policy requests_read  on public.requests     for select to authenticated using (is_admin() or district_id = my_district());
create policy notes_read     on public.request_notes for select to authenticated using (is_admin());
create policy ledger_read    on public.ledger       for select to authenticated using (is_admin() or district_id = my_district());
create policy outbox_read    on public.outbox       for select to authenticated using (is_admin());

revoke insert, update, delete on all tables in schema public from anon, authenticated;
revoke all on all tables in schema public from anon;
