-- =====================================================================
-- FOUND IT - 99: Checks (run AFTER 01 -> 07). Nothing here changes data
-- permanently. Run each block on its own and compare with "Expected".
-- =====================================================================


-- ---------------------------------------------------------------------
-- CHECK 1: the 5 tables exist and RLS is ON
-- Expected: areas, categories, cities, profiles, reports -> rowsecurity = true
-- ---------------------------------------------------------------------
select tablename, rowsecurity
from pg_tables
where schemaname = 'public'
order by tablename;


-- ---------------------------------------------------------------------
-- CHECK 2: starting data
-- Expected: cities = 3, categories = 7, areas = 77
--   then per city: Alexandria 30, Cairo 30, Giza 17
-- ---------------------------------------------------------------------
select
  (select count(*) from public.cities)     as cities,
  (select count(*) from public.categories) as categories,
  (select count(*) from public.areas)      as areas;

select c.name_en as city, count(a.id) as areas
from public.cities c
left join public.areas a on a.city_id = c.id
group by c.name_en
order by c.name_en;


-- ---------------------------------------------------------------------
-- CHECK 3: the functions exist
-- Expected (11): create_report, get_city_areas, get_home_feed, get_my_profile,
--   get_my_reports, get_my_reports_counts, search_reports, set_my_city,
--   soft_delete_report, update_report, update_report_status
--   (+ handle_new_user, set_updated_at = trigger helpers)
-- ---------------------------------------------------------------------
select routine_name
from information_schema.routines
where routine_schema = 'public'
order by routine_name;


-- ---------------------------------------------------------------------
-- CHECK 4: the photos bucket
-- Expected: report-images | true | 10485760 | {image/jpeg,image/png}
-- ---------------------------------------------------------------------
select id, public, file_size_limit, allowed_mime_types
from storage.buckets
where id = 'report-images';


-- ---------------------------------------------------------------------
-- CHECK 5: the sign-up trigger creates a profile
--   1) Dashboard -> Authentication -> Users -> "Add user" -> "Create new user"
--      (any test email + password, tick "Auto Confirm User")
--   2) Run this. Expected: one row with the test email.
-- ---------------------------------------------------------------------
select id, email, full_name, role, created_at
from public.profiles
order by created_at desc
limit 5;


-- ---------------------------------------------------------------------
-- CHECK 6: test the functions AS that test user
--   1) Put the id from CHECK 5 in v_user below (keep the quotes).
--   2) Run the whole block at once.
--   The block ENDS WITH AN ERROR ON PURPOSE: the error undoes everything
--   (no test data is left behind) and its message shows the results.
--
--   Expected message (ref_code number can differ):
--   TEST OK | city=Cairo | areas=30 | ref_code=RPT-1001 | area=Maadi/المعادي |
--   category=Wallets | feed=1 | search=1 | area filter=1 | total=1 active=1 |
--   after delete=0 | short title=blocked | area from other city=blocked
--   Any OTHER error = something is wrong -> send it to Ahmed.
-- ---------------------------------------------------------------------
do $$
declare
  v_user         uuid := 'PUT-USER-ID-HERE';
  v_cairo        uuid;
  v_maadi        uuid;
  v_dokki        uuid;
  v_wallet       uuid;
  v_areas        int;
  v_profile      record;
  v_report       public.report_details;
  v_feed         int;
  v_search       int;
  v_area_filter  int;
  v_counts       record;
  v_after_delete int;
  v_short_title  text;
  v_wrong_area   text;
begin
  -- act as the test user (like a logged-in app user)
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_user, 'role', 'authenticated')::text, true);
  execute 'set local role authenticated';

  select id into v_cairo  from public.cities     where name_en = 'Cairo';
  select id into v_wallet from public.categories where name_en = 'Wallets';
  select id into v_maadi  from public.areas where city_id = v_cairo and name_en = 'Maadi';
  select a.id into v_dokki from public.areas a
    join public.cities c on c.id = a.city_id
   where c.name_en = 'Giza' and a.name_en = 'Dokki';

  select count(*) into v_areas from public.get_city_areas(v_cairo, 'ar');

  perform public.set_my_city(v_cairo);
  select * into v_profile from public.get_my_profile();

  v_report := public.create_report(
    'lost', 'Black leather wallet', v_wallet, v_cairo, v_maadi,
    array['https://example.com/test.jpg']);

  select count(*) into v_feed   from public.get_home_feed(v_cairo);
  select count(*) into v_search from public.search_reports(v_cairo, 'wallet');
  select count(*) into v_area_filter
    from public.search_reports(p_city_id => v_cairo, p_area_ids => array[v_maadi]);
  select * into v_counts from public.get_my_reports_counts();

  perform public.soft_delete_report(v_report.id);
  select count(*) into v_after_delete from public.get_my_reports();

  -- rule check 1: a 2-letter title must be rejected
  begin
    perform public.create_report(
      'lost', 'ab', v_wallet, v_cairo, v_maadi, array['https://example.com/x.jpg']);
    v_short_title := 'NOT blocked (problem!)';
  exception when check_violation then
    v_short_title := 'blocked';
  end;

  -- rule check 2: Cairo report with a Giza area (Dokki) must be rejected
  begin
    perform public.create_report(
      'lost', 'Blue backpack', v_wallet, v_cairo, v_dokki, array['https://example.com/y.jpg']);
    v_wrong_area := 'NOT blocked (problem!)';
  exception when foreign_key_violation then
    v_wrong_area := 'blocked';
  end;

  raise exception 'TEST OK | city=% | areas=% | ref_code=% | area=%/% | category=% | feed=% | search=% | area filter=% | total=% active=% | after delete=% | short title=% | area from other city=%',
    v_profile.city_name_en, v_areas, v_report.ref_code,
    v_report.area_name_en, v_report.area_name_ar, v_report.category_name_en,
    v_feed, v_search, v_area_filter, v_counts.total, v_counts.active,
    v_after_delete, v_short_title, v_wrong_area;
end
$$;
