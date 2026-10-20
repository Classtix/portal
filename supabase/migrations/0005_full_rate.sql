-- ClassTix — all of each district's $2 per student becomes points: 1 point per student per month ($2 of rewards).
-- Run once in the Supabase SQL editor. Updates every district's monthly points; the new amount is credited at the next reset.
create or replace function public.monthly_for(p_students int) returns int
language sql immutable as $$ select greatest(coalesce(p_students, 0), 0) $$;

update public.districts set monthly = monthly_for(students);
