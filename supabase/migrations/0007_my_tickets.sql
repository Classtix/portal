-- ClassTix — My Tickets: ClassTix attaches ticket files or transfer links to approved requests,
-- and districts download them from the portal.
-- Run once in the Supabase SQL editor.

create table if not exists public.deliveries (
  id          uuid primary key default gen_random_uuid(),
  request_id  uuid not null references public.requests (id) on delete cascade,
  district_id uuid not null references public.districts (id),
  kind        text not null check (kind in ('file', 'link')),
  label       text not null default '',
  path        text,            -- storage path in the private "tickets" bucket (kind = file)
  file_name   text,
  size        bigint,
  url         text,            -- transfer or gift card link (kind = link)
  created_by  uuid references auth.users (id),
  created_at  timestamptz not null default now(),
  downloaded_at timestamptz,
  check ((kind = 'file' and path is not null) or (kind = 'link' and url is not null))
);
create index if not exists deliveries_request on public.deliveries (request_id);
create index if not exists deliveries_district on public.deliveries (district_id);

alter table public.deliveries enable row level security;
drop policy if exists deliveries_read on public.deliveries;
create policy deliveries_read on public.deliveries for select to authenticated using (is_admin() or district_id = my_district());
revoke insert, update, delete on public.deliveries from anon, authenticated;
revoke all on public.deliveries from anon;
grant select on public.deliveries to authenticated;
grant all on public.deliveries to service_role;

-- Private storage bucket for ticket files. Only the server (service role) reads or writes it;
-- districts get short-lived download links after the app checks the file is theirs.
do $$ begin
  if to_regclass('storage.buckets') is not null then
    insert into storage.buckets (id, name, public, file_size_limit)
    values ('tickets', 'tickets', false, 26214400)
    on conflict (id) do nothing;
  end if;
end $$;

create or replace function public.add_delivery(p_request uuid, p_kind text, p_label text, p_path text, p_file_name text, p_size bigint, p_url text)
returns uuid language plpgsql security definer set search_path = public as $$
declare r requests; v_id uuid; v_url text := trim(coalesce(p_url, ''));
begin
  perform require_admin();
  select * into r from requests where id = p_request;
  if not found then raise exception 'Request not found.'; end if;
  if r.status not in ('Approved', 'Fulfilled') then raise exception 'Approve the request before adding tickets.'; end if;
  if p_kind = 'link' and v_url !~* '^https?://' then raise exception 'Enter a link that starts with https://'; end if;
  if p_kind = 'file' and coalesce(p_path, '') not like r.district_id::text || '/' || r.id::text || '/%' then
    raise exception 'That file isn''t attached to this request.'; end if;
  insert into deliveries (request_id, district_id, kind, label, path, file_name, size, url, created_by)
  values (r.id, r.district_id, p_kind, left(trim(coalesce(p_label, '')), 120),
          case when p_kind = 'file' then p_path end, case when p_kind = 'file' then left(p_file_name, 200) end,
          case when p_kind = 'file' then p_size end, case when p_kind = 'link' then left(v_url, 2000) end, auth.uid())
  returning id into v_id;
  return v_id;
end $$;

-- returns the storage path (if any) so the app can delete the file too
create or replace function public.remove_delivery(p_id uuid) returns text
language plpgsql security definer set search_path = public as $$
declare v deliveries;
begin
  perform require_admin();
  delete from deliveries where id = p_id returning * into v;
  if not found then raise exception 'Already removed.'; end if;
  return v.path;
end $$;

create or replace function public.mark_downloaded(p_id uuid) returns void
language plpgsql security definer set search_path = public as $$
begin
  update deliveries set downloaded_at = coalesce(downloaded_at, now())
  where id = p_id and district_id = my_district();
end $$;

-- "Mark fulfilled" now points districts to My Tickets when files or links are attached.
create or replace function public.fulfil_request(p_id uuid) returns void
language plpgsql security definer set search_path = public as $$
declare r requests; e events; n int; v_type text;
begin
  perform require_admin();
  select * into r from requests where id = p_id for update;
  if not found or r.status <> 'Approved' then raise exception 'Only approved requests can be marked fulfilled.'; end if;
  select * into e from events where id = r.event_id;
  select count(*) into n from deliveries where request_id = p_id;
  select name into v_type from ticket_types where id = r.type_id;
  update requests set status = 'Fulfilled', fulfilled_at = now() where id = p_id;
  if n > 0 then
    perform notify_district(r.district_id, 'Your tickets are ready: ' || e.title,
      'Your ' || r.approved_qty || ' × ' || coalesce(v_type, 'tickets') || ' for ' || e.title || ' (' || event_when(e) || E') are ready to download.\n\n'
      || 'Sign in to the ClassTix portal and open My Tickets: https://portal.classtix.org/district/tickets' || E'\n\nThe ClassTix team', 'fulfilled');
  else
    perform notify_district(r.district_id, 'Tickets on the way: ' || e.title,
      'Your ' || r.approved_qty || ' tickets for ' || e.title || ' (' || event_when(e) || E') have been sent. Look out for them by email or text.\n\nThe ClassTix team', 'fulfilled');
  end if;
end $$;

grant execute on function public.add_delivery(uuid, text, text, text, text, bigint, text), public.remove_delivery(uuid),
  public.mark_downloaded(uuid), public.fulfil_request(uuid) to authenticated;
