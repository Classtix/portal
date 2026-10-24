-- ClassTix — ASU Athletics: keep weekday (Mon–Fri) games only when they start between 5:00 PM and 8:00 PM.
-- Archives weekday ASU games that start before 5:00 PM or after 8:00 PM. Weekend games are untouched.
-- Games with no start time yet ("to be announced") are kept; check them once ASU posts times.
-- Safe to run more than once. Run in the Supabase SQL editor.
begin;

update events set status = 'Archived', updated_at = now()
where series like 'asu-%'
  and status = 'Published'
  and date is not null
  and extract(isodow from date) between 1 and 5
  and coalesce(time, '') ~ '^\d{1,2}:\d{2}'
  and (time::time < time '17:00' or time::time > time '20:00');

commit;

-- What's left for weekday ASU games, by start time:
select coalesce(nullif(time, ''), 'TBA') as start_time, count(*) as weekday_games
from events where series like 'asu-%' and status = 'Published' and extract(isodow from date) between 1 and 5
group by 1 order by 1;

-- Open requests on games that were just archived (handle in Requests):
select r.code, d.name as district, e.title, e.date, r.status
from requests r join events e on e.id = r.event_id join districts d on d.id = r.district_id
where e.series like 'asu-%' and e.status = 'Archived' and r.status in ('Pending', 'Approved');
