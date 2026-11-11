-- =====================================================================
-- FOUND IT - 05: View + Functions for the team
--
-- Call a function from Flutter with:
--   await supabase.rpc('function_name', params: {'p_x': ...});
--
-- All functions run with the CALLER's permissions (security invoker),
-- so the RLS rules in 03_security.sql always apply.
-- Full docs + Dart examples: docs/database.md
-- =====================================================================


-- ---------------------------------------------------------------------
-- VIEW report_details
-- A report + its category name + its city name, ready to show in a card.
-- security_invoker = true -> the reports RLS rules apply to the view.
-- ---------------------------------------------------------------------
create or replace view public.report_details
with (security_invoker = true)
as
select
  r.id,
  r.ref_code,
  r.user_id,
  r.type,
  r.title,
  r.description,
  r.category_id,
  c.name_en  as category_name_en,
  c.name_ar  as category_name_ar,
  c.icon     as category_icon,
  r.city_id,
  ci.name_en as city_name_en,
  ci.name_ar as city_name_ar,
  r.district,
  r.item_date,
  r.images,
  r.status,
  r.deleted_at,
  r.created_at,
  r.updated_at,
  (r.user_id = auth.uid()) as is_mine
from public.reports r
left join public.categories c  on c.id  = r.category_id
left join public.cities     ci on ci.id = r.city_id;

revoke all on public.report_details from anon, authenticated;
grant select on public.report_details to authenticated;


-- ---------------------------------------------------------------------
-- get_my_profile()  ->  the logged-in user's profile + city name
-- ---------------------------------------------------------------------
create or replace function public.get_my_profile()
returns table (
  id            uuid,
  full_name     text,
  email         text,
  phone         text,
  address       text,
  avatar_url    text,
  role          text,
  city_id       uuid,
  city_name_en  text,
  city_name_ar  text,
  created_at    timestamptz
)
language sql
stable
set search_path = ''
as $$
  select p.id, p.full_name, p.email, p.phone, p.address, p.avatar_url, p.role,
         p.city_id, c.name_en, c.name_ar, p.created_at
  from public.profiles p
  left join public.cities c on c.id = p.city_id
  where p.id = auth.uid();
$$;


