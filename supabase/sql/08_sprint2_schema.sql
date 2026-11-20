-- =====================================================================
-- FOUND IT - 08: Sprint 2 schema (matches, chat, notifications, push)
--
-- What this adds:
--   1) report_private_details  -> secret details only the owner can see
--   2) matches                 -> links a Lost report with a Found report
--   3) messages                -> chat messages inside one match
--   4) notifications           -> in-app notifications (+ source of push)
--   5) device_tokens           -> phones that receive push notifications
--   6) chat-images bucket      -> private chat photos
--   7) Realtime on messages / matches / notifications
--
-- Run once, after 01 -> 07. Safe to run again.
-- Then run 09_sprint2_functions.sql.
-- =====================================================================


-- ---------------------------------------------------------------------
-- 1) report_private_details
--    Kept in its own table (not a column on reports) because every
--    logged-in user can read the reports table. Only the owner can
--    read / write this one.
-- ---------------------------------------------------------------------
create table if not exists public.report_private_details (
  report_id   uuid primary key references public.reports (id) on delete cascade,
  details     text not null check (char_length(btrim(details)) between 1 and 500),
  updated_at  timestamptz not null default now()
);

alter table public.report_private_details enable row level security;

revoke all on public.report_private_details from anon, authenticated;
grant select, insert, update, delete on public.report_private_details to authenticated;

drop policy if exists "private details: owner only" on public.report_private_details;
create policy "private details: owner only"
  on public.report_private_details for all
  to authenticated
  using (exists (select 1 from public.reports r
                 where r.id = report_id and r.user_id = (select auth.uid())))
  with check (exists (select 1 from public.reports r
                      where r.id = report_id and r.user_id = (select auth.uid())));


-- ---------------------------------------------------------------------
-- 2) matches
--    status:  potential -> chatting -> verified -> recovered
--             (or rejected at any point before recovered)
--    One side's report can be NULL for a "manual" match: a user taps
--    "This is Mine" / "I Found This" without having a report of their own.
-- ---------------------------------------------------------------------
create table if not exists public.matches (
  id                  uuid primary key default gen_random_uuid(),
  lost_report_id      uuid references public.reports (id) on delete cascade,
  found_report_id     uuid references public.reports (id) on delete cascade,
  lost_user_id        uuid not null references public.profiles (id) on delete cascade,
  found_user_id       uuid not null references public.profiles (id) on delete cascade,
  status              text not null default 'potential'
                      check (status in ('potential', 'chatting', 'verified', 'rejected', 'recovered')),
  ownership_verified  boolean not null default false,
  similarity          int not null default 0 check (similarity between 0 and 100),
  source              text not null default 'auto' check (source in ('auto', 'manual')),
  rejected_by         uuid references public.profiles (id) on delete set null,
  verified_at         timestamptz,
  recovered_at        timestamptz,
  last_message_at     timestamptz,
  created_at          timestamptz not null default now(),
  updated_at          timestamptz not null default now(),

  constraint matches_two_people check (lost_user_id <> found_user_id),
  constraint matches_has_report check (lost_report_id is not null or found_report_id is not null),
  -- the same Lost + Found pair can only be matched once
  -- (NULLs never clash, manual matches are de-duplicated by the function)
  constraint matches_pair_key unique (lost_report_id, found_report_id)
);

create index if not exists matches_lost_user_idx   on public.matches (lost_user_id, created_at desc);
create index if not exists matches_found_user_idx  on public.matches (found_user_id, created_at desc);
create index if not exists matches_lost_report_idx on public.matches (lost_report_id);
create index if not exists matches_found_report_idx on public.matches (found_report_id);

drop trigger if exists matches_set_updated_at on public.matches;
create trigger matches_set_updated_at
  before update on public.matches
  for each row execute function public.set_updated_at();

alter table public.matches enable row level security;

-- read only from the app. All changes go through functions (09 file).
revoke all on public.matches from anon, authenticated;
grant select on public.matches to authenticated;

drop policy if exists "matches: read own" on public.matches;
create policy "matches: read own"
  on public.matches for select
  to authenticated
  using ((select auth.uid()) in (lost_user_id, found_user_id));


-- ---------------------------------------------------------------------
-- Helper used by the policies below (and by storage).
-- security definer = it can look at matches without RLS getting in the way.
-- ---------------------------------------------------------------------
create or replace function public.is_match_participant(p_match_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.matches m
    where m.id = p_match_id
      and auth.uid() in (m.lost_user_id, m.found_user_id)
  );
$$;

-- can I still send messages in this match? (not rejected / recovered)
create or replace function public.can_send_in_match(p_match_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.matches m
    where m.id = p_match_id
      and auth.uid() in (m.lost_user_id, m.found_user_id)
      and m.status in ('potential', 'chatting', 'verified')
  );
$$;

-- storage folders are text: "<match_id>/photo.jpg"
create or replace function public.can_access_chat_folder(p_folder text)
returns boolean
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if p_folder is null
     or p_folder !~ '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$' then
    return false;
  end if;
  return public.is_match_participant(p_folder::uuid);
end;
$$;


