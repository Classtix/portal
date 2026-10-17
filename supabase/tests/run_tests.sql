-- Business-rule tests. Run: psql -v ON_ERROR_STOP=1 -f run_tests.sql (after stub + migrations).
\set QUIET on
create or replace function pg_temp.as_user(u uuid) returns void language plpgsql as $$
begin
  perform set_config('request.jwt.claim.sub', coalesce(u::text, ''), false);
  if u is null then execute 'set role service_role'; else execute 'set role authenticated'; end if;
end $$;
create or replace function pg_temp.ok(cond boolean, msg text) returns void language plpgsql as $$
begin if not coalesce(cond, false) then raise exception 'FAIL: %', msg; end if; raise notice 'ok - %', msg; end $$;
create or replace function pg_temp.fails(sql text, expect text, msg text) returns void language plpgsql as $$
begin
  begin execute sql; exception when others then
    if sqlerrm ilike '%' || expect || '%' then raise notice 'ok - % (%)', msg, sqlerrm; return; end if;
    raise exception 'FAIL: % — wrong error: %', msg, sqlerrm;
  end;
  raise exception 'FAIL: % — expected an error', msg;
end $$;

-- people
insert into auth.users (id, email) values
  ('00000000-0000-0000-0000-00000000000a', 'damian@classtix.org'),
  ('00000000-0000-0000-0000-00000000000b', 'maria@tempe.example'),
  ('00000000-0000-0000-0000-00000000000c', 'other@mesa.example');
insert into profiles (id, name, email, role, status) values ('00000000-0000-0000-0000-00000000000a', 'Damian', 'damian@classtix.org', 'admin', 'Active');

-- as admin: set up a second district and users
select pg_temp.as_user('00000000-0000-0000-0000-00000000000a');
select pg_temp.ok(is_admin(), 'admin recognised');
select create_district('Mesa Unified', 'az', 6000, 't1', 300, 'office@mesa.example') as mesa \gset
select id as tempe from districts where name = 'Tempe Union HSD' \gset
select admin_set_profile('00000000-0000-0000-0000-00000000000b', 'Maria', 'maria@tempe.example', 'district', :'tempe', 'Invited');
select admin_set_profile('00000000-0000-0000-0000-00000000000c', 'Ollie', 'other@mesa.example', 'district', :'mesa', 'Invited');
select pg_temp.ok((select count(*) from events where status = 'Published' and series is null) = 26, 'catalog seeded (26 published)');
select pg_temp.ok((select available(:'tempe')) = 4280, 'Tempe starts with 4,280');

-- a test event with a tight inventory
select save_event(jsonb_build_object('title','Suns test game','cat','sports','dated',true,
  'date', (az_today() + 20)::text, 'deadline', (az_today() + 10)::text, 'venue','Footprint Center','max_per_request', 8,
  'types', jsonb_build_array(jsonb_build_object('name','Upper','qty',10,'points',40,'seats',2)))) as ev \gset
select id as ty from ticket_types where event_id = :'ev' \gset

-- invited user can't act until they sign in
select pg_temp.as_user('00000000-0000-0000-0000-00000000000b');
select pg_temp.fails($$select submit_request('$$ || :'ty' || $$', 2, '')$$, 'linked to an active district', 'invited user blocked');
select touch_login();
select pg_temp.ok((select status from profiles where id = auth.uid()) = 'Active', 'first sign-in activates');
select pg_temp.as_user('00000000-0000-0000-0000-00000000000c'); select touch_login();

-- district rules
select pg_temp.as_user('00000000-0000-0000-0000-00000000000b');
select pg_temp.ok((select count(*) from districts) = 1, 'district sees only its own district');
select pg_temp.ok(available(:'mesa') is null, 'district cannot read another balance');
select pg_temp.fails($$select submit_request('$$ || :'ty' || $$', 9, '')$$, 'most you can request', 'per-request max enforced');
select pg_temp.fails($$select approve_request(gen_random_uuid())$$, 'Only ClassTix admins', 'district cannot approve');
select submit_request(:'ty', 6, 'Attendance winners, Lincoln') as code1 \gset
select pg_temp.ok(available(:'tempe') = 4280 - 240 and held(:'tempe') = 240, 'points held on submit');
select pg_temp.ok((select count(*) from outbox where kind = 'new') = 0, 'district cannot read outbox');

select pg_temp.as_user('00000000-0000-0000-0000-00000000000c');
select pg_temp.ok((select count(*) from requests) = 0, 'other district cannot see Tempe requests');
select pg_temp.fails($$select submit_request('$$ || :'ty' || $$', 8, '')$$, 'have', 'cannot overspend (300 pts < 320)');
select submit_request(:'ty', 7, '') as code2 \gset
select pg_temp.fails($$select cancel_request((select id from requests where code = '$$ || :'code1' || $$'))$$, 'not found', 'cannot touch another district''s request');

