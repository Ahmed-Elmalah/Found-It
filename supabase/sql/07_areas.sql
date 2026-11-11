-- =====================================================================
-- FOUND IT - 07: Areas (districts inside each city)
--
-- What changes:
--   1) New table  areas  (Maadi, Heliopolis ... in Arabic + English),
--      every area belongs to ONE city.
--   2) reports.district (free text) is REPLACED by reports.area_id.
--   3) A report's area MUST be inside the report's city. The database
--      enforces it with a composite foreign key (area_id, city_id).
--   4) The view + the report functions are re-created to use the area.
--   5) New function get_city_areas(p_city_id, p_lang).
--
-- Run once, after 01 -> 06. The reports table must be EMPTY
-- (it is: the test in 99_verify.sql rolls everything back).
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1) areas table
-- ---------------------------------------------------------------------
create table if not exists public.areas (
  id          uuid primary key default gen_random_uuid(),
  city_id     uuid not null references public.cities (id),
  name_en     text not null,
  name_ar     text not null,
  is_active   boolean not null default true,
  sort_order  int not null default 0,
  created_at  timestamptz not null default now(),

  -- the same name can't repeat inside one city
  constraint areas_city_name_en_key unique (city_id, name_en),
  constraint areas_city_name_ar_key unique (city_id, name_ar),
  -- needed so reports can point at (area, city) together
  constraint areas_id_city_key unique (id, city_id)
);

alter table public.areas enable row level security;

revoke all on public.areas from anon, authenticated;
grant select on public.areas to anon, authenticated;

drop policy if exists "areas: read active" on public.areas;
create policy "areas: read active"
  on public.areas for select
  to anon, authenticated
  using (is_active);


-- ---------------------------------------------------------------------
-- 2) The view + functions that use reports.district must go first
--    (they are re-created below with area instead of district)
-- ---------------------------------------------------------------------
drop function if exists public.get_home_feed(uuid, text, int, int);
drop function if exists public.search_reports(uuid, text, text, uuid[], text, date, date, int, int);
drop function if exists public.create_report(text, text, uuid, uuid, text, text[], date, text);
drop function if exists public.update_report(uuid, text, text, text, uuid, uuid, text, date, text[]);
drop function if exists public.get_my_reports(text);
drop view if exists public.report_details;


-- ---------------------------------------------------------------------
-- 3) reports: district (text) -> area_id (uuid)
-- ---------------------------------------------------------------------
alter table public.reports drop column if exists district;
alter table public.reports add column if not exists area_id uuid not null;

alter table public.reports drop constraint if exists reports_area_in_city_fkey;
alter table public.reports
  add constraint reports_area_in_city_fkey
  foreign key (area_id, city_id) references public.areas (id, city_id);

create index if not exists reports_area_idx on public.reports (area_id, city_id);

-- the app may set area_id on insert / update
grant insert (area_id) on public.reports to authenticated;
grant update (area_id) on public.reports to authenticated;


-- ---------------------------------------------------------------------
-- 4) VIEW report_details (now with the area names)
-- ---------------------------------------------------------------------
create view public.report_details
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
  r.area_id,
  a.name_en  as area_name_en,
  a.name_ar  as area_name_ar,
  r.item_date,
  r.images,
  r.status,
  r.deleted_at,
  r.created_at,
  r.updated_at,
  (r.user_id = auth.uid()) as is_mine
from public.reports r
left join public.categories c  on c.id  = r.category_id
left join public.cities     ci on ci.id = r.city_id
left join public.areas      a  on a.id  = r.area_id;

revoke all on public.report_details from anon, authenticated;
grant select on public.report_details to authenticated;


