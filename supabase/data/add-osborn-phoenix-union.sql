-- ClassTix — add Osborn School District and Phoenix Union High School District.
-- Student counts and school lists are from SchoolDigger's district pages; change them in Admin → Districts if your
-- agreement uses a different number. Each district is credited this month's points now, the same as "New district" in the admin.
-- Safe to run more than once (skips a district that already exists). Run in the Supabase SQL editor.
begin;

with d as (
  insert into districts (name, state, students, tier, monthly, contact, schools)
  select 'Osborn School District', 'AZ', 2518, 't2', monthly_for(2518), '', array[
    'Clarendon School', 'Encanto School', 'Longview Elementary School', 'Montecito Community School',
    'Osborn Community iSchool', 'Osborn Middle School', 'Solano School']
  where not exists (select 1 from districts where name = 'Osborn School District')
  returning id, monthly)
insert into ledger (district_id, entry, amount) select id, 'Monthly allocation, ' || month_label(az_month()), monthly from d;

with d as (
  insert into districts (name, state, students, tier, monthly, contact, schools)
  select 'Phoenix Union High School District', 'AZ', 25800, 't2', monthly_for(25800), '', array[
    'Alhambra High School', 'Betty Fairfax High School', 'Bostrom Alternative Center', 'Camelback High School',
    'Carl Hayden High School', 'Central High School', 'Cesar Chavez High School', 'Desiderata',
    'Franklin Police and Fire High School', 'Linda Abril Educational Academy', 'Maryvale High School',
    'Metro Tech High School', 'North High School', 'Phoenix Coding Academy', 'Phoenix Digital Academy',
    'Phoenix Educator Preparatory', 'Phoenix Union Bioscience High School', 'Phoenix Union-Wilson College Preparatory',
    'PXU City', 'South Mountain High School', 'Trevor Browne High School']
  where not exists (select 1 from districts where name = 'Phoenix Union High School District')
  returning id, monthly)
insert into ledger (district_id, entry, amount) select id, 'Monthly allocation, ' || month_label(az_month()), monthly from d;

commit;

select name, students, monthly as monthly_points, cardinality(schools) as schools from districts order by name;
