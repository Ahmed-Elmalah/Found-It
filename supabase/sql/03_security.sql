-- =====================================================================
-- FOUND IT - 03: Security (RLS policies + column permissions)
--
-- RLS = Row Level Security: decides WHICH ROWS a user can see / change.
-- GRANT = decides WHICH COLUMNS a user can change.
-- anon = not logged in, authenticated = logged in.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Turn RLS on (with RLS on and no policy, nothing is allowed)
-- ---------------------------------------------------------------------
alter table public.cities     enable row level security;
alter table public.categories enable row level security;
alter table public.profiles   enable row level security;
alter table public.reports    enable row level security;


-- ---------------------------------------------------------------------
-- Column permissions
-- ---------------------------------------------------------------------
-- cities / categories: read only, for everyone
revoke all on public.cities, public.categories from anon, authenticated;
grant select on public.cities, public.categories to anon, authenticated;

-- profiles: read + edit some columns. No insert (the trigger does it),
-- no delete, and role / email / id can NOT be changed from the app.
revoke all on public.profiles from anon, authenticated;
grant select on public.profiles to authenticated;
grant update (full_name, phone, address, avatar_url, city_id)
  on public.profiles to authenticated;

-- reports: no real DELETE ever (soft delete = update deleted_at).
-- id / ref_code / user_id / created_at can NOT be set from the app.
revoke all on public.reports from anon, authenticated;
grant select on public.reports to authenticated;
grant insert (type, title, description, category_id, city_id, district, item_date, images)
  on public.reports to authenticated;
grant update (type, title, description, category_id, city_id, district, item_date, images, status, deleted_at)
  on public.reports to authenticated;

-- needed to generate ref_code (RPT-xxxx) on insert
grant usage on sequence public.report_ref_seq to authenticated;


-- ---------------------------------------------------------------------
-- cities / categories policies
-- ---------------------------------------------------------------------
drop policy if exists "cities: read active" on public.cities;
create policy "cities: read active"
  on public.cities for select
  to anon, authenticated
  using (is_active);

drop policy if exists "categories: read active" on public.categories;
create policy "categories: read active"
  on public.categories for select
  to anon, authenticated
  using (is_active);


-- ---------------------------------------------------------------------
-- profiles policies: a user sees and edits ONLY their own profile
-- ---------------------------------------------------------------------
drop policy if exists "profiles: read own" on public.profiles;
create policy "profiles: read own"
  on public.profiles for select
  to authenticated
  using ((select auth.uid()) = id);

drop policy if exists "profiles: update own" on public.profiles;
create policy "profiles: update own"
  on public.profiles for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);


-- ---------------------------------------------------------------------
-- reports policies
-- ---------------------------------------------------------------------
-- read: everyone sees reports that are not deleted + always their own
drop policy if exists "reports: read visible" on public.reports;
create policy "reports: read visible"
  on public.reports for select
  to authenticated
  using (deleted_at is null or user_id = (select auth.uid()));

-- insert: only as yourself
drop policy if exists "reports: insert own" on public.reports;
create policy "reports: insert own"
  on public.reports for insert
  to authenticated
  with check (user_id = (select auth.uid()));

-- update (edit + soft delete): only your own reports
drop policy if exists "reports: update own" on public.reports;
create policy "reports: update own"
  on public.reports for update
  to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));