-- ---------------------------------------------------------------------
-- 5) get_city_areas(p_city_id, p_lang)  ->  areas of one city
--    p_lang: 'en' (default) or 'ar' -> sorted by the name in that language.
--    "Other" always comes last.
-- ---------------------------------------------------------------------
create or replace function public.get_city_areas(
  p_city_id  uuid,
  p_lang     text default 'en'
)
returns setof public.areas
language sql
stable
set search_path = ''
as $$
  select *
  from public.areas a
  where a.city_id = p_city_id
    and a.is_active
  order by a.sort_order,
           case when p_lang = 'ar' then a.name_ar else a.name_en end;
$$;


-- ---------------------------------------------------------------------
-- 6) Report functions, re-created with area
-- ---------------------------------------------------------------------

-- get_home_feed: same as before
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


-- search_reports: p_district (text) -> p_area_ids (uuid[])
create or replace function public.search_reports(
  p_city_id       uuid,
  p_query         text   default null,
  p_type          text   default null,
  p_category_ids  uuid[] default null,
  p_area_ids      uuid[] default null,
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
    and (p_area_ids is null
         or cardinality(p_area_ids) = 0
         or d.area_id = any (p_area_ids))
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


-- create_report: p_district (text) -> p_area_id (uuid)
create or replace function public.create_report(
  p_type         text,
  p_title        text,
  p_category_id  uuid,
  p_city_id      uuid,
  p_area_id      uuid,
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
    (type, title, description, category_id, city_id, area_id, item_date, images)
  values (
    p_type,
    btrim(p_title),
    nullif(btrim(p_description), ''),
    p_category_id,
    p_city_id,
    p_area_id,
    coalesce(p_item_date, current_date),
    p_images
  )
  returning id into v_id;

  select * into v_row from public.report_details where id = v_id;
  return v_row;
end;
$$;


-- update_report: p_district (text) -> p_area_id (uuid)
-- If you change the city, send the new area too (it must be in that city).
create or replace function public.update_report(
  p_report_id    uuid,
  p_type         text   default null,
  p_title        text   default null,
  p_description  text   default null,
  p_category_id  uuid   default null,
  p_city_id      uuid   default null,
  p_area_id      uuid   default null,
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
         area_id     = coalesce(p_area_id, area_id),
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


-- get_my_reports: same as before
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
-- 7) Permissions for the new / re-created functions
-- ---------------------------------------------------------------------
revoke execute on all functions in schema public from public, anon;
grant  execute on all functions in schema public to authenticated;
revoke execute on function public.handle_new_user() from authenticated;
revoke execute on function public.set_updated_at()  from authenticated;


-- ---------------------------------------------------------------------
-- 8) Seed: areas of Cairo, Giza, Alexandria (English + Arabic)
--    sort_order: 1 = normal, 99 = "Other" (always last)
-- ---------------------------------------------------------------------
insert into public.areas (city_id, name_en, name_ar, sort_order)
select c.id, v.name_en, v.name_ar, v.sort_order
from public.cities c
cross join (values
  ('Abbassia',                  'العباسية',               1),
  ('Ain Shams',                 'عين شمس',               1),
  ('Basatin',                   'البساتين',               1),
  ('Dar El Salam',              'دار السلام',             1),
  ('Downtown',                  'وسط البلد',              1),
  ('El Marg',                   'المرج',                  1),
  ('El Matareya',               'المطرية',                1),
  ('El Rehab',                  'الرحاب',                 1),
  ('El Salam City',             'مدينة السلام',           1),
  ('El Shorouk',                'الشروق',                 1),
  ('El Zeitoun',                'الزيتون',                1),
  ('Fifth Settlement',          'التجمع الخامس',          1),
  ('Garden City',               'جاردن سيتي',             1),
  ('Hadayek El Kobba',          'حدائق القبة',            1),
  ('Heliopolis',                'مصر الجديدة',            1),
  ('Helwan',                    'حلوان',                  1),
  ('Madinaty',                  'مدينتي',                 1),
  ('Maadi',                     'المعادي',                1),
  ('Manial',                    'المنيل',                 1),
  ('Mokattam',                  'المقطم',                 1),
  ('Nasr City',                 'مدينة نصر',              1),
  ('New Administrative Capital','العاصمة الإدارية الجديدة', 1),
  ('New Cairo',                 'القاهرة الجديدة',        1),
  ('Obour City',                'مدينة العبور',           1),
  ('Old Cairo',                 'مصر القديمة',            1),
  ('Rod El Farag',              'روض الفرج',              1),
  ('Sayeda Zeinab',             'السيدة زينب',            1),
  ('Shubra',                    'شبرا',                   1),
  ('Zamalek',                   'الزمالك',                1),
  ('Other',                     'أخرى',                   99)
) as v(name_en, name_ar, sort_order)
where c.name_en = 'Cairo'
on conflict (city_id, name_en) do nothing;


insert into public.areas (city_id, name_en, name_ar, sort_order)
select c.id, v.name_en, v.name_ar, v.sort_order
from public.cities c
cross join (values
  ('6th of October City',       'مدينة 6 أكتوبر',         1),
  ('Agouza',                    'العجوزة',                1),
  ('Badrashin',                 'البدرشين',               1),
  ('Boulaq El Dakrour',         'بولاق الدكرور',          1),
  ('Dokki',                     'الدقي',                  1),
  ('Faisal',                    'فيصل',                   1),
  ('Giza Square',               'ميدان الجيزة',           1),
  ('Hadayek El Ahram',          'حدائق الأهرام',          1),
  ('Haram',                     'الهرم',                  1),
  ('Hawamdeya',                 'الحوامدية',              1),
  ('Imbaba',                    'إمبابة',                 1),
  ('Kit Kat',                   'الكيت كات',              1),
  ('Mohandessin',               'المهندسين',              1),
  ('Omraniya',                  'العمرانية',              1),
  ('Sheikh Zayed',              'الشيخ زايد',             1),
  ('Warraq',                    'الوراق',                 1),
  ('Other',                     'أخرى',                   99)
) as v(name_en, name_ar, sort_order)
where c.name_en = 'Giza'
on conflict (city_id, name_en) do nothing;


insert into public.areas (city_id, name_en, name_ar, sort_order)
select c.id, v.name_en, v.name_ar, v.sort_order
from public.cities c
cross join (values
  ('Abu Qir',                   'أبو قير',                1),
  ('Agami',                     'العجمي',                 1),
  ('Amreya',                    'العامرية',               1),
  ('Asafra',                    'العصافرة',               1),
  ('Bahary',                    'بحري',                   1),
  ('Bolkly',                    'بولكلي',                 1),
  ('Borg El Arab',              'برج العرب',              1),
  ('Camp Shezar',               'كامب شيزار',             1),
  ('Cleopatra',                 'كليوباترا',              1),
  ('El Gomrok',                 'الجمرك',                 1),
  ('El Ibrahimiya',             'الإبراهيمية',            1),
  ('El Max',                    'المكس',                  1),
  ('Gleem',                     'جليم',                   1),
  ('Kafr Abdo',                 'كفر عبده',               1),
  ('Karmouz',                   'كرموز',                  1),
  ('Laurent',                   'لوران',                  1),
  ('Mandara',                   'المندرة',                1),
  ('Mansheya',                  'المنشية',                1),
  ('Miami',                     'ميامي',                  1),
  ('Moharam Bek',               'محرم بك',                1),
  ('Montaza',                   'المنتزه',                1),
  ('Raml Station',              'محطة الرمل',             1),
  ('Roushdy',                   'رشدي',                   1),
  ('San Stefano',               'سان ستيفانو',            1),
  ('Sidi Bishr',                'سيدي بشر',               1),
  ('Sidi Gaber',                'سيدي جابر',              1),
  ('Smouha',                    'سموحة',                  1),
  ('Sporting',                  'سبورتنج',                1),
  ('Stanley',                   'ستانلي',                 1),
  ('Other',                     'أخرى',                   99)
) as v(name_en, name_ar, sort_order)
where c.name_en = 'Alexandria'
on conflict (city_id, name_en) do nothing;
