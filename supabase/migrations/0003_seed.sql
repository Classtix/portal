-- ClassTix — starting data: your Live Marketplace catalog, Tempe Union HSD, retail gift card program.
-- Run once after 0001 and 0002. Safe to skip if you'd rather start empty.
begin;
update settings set current_month = az_month(), rollover = false, retail = '{"days":[1,15],"retailers":["Dick''s Sporting Goods","Foot Locker","Target","Walmart","Harkins Theatres","AMC Theatres","The Cheesecake Factory"],"denoms":[{"label":"$50","points":25,"qty":10},{"label":"$100","points":50,"qty":5}]}'::jsonb;
with d as (insert into districts (name, state, students, tier, monthly, contact) values ('Tempe Union HSD','AZ',4500,'t2',4280,'') returning id)
insert into ledger (district_id, entry, amount) select id, 'Monthly allocation, ' || month_label(az_month()) || ' (fall pilot)', 4280 from d;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Sun Devil basketball', 'sports', 'ASU Athletics', 'Each award covers 2 tickets: a student plus a parent or chaperone.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 120, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Sun Devil football', 'sports', 'ASU Athletics', 'Each award covers 2 tickets: a student plus a parent or chaperone.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 80, 20, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Arizona Cardinals game', 'sports', 'Arizona Cardinals', 'Each award covers 2 tickets: a student plus a parent or chaperone.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 40, 40, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Arizona Diamondbacks game', 'sports', 'Arizona Diamondbacks', 'Each award covers 2 tickets: a student plus a parent or chaperone.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 120, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Desert Botanical Garden', 'arts', 'Desert Botanical Garden', 'Each award covers 2 tickets: a student plus a parent or chaperone.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 80, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Dinner for two, local Tempe restaurant', 'dining', 'Local restaurant partners', 'Each award covers 2 tickets: a student plus a parent or chaperone.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 80, 20, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Dinner for four at a fine dining restaurant', 'dining', 'Fine dining partners', 'Each award covers 4 tickets: a family of 4. Premium experience with limited availability.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (4 tickets)', 20, 60, 4 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Broadway at ASU Gammage', 'arts', 'ASU Gammage', 'Each award covers 2 tickets: a student plus a parent or chaperone. Premium experience with limited availability.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 40, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Heard Museum family visit', 'arts', 'Heard Museum', 'Each award covers 4 tickets: a family of 4.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (4 tickets)', 80, 10, 4 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Banda MS: Somos MS Tour', 'music', 'Mortgage Matchup Center', 'Each award covers 2 tickets: a student plus a parent or chaperone.', true, '2026-11-28'::date, 'Mortgage Matchup Center', '2026-11-27'::date, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 30, 40, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('The Filharmonic, a cappella', 'music', 'Tempe Center for the Arts', 'Each award covers 2 tickets: a student plus a parent or chaperone.', true, '2026-10-16'::date, 'Tempe Center for the Arts', '2026-10-15'::date, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 40, 20, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Gorillaz: The Mountain Tour', 'music', 'Mortgage Matchup Center', 'Each award covers 2 tickets: a student plus a parent or chaperone. Premium experience with limited availability.', true, '2026-10-23'::date, 'Mortgage Matchup Center', '2026-10-22'::date, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 24, 40, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Kacey Musgraves: Middle of Nowhere Tour', 'music', 'Mortgage Matchup Center', 'Each award covers 2 tickets: a student plus a parent or chaperone. Premium experience with limited availability.', true, '2026-10-17'::date, 'Mortgage Matchup Center', '2026-10-16'::date, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 40, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Orkesta Mendoza', 'music', 'Tempe Center for the Arts', 'Each award covers 2 tickets: a student plus a parent or chaperone.', true, '2026-11-14'::date, 'Tempe Center for the Arts', '2026-11-13'::date, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 40, 20, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Teddy Swims: The UGLY Tour', 'music', 'Mortgage Matchup Center', 'Each award covers 2 tickets: a student plus a parent or chaperone.', true, '2026-11-16'::date, 'Mortgage Matchup Center', '2026-11-15'::date, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 30, 40, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Weezer with The Shins and Silversun Pickups', 'music', 'Mortgage Matchup Center', 'Each award covers 2 tickets: a student plus a parent or chaperone.', true, '2026-10-20'::date, 'Mortgage Matchup Center', '2026-10-19'::date, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 30, 40, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Phoenix Mercury game', 'sports', 'Phoenix Mercury', 'Each award covers 2 tickets: a student plus a parent or chaperone.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 80, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Musical Instrument Museum family visit', 'arts', 'Musical Instrument Museum', 'Each award covers 4 tickets: a family of 4.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (4 tickets)', 80, 10, 4 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Arizona Opera performance', 'arts', 'Arizona Opera', 'Each award covers 2 tickets: a student plus a parent or chaperone.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 40, 20, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Phoenix Art Museum family visit', 'arts', 'Phoenix Art Museum', 'Each award covers 4 tickets: a family of 4.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (4 tickets)', 80, 10, 4 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Phoenix Rising FC match', 'sports', 'Phoenix Rising FC', 'Each award covers 2 tickets: a student plus a parent or chaperone.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 80, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Arizona Science Center family visit', 'arts', 'Arizona Science Center', 'Each award covers 4 tickets: a family of 4.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (4 tickets)', 80, 20, 4 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Phoenix Suns, lower level', 'sports', 'Phoenix Suns', 'Each award covers 2 tickets: a student plus a parent or chaperone. Premium experience with limited availability.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 24, 50, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Phoenix Suns, upper level', 'sports', 'Phoenix Suns', 'Each award covers 2 tickets: a student plus a parent or chaperone.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 80, 20, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('The Phoenix Symphony', 'arts', 'The Phoenix Symphony', 'Each award covers 2 tickets: a student plus a parent or chaperone.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 60, 20, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, venue, deadline, status)
  values ('Phoenix Zoo family visit', 'arts', 'Phoenix Zoo', 'Each award covers 4 tickets: a family of 4.', false, null, '', null, 'Published') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (4 tickets)', 80, 20, 4 from e;
select ensure_retail(az_month()), ensure_retail(next_month(az_month()));
commit;
