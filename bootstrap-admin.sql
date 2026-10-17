-- Make your first ClassTix Admin (run once).
-- 1. Supabase → Authentication → Users → Add user → "Create new user":
--    email = the address you'll sign in with, set a password, tick "Auto Confirm User".
-- 2. Change the email and name below to match, then run this in the SQL editor.
insert into public.profiles (id, name, email, role, status)
select id, 'Damian Perez', email, 'admin', 'Active'
from auth.users where email = 'hello@classtix.org'
on conflict (id) do update set role = 'admin', status = 'Active', district_id = null;
-- Everyone else is invited from the portal's Users page.