-- ---------------------------------------------------------------------
-- 3) messages
--    A message has text, a photo, or both.
--    image_path = path inside the chat-images bucket: "<match_id>/<file>.jpg"
-- ---------------------------------------------------------------------
create table if not exists public.messages (
  id          uuid primary key default gen_random_uuid(),
  match_id    uuid not null references public.matches (id) on delete cascade,
  sender_id   uuid not null default auth.uid() references public.profiles (id) on delete cascade,
  body        text check (body is null or char_length(btrim(body)) between 1 and 2000),
  image_path  text,
  read_at     timestamptz,
  created_at  timestamptz not null default now(),

  constraint messages_not_empty check (body is not null or image_path is not null)
);

create index if not exists messages_match_idx on public.messages (match_id, created_at);
create index if not exists messages_unread_idx on public.messages (match_id) where read_at is null;

alter table public.messages enable row level security;

revoke all on public.messages from anon, authenticated;
grant select on public.messages to authenticated;
grant insert (match_id, body, image_path) on public.messages to authenticated;

drop policy if exists "messages: read own chats" on public.messages;
create policy "messages: read own chats"
  on public.messages for select
  to authenticated
  using (public.is_match_participant(match_id));

drop policy if exists "messages: send in open chats" on public.messages;
create policy "messages: send in open chats"
  on public.messages for insert
  to authenticated
  with check (
    sender_id = (select auth.uid())
    and public.can_send_in_match(match_id)
  );


-- ---------------------------------------------------------------------
-- 4) notifications
--    The app builds the text from "type" + the fields (so it can show
--    Arabic or English). The push Edge Function reads the same rows.
-- ---------------------------------------------------------------------
create table if not exists public.notifications (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references public.profiles (id) on delete cascade,
  type             text not null check (type in (
                     'potential_match',     -- new match for my report
                     'new_message',         -- new chat message
                     'ownership_verified',  -- finder confirmed ownership
                     'match_rejected',      -- the other user rejected the match
                     'item_recovered'       -- item marked recovered
                   )),
  match_id         uuid references public.matches (id) on delete cascade,
  report_id        uuid references public.reports (id) on delete set null,
  report_title     text,          -- e.g. "Black leather wallet"
  report_type      text,          -- 'lost' | 'found' (MY report's type)
  actor_name       text,          -- e.g. "Mona K." (who sent / did it)
  message_preview  text,          -- first 80 chars of a chat message
  read_at          timestamptz,
  created_at       timestamptz not null default now()
);

create index if not exists notifications_user_idx
  on public.notifications (user_id, created_at desc);
create index if not exists notifications_unread_idx
  on public.notifications (user_id) where read_at is null;

alter table public.notifications enable row level security;

revoke all on public.notifications from anon, authenticated;
grant select on public.notifications to authenticated;

drop policy if exists "notifications: read own" on public.notifications;
create policy "notifications: read own"
  on public.notifications for select
  to authenticated
  using (user_id = (select auth.uid()));


-- ---------------------------------------------------------------------
-- 5) device_tokens (FCM tokens). The app never reads this table:
--    it only calls save_device_token / delete_device_token.
-- ---------------------------------------------------------------------
create table if not exists public.device_tokens (
  token       text primary key,
  user_id     uuid not null references public.profiles (id) on delete cascade,
  platform    text not null default 'android' check (platform in ('android', 'ios', 'web')),
  lang        text not null default 'en' check (lang in ('en', 'ar')),
  updated_at  timestamptz not null default now()
);

create index if not exists device_tokens_user_idx on public.device_tokens (user_id);

alter table public.device_tokens enable row level security;
revoke all on public.device_tokens from anon, authenticated;
-- no policies on purpose: only security-definer functions and the
-- Edge Function (service role) can touch it.


-- ---------------------------------------------------------------------
-- 6) chat-images bucket (PRIVATE: no public URLs, use signed URLs)
--    Path: chat-images/<match_id>/<file name>.jpg
--    Only the 2 people in that match can upload / view.
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('chat-images', 'chat-images', false, 10485760, array['image/jpeg', 'image/png'])
on conflict (id) do update
  set public             = excluded.public,
      file_size_limit    = excluded.file_size_limit,
      allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "chat-images: read own chats" on storage.objects;
create policy "chat-images: read own chats"
  on storage.objects for select
  to authenticated
  using (
    bucket_id = 'chat-images'
    and public.can_access_chat_folder((storage.foldername(name))[1])
  );

drop policy if exists "chat-images: upload to own chats" on storage.objects;
create policy "chat-images: upload to own chats"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'chat-images'
    and public.can_access_chat_folder((storage.foldername(name))[1])
  );


-- ---------------------------------------------------------------------
-- 7) Realtime: the app gets new rows live (WebSockets).
--    RLS still applies: you only receive rows you are allowed to read.
-- ---------------------------------------------------------------------
do $$
declare
  t text;
begin
  foreach t in array array['messages', 'matches', 'notifications'] loop
    if not exists (
      select 1 from pg_publication_tables
      where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = t
    ) then
      execute format('alter publication supabase_realtime add table public.%I', t);
    end if;
  end loop;
end;
$$;


-- ---------------------------------------------------------------------
-- 8) Function permissions (the helpers above)
-- ---------------------------------------------------------------------
revoke execute on all functions in schema public from public, anon;
grant  execute on all functions in schema public to authenticated;
revoke execute on function public.handle_new_user() from authenticated;
revoke execute on function public.set_updated_at()  from authenticated;
