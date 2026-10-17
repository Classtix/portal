-- ASU Sun Devils home games for the ClassTix portal (source: sundevils.com schedule feed, pulled Oct 17, 2026).
-- Paste into Supabase → SQL Editor → New query → Run. Safe to run again: games already added are skipped.
begin;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. Central Arizona', 'sports', 'ASU Athletics', 'Arizona State baseball home game against Central Arizona at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-21'::date, '13:00', 'Phoenix Municipal Stadium', '2026-10-18'::date, 'Published', 'asu-1172526'
  where not exists (select 1 from events where series = 'asu-1172526') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. Pima CC', 'sports', 'ASU Athletics', 'Arizona State softball home game against Pima CC at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-21'::date, '18:30', 'Alberta B. Farrington Stadium', '2026-10-18'::date, 'Published', 'asu-1091526'
  where not exists (select 1 from events where series = 'asu-1091526') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Soccer vs. Baylor', 'sports', 'ASU Athletics', 'Arizona State soccer home game against Baylor at Sun Devil Soccer Stadium, 655 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-22'::date, '19:00', 'Sun Devil Soccer Stadium', '2026-10-19'::date, 'Published', 'asu-348926'
  where not exists (select 1 from events where series = 'asu-348926') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Football vs. Kansas State', 'sports', 'ASU Athletics', 'Arizona State football home game against Kansas State at Mountain America Stadium, 500 E Veterans Way, Tempe, AZ 85287. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2026-10-24'::date, '', 'Mountain America Stadium', '2026-10-21'::date, 'Published', 'asu-347176'
  where not exists (select 1 from events where series = 'asu-347176') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 20, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Soccer vs. Colorado', 'sports', 'ASU Athletics', 'Arizona State soccer home game against Colorado at Sun Devil Soccer Stadium, 655 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-25'::date, '13:00', 'Sun Devil Soccer Stadium', '2026-10-22'::date, 'Published', 'asu-348946'
  where not exists (select 1 from events where series = 'asu-348946') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. South Mountain', 'sports', 'ASU Athletics', 'Arizona State baseball home game against South Mountain at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-28'::date, '13:00', 'Phoenix Municipal Stadium', '2026-10-25'::date, 'Published', 'asu-1172531'
  where not exists (select 1 from events where series = 'asu-1172531') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Soccer vs. Arizona', 'sports', 'ASU Athletics', 'Arizona State soccer home game against Arizona at Sun Devil Soccer Stadium, 655 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-30'::date, '19:00', 'Sun Devil Soccer Stadium', '2026-10-27'::date, 'Published', 'asu-348931'
  where not exists (select 1 from events where series = 'asu-348931') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Volleyball vs. UCF', 'sports', 'ASU Athletics', 'Arizona State volleyball home game against UCF at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-10-30'::date, '19:00', 'Desert Financial Arena', '2026-10-27'::date, 'Published', 'asu-352021'
  where not exists (select 1 from events where series = 'asu-352021') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Volleyball vs. Houston', 'sports', 'ASU Athletics', 'Arizona State volleyball home game against Houston at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-01'::date, '13:00', 'Desert Financial Arena', '2026-10-29'::date, 'Published', 'asu-352026'
  where not exists (select 1 from events where series = 'asu-352026') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Jackson State', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Jackson State at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-02'::date, '17:00', 'Desert Financial Arena', '2026-10-30'::date, 'Published', 'asu-354081'
  where not exists (select 1 from events where series = 'asu-354081') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. East Tennessee State', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against East Tennessee State at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-02'::date, '20:00', 'Desert Financial Arena', '2026-10-30'::date, 'Published', 'asu-1026076'
  where not exists (select 1 from events where series = 'asu-1026076') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Northern Arizona', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Northern Arizona at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-05'::date, '18:30', 'Desert Financial Arena', '2026-11-02'::date, 'Published', 'asu-354086'
  where not exists (select 1 from events where series = 'asu-354086') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Denver', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Denver at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-06'::date, '19:00', 'Mullett Arena', '2026-11-03'::date, 'Published', 'asu-352506'
  where not exists (select 1 from events where series = 'asu-352506') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Northern Colorado', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Northern Colorado at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-06'::date, '19:00', 'Desert Financial Arena', '2026-11-03'::date, 'Published', 'asu-1026081'
  where not exists (select 1 from events where series = 'asu-1026081') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Football vs. Colorado', 'sports', 'ASU Athletics', 'Arizona State football home game against Colorado at Mountain America Stadium, 500 E Veterans Way, Tempe, AZ 85287. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2026-11-07'::date, '', 'Mountain America Stadium', '2026-11-04'::date, 'Published', 'asu-347186'
  where not exists (select 1 from events where series = 'asu-347186') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 20, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Denver', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Denver at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-08'::date, '12:00', 'Mullett Arena', '2026-11-05'::date, 'Published', 'asu-352511'
  where not exists (select 1 from events where series = 'asu-352511') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Volleyball vs. Utah', 'sports', 'ASU Athletics', 'Arizona State volleyball home game against Utah at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-08'::date, '13:00', 'Desert Financial Arena', '2026-11-05'::date, 'Published', 'asu-352036'
  where not exists (select 1 from events where series = 'asu-352036') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Hofstra', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Hofstra at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-10'::date, '19:00', 'Desert Financial Arena', '2026-11-07'::date, 'Published', 'asu-1026086'
  where not exists (select 1 from events where series = 'asu-1026086') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. ULM', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against ULM at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-13'::date, '19:00', 'Desert Financial Arena', '2026-11-10'::date, 'Published', 'asu-1026091'
  where not exists (select 1 from events where series = 'asu-1026091') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Wrestling vs. Sun Devil Invitational vs. ACU/Hope International/Embry RIddle', 'sports', 'ASU Athletics', 'Arizona State wrestling home game against Sun Devil Invitational vs. ACU/Hope International/Embry RIddle at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-14'::date, '11:00', 'Desert Financial Arena', '2026-11-11'::date, 'Published', 'asu-1329481'
  where not exists (select 1 from events where series = 'asu-1329481') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Penn State', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Penn State at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-15'::date, '14:00', 'Desert Financial Arena', '2026-11-12'::date, 'Published', 'asu-354096'
  where not exists (select 1 from events where series = 'asu-354096') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. San Diego', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against San Diego at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-17'::date, '18:30', 'Desert Financial Arena', '2026-11-14'::date, 'Published', 'asu-354101'
  where not exists (select 1 from events where series = 'asu-354101') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Oakland', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Oakland at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-18'::date, '19:00', 'Desert Financial Arena', '2026-11-15'::date, 'Published', 'asu-1026096'
  where not exists (select 1 from events where series = 'asu-1026096') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Wrestling vs. #2 Oklahoma St.', 'sports', 'ASU Athletics', 'Arizona State wrestling home game against #2 Oklahoma St. at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-20'::date, '18:00', 'Desert Financial Arena', '2026-11-17'::date, 'Published', 'asu-1222526'
  where not exists (select 1 from events where series = 'asu-1222526') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Santa Clara', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Santa Clara at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-20'::date, '18:30', 'Mullett Arena', '2026-11-17'::date, 'Published', 'asu-354106'
  where not exists (select 1 from events where series = 'asu-354106') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Football vs. Oklahoma State', 'sports', 'ASU Athletics', 'Arizona State football home game against Oklahoma State at Mountain America Stadium, 500 E Veterans Way, Tempe, AZ 85287. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2026-11-21'::date, '', 'Mountain America Stadium', '2026-11-18'::date, 'Published', 'asu-347196'
  where not exists (select 1 from events where series = 'asu-347196') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 20, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. San Jose State', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against San Jose State at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-24'::date, '18:30', 'Desert Financial Arena', '2026-11-21'::date, 'Published', 'asu-354111'
  where not exists (select 1 from events where series = 'asu-354111') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Volleyball vs. Kansas St.', 'sports', 'ASU Athletics', 'Arizona State volleyball home game against Kansas St. at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-25'::date, '19:00', 'Desert Financial Arena', '2026-11-22'::date, 'Published', 'asu-352056'
  where not exists (select 1 from events where series = 'asu-352056') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Volleyball vs. Kansas', 'sports', 'ASU Athletics', 'Arizona State volleyball home game against Kansas at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-27'::date, '19:00', 'Desert Financial Arena', '2026-11-24'::date, 'Published', 'asu-352061'
  where not exists (select 1 from events where series = 'asu-352061') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Alaska Anchorage', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Alaska Anchorage at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-27'::date, '19:00', 'Mullett Arena', '2026-11-24'::date, 'Published', 'asu-353581'
  where not exists (select 1 from events where series = 'asu-353581') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. CSU Bakersfield', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against CSU Bakersfield at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-28'::date, '14:30', 'Desert Financial Arena', '2026-11-25'::date, 'Published', 'asu-354116'
  where not exists (select 1 from events where series = 'asu-354116') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Alaska Anchorage', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Alaska Anchorage at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-28'::date, '17:00', 'Mullett Arena', '2026-11-25'::date, 'Published', 'asu-353586'
  where not exists (select 1 from events where series = 'asu-353586') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Wake Forest', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Wake Forest at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-29'::date, '12:30', 'Desert Financial Arena', '2026-11-26'::date, 'Published', 'asu-354121'
  where not exists (select 1 from events where series = 'asu-354121') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Montana', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Montana at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-11-30'::date, '19:00', 'Desert Financial Arena', '2026-11-27'::date, 'Published', 'asu-1026111'
  where not exists (select 1 from events where series = 'asu-1026111') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Colorado College', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Colorado College at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-04'::date, '19:00', 'Mullett Arena', '2026-12-01'::date, 'Published', 'asu-352526'
  where not exists (select 1 from events where series = 'asu-352526') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Colorado College', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Colorado College at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-05'::date, '17:00', 'Mullett Arena', '2026-12-02'::date, 'Published', 'asu-352531'
  where not exists (select 1 from events where series = 'asu-352531') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Gonzaga', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Gonzaga at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-06'::date, '14:00', 'Mullett Arena', '2026-12-03'::date, 'Published', 'asu-354126'
  where not exists (select 1 from events where series = 'asu-354126') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. University of Texas Rio Grande Valley', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against University of Texas Rio Grande Valley at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-08'::date, '17:00', 'Desert Financial Arena', '2026-12-05'::date, 'Published', 'asu-354131'
  where not exists (select 1 from events where series = 'asu-354131') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Mercer', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Mercer at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-08'::date, '20:00', 'Desert Financial Arena', '2026-12-05'::date, 'Published', 'asu-1026121'
  where not exists (select 1 from events where series = 'asu-1026121') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Western Michigan', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Western Michigan at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-11'::date, '19:00', 'Mullett Arena', '2026-12-08'::date, 'Published', 'asu-352536'
  where not exists (select 1 from events where series = 'asu-352536') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Western Michigan', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Western Michigan at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-12'::date, '17:00', 'Mullett Arena', '2026-12-09'::date, 'Published', 'asu-352541'
  where not exists (select 1 from events where series = 'asu-352541') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. San Diego', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against San Diego at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-20'::date, '17:00', 'Desert Financial Arena', '2026-12-17'::date, 'Published', 'asu-1026131'
  where not exists (select 1 from events where series = 'asu-1026131') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Utah', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Utah at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-21'::date, '13:00', 'Desert Financial Arena', '2026-12-18'::date, 'Published', 'asu-1171446'
  where not exists (select 1 from events where series = 'asu-1171446') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Wrestling vs. Wisconsin', 'sports', 'ASU Athletics', 'Arizona State wrestling home game against Wisconsin at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-21'::date, '19:00', 'Desert Financial Arena', '2026-12-18'::date, 'Published', 'asu-1329486'
  where not exists (select 1 from events where series = 'asu-1329486') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Idaho', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Idaho at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-23'::date, '18:00', 'Desert Financial Arena', '2026-12-20'::date, 'Published', 'asu-1026136'
  where not exists (select 1 from events where series = 'asu-1026136') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Southern Illinois', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Southern Illinois at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2026-12-29'::date, '19:00', 'Desert Financial Arena', '2026-12-26'::date, 'Published', 'asu-1026141'
  where not exists (select 1 from events where series = 'asu-1026141') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. BYU', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against BYU at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-02'::date, '20:00', 'Desert Financial Arena', '2026-12-30'::date, 'Published', 'asu-1171456'
  where not exists (select 1 from events where series = 'asu-1171456') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Iowa State', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Iowa State at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-06'::date, '18:30', 'Desert Financial Arena', '2027-01-03'::date, 'Published', 'asu-1171471'
  where not exists (select 1 from events where series = 'asu-1171471') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. UCF', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against UCF at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-09'::date, '14:00', 'Desert Financial Arena', '2027-01-06'::date, 'Published', 'asu-1171476'
  where not exists (select 1 from events where series = 'asu-1171476') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Minnesota Duluth', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Minnesota Duluth at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-15'::date, '19:00', 'Mullett Arena', '2027-01-12'::date, 'Published', 'asu-352566'
  where not exists (select 1 from events where series = 'asu-352566') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Texas Tech', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Texas Tech at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-16'::date, '14:00', 'Desert Financial Arena', '2027-01-13'::date, 'Published', 'asu-1171496'
  where not exists (select 1 from events where series = 'asu-1171496') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Minnesota Duluth', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Minnesota Duluth at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-16'::date, '17:00', 'Mullett Arena', '2027-01-13'::date, 'Published', 'asu-352571'
  where not exists (select 1 from events where series = 'asu-352571') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Wrestling vs. Oklahoma', 'sports', 'ASU Athletics', 'Arizona State wrestling home game against Oklahoma at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-17'::date, '13:00', 'Desert Financial Arena', '2027-01-14'::date, 'Published', 'asu-1329431'
  where not exists (select 1 from events where series = 'asu-1329431') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Kansas State', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Kansas State at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-19'::date, '18:00', 'Desert Financial Arena', '2027-01-16'::date, 'Published', 'asu-1171501'
  where not exists (select 1 from events where series = 'asu-1171501') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. TCU', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against TCU at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-20'::date, '17:00', 'Desert Financial Arena', '2027-01-17'::date, 'Published', 'asu-1171506'
  where not exists (select 1 from events where series = 'asu-1171506') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Houston', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Houston at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-23'::date, '18:00', 'Desert Financial Arena', '2027-01-20'::date, 'Published', 'asu-1171511'
  where not exists (select 1 from events where series = 'asu-1171511') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Arizona', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Arizona at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-30'::date, '14:00', 'Desert Financial Arena', '2027-01-27'::date, 'Published', 'asu-1171536'
  where not exists (select 1 from events where series = 'asu-1171536') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Wrestling vs. Utah Valley', 'sports', 'ASU Athletics', 'Arizona State wrestling home game against Utah Valley at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-01-30'::date, '19:00', 'Desert Financial Arena', '2027-01-27'::date, 'Published', 'asu-1329441'
  where not exists (select 1 from events where series = 'asu-1329441') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. West Virginia', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against West Virginia at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-03'::date, '20:00', 'Desert Financial Arena', '2027-01-31'::date, 'Published', 'asu-1171541'
  where not exists (select 1 from events where series = 'asu-1171541') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. TCU', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against TCU at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-06'::date, '17:00', 'Desert Financial Arena', '2027-02-03'::date, 'Published', 'asu-1171546'
  where not exists (select 1 from events where series = 'asu-1171546') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Wrestling vs. Northern Iowa', 'sports', 'ASU Athletics', 'Arizona State wrestling home game against Northern Iowa at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-07'::date, '13:00', 'Desert Financial Arena', '2027-02-04'::date, 'Published', 'asu-1329446'
  where not exists (select 1 from events where series = 'asu-1329446') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. North Dakota', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against North Dakota at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-12'::date, '19:00', 'Mullett Arena', '2027-02-09'::date, 'Published', 'asu-352596'
  where not exists (select 1 from events where series = 'asu-352596') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Cincinnati', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Cincinnati at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-13'::date, '12:30', 'Desert Financial Arena', '2027-02-10'::date, 'Published', 'asu-1171571'
  where not exists (select 1 from events where series = 'asu-1171571') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. North Dakota', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against North Dakota at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-13'::date, '17:00', 'Mullett Arena', '2027-02-10'::date, 'Published', 'asu-352601'
  where not exists (select 1 from events where series = 'asu-352601') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Arizona', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Arizona at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-13'::date, '18:00', 'Desert Financial Arena', '2027-02-10'::date, 'Published', 'asu-1171566'
  where not exists (select 1 from events where series = 'asu-1171566') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Baylor', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Baylor at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-16'::date, '20:00', 'Desert Financial Arena', '2027-02-13'::date, 'Published', 'asu-1171731'
  where not exists (select 1 from events where series = 'asu-1171731') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Iowa State', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Iowa State at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-19'::date, '20:00', 'Desert Financial Arena', '2027-02-16'::date, 'Published', 'asu-1171736'
  where not exists (select 1 from events where series = 'asu-1171736') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Utah', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Utah at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-23'::date, '21:00', 'Desert Financial Arena', '2027-02-20'::date, 'Published', 'asu-1171821'
  where not exists (select 1 from events where series = 'asu-1171821') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Women''s Basketball vs. Colorado', 'sports', 'ASU Athletics', 'Arizona State women''s basketball home game against Colorado at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-24'::date, '18:30', 'Desert Financial Arena', '2027-02-21'::date, 'Published', 'asu-1171826'
  where not exists (select 1 from events where series = 'asu-1171826') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Omaha', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Omaha at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-26'::date, '19:00', 'Mullett Arena', '2027-02-23'::date, 'Published', 'asu-352616'
  where not exists (select 1 from events where series = 'asu-352616') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Ice Hockey vs. Omaha', 'sports', 'ASU Athletics', 'Arizona State ice hockey home game against Omaha at Mullett Arena, 411 S Packard Dr, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-02-27'::date, '17:00', 'Mullett Arena', '2027-02-24'::date, 'Published', 'asu-352621'
  where not exists (select 1 from events where series = 'asu-352621') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 10, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Men''s Basketball vs. Baylor', 'sports', 'ASU Athletics', 'Arizona State men''s basketball home game against Baylor at Desert Financial Arena, 600 E Veterans Way, Tempe, AZ 85281. Each award is 2 tickets: a student plus a parent or chaperone.', true, '2027-03-02'::date, '20:30', 'Desert Financial Arena', '2027-02-27'::date, 'Published', 'asu-1171841'
  where not exists (select 1 from events where series = 'asu-1171841') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. BYU', 'sports', 'ASU Athletics', 'Arizona State softball home game against BYU at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-03-11'::date, '', 'Alberta B. Farrington Stadium', '2027-03-08'::date, 'Published', 'asu-905031'
  where not exists (select 1 from events where series = 'asu-905031') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. BYU', 'sports', 'ASU Athletics', 'Arizona State softball home game against BYU at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-03-12'::date, '', 'Alberta B. Farrington Stadium', '2027-03-09'::date, 'Published', 'asu-905036'
  where not exists (select 1 from events where series = 'asu-905036') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. BYU', 'sports', 'ASU Athletics', 'Arizona State softball home game against BYU at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-03-13'::date, '', 'Alberta B. Farrington Stadium', '2027-03-10'::date, 'Published', 'asu-905041'
  where not exists (select 1 from events where series = 'asu-905041') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. UCF', 'sports', 'ASU Athletics', 'Arizona State baseball home game against UCF at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-03-25'::date, '', 'Phoenix Municipal Stadium', '2027-03-22'::date, 'Published', 'asu-906161'
  where not exists (select 1 from events where series = 'asu-906161') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. Arizona', 'sports', 'ASU Athletics', 'Arizona State softball home game against Arizona at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-03-26'::date, '', 'Alberta B. Farrington Stadium', '2027-03-23'::date, 'Published', 'asu-905061'
  where not exists (select 1 from events where series = 'asu-905061') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. UCF', 'sports', 'ASU Athletics', 'Arizona State baseball home game against UCF at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-03-26'::date, '', 'Phoenix Municipal Stadium', '2027-03-23'::date, 'Published', 'asu-906166'
  where not exists (select 1 from events where series = 'asu-906166') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. Arizona', 'sports', 'ASU Athletics', 'Arizona State softball home game against Arizona at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-03-27'::date, '', 'Alberta B. Farrington Stadium', '2027-03-24'::date, 'Published', 'asu-905066'
  where not exists (select 1 from events where series = 'asu-905066') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. UCF', 'sports', 'ASU Athletics', 'Arizona State baseball home game against UCF at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-03-27'::date, '', 'Phoenix Municipal Stadium', '2027-03-24'::date, 'Published', 'asu-906171'
  where not exists (select 1 from events where series = 'asu-906171') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. Arizona', 'sports', 'ASU Athletics', 'Arizona State softball home game against Arizona at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-03-28'::date, '', 'Alberta B. Farrington Stadium', '2027-03-25'::date, 'Published', 'asu-905071'
  where not exists (select 1 from events where series = 'asu-905071') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. Kansas St.', 'sports', 'ASU Athletics', 'Arizona State baseball home game against Kansas St. at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-02'::date, '', 'Phoenix Municipal Stadium', '2027-03-30'::date, 'Published', 'asu-906266'
  where not exists (select 1 from events where series = 'asu-906266') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. Kansas St.', 'sports', 'ASU Athletics', 'Arizona State baseball home game against Kansas St. at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-03'::date, '', 'Phoenix Municipal Stadium', '2027-03-31'::date, 'Published', 'asu-906271'
  where not exists (select 1 from events where series = 'asu-906271') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. Kansas St.', 'sports', 'ASU Athletics', 'Arizona State baseball home game against Kansas St. at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-04'::date, '', 'Phoenix Municipal Stadium', '2027-04-01'::date, 'Published', 'asu-906276'
  where not exists (select 1 from events where series = 'asu-906276') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. Houston', 'sports', 'ASU Athletics', 'Arizona State softball home game against Houston at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-09'::date, '', 'Alberta B. Farrington Stadium', '2027-04-06'::date, 'Published', 'asu-905181'
  where not exists (select 1 from events where series = 'asu-905181') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. Houston', 'sports', 'ASU Athletics', 'Arizona State softball home game against Houston at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-10'::date, '', 'Alberta B. Farrington Stadium', '2027-04-07'::date, 'Published', 'asu-905186'
  where not exists (select 1 from events where series = 'asu-905186') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. Houston', 'sports', 'ASU Athletics', 'Arizona State softball home game against Houston at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-11'::date, '', 'Alberta B. Farrington Stadium', '2027-04-08'::date, 'Published', 'asu-905191'
  where not exists (select 1 from events where series = 'asu-905191') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. Arizona', 'sports', 'ASU Athletics', 'Arizona State baseball home game against Arizona at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-16'::date, '', 'Phoenix Municipal Stadium', '2027-04-13'::date, 'Published', 'asu-906476'
  where not exists (select 1 from events where series = 'asu-906476') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. Arizona', 'sports', 'ASU Athletics', 'Arizona State baseball home game against Arizona at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-17'::date, '', 'Phoenix Municipal Stadium', '2027-04-14'::date, 'Published', 'asu-906481'
  where not exists (select 1 from events where series = 'asu-906481') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. Arizona', 'sports', 'ASU Athletics', 'Arizona State baseball home game against Arizona at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-18'::date, '', 'Phoenix Municipal Stadium', '2027-04-15'::date, 'Published', 'asu-906486'
  where not exists (select 1 from events where series = 'asu-906486') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. Iowa State', 'sports', 'ASU Athletics', 'Arizona State softball home game against Iowa State at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-23'::date, '', 'Alberta B. Farrington Stadium', '2027-04-20'::date, 'Published', 'asu-905211'
  where not exists (select 1 from events where series = 'asu-905211') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. Iowa State', 'sports', 'ASU Athletics', 'Arizona State softball home game against Iowa State at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-24'::date, '', 'Alberta B. Farrington Stadium', '2027-04-21'::date, 'Published', 'asu-905216'
  where not exists (select 1 from events where series = 'asu-905216') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Softball vs. Iowa State', 'sports', 'ASU Athletics', 'Arizona State softball home game against Iowa State at Alberta B. Farrington Stadium, 510 S Athletes Pl, Tempe, AZ 85288. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-04-25'::date, '', 'Alberta B. Farrington Stadium', '2027-04-22'::date, 'Published', 'asu-905221'
  where not exists (select 1 from events where series = 'asu-905221') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. Houston', 'sports', 'ASU Athletics', 'Arizona State baseball home game against Houston at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-05-07'::date, '', 'Phoenix Municipal Stadium', '2027-05-04'::date, 'Published', 'asu-906611'
  where not exists (select 1 from events where series = 'asu-906611') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. Houston', 'sports', 'ASU Athletics', 'Arizona State baseball home game against Houston at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-05-08'::date, '', 'Phoenix Municipal Stadium', '2027-05-05'::date, 'Published', 'asu-906616'
  where not exists (select 1 from events where series = 'asu-906616') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. Houston', 'sports', 'ASU Athletics', 'Arizona State baseball home game against Houston at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-05-09'::date, '', 'Phoenix Municipal Stadium', '2027-05-06'::date, 'Published', 'asu-906621'
  where not exists (select 1 from events where series = 'asu-906621') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. BYU', 'sports', 'ASU Athletics', 'Arizona State baseball home game against BYU at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-05-20'::date, '', 'Phoenix Municipal Stadium', '2027-05-17'::date, 'Published', 'asu-906651'
  where not exists (select 1 from events where series = 'asu-906651') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. BYU', 'sports', 'ASU Athletics', 'Arizona State baseball home game against BYU at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-05-21'::date, '', 'Phoenix Municipal Stadium', '2027-05-18'::date, 'Published', 'asu-906641'
  where not exists (select 1 from events where series = 'asu-906641') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
with e as (insert into events (title, cat, partner, description, dated, date, time, venue, deadline, status, series)
  select 'ASU Baseball vs. BYU', 'sports', 'ASU Athletics', 'Arizona State baseball home game against BYU at Phoenix Municipal Stadium, 5999 E Van Buren St, Phoenix, AZ. Each award is 2 tickets: a student plus a parent or chaperone. Start time to be announced by ASU.', true, '2027-05-22'::date, '', 'Phoenix Municipal Stadium', '2027-05-19'::date, 'Published', 'asu-906646'
  where not exists (select 1 from events where series = 'asu-906646') returning id)
insert into ticket_types (event_id, name, qty, points, seats) select id, 'Award (2 tickets)', 20, 10, 2 from e;
-- The dated games replace the old 'anytime' ASU listings. Archived, not deleted: restore them under Events & items → Archived.
update events set status = 'Archived', updated_at = now() where series is null and title in ('Sun Devil football','Sun Devil basketball') and status = 'Published';
commit;
