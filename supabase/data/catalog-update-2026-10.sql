-- ClassTix — October 2026 catalog update. Run once in Supabase → SQL Editor. Safe to run again.
--  * Dining joins Retail as "Restaurant & Retail"; twice-monthly gift card drops end; gift cards become always-available items
--  * Undated sports listings are retired (Diamondbacks, Phoenix Rising, Mercury, and the undated Suns/Cardinals)
--  * Suns and Cardinals home games and concerts at five Valley venues are added with dates
begin;

-- 1. Categories: dining -> retail
update events set cat = 'retail', updated_at = now() where cat = 'dining';

-- 2. End the gift card drops: archive upcoming drops and stop scheduling new ones
update events set status = 'Archived', updated_at = now() where series = 'retail' and status = 'Published';
update settings set retail = jsonb_set(retail, '{retailers}', '[]'::jsonb);

-- 3. Retire undated sports listings
update events set status = 'Archived', updated_at = now() where cat = 'sports' and not dated and status = 'Published';


-- 4. Gift cards, always available (Restaurant & Retail)

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Dick''s Sporting Goods gift card', 'retail', 'Dick''s Sporting Goods', 'A Dick''s Sporting Goods gift card, delivered digitally. Pick $50 or $100.', false, null, '', '', null, 'Published', 'giftcard-dick-s-sporting-goods'
  where not exists (select 1 from events where series = 'giftcard-dick-s-sporting-goods') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('$50 gift card', 40, 25, 1, 1),
    ('$100 gift card', 20, 50, 1, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Foot Locker gift card', 'retail', 'Foot Locker', 'A Foot Locker gift card, delivered digitally. Pick $50 or $100.', false, null, '', '', null, 'Published', 'giftcard-foot-locker'
  where not exists (select 1 from events where series = 'giftcard-foot-locker') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('$50 gift card', 40, 25, 1, 1),
    ('$100 gift card', 20, 50, 1, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Target gift card', 'retail', 'Target', 'A Target gift card, delivered digitally. Pick $50 or $100.', false, null, '', '', null, 'Published', 'giftcard-target'
  where not exists (select 1 from events where series = 'giftcard-target') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('$50 gift card', 40, 25, 1, 1),
    ('$100 gift card', 20, 50, 1, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Walmart gift card', 'retail', 'Walmart', 'A Walmart gift card, delivered digitally. Pick $50 or $100.', false, null, '', '', null, 'Published', 'giftcard-walmart'
  where not exists (select 1 from events where series = 'giftcard-walmart') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('$50 gift card', 40, 25, 1, 1),
    ('$100 gift card', 20, 50, 1, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Harkins Theatres gift card', 'retail', 'Harkins Theatres', 'A Harkins Theatres gift card, delivered digitally. Pick $50 or $100.', false, null, '', '', null, 'Published', 'giftcard-harkins-theatres'
  where not exists (select 1 from events where series = 'giftcard-harkins-theatres') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('$50 gift card', 40, 25, 1, 1),
    ('$100 gift card', 20, 50, 1, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'AMC Theatres gift card', 'retail', 'AMC Theatres', 'A AMC Theatres gift card, delivered digitally. Pick $50 or $100.', false, null, '', '', null, 'Published', 'giftcard-amc-theatres'
  where not exists (select 1 from events where series = 'giftcard-amc-theatres') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('$50 gift card', 40, 25, 1, 1),
    ('$100 gift card', 20, 50, 1, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'The Cheesecake Factory gift card', 'retail', 'The Cheesecake Factory', 'A The Cheesecake Factory gift card, delivered digitally. Pick $50 or $100.', false, null, '', '', null, 'Published', 'giftcard-the-cheesecake-factory'
  where not exists (select 1 from events where series = 'giftcard-the-cheesecake-factory') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('$50 gift card', 40, 25, 1, 1),
    ('$100 gift card', 20, 50, 1, 2)) as t(name, qty, points, seats, sort);

-- 5. Phoenix Suns home games, 2026-27 season (nba.com/suns/schedule)

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Golden State Warriors', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Golden State Warriors at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-24'::date, '19:00', 'Mortgage Matchup Center', '2026-10-22'::date, 'Published', 'suns-2026-10-24'
  where not exists (select 1 from events where series = 'suns-2026-10-24') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Denver Nuggets', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Denver Nuggets at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-30'::date, '19:00', 'Mortgage Matchup Center', '2026-10-27'::date, 'Published', 'suns-2026-10-30'
  where not exists (select 1 from events where series = 'suns-2026-10-30') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Portland Trail Blazers', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Portland Trail Blazers at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-04'::date, '19:00', 'Mortgage Matchup Center', '2026-11-01'::date, 'Published', 'suns-2026-11-04'
  where not exists (select 1 from events where series = 'suns-2026-11-04') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Orlando Magic', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Orlando Magic at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-05'::date, '19:00', 'Mortgage Matchup Center', '2026-11-02'::date, 'Published', 'suns-2026-11-05'
  where not exists (select 1 from events where series = 'suns-2026-11-05') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Houston Rockets', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Houston Rockets at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-07'::date, '19:00', 'Mortgage Matchup Center', '2026-11-04'::date, 'Published', 'suns-2026-11-07'
  where not exists (select 1 from events where series = 'suns-2026-11-07') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. San Antonio Spurs', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the San Antonio Spurs at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-09'::date, '19:00', 'Mortgage Matchup Center', '2026-11-06'::date, 'Published', 'suns-2026-11-09'
  where not exists (select 1 from events where series = 'suns-2026-11-09') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. LA Clippers', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the LA Clippers at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-10'::date, '19:00', 'Mortgage Matchup Center', '2026-11-07'::date, 'Published', 'suns-2026-11-10'
  where not exists (select 1 from events where series = 'suns-2026-11-10') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Charlotte Hornets', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Charlotte Hornets at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-12'::date, '19:00', 'Mortgage Matchup Center', '2026-11-09'::date, 'Published', 'suns-2026-11-12'
  where not exists (select 1 from events where series = 'suns-2026-11-12') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Los Angeles Lakers', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Los Angeles Lakers at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-15'::date, '14:00', 'Mortgage Matchup Center', '2026-11-12'::date, 'Published', 'suns-2026-11-15'
  where not exists (select 1 from events where series = 'suns-2026-11-15') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Dallas Mavericks', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Dallas Mavericks at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-27'::date, '19:00', 'Mortgage Matchup Center', '2026-11-24'::date, 'Published', 'suns-2026-11-27'
  where not exists (select 1 from events where series = 'suns-2026-11-27') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. LA Clippers', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the LA Clippers at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-01'::date, '19:00', 'Mortgage Matchup Center', '2026-11-28'::date, 'Published', 'suns-2026-12-01'
  where not exists (select 1 from events where series = 'suns-2026-12-01') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Sacramento Kings', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Sacramento Kings at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-02'::date, '19:00', 'Mortgage Matchup Center', '2026-11-29'::date, 'Published', 'suns-2026-12-02'
  where not exists (select 1 from events where series = 'suns-2026-12-02') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Minnesota Timberwolves', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Minnesota Timberwolves at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-12'::date, '19:00', 'Mortgage Matchup Center', '2026-12-09'::date, 'Published', 'suns-2026-12-12'
  where not exists (select 1 from events where series = 'suns-2026-12-12') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Atlanta Hawks', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Atlanta Hawks at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-14'::date, '19:00', 'Mortgage Matchup Center', '2026-12-11'::date, 'Published', 'suns-2026-12-14'
  where not exists (select 1 from events where series = 'suns-2026-12-14') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Indiana Pacers', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Indiana Pacers at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-23'::date, '19:00', 'Mortgage Matchup Center', '2026-12-20'::date, 'Published', 'suns-2026-12-23'
  where not exists (select 1 from events where series = 'suns-2026-12-23') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Golden State Warriors', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Golden State Warriors at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-28'::date, '19:00', 'Mortgage Matchup Center', '2026-12-25'::date, 'Published', 'suns-2026-12-28'
  where not exists (select 1 from events where series = 'suns-2026-12-28') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Philadelphia 76ers', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Philadelphia 76ers at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-30'::date, '19:00', 'Mortgage Matchup Center', '2026-12-27'::date, 'Published', 'suns-2026-12-30'
  where not exists (select 1 from events where series = 'suns-2026-12-30') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. New York Knicks', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the New York Knicks at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-31'::date, '19:00', 'Mortgage Matchup Center', '2026-12-28'::date, 'Published', 'suns-2026-12-31'
  where not exists (select 1 from events where series = 'suns-2026-12-31') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Sacramento Kings', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Sacramento Kings at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-02'::date, '19:00', 'Mortgage Matchup Center', '2026-12-30'::date, 'Published', 'suns-2027-01-02'
  where not exists (select 1 from events where series = 'suns-2027-01-02') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Boston Celtics', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Boston Celtics at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-04'::date, '19:00', 'Mortgage Matchup Center', '2027-01-01'::date, 'Published', 'suns-2027-01-04'
  where not exists (select 1 from events where series = 'suns-2027-01-04') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Chicago Bulls', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Chicago Bulls at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-10'::date, '17:00', 'Mortgage Matchup Center', '2027-01-07'::date, 'Published', 'suns-2027-01-10'
  where not exists (select 1 from events where series = 'suns-2027-01-10') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Memphis Grizzlies', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Memphis Grizzlies at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-20'::date, '19:00', 'Mortgage Matchup Center', '2027-01-17'::date, 'Published', 'suns-2027-01-20'
  where not exists (select 1 from events where series = 'suns-2027-01-20') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Utah Jazz', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Utah Jazz at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-22'::date, '19:00', 'Mortgage Matchup Center', '2027-01-19'::date, 'Published', 'suns-2027-01-22'
  where not exists (select 1 from events where series = 'suns-2027-01-22') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Utah Jazz', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Utah Jazz at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-24'::date, '14:00', 'Mortgage Matchup Center', '2027-01-21'::date, 'Published', 'suns-2027-01-24'
  where not exists (select 1 from events where series = 'suns-2027-01-24') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Cleveland Cavaliers', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Cleveland Cavaliers at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-03'::date, '19:00', 'Mortgage Matchup Center', '2027-01-31'::date, 'Published', 'suns-2027-02-03'
  where not exists (select 1 from events where series = 'suns-2027-02-03') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Houston Rockets', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Houston Rockets at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-05'::date, '19:00', 'Mortgage Matchup Center', '2027-02-02'::date, 'Published', 'suns-2027-02-05'
  where not exists (select 1 from events where series = 'suns-2027-02-05') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Los Angeles Lakers', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Los Angeles Lakers at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-08'::date, '19:30', 'Mortgage Matchup Center', '2027-02-05'::date, 'Published', 'suns-2027-02-08'
  where not exists (select 1 from events where series = 'suns-2027-02-08') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Detroit Pistons', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Detroit Pistons at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-10'::date, '19:00', 'Mortgage Matchup Center', '2027-02-07'::date, 'Published', 'suns-2027-02-10'
  where not exists (select 1 from events where series = 'suns-2027-02-10') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. New Orleans Pelicans', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the New Orleans Pelicans at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-27'::date, '19:00', 'Mortgage Matchup Center', '2027-02-24'::date, 'Published', 'suns-2027-02-27'
  where not exists (select 1 from events where series = 'suns-2027-02-27') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Washington Wizards', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Washington Wizards at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-01'::date, '19:30', 'Mortgage Matchup Center', '2027-02-26'::date, 'Published', 'suns-2027-03-01'
  where not exists (select 1 from events where series = 'suns-2027-03-01') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Brooklyn Nets', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Brooklyn Nets at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-03'::date, '19:00', 'Mortgage Matchup Center', '2027-02-28'::date, 'Published', 'suns-2027-03-03'
  where not exists (select 1 from events where series = 'suns-2027-03-03') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Minnesota Timberwolves', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Minnesota Timberwolves at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-05'::date, '19:00', 'Mortgage Matchup Center', '2027-03-02'::date, 'Published', 'suns-2027-03-05'
  where not exists (select 1 from events where series = 'suns-2027-03-05') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Miami Heat', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Miami Heat at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-19'::date, '19:30', 'Mortgage Matchup Center', '2027-03-16'::date, 'Published', 'suns-2027-03-19'
  where not exists (select 1 from events where series = 'suns-2027-03-19') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Portland Trail Blazers', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Portland Trail Blazers at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-21'::date, '14:00', 'Mortgage Matchup Center', '2027-03-18'::date, 'Published', 'suns-2027-03-21'
  where not exists (select 1 from events where series = 'suns-2027-03-21') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Oklahoma City Thunder', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Oklahoma City Thunder at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-23'::date, '20:00', 'Mortgage Matchup Center', '2027-03-20'::date, 'Published', 'suns-2027-03-23'
  where not exists (select 1 from events where series = 'suns-2027-03-23') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Oklahoma City Thunder', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Oklahoma City Thunder at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-24'::date, '19:00', 'Mortgage Matchup Center', '2027-03-21'::date, 'Published', 'suns-2027-03-24'
  where not exists (select 1 from events where series = 'suns-2027-03-24') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Milwaukee Bucks', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Milwaukee Bucks at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-26'::date, '19:00', 'Mortgage Matchup Center', '2027-03-23'::date, 'Published', 'suns-2027-03-26'
  where not exists (select 1 from events where series = 'suns-2027-03-26') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Toronto Raptors', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Toronto Raptors at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-28'::date, '18:00', 'Mortgage Matchup Center', '2027-03-25'::date, 'Published', 'suns-2027-03-28'
  where not exists (select 1 from events where series = 'suns-2027-03-28') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Denver Nuggets', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Denver Nuggets at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-04-02'::date, '19:00', 'Mortgage Matchup Center', '2027-03-30'::date, 'Published', 'suns-2027-04-02'
  where not exists (select 1 from events where series = 'suns-2027-04-02') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Phoenix Suns vs. Memphis Grizzlies', 'sports', 'Phoenix Suns', 'Phoenix Suns home game against the Memphis Grizzlies at Mortgage Matchup Center (formerly Footprint Center). Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-04-09'::date, '19:00', 'Mortgage Matchup Center', '2027-04-06'::date, 'Published', 'suns-2027-04-09'
  where not exists (select 1 from events where series = 'suns-2027-04-09') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Upper level (2 tickets)', 20, 20, 2, 1),
    ('Lower level (2 tickets)', 6, 50, 2, 2)) as t(name, qty, points, seats, sort);

-- 6. Arizona Cardinals home games, 2026 season (azcardinals.com/schedule). Week 18 vs. 49ers is date TBD and not included.

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Arizona Cardinals vs. Denver Broncos', 'sports', 'Arizona Cardinals', 'Arizona Cardinals home game against the Denver Broncos at State Farm Stadium. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-25'::date, '13:05', 'State Farm Stadium', '2026-10-22'::date, 'Published', 'cardinals-2026-10-25'
  where not exists (select 1 from events where series = 'cardinals-2026-10-25') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Arizona Cardinals vs. Los Angeles Rams', 'sports', 'Arizona Cardinals', 'Arizona Cardinals home game against the Los Angeles Rams at State Farm Stadium. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-15'::date, '14:05', 'State Farm Stadium', '2026-11-12'::date, 'Published', 'cardinals-2026-11-15'
  where not exists (select 1 from events where series = 'cardinals-2026-11-15') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Arizona Cardinals vs. Washington Commanders', 'sports', 'Arizona Cardinals', 'Arizona Cardinals home game against the Washington Commanders at State Farm Stadium. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-29'::date, '14:25', 'State Farm Stadium', '2026-11-26'::date, 'Published', 'cardinals-2026-11-29'
  where not exists (select 1 from events where series = 'cardinals-2026-11-29') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Arizona Cardinals vs. Philadelphia Eagles', 'sports', 'Arizona Cardinals', 'Arizona Cardinals home game against the Philadelphia Eagles at State Farm Stadium. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-06'::date, '14:05', 'State Farm Stadium', '2026-12-03'::date, 'Published', 'cardinals-2026-12-06'
  where not exists (select 1 from events where series = 'cardinals-2026-12-06') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Arizona Cardinals vs. New York Jets', 'sports', 'Arizona Cardinals', 'Arizona Cardinals home game against the New York Jets at State Farm Stadium. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-20'::date, '14:05', 'State Farm Stadium', '2026-12-17'::date, 'Published', 'cardinals-2026-12-20'
  where not exists (select 1 from events where series = 'cardinals-2026-12-20') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Arizona Cardinals vs. Las Vegas Raiders', 'sports', 'Arizona Cardinals', 'Arizona Cardinals home game against the Las Vegas Raiders at State Farm Stadium. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-03'::date, '14:05', 'State Farm Stadium', '2026-12-31'::date, 'Published', 'cardinals-2027-01-03'
  where not exists (select 1 from events where series = 'cardinals-2027-01-03') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

-- 7. Concerts at State Farm Stadium, Chase Field, Talking Stick Resort Amphitheatre, Mortgage Matchup Center (formerly Footprint Center) and Arizona Financial Theatre (venue calendars via Songkick, Oct 21 2026)

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Doja Cat', 'music', 'Mortgage Matchup Center', 'Doja Cat live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-29'::date, '19:30', 'Mortgage Matchup Center', '2026-10-26'::date, 'Published', 'concert-doja-cat-2026-10-29'
  where not exists (select 1 from events where series = 'concert-doja-cat-2026-10-29') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Don Omar', 'music', 'Mortgage Matchup Center', 'Don Omar live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-08'::date, '20:00', 'Mortgage Matchup Center', '2026-11-05'::date, 'Published', 'concert-don-omar-2026-11-08'
  where not exists (select 1 from events where series = 'concert-don-omar-2026-11-08') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'The Smashing Pumpkins', 'music', 'Mortgage Matchup Center', 'The Smashing Pumpkins live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-11'::date, '20:00', 'Mortgage Matchup Center', '2026-11-08'::date, 'Published', 'concert-the-smashing-pumpkins-2026-11-11'
  where not exists (select 1 from events where series = 'concert-the-smashing-pumpkins-2026-11-11') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'KATSEYE', 'music', 'Mortgage Matchup Center', 'KATSEYE live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-24'::date, '20:00', 'Mortgage Matchup Center', '2026-11-21'::date, 'Published', 'concert-katseye-2026-11-24'
  where not exists (select 1 from events where series = 'concert-katseye-2026-11-24') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'The Neighbourhood with Nessa Barrett', 'music', 'Mortgage Matchup Center', 'The Neighbourhood with Nessa Barrett live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-30'::date, '19:00', 'Mortgage Matchup Center', '2026-11-27'::date, 'Published', 'concert-the-neighbourhood-with-nessa-barrett-2026-11-30'
  where not exists (select 1 from events where series = 'concert-the-neighbourhood-with-nessa-barrett-2026-11-30') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Trans-Siberian Orchestra', 'music', 'Mortgage Matchup Center', 'Trans-Siberian Orchestra live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-06'::date, '19:30', 'Mortgage Matchup Center', '2026-12-03'::date, 'Published', 'concert-trans-siberian-orchestra-2026-12-06'
  where not exists (select 1 from events where series = 'concert-trans-siberian-orchestra-2026-12-06') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Valentine''s Super Love Jam 2027', 'music', 'Mortgage Matchup Center', 'Valentine''s Super Love Jam 2027 live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-06'::date, '19:30', 'Mortgage Matchup Center', '2027-02-03'::date, 'Published', 'concert-valentine-s-super-love-jam-2027-2027-02-06'
  where not exists (select 1 from events where series = 'concert-valentine-s-super-love-jam-2027-2027-02-06') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Elevation Worship', 'music', 'Mortgage Matchup Center', 'Elevation Worship live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-06'::date, '19:00', 'Mortgage Matchup Center', '2027-03-03'::date, 'Published', 'concert-elevation-worship-2027-03-06'
  where not exists (select 1 from events where series = 'concert-elevation-worship-2027-03-06') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Greta Van Fleet', 'music', 'Mortgage Matchup Center', 'Greta Van Fleet live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-20'::date, '19:00', 'Mortgage Matchup Center', '2027-03-17'::date, 'Published', 'concert-greta-van-fleet-2027-03-20'
  where not exists (select 1 from events where series = 'concert-greta-van-fleet-2027-03-20') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Los Parras', 'music', 'Mortgage Matchup Center', 'Los Parras live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-27'::date, '20:00', 'Mortgage Matchup Center', '2027-03-24'::date, 'Published', 'concert-los-parras-2027-03-27'
  where not exists (select 1 from events where series = 'concert-los-parras-2027-03-27') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Hans Zimmer Live', 'music', 'Mortgage Matchup Center', 'Hans Zimmer Live live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-30'::date, '19:30', 'Mortgage Matchup Center', '2027-03-27'::date, 'Published', 'concert-hans-zimmer-live-2027-03-30'
  where not exists (select 1 from events where series = 'concert-hans-zimmer-live-2027-03-30') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Nickelback', 'music', 'Mortgage Matchup Center', 'Nickelback live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-04-20'::date, '18:30', 'Mortgage Matchup Center', '2027-04-17'::date, 'Published', 'concert-nickelback-2027-04-20'
  where not exists (select 1 from events where series = 'concert-nickelback-2027-04-20') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Fantasia', 'music', 'Mortgage Matchup Center', 'Fantasia live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-04-23'::date, '20:00', 'Mortgage Matchup Center', '2027-04-20'::date, 'Published', 'concert-fantasia-2027-04-23'
  where not exists (select 1 from events where series = 'concert-fantasia-2027-04-23') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Niall Horan', 'music', 'Mortgage Matchup Center', 'Niall Horan live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-05-20'::date, '19:30', 'Mortgage Matchup Center', '2027-05-17'::date, 'Published', 'concert-niall-horan-2027-05-20'
  where not exists (select 1 from events where series = 'concert-niall-horan-2027-05-20') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Banda MS de Sergio Lizárraga', 'music', 'Mortgage Matchup Center', 'Banda MS de Sergio Lizárraga live at Mortgage Matchup Center. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-09-18'::date, '20:00', 'Mortgage Matchup Center', '2027-09-15'::date, 'Published', 'concert-banda-ms-de-sergio-liz-rraga-2027-09-18'
  where not exists (select 1 from events where series = 'concert-banda-ms-de-sergio-liz-rraga-2027-09-18') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 40, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Malcolm Todd', 'music', 'Arizona Financial Theatre', 'Malcolm Todd live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-25'::date, '20:00', 'Arizona Financial Theatre', '2026-10-22'::date, 'Published', 'concert-malcolm-todd-2026-10-25'
  where not exists (select 1 from events where series = 'concert-malcolm-todd-2026-10-25') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Chief Keef', 'music', 'Arizona Financial Theatre', 'Chief Keef live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-26'::date, '20:00', 'Arizona Financial Theatre', '2026-10-23'::date, 'Published', 'concert-chief-keef-2026-10-26'
  where not exists (select 1 from events where series = 'concert-chief-keef-2026-10-26') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Jodeci', 'music', 'Arizona Financial Theatre', 'Jodeci live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-30'::date, '20:00', 'Arizona Financial Theatre', '2026-10-27'::date, 'Published', 'concert-jodeci-2026-10-30'
  where not exists (select 1 from events where series = 'concert-jodeci-2026-10-30') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select '311', 'music', 'Arizona Financial Theatre', '311 live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-05'::date, '19:30', 'Arizona Financial Theatre', '2026-11-02'::date, 'Published', 'concert-311-2026-11-05'
  where not exists (select 1 from events where series = 'concert-311-2026-11-05') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Underoath', 'music', 'Arizona Financial Theatre', 'Underoath live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-09'::date, '18:30', 'Arizona Financial Theatre', '2026-11-06'::date, 'Published', 'concert-underoath-2026-11-09'
  where not exists (select 1 from events where series = 'concert-underoath-2026-11-09') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Jessie Reyez', 'music', 'Arizona Financial Theatre', 'Jessie Reyez live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-10'::date, '20:00', 'Arizona Financial Theatre', '2026-11-07'::date, 'Published', 'concert-jessie-reyez-2026-11-10'
  where not exists (select 1 from events where series = 'concert-jessie-reyez-2026-11-10') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Sabaton', 'music', 'Arizona Financial Theatre', 'Sabaton live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-11'::date, '19:00', 'Arizona Financial Theatre', '2026-11-08'::date, 'Published', 'concert-sabaton-2026-11-11'
  where not exists (select 1 from events where series = 'concert-sabaton-2026-11-11') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Duelo', 'music', 'Arizona Financial Theatre', 'Duelo live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-13'::date, '20:00', 'Arizona Financial Theatre', '2026-11-10'::date, 'Published', 'concert-duelo-2026-11-13'
  where not exists (select 1 from events where series = 'concert-duelo-2026-11-13') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Brand New', 'music', 'Arizona Financial Theatre', 'Brand New live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-14'::date, '20:00', 'Arizona Financial Theatre', '2026-11-11'::date, 'Published', 'concert-brand-new-2026-11-14'
  where not exists (select 1 from events where series = 'concert-brand-new-2026-11-14') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Steve Lacy', 'music', 'Arizona Financial Theatre', 'Steve Lacy live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-17'::date, '20:00', 'Arizona Financial Theatre', '2026-11-14'::date, 'Published', 'concert-steve-lacy-2026-11-17'
  where not exists (select 1 from events where series = 'concert-steve-lacy-2026-11-17') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Trivium', 'music', 'Arizona Financial Theatre', 'Trivium live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-02'::date, '18:30', 'Arizona Financial Theatre', '2026-11-29'::date, 'Published', 'concert-trivium-2026-12-02'
  where not exists (select 1 from events where series = 'concert-trivium-2026-12-02') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Pedro Fernández', 'music', 'Arizona Financial Theatre', 'Pedro Fernández live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-04'::date, '20:00', 'Arizona Financial Theatre', '2026-12-01'::date, 'Published', 'concert-pedro-fern-ndez-2026-12-04'
  where not exists (select 1 from events where series = 'concert-pedro-fern-ndez-2026-12-04') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Victoria Monét', 'music', 'Arizona Financial Theatre', 'Victoria Monét live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-05'::date, '20:00', 'Arizona Financial Theatre', '2026-12-02'::date, 'Published', 'concert-victoria-mon-t-2026-12-05'
  where not exists (select 1 from events where series = 'concert-victoria-mon-t-2026-12-05') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Udit Narayan', 'music', 'Arizona Financial Theatre', 'Udit Narayan live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-06'::date, '18:30', 'Arizona Financial Theatre', '2026-12-03'::date, 'Published', 'concert-udit-narayan-2026-12-06'
  where not exists (select 1 from events where series = 'concert-udit-narayan-2026-12-06') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Sam Barber', 'music', 'Arizona Financial Theatre', 'Sam Barber live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-11'::date, '19:00', 'Arizona Financial Theatre', '2026-12-08'::date, 'Published', 'concert-sam-barber-2026-12-11'
  where not exists (select 1 from events where series = 'concert-sam-barber-2026-12-11') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Tyla', 'music', 'Arizona Financial Theatre', 'Tyla live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-14'::date, '20:00', 'Arizona Financial Theatre', '2026-12-11'::date, 'Published', 'concert-tyla-2026-12-14'
  where not exists (select 1 from events where series = 'concert-tyla-2026-12-14') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'CeCe Winans', 'music', 'Arizona Financial Theatre', 'CeCe Winans live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-15'::date, '19:00', 'Arizona Financial Theatre', '2026-12-12'::date, 'Published', 'concert-cece-winans-2026-12-15'
  where not exists (select 1 from events where series = 'concert-cece-winans-2026-12-15') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Windwaker', 'music', 'Arizona Financial Theatre', 'Windwaker live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-16'::date, '18:30', 'Arizona Financial Theatre', '2026-12-13'::date, 'Published', 'concert-windwaker-2026-12-16'
  where not exists (select 1 from events where series = 'concert-windwaker-2026-12-16') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'The Piano Guys', 'music', 'Arizona Financial Theatre', 'The Piano Guys live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-20'::date, '19:30', 'Arizona Financial Theatre', '2027-01-17'::date, 'Published', 'concert-the-piano-guys-2027-01-20'
  where not exists (select 1 from events where series = 'concert-the-piano-guys-2027-01-20') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Polyphia', 'music', 'Arizona Financial Theatre', 'Polyphia live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-05'::date, '19:30', 'Arizona Financial Theatre', '2027-02-02'::date, 'Published', 'concert-polyphia-2027-02-05'
  where not exists (select 1 from events where series = 'concert-polyphia-2027-02-05') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Yuridia', 'music', 'Arizona Financial Theatre', 'Yuridia live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-13'::date, '20:00', 'Arizona Financial Theatre', '2027-02-10'::date, 'Published', 'concert-yuridia-2027-02-13'
  where not exists (select 1 from events where series = 'concert-yuridia-2027-02-13') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Carly Rae Jepsen', 'music', 'Arizona Financial Theatre', 'Carly Rae Jepsen live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-05-01'::date, '19:30', 'Arizona Financial Theatre', '2027-04-28'::date, 'Published', 'concert-carly-rae-jepsen-2027-05-01'
  where not exists (select 1 from events where series = 'concert-carly-rae-jepsen-2027-05-01') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Ha*Ash', 'music', 'Arizona Financial Theatre', 'Ha*Ash live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-05-08'::date, '20:00', 'Arizona Financial Theatre', '2027-05-05'::date, 'Published', 'concert-ha-ash-2027-05-08'
  where not exists (select 1 from events where series = 'concert-ha-ash-2027-05-08') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Leon Bridges', 'music', 'Arizona Financial Theatre', 'Leon Bridges live at Arizona Financial Theatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-09-29'::date, '19:30', 'Arizona Financial Theatre', '2027-09-26'::date, 'Published', 'concert-leon-bridges-2027-09-29'
  where not exists (select 1 from events where series = 'concert-leon-bridges-2027-09-29') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 10, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Harry Styles', 'music', 'State Farm Stadium', 'Harry Styles live at State Farm Stadium. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-04-02'::date, '19:45', 'State Farm Stadium', '2027-03-30'::date, 'Published', 'concert-harry-styles-2027-04-02'
  where not exists (select 1 from events where series = 'concert-harry-styles-2027-04-02') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 50, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Harry Styles', 'music', 'State Farm Stadium', 'Harry Styles live at State Farm Stadium. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-04-03'::date, '19:45', 'State Farm Stadium', '2027-03-31'::date, 'Published', 'concert-harry-styles-2027-04-03'
  where not exists (select 1 from events where series = 'concert-harry-styles-2027-04-03') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 50, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Hondo Rodeo Fest with Miranda Lambert', 'music', 'Chase Field', 'Hondo Rodeo Fest with Miranda Lambert live at Chase Field. A three-day rodeo and concert weekend, Nov 13–15. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-13'::date, '', 'Chase Field', '2026-11-10'::date, 'Published', 'concert-hondo-rodeo-fest-with-miranda-lambert-2026-11-13'
  where not exists (select 1 from events where series = 'concert-hondo-rodeo-fest-with-miranda-lambert-2026-11-13') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 50, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Slipknot', 'music', 'Chase Field', 'Slipknot live at Chase Field. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-08-18'::date, '18:00', 'Chase Field', '2027-08-15'::date, 'Published', 'concert-slipknot-2027-08-18'
  where not exists (select 1 from events where series = 'concert-slipknot-2027-08-18') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 50, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Dan + Shay', 'music', 'Talking Stick Resort Amphitheatre', 'Dan + Shay live at Talking Stick Resort Amphitheatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-05'::date, '18:00', 'Talking Stick Resort Amphitheatre', '2026-11-02'::date, 'Published', 'concert-dan-shay-2026-11-05'
  where not exists (select 1 from events where series = 'concert-dan-shay-2026-11-05') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Three Days Grace', 'music', 'Talking Stick Resort Amphitheatre', 'Three Days Grace live at Talking Stick Resort Amphitheatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-21'::date, '19:00', 'Talking Stick Resort Amphitheatre', '2026-11-18'::date, 'Published', 'concert-three-days-grace-2026-11-21'
  where not exists (select 1 from events where series = 'concert-three-days-grace-2026-11-21') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Iron Maiden', 'music', 'Talking Stick Resort Amphitheatre', 'Iron Maiden live at Talking Stick Resort Amphitheatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-04-26'::date, '18:30', 'Talking Stick Resort Amphitheatre', '2027-04-23'::date, 'Published', 'concert-iron-maiden-2027-04-26'
  where not exists (select 1 from events where series = 'concert-iron-maiden-2027-04-26') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Stick Figure', 'music', 'Talking Stick Resort Amphitheatre', 'Stick Figure live at Talking Stick Resort Amphitheatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-06-03'::date, '18:30', 'Talking Stick Resort Amphitheatre', '2027-05-31'::date, 'Published', 'concert-stick-figure-2027-06-03'
  where not exists (select 1 from events where series = 'concert-stick-figure-2027-06-03') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Matchbox Twenty', 'music', 'Talking Stick Resort Amphitheatre', 'Matchbox Twenty live at Talking Stick Resort Amphitheatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-06-12'::date, '19:30', 'Talking Stick Resort Amphitheatre', '2027-06-09'::date, 'Published', 'concert-matchbox-twenty-2027-06-12'
  where not exists (select 1 from events where series = 'concert-matchbox-twenty-2027-06-12') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'A Perfect Circle', 'music', 'Talking Stick Resort Amphitheatre', 'A Perfect Circle live at Talking Stick Resort Amphitheatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-06-13'::date, '19:30', 'Talking Stick Resort Amphitheatre', '2027-06-10'::date, 'Published', 'concert-a-perfect-circle-2027-06-13'
  where not exists (select 1 from events where series = 'concert-a-perfect-circle-2027-06-13') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 30, 2, 1)) as t(name, qty, points, seats, sort);

with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'Papa Roach', 'music', 'Talking Stick Resort Amphitheatre', 'Papa Roach live at Talking Stick Resort Amphitheatre. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-06-16'::date, '19:00', 'Talking Stick Resort Amphitheatre', '2027-06-13'::date, 'Published', 'concert-papa-roach-2027-06-16'
  where not exists (select 1 from events where series = 'concert-papa-roach-2027-06-16') returning id)
insert into ticket_types (event_id, name, qty, points, seats, sort) select e.id, t.* from e cross join (values
    ('Award (2 tickets)', 20, 30, 2, 1)) as t(name, qty, points, seats, sort);

-- 8. Banda MS moved to Sept 18, 2027 on the venue calendar; retire the old Nov 28, 2026 listing if it has no requests

update events e set status = 'Archived', updated_at = now() where e.title like 'Banda MS:%' and e.date = '2026-11-28' and e.series is null and not exists (select 1 from requests r where r.event_id = e.id);

commit;