-- ---------------------------------------------------------------------
-- set_my_city(p_city_id)  ->  save the user's chosen city
-- ---------------------------------------------------------------------
create or replace function public.set_my_city(p_city_id uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  if not exists (select 1 from public.cities where id = p_city_id and is_active) then
    raise exception 'City not found' using errcode = 'P0002';
  end if;

  update public.profiles
     set city_id = p_city_id
   where id = auth.uid();
end;
$$;


-- ---------------------------------------------------------------------
-- get_home_feed(p_city_id, p_type, p_limit, p_offset)
--   Latest ACTIVE reports in a city, newest first.
--   p_type: null = All, 'lost', or 'found'
-- ---------------------------------------------------------------------
create or replace function public.get_home_feed(
  p_city_id  uuid,
  p_type     text default null,
  p_limit    int  default 20,
  p_offset   int  default 0
)
returns setof public.report_details
language sql
stable
set search_path = ''
as $$
  select *
  from public.report_details d
  where d.city_id = p_city_id
    and d.deleted_at is null
    and d.status = 'active'
    and (p_type is null or d.type = p_type)
  order by d.created_at desc
  limit least(greatest(p_limit, 1), 50)
  offset greatest(p_offset, 0);
$$;


-- ---------------------------------------------------------------------
-- search_reports(...)  ->  Explore screen search + filters
--   Every filter is optional: pass null (or leave it out) to skip it.
--   p_query searches the title and the description.
--   Returns ACTIVE, not-deleted reports in the city, newest first.
-- ---------------------------------------------------------------------
create or replace function public.search_reports(
  p_city_id       uuid,
  p_query         text   default null,
  p_type          text   default null,
  p_category_ids  uuid[] default null,
  p_district      text   default null,
  p_date_from     date   default null,
  p_date_to       date   default null,
  p_limit         int    default 20,
  p_offset        int    default 0
)
returns setof public.report_details
language sql
stable
set search_path = ''
as $$
  select *
  from public.report_details d
  where d.city_id = p_city_id
    and d.deleted_at is null
    and d.status = 'active'
    and (p_type is null or d.type = p_type)
    and (p_category_ids is null
         or cardinality(p_category_ids) = 0
         or d.category_id = any (p_category_ids))
    and (p_district is null
         or btrim(p_district) = ''
         or d.district ilike '%' || btrim(p_district) || '%')
    and (p_date_from is null or d.item_date >= p_date_from)
    and (p_date_to   is null or d.item_date <= p_date_to)
    and (p_query is null
         or btrim(p_query) = ''
         or d.title       ilike '%' || btrim(p_query) || '%'
         or d.description ilike '%' || btrim(p_query) || '%')
  order by d.created_at desc
  limit least(greatest(p_limit, 1), 50)
  offset greatest(p_offset, 0);
$$;


-- ---------------------------------------------------------------------
-- create_report(...)  ->  insert a report for the logged-in user
--   Returns the new report (with ref_code like 'RPT-1001').
--   Upload the photos to the report-images bucket FIRST, then pass
--   their public URLs in p_images (1 to 4).
-- ---------------------------------------------------------------------
create or replace function public.create_report(
  p_type         text,
  p_title        text,
  p_category_id  uuid,
  p_city_id      uuid,
  p_district     text,
  p_images       text[],
  p_item_date    date default null,
  p_description  text default null
)
returns public.report_details
language plpgsql
set search_path = ''
as $$
declare
  v_id  uuid;
  v_row public.report_details;
begin
  insert into public.reports
    (type, title, description, category_id, city_id, district, item_date, images)
  values (
    p_type,
    btrim(p_title),
    nullif(btrim(p_description), ''),
    p_category_id,
    p_city_id,
    btrim(p_district),
    coalesce(p_item_date, current_date),
    p_images
  )
  returning id into v_id;

  select * into v_row from public.report_details where id = v_id;
  return v_row;
end;
$$;


-- ---------------------------------------------------------------------
-- update_report(p_report_id, ...)  ->  edit your own report
--   Only the params you pass are changed (null = keep the old value).
--   To clear the description, pass an empty string ''.
-- ---------------------------------------------------------------------
create or replace function public.update_report(
  p_report_id    uuid,
  p_type         text   default null,
  p_title        text   default null,
  p_description  text   default null,
  p_category_id  uuid   default null,
  p_city_id      uuid   default null,
  p_district     text   default null,
  p_item_date    date   default null,
  p_images       text[] default null
)
returns public.report_details
language plpgsql
set search_path = ''
as $$
declare
  v_row public.report_details;
begin
  update public.reports
     set type        = coalesce(p_type, type),
         title       = coalesce(btrim(p_title), title),
         description = case when p_description is null then description
                            else nullif(btrim(p_description), '') end,
         category_id = coalesce(p_category_id, category_id),
         city_id     = coalesce(p_city_id, city_id),
         district    = coalesce(btrim(p_district), district),
         item_date   = coalesce(p_item_date, item_date),
         images      = coalesce(p_images, images)
   where id = p_report_id
     and user_id = auth.uid()
     and deleted_at is null;

  if not found then
    raise exception 'Report not found' using errcode = 'P0002';
  end if;

  select * into v_row from public.report_details where id = p_report_id;
  return v_row;
end;
$$;


-- ---------------------------------------------------------------------
-- update_report_status(p_report_id, p_status)
--   p_status: 'active' | 'matching' | 'recovered'
-- ---------------------------------------------------------------------
create or replace function public.update_report_status(
  p_report_id  uuid,
  p_status     text
)
returns void
language plpgsql
set search_path = ''
as $$
begin
  update public.reports
     set status = p_status
   where id = p_report_id
     and user_id = auth.uid()
     and deleted_at is null;

  if not found then
    raise exception 'Report not found' using errcode = 'P0002';
  end if;
end;
$$;


-- ---------------------------------------------------------------------
-- soft_delete_report(p_report_id)  ->  "delete" your own report
--   Sets deleted_at, so it disappears from Home / Explore / My Reports.
-- ---------------------------------------------------------------------
create or replace function public.soft_delete_report(p_report_id uuid)
returns void
language plpgsql
set search_path = ''
as $$
begin
  update public.reports
     set deleted_at = now()
   where id = p_report_id
     and user_id = auth.uid()
     and deleted_at is null;

  if not found then
    raise exception 'Report not found' using errcode = 'P0002';
  end if;
end;
$$;


-- ---------------------------------------------------------------------
-- get_my_reports(p_status)  ->  My Reports list, newest first
--   p_status: null = All, 'active', 'matching', or 'recovered'
-- ---------------------------------------------------------------------
create or replace function public.get_my_reports(p_status text default null)
returns setof public.report_details
language sql
stable
set search_path = ''
as $$
  select *
  from public.report_details d
  where d.user_id = auth.uid()
    and d.deleted_at is null
    and (p_status is null or d.status = p_status)
  order by d.created_at desc;
$$;


-- ---------------------------------------------------------------------
-- get_my_reports_counts()  ->  numbers for the My Reports tabs
--   (All 3 / Active 1 / Matching 1 / Recovered 1)
-- ---------------------------------------------------------------------
create or replace function public.get_my_reports_counts()
returns table (
  total      bigint,
  active     bigint,
  matching   bigint,
  recovered  bigint
)
language sql
stable
set search_path = ''
as $$
  select count(*),
         count(*) filter (where r.status = 'active'),
         count(*) filter (where r.status = 'matching'),
         count(*) filter (where r.status = 'recovered')
  from public.reports r
  where r.user_id = auth.uid()
    and r.deleted_at is null;
$$;


-- ---------------------------------------------------------------------
-- Permissions: only logged-in users can call the functions
-- ---------------------------------------------------------------------
revoke execute on all functions in schema public from public, anon;
grant  execute on all functions in schema public to authenticated;

-- trigger functions are never called from the app
revoke execute on function public.handle_new_user() from authenticated;
revoke execute on function public.set_updated_at()  from authenticated;
