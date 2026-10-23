-- ClassTix — add a $250 option (125 points) to every gift card, retail and restaurant.
-- Safe to run more than once. Run in the Supabase SQL editor.
begin;

insert into ticket_types (event_id, name, qty, points, seats, sort)
select e.id, '$250 gift card', 10, 125, 1, 3
from events e
where e.series ~ '^(giftcard|restaurantcard)-'
  and not exists (select 1 from ticket_types t where t.event_id = e.id and t.name = '$250 gift card');

update events set description = replace(description, 'Pick $50 or $100.', 'Pick $50, $100 or $250.'), updated_at = now()
where series ~ '^(giftcard|restaurantcard)-' and description like '%Pick $50 or $100.%';

commit;

select e.title, string_agg(t.name || ' = ' || t.points || ' pts', ', ' order by t.sort) as options
from events e join ticket_types t on t.event_id = e.id
where e.series ~ '^(giftcard|restaurantcard)-' group by e.title order by e.title;
