-- =====================================================================
-- FOUND IT - 01: Tables
-- Run order: 01 -> 02 -> 03 -> 04 -> 05 -> 06 (Supabase SQL Editor)
-- Safe to re-run: uses "if not exists".
-- =====================================================================


-- ---------------------------------------------------------------------
-- cities: the supported cities (Cairo, Alexandria, Giza ...)
-- ---------------------------------------------------------------------
create table if not exists public.cities (
  id          uuid primary key default gen_random_uuid(),
  name_en     text not null unique,
  name_ar     text not null unique,
  is_active   boolean not null default true,   -- false = hidden from the app
  sort_order  int not null default 0,          -- order in the city list
  created_at  timestamptz not null default now()
);


-- ---------------------------------------------------------------------
-- categories: item categories (Electronics, Wallets, Keys ...)
-- icon = a Material icon name, mapped to an IconData in Flutter
-- ---------------------------------------------------------------------
create table if not exists public.categories (
  id          uuid primary key default gen_random_uuid(),
  name_en     text not null unique,
  name_ar     text not null unique,
  icon        text,
  is_active   boolean not null default true,
  sort_order  int not null default 0,
  created_at  timestamptz not null default now()
);


-- ---------------------------------------------------------------------
-- profiles: one row per user (created automatically on sign up,
-- see 02_triggers.sql). id = the user's id in auth.users.
-- ---------------------------------------------------------------------
create table if not exists public.profiles (
  id          uuid primary key references auth.users (id) on delete cascade,
  full_name   text not null default '',
  email       text not null,
  phone       text,                            -- e.g. +201012345678
  address     text,
  avatar_url  text,
  city_id     uuid references public.cities (id) on delete set null,  -- null = not chosen yet
  role        text not null default 'user' check (role in ('user', 'admin')),
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);


-- ---------------------------------------------------------------------
-- reports: Lost / Found reports
-- ref_code is generated automatically: RPT-1001, RPT-1002, ...
-- Reports are NEVER deleted: "delete" sets deleted_at (soft delete).
-- ---------------------------------------------------------------------
create sequence if not exists public.report_ref_seq start with 1001;

create table if not exists public.reports (
  id           uuid primary key default gen_random_uuid(),
  ref_code     text not null unique default ('RPT-' || nextval('public.report_ref_seq')),
  user_id      uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  type         text not null check (type in ('lost', 'found')),
  title        text not null check (char_length(btrim(title)) between 3 and 50),
  description  text check (description is null or char_length(description) <= 1000),
  category_id  uuid not null references public.categories (id),
  city_id      uuid not null references public.cities (id),
  district     text not null check (char_length(btrim(district)) between 2 and 100),
  item_date    date not null default current_date,      -- the day it was lost / found
  images       text[] not null check (cardinality(images) between 1 and 4),  -- public image URLs
  status       text not null default 'active' check (status in ('active', 'matching', 'recovered')),
  deleted_at   timestamptz,                               -- not null = deleted
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);


-- ---------------------------------------------------------------------
-- Indexes (make the common queries fast)
-- ---------------------------------------------------------------------
create index if not exists reports_city_feed_idx
  on public.reports (city_id, created_at desc)
  where deleted_at is null;

create index if not exists reports_user_idx
  on public.reports (user_id, created_at desc);

create index if not exists reports_category_idx
  on public.reports (category_id);

create index if not exists profiles_city_idx
  on public.profiles (city_id);
