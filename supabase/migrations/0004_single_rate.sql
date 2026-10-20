-- ClassTix — one funding rate for every district: $2 per student per month.
-- 95% of that becomes points at $2 per point, so monthly points = students × 0.95, rounded to the nearest 10.
-- Run once in the Supabase SQL editor. Existing districts are recalculated from their student counts.

create or replace function public.monthly_for(p_students int) returns int
language sql immutable as $$ select (round(coalesce(p_students, 0) * 0.95 / 10.0) * 10)::int $$;
grant execute on function public.monthly_for(int) to authenticated, service_role;

alter table public.districts alter column tier set default 't2';
update public.districts set tier = 't2', next_tier = null, monthly = monthly_for(students);

-- The tier and monthly arguments stay so older app versions keep working; both are now ignored.
create or replace function public.create_district(p_name text, p_state text, p_students int, p_tier text, p_monthly int, p_contact text)
returns uuid language plpgsql security definer set search_path = public as $$
declare v_id uuid; m text; v_monthly int := monthly_for(p_students);
begin
  perform require_admin();
  if coalesce(trim(p_name), '') = '' then raise exception 'Add the district''s name.'; end if;
  if coalesce(p_students, 0) < 1 then raise exception 'Enter the number of students.'; end if;
  insert into districts (name, state, students, tier, monthly, contact)
  values (trim(p_name), upper(coalesce(nullif(trim(p_state), ''), 'AZ')), p_students, 't2', v_monthly, coalesce(trim(p_contact), ''))
  returning id into v_id;
  select current_month into m from settings;
  insert into ledger (district_id, entry, amount) values (v_id, 'Monthly allocation, ' || month_label(m), v_monthly);
  return v_id;
end $$;

create or replace function public.update_district(p_id uuid, p_name text, p_students int, p_contact text, p_monthly int, p_tier text)
returns void language plpgsql security definer set search_path = public as $$
declare d districts;
begin
  perform require_admin();
  select * into d from districts where id = p_id for update;
  if not found then raise exception 'District not found.'; end if;
  if p_students is not null and p_students < 1 then raise exception 'Enter the number of students.'; end if;
  update districts set
    name = coalesce(nullif(trim(p_name), ''), name),
    students = coalesce(p_students, students),
    contact = coalesce(trim(p_contact), contact),
    monthly = monthly_for(coalesce(p_students, students)),
    tier = 't2', next_tier = null
  where id = p_id;
end $$;
