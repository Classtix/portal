-- ClassTix — gift card update (Oct 23, 2026)
-- 1. Adds a $25 option to every gift card. Points are whole numbers and 1 point = $2, so $25 is priced at 13 points
--    (rounded up from 12.5). Change it in Admin → Events & items if you prefer 12.
-- 2. Adds Starbucks and Chick-fil-A gift cards under Restaurants ($25 / $50 / $100 / $250).
-- 3. Archives "Dinner for four at a fine dining restaurant".
-- Safe to run more than once. Run in the Supabase SQL editor.
begin;

-- 2. new restaurant cards (created first so step 1 gives them the $25 option too)
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Starbucks gift card', 'retail', 'Starbucks', 'A Starbucks gift card, delivered digitally. Pick $25, $50, $100 or $250.', false, null, '', '', null, 'Published', 'restaurantcard-starbucks'
  where not exists (select 1 from events where series = 'restaurantcard-starbucks') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('$50 gift card', 40, 25, 1, 1), ('$100 gift card', 20, 50, 1, 2), ('$250 gift card', 10, 125, 1, 3)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Chick-fil-A gift card', 'retail', 'Chick-fil-A', 'A Chick-fil-A gift card, delivered digitally. Pick $25, $50, $100 or $250.', false, null, '', '', null, 'Published', 'restaurantcard-chick-fil-a'
  where not exists (select 1 from events where series = 'restaurantcard-chick-fil-a') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('$50 gift card', 40, 25, 1, 1), ('$100 gift card', 20, 50, 1, 2), ('$250 gift card', 10, 125, 1, 3)) as t(name, qty, points, seats, sort);

-- 1. $25 option on every gift card
insert into ticket_types (event_id, name, qty, points, seats, sort)
select e.id, '$25 gift card', 60, 13, 1, 0
from events e
where e.series ~ '^(giftcard|restaurantcard)-'
  and not exists (select 1 from ticket_types t where t.event_id = e.id and t.name = '$25 gift card');

update events set description = replace(replace(description, 'Pick $50, $100 or $250.', 'Pick $25, $50, $100 or $250.'), 'Pick $50 or $100.', 'Pick $25, $50, $100 or $250.'), updated_at = now()
where series ~ '^(giftcard|restaurantcard)-' and (description like '%Pick $50, $100 or $250.%' or description like '%Pick $50 or $100.%');

-- 3. retire dinner for four
update events set status = 'Archived', updated_at = now()
where title = 'Dinner for four at a fine dining restaurant' and status in ('Published', 'Draft');

commit;

select e.title, e.status, string_agg(t.name || ' = ' || t.points || ' pts', ', ' order by t.sort) as options
from events e left join ticket_types t on t.event_id = e.id
where e.cat = 'retail' and e.status = 'Published' group by e.title, e.status order by e.title;

-- Any open requests for the archived dinner (handle in Requests; usually none):
select r.code, d.name as district, r.qty, r.status from requests r join events e on e.id = r.event_id join districts d on d.id = r.district_id
where e.title = 'Dinner for four at a fine dining restaurant' and r.status in ('Pending', 'Approved');