-- admin decisions
select pg_temp.as_user('00000000-0000-0000-0000-00000000000a');
select pg_temp.ok((select count(*) from outbox where kind = 'new') = 2, 'admins emailed for each new request');
select approve_request((select id from requests where code = :'code1'));
select pg_temp.ok((select approved from ticket_types where id = :'ty') = 6, 'inventory updated on approve');
select pg_temp.fails($$select approve_request((select id from requests where code = '$$ || :'code2' || $$'))$$, 'Only 4 left', 'no overselling');
select approve_request((select id from requests where code = :'code2'), 4);
select pg_temp.ok(available(:'mesa') = 300 - 160, 'partial approve releases unused points');
select pg_temp.ok((select approved from ticket_types where id = :'ty') = 10, 'sold out');
select fulfil_request((select id from requests where code = :'code1'));
select set_internal_note((select id from requests where code = :'code1'), 'sent via Ticketmaster');
select pg_temp.fails($$select save_event(jsonb_build_object('id','$$ || :'ev' || $$','title','Suns test game','dated',true,'date','$$ || (current_date + 20)::text || $$','types',jsonb_build_array(jsonb_build_object('id','$$ || :'ty' || $$','name','Upper','qty',5,'points',40))))$$, 'Quantity can''t go below', 'quantity floor = approved');

-- district can't see internal notes
select pg_temp.as_user('00000000-0000-0000-0000-00000000000b');
select pg_temp.ok((select count(*) from request_notes) = 0, 'internal notes hidden from districts');

-- date change notifies, cancel refunds approved-unsent, keeps fulfilled
select pg_temp.as_user('00000000-0000-0000-0000-00000000000a');
select save_event(jsonb_build_object('id', :'ev', 'title','Suns test game','cat','sports','dated',true,
  'date', (az_today() + 21)::text, 'deadline', (az_today() + 10)::text, 'venue','Footprint Center',
  'types', jsonb_build_array(jsonb_build_object('id', :'ty', 'name','Upper','qty',10,'points',40,'seats',2))));
select pg_temp.ok((select count(*) from outbox where kind = 'changed') = 2, 'both districts told about the date change');
select cancel_event(:'ev');
select pg_temp.ok(available(:'mesa') = 300, 'event cancel refunds approved, unsent request');
select pg_temp.ok(available(:'tempe') = 4280 - 240, 'fulfilled request stays spent');
select pg_temp.ok((select approved from ticket_types where id = :'ty') = 6, 'inventory released for cancelled approval');

-- reject + adjust
select save_event(jsonb_build_object('title','Gift card','cat','retail','dated',false,
  'types', jsonb_build_array(jsonb_build_object('name','Target $50','qty',3,'points',25)))) as gc \gset
select pg_temp.as_user('00000000-0000-0000-0000-00000000000b');
select submit_request((select id from ticket_types where event_id = :'gc'), 2, '') as code3 \gset
select pg_temp.as_user('00000000-0000-0000-0000-00000000000a');
select pg_temp.fails($$select reject_request((select id from requests where code = '$$ || :'code3' || $$'), ' ')$$, 'reason', 'reject needs a reason');
select reject_request((select id from requests where code = :'code3'), 'Not enough tickets left');
select adjust_points(:'tempe', -40, 'Correction');
select pg_temp.ok(available(:'tempe') = 4280 - 240 - 40, 'reject releases, adjustment applies');

-- monthly reset: holds survive, unused expire, tier change applies
select pg_temp.as_user('00000000-0000-0000-0000-00000000000b');
select submit_request((select id from ticket_types where event_id = :'gc'), 1, '') as code4 \gset
select pg_temp.as_user('00000000-0000-0000-0000-00000000000a');
select update_district(:'tempe', null, null, null, 5000, 't1');
select pg_temp.fails('select run_monthly_reset()', 'hasn''t started', 'cannot start next month early');
reset role;
update settings set current_month = to_char((az_today() - interval '1 month'), 'YYYY-MM');
select pg_temp.as_user(null);
select cron_tick() as tick \gset
\echo :tick
select pg_temp.ok((select current_month from settings) = az_month(), 'cron caught up to this month');
select pg_temp.ok(available('00000000-0000-0000-0000-000000000000'::uuid) = 0, 'service role can read balances');
select pg_temp.ok(available(:'tempe') = 5000, 'unused expired, new allocation credited');
select pg_temp.ok(held(:'tempe') = 25, 'pending hold survives the reset');
select pg_temp.ok((select tier from districts where id = :'tempe') = 't1' and (select next_tier from districts where id = :'tempe') is null, 'tier change applied');
select pg_temp.ok((select count(*) from outbox where kind = 'reset') = 2, 'reset email per district');
select pg_temp.ok((select count(*) from events where series = 'retail' and date >= az_today()) >= 2, 'retail drops scheduled');
select pg_temp.ok((select count(*) from ticket_types t join events e on e.id = t.event_id where e.series = 'retail' group by e.id limit 1) = 14, '7 retailers × 2 values per drop');
select cron_tick() as tick2 \gset
select pg_temp.ok((:'tick2'::jsonb->>'retail_drops_added')::int = 0, 'cron is idempotent');

-- reject after reset returns points to the new month
select pg_temp.as_user('00000000-0000-0000-0000-00000000000a');
select reject_request((select id from requests where code = :'code4'), 'Other');
select pg_temp.ok(available(:'tempe') = 5000 + 25, 'hold released into the new month');

-- deactivate district
select set_district_status(:'mesa', 'Inactive');
select pg_temp.as_user('00000000-0000-0000-0000-00000000000c');
select pg_temp.ok(my_district() is null and (select count(*) from districts) = 0, 'deactivated district loses access');

-- anon sees nothing
reset role; set role anon;
select pg_temp.fails('select count(*) from districts', 'permission denied', 'anonymous visitors blocked');
reset role;
\echo ALL TESTS PASSED
