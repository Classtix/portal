-- ClassTix — Restaurant & Retail clean-up (Oct 2026)
-- 1. The Cheesecake Factory gift card moves from "Gift cards" to "Restaurants" (still a $50 / $100 card).
-- 2. "Dinner for two, local Tempe restaurant" is archived, so districts no longer see it.
-- Safe to run more than once. Run in the Supabase SQL editor.
begin;

update events
set series = 'restaurantcard-the-cheesecake-factory',
    description = 'The Cheesecake Factory gift card for a family dinner, delivered digitally. Pick $50 or $100.'
where series = 'giftcard-the-cheesecake-factory';

update events set status = 'Archived', updated_at = now()
where title = 'Dinner for two, local Tempe restaurant' and status in ('Published', 'Draft');

commit;

-- Any requests still open for the archived dinner (handle them in Requests; usually none):
select r.code, d.name as district, r.qty, r.status
from requests r join events e on e.id = r.event_id join districts d on d.id = r.district_id
where e.title = 'Dinner for two, local Tempe restaurant' and r.status in ('Pending', 'Approved');
