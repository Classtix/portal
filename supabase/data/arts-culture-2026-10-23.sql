-- ClassTix — Arts & Culture update (Oct 23, 2026)
-- Archives The Phoenix Symphony and adds four family visits (each award = 4 tickets, a family of 4).
-- Point prices follow the existing museum tiers (Heard/Phoenix Art Museum 10 pts; Zoo/Science Center 20 pts);
-- change them in Admin -> Events & items. Safe to run more than once. Run in the Supabase SQL editor.
begin;

update events set status = 'Archived', updated_at = now()
where title = 'The Phoenix Symphony' and cat = 'arts' and status in ('Published', 'Draft');

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Children''s Museum of Phoenix family visit', 'arts', 'Children''s Museum of Phoenix', 'Hands-on play museum in downtown Phoenix, best for younger students. Each award covers 4 tickets: a family of 4.', false, null, '', '', null, 'Published', 'arts-childrens-museum-phoenix'
  where not exists (select 1 from events where series = 'arts-childrens-museum-phoenix') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select id, 'Award (4 tickets)', 80, 10, 4, 1 from e;

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Arizona Museum of Natural History family visit', 'arts', 'Arizona Museum of Natural History', 'Dinosaur Hall and Southwest history in Mesa. Each award covers 4 tickets: a family of 4.', false, null, '', '', null, 'Published', 'arts-az-natural-history'
  where not exists (select 1 from events where series = 'arts-az-natural-history') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select id, 'Award (4 tickets)', 80, 10, 4, 1 from e;

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Museum of Illusions Scottsdale family visit', 'arts', 'Museum of Illusions Scottsdale', 'Interactive optical-illusion rooms in Scottsdale. Each award covers 4 tickets: a family of 4.', false, null, '', '', null, 'Published', 'arts-museum-of-illusions-scottsdale'
  where not exists (select 1 from events where series = 'arts-museum-of-illusions-scottsdale') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select id, 'Award (4 tickets)', 80, 20, 4, 1 from e;

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Butterfly Wonderland family visit', 'arts', 'Butterfly Wonderland', 'America''s largest butterfly conservatory, in Scottsdale. Each award covers 4 tickets: a family of 4.', false, null, '', '', null, 'Published', 'arts-butterfly-wonderland'
  where not exists (select 1 from events where series = 'arts-butterfly-wonderland') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select id, 'Award (4 tickets)', 80, 20, 4, 1 from e;

commit;

select e.title, min(t.points) as points, min(t.seats) as tickets from events e join ticket_types t on t.event_id = e.id
where e.cat = 'arts' and e.status = 'Published' and not e.dated group by e.title order by e.title;

-- Open requests for the archived Symphony listing (handle in Requests; usually none):
select r.code, d.name as district, r.qty, r.status from requests r join events e on e.id = r.event_id join districts d on d.id = r.district_id
where e.title = 'The Phoenix Symphony' and r.status in ('Pending', 'Approved');
