-- =====================================================================
-- FOUND IT - 09: Sprint 2 functions + triggers
--
--   Story #1 Report Details : get_report_details, create_report / update_report
--                             (+ p_private_details)
--   Story #2 Matches        : match engine trigger, get_my_matches,
--                             get_match_details, create_manual_match,
--                             reject_match, get_my_matches_count
--   Story #3 Chat           : new-message trigger, get_my_chats,
--                             mark_messages_read, get_unread_messages_count,
--                             confirm_ownership
--   Story #4 Recovery       : mark_item_recovered, get_match_contact,
--                             feeds show active + matching
--   Story #5 Notifications  : notification triggers, mark_notifications_read,
--                             get_unread_notifications_count,
--                             save_device_token, delete_device_token
--
-- Run once, after 08_sprint2_schema.sql. Safe to run again.
--
-- Error codes the app can get (PostgrestException.code):
--   P0002 = not found          (report / match does not exist or isn't yours)
--   42501 = not allowed        (e.g. only the finder can confirm ownership)
--   55000 = wrong state        (e.g. match already closed, ownership not verified)
-- =====================================================================


-- =====================================================================
-- PART A: internal helpers (the app can NOT call these)
-- =====================================================================

-- a user's name to show to the other side (never the email / phone)
create or replace function public._display_name(p_user_id uuid)
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(nullif(btrim(p.full_name), ''), 'User')
  from public.profiles p
  where p.id = p_user_id;
$$;


-- public summary of one report (used inside match / chat answers)
create or replace function public._report_summary(p_report_id uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id',               d.id,
    'ref_code',         d.ref_code,
    'type',             d.type,
    'title',            d.title,
    'description',      d.description,
    'image',            d.images[1],
    'images',           to_jsonb(d.images),
    'category_name_en', d.category_name_en,
    'category_name_ar', d.category_name_ar,
    'city_name_en',     d.city_name_en,
    'city_name_ar',     d.city_name_ar,
    'area_name_en',     d.area_name_en,
    'area_name_ar',     d.area_name_ar,
    'item_date',        d.item_date,
    'status',           d.status,
    'is_deleted',       d.deleted_at is not null
  )
  from public.report_details d
  where d.id = p_report_id;
$$;


-- one match, seen from the CALLER's side (my_report / other_report)
create or replace function public._match_json(m public.matches)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'match_id',           m.id,
    'status',             m.status,
    'similarity',         m.similarity,
    'source',             m.source,
    'ownership_verified', m.ownership_verified,
    'i_am_finder',        auth.uid() = m.found_user_id,
    'created_at',         m.created_at,
    'last_message_at',    m.last_message_at,
    'my_report',          public._report_summary(
                            case when auth.uid() = m.lost_user_id
                                 then m.lost_report_id else m.found_report_id end),
    'other_report',       public._report_summary(
                            case when auth.uid() = m.lost_user_id
                                 then m.found_report_id else m.lost_report_id end),
    'other_user_name',    public._display_name(
                            case when auth.uid() = m.lost_user_id
                                 then m.found_user_id else m.lost_user_id end)
  );
$$;


-- similarity score 0..100 (category + city are always the same)
--   50 base + 30 same area + (20 - 5 per day apart)  ->  55 .. 100
create or replace function public._similarity(p_same_area boolean, p_days_apart int)
returns int
language sql
immutable
set search_path = ''
as $$
  select least(100, 50
                    + case when p_same_area then 30 else 0 end
                    + greatest(0, 20 - 5 * abs(coalesce(p_days_apart, 3))));
$$;


-- report status follows its matches:
--   has an open match -> 'matching', otherwise -> 'active'
--   'recovered' never changes back.
create or replace function public._refresh_report_status(p_report_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_new text;
begin
  if p_report_id is null then
    return;
  end if;

  v_new := case when exists (
             select 1 from public.matches m
             where p_report_id in (m.lost_report_id, m.found_report_id)
               and m.status in ('potential', 'chatting', 'verified')
           ) then 'matching' else 'active' end;

  update public.reports
     set status = v_new
   where id = p_report_id
     and status <> 'recovered'
     and status <> v_new;
end;
$$;


-- add one notification (the push Edge Function picks it up)
create or replace function public._notify(
  p_user_id    uuid,
  p_type       text,
  p_match_id   uuid,
  p_report_id  uuid,
  p_actor      text default null,
  p_preview    text default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if p_user_id is null then
    return;
  end if;

  insert into public.notifications
    (user_id, type, match_id, report_id, report_title, report_type, actor_name, message_preview)
  select p_user_id, p_type, p_match_id, p_report_id, r.title, r.type, p_actor, p_preview
  from (select 1) one
  left join public.reports r on r.id = p_report_id;
end;
$$;


-- =====================================================================
-- PART B: triggers (run by the database on their own)
-- =====================================================================

-- ---------------------------------------------------------------------
-- B1) MATCH ENGINE: a new report looks for opposite reports with
--     same category + same city + item date within 3 days.
-- ---------------------------------------------------------------------
create or replace function public.find_matches_for_new_report()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  o record;
begin
  if new.deleted_at is not null or new.status <> 'active' then
    return new;
  end if;

  for o in
    select r.id, r.user_id, r.area_id, r.item_date
    from public.reports r
    where r.type <> new.type
      and r.category_id = new.category_id
      and r.city_id = new.city_id
      and r.user_id <> new.user_id
      and r.deleted_at is null
      and r.status in ('active', 'matching')
      and abs(r.item_date - new.item_date) <= 3
  loop
    insert into public.matches
      (lost_report_id, found_report_id, lost_user_id, found_user_id, similarity, source)
    values (
      case when new.type = 'lost'  then new.id      else o.id      end,
      case when new.type = 'found' then new.id      else o.id      end,
      case when new.type = 'lost'  then new.user_id else o.user_id end,
      case when new.type = 'found' then new.user_id else o.user_id end,
      public._similarity(new.area_id = o.area_id, new.item_date - o.item_date),
      'auto'
    )
    on conflict (lost_report_id, found_report_id) do nothing;

    perform public._refresh_report_status(o.id);
  end loop;

  perform public._refresh_report_status(new.id);
  return new;
end;
$$;

drop trigger if exists reports_find_matches on public.reports;
create trigger reports_find_matches
  after insert on public.reports
  for each row execute function public.find_matches_for_new_report();


-- ---------------------------------------------------------------------
-- B2) New match -> "Potential match found" notification
--     auto match   -> both users
--     manual match -> only the report owner (not the person who tapped)
-- ---------------------------------------------------------------------
create or replace function public.notify_new_match()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_actor text := case when new.source = 'manual'
                       then public._display_name(auth.uid()) end;
begin
  if new.source = 'auto' or auth.uid() is distinct from new.lost_user_id then
    perform public._notify(new.lost_user_id, 'potential_match', new.id,
                           new.lost_report_id, v_actor);
  end if;

  if new.source = 'auto' or auth.uid() is distinct from new.found_user_id then
    perform public._notify(new.found_user_id, 'potential_match', new.id,
                           new.found_report_id, v_actor);
  end if;

  return new;
end;
$$;

drop trigger if exists matches_notify_new on public.matches;
create trigger matches_notify_new
  after insert on public.matches
  for each row execute function public.notify_new_match();


-- ---------------------------------------------------------------------
-- B3) New chat message:
--     - first message moves the match potential -> chatting
--     - saves last_message_at (for the chat list order)
--     - notifies the other user
-- ---------------------------------------------------------------------
create or replace function public.on_new_message()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  m        public.matches;
  v_other  uuid;
begin
  update public.matches
     set status = case when status = 'potential' then 'chatting' else status end,
         last_message_at = new.created_at
   where id = new.match_id
  returning * into m;

  v_other := case when new.sender_id = m.lost_user_id
                  then m.found_user_id else m.lost_user_id end;

  perform public._notify(
    v_other,
    'new_message',
    m.id,
    coalesce(case when v_other = m.lost_user_id then m.lost_report_id else m.found_report_id end,
             m.lost_report_id, m.found_report_id),
    public._display_name(new.sender_id),
    left(btrim(new.body), 80)          -- null for a photo-only message
  );

  return new;
end;
$$;

drop trigger if exists messages_on_new on public.messages;
create trigger messages_on_new
  after insert on public.messages
  for each row execute function public.on_new_message();


-- ---------------------------------------------------------------------
-- B4) A report is deleted (soft delete) -> close its open matches
-- ---------------------------------------------------------------------
create or replace function public.close_matches_of_deleted_report()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  o public.matches;
begin
  if old.deleted_at is null and new.deleted_at is not null then
    for o in
      update public.matches
         set status = 'rejected',
             rejected_by = new.user_id
       where new.id in (lost_report_id, found_report_id)
         and status in ('potential', 'chatting', 'verified')
      returning *
    loop
      perform public._refresh_report_status(o.lost_report_id);
      perform public._refresh_report_status(o.found_report_id);
    end loop;
  end if;
  return new;
end;
$$;

drop trigger if exists reports_close_matches_on_delete on public.reports;
create trigger reports_close_matches_on_delete
  after update of deleted_at on public.reports
  for each row execute function public.close_matches_of_deleted_report();


-- =====================================================================
-- PART C: Story #1 - Report Details
-- =====================================================================

-- ---------------------------------------------------------------------
-- get_report_details(p_report_id) -> one report with everything the
-- details screen needs. private_details only for the owner.
-- Never returns phone / email.
-- ---------------------------------------------------------------------
create or replace function public.get_report_details(p_report_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  d               public.report_details;
  v_mine          boolean;
  v_match_id      uuid;
  v_match_status  text;
begin
  select * into d
  from public.report_details
  where id = p_report_id
    and (deleted_at is null or user_id = auth.uid());

  if not found then
    raise exception 'Report not found' using errcode = 'P0002';
  end if;

  v_mine := d.user_id = auth.uid();

  -- did I (not the owner) already open a match on this report?
  if not v_mine then
    select m.id, m.status into v_match_id, v_match_status
    from public.matches m
    where p_report_id in (m.lost_report_id, m.found_report_id)
      and auth.uid() in (m.lost_user_id, m.found_user_id)
    order by m.created_at desc
    limit 1;
  end if;

  return to_jsonb(d) || jsonb_build_object(
    'is_mine',             v_mine,
    'owner_name',          public._display_name(d.user_id),
    'has_private_details', exists (select 1 from public.report_private_details p
                                   where p.report_id = d.id),
    'private_details',     case when v_mine then
                             (select p.details from public.report_private_details p
                              where p.report_id = d.id) end,
    'my_match_id',         v_match_id,
    'my_match_status',     v_match_status
  );
end;
$$;


-- ---------------------------------------------------------------------
-- create_report / update_report: same as 07 + p_private_details
-- (Dart named params: old calls keep working)
-- ---------------------------------------------------------------------
drop function if exists public.create_report(text, text, uuid, uuid, uuid, text[], date, text);
drop function if exists public.update_report(uuid, text, text, text, uuid, uuid, uuid, date, text[]);

create or replace function public.create_report(
  p_type             text,
  p_title            text,
  p_category_id      uuid,
  p_city_id          uuid,
  p_area_id          uuid,
  p_images           text[],
  p_item_date        date default null,
  p_description      text default null,
  p_private_details  text default null
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

  if nullif(btrim(p_private_details), '') is not null then
    insert into public.report_private_details (report_id, details)
    values (v_id, btrim(p_private_details));
  end if;

  select * into v_row from public.report_details where id = v_id;
  return v_row;
end;
$$;


-- p_private_details: null = don't change, '' = remove, text = save
create or replace function public.update_report(
  p_report_id        uuid,
  p_type             text   default null,
  p_title            text   default null,
  p_description      text   default null,
  p_category_id      uuid   default null,
  p_city_id          uuid   default null,
  p_area_id          uuid   default null,
  p_item_date        date   default null,
  p_images           text[] default null,
  p_private_details  text   default null
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

  if p_private_details is not null then
    if btrim(p_private_details) = '' then
      delete from public.report_private_details where report_id = p_report_id;
    else
      insert into public.report_private_details (report_id, details)
      values (p_report_id, btrim(p_private_details))
      on conflict (report_id) do update
        set details = excluded.details,
            updated_at = now();
    end if;
  end if;

  select * into v_row from public.report_details where id = p_report_id;
  return v_row;
end;
$$;


-- =====================================================================
-- PART D: Story #2 - Potential Matches
-- =====================================================================

-- ---------------------------------------------------------------------
-- get_my_matches(p_report_id) -> my OPEN matches (potential / chatting /
-- verified), best similarity first. p_report_id = only for that report.
-- ---------------------------------------------------------------------
create or replace function public.get_my_matches(p_report_id uuid default null)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    jsonb_agg(public._match_json(m) order by m.similarity desc, m.created_at desc),
    '[]'::jsonb)
  from public.matches m
  where auth.uid() in (m.lost_user_id, m.found_user_id)
    and m.status in ('potential', 'chatting', 'verified')
    and (p_report_id is null or p_report_id in (m.lost_report_id, m.found_report_id))
    and not exists (select 1 from public.reports r
                    where r.id in (m.lost_report_id, m.found_report_id)
                      and r.deleted_at is not null);
$$;


-- ---------------------------------------------------------------------
-- get_match_details(p_match_id) -> one match (P29 compare + chat header)
-- ---------------------------------------------------------------------
create or replace function public.get_match_details(p_match_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  m public.matches;
begin
  select * into m
  from public.matches
  where id = p_match_id
    and auth.uid() in (lost_user_id, found_user_id);

  if not found then
    raise exception 'Match not found' using errcode = 'P0002';
  end if;

  return public._match_json(m);
end;
$$;


-- ---------------------------------------------------------------------
-- create_manual_match(p_report_id) -> "This is Mine" / "I Found This"
-- Returns the existing match if I already have one on this report.
-- ---------------------------------------------------------------------
create or replace function public.create_manual_match(p_report_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  r         public.reports;
  v_id      uuid;
  v_status  text;
begin
  if auth.uid() is null then
    raise exception 'Not logged in' using errcode = '42501';
  end if;

  select * into r
  from public.reports
  where id = p_report_id
    and deleted_at is null;

  if not found then
    raise exception 'Report not found' using errcode = 'P0002';
  end if;

  if r.user_id = auth.uid() then
    raise exception 'You cannot claim your own report' using errcode = '42501';
  end if;

  -- already have one? (open ones first)
  select m.id, m.status into v_id, v_status
  from public.matches m
  where p_report_id in (m.lost_report_id, m.found_report_id)
    and auth.uid() in (m.lost_user_id, m.found_user_id)
  order by (m.status in ('potential', 'chatting', 'verified')) desc, m.created_at desc
  limit 1;

  if v_id is not null then
    return jsonb_build_object('match_id', v_id, 'status', v_status, 'is_new', false);
  end if;

  if r.status = 'recovered' then
    raise exception 'Report already recovered' using errcode = '55000';
  end if;

  insert into public.matches
    (lost_report_id, found_report_id, lost_user_id, found_user_id, similarity, source)
  values (
    case when r.type = 'lost'  then r.id end,
    case when r.type = 'found' then r.id end,
    case when r.type = 'lost'  then r.user_id else auth.uid() end,
    case when r.type = 'found' then r.user_id else auth.uid() end,
    0,
    'manual'
  )
  returning id into v_id;

  perform public._refresh_report_status(r.id);

  return jsonb_build_object('match_id', v_id, 'status', 'potential', 'is_new', true);
end;
$$;


-- ---------------------------------------------------------------------
-- reject_match(p_match_id) -> Dismiss / Not my item / Reject Match
-- ---------------------------------------------------------------------
create or replace function public.reject_match(p_match_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  m        public.matches;
  v_other  uuid;
begin
  select * into m
  from public.matches
  where id = p_match_id
    and auth.uid() in (lost_user_id, found_user_id)
  for update;

  if not found then
    raise exception 'Match not found' using errcode = 'P0002';
  end if;

  if m.status in ('rejected', 'recovered') then
    raise exception 'Match is already closed' using errcode = '55000';
  end if;

  update public.matches
     set status = 'rejected',
         rejected_by = auth.uid()
   where id = p_match_id;

  perform public._refresh_report_status(m.lost_report_id);
  perform public._refresh_report_status(m.found_report_id);

  v_other := case when auth.uid() = m.lost_user_id then m.found_user_id else m.lost_user_id end;
  perform public._notify(
    v_other, 'match_rejected', m.id,
    case when v_other = m.lost_user_id then m.lost_report_id else m.found_report_id end,
    public._display_name(auth.uid()));
end;
$$;


-- ---------------------------------------------------------------------
-- get_my_matches_count() -> number of NEW suggestions (status potential)
-- for the Home banner and Profile -> Activity.
-- ---------------------------------------------------------------------
create or replace function public.get_my_matches_count()
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)::int
  from public.matches m
  where auth.uid() in (m.lost_user_id, m.found_user_id)
    and m.status = 'potential'
    and not exists (select 1 from public.reports r
                    where r.id in (m.lost_report_id, m.found_report_id)
                      and r.deleted_at is not null);
$$;


-- =====================================================================
-- PART E: Story #3 - Chat
-- (sending a message = a normal insert into messages, see the docs)
-- =====================================================================

-- ---------------------------------------------------------------------
-- get_my_chats() -> Messages tab (P31): every match that has messages,
-- newest activity first, with the last message + unread count.
-- ---------------------------------------------------------------------
create or replace function public.get_my_chats()
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(jsonb_agg(c.item order by c.last_at desc), '[]'::jsonb)
  from (
    select
      m.last_message_at as last_at,
      public._match_json(m) || jsonb_build_object(
        'last_message', (
          select jsonb_build_object(
                   'body',       x.body,
                   'has_image',  x.image_path is not null,
                   'is_mine',    x.sender_id = auth.uid(),
                   'created_at', x.created_at)
          from public.messages x
          where x.match_id = m.id
          order by x.created_at desc
          limit 1),
        'unread_count', (
          select count(*)
          from public.messages x
          where x.match_id = m.id
            and x.sender_id <> auth.uid()
            and x.read_at is null)
      ) as item
    from public.matches m
    where auth.uid() in (m.lost_user_id, m.found_user_id)
      and m.last_message_at is not null
  ) c;
$$;


-- ---------------------------------------------------------------------
-- mark_messages_read(p_match_id) -> call when the chat screen opens
-- and when a new message arrives while it is open.
-- ---------------------------------------------------------------------
create or replace function public.mark_messages_read(p_match_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_match_participant(p_match_id) then
    raise exception 'Match not found' using errcode = 'P0002';
  end if;

  update public.messages
     set read_at = now()
   where match_id = p_match_id
     and sender_id <> auth.uid()
     and read_at is null;
end;
$$;


-- ---------------------------------------------------------------------
-- get_unread_messages_count() -> the badge on the Messages tab
-- ---------------------------------------------------------------------
create or replace function public.get_unread_messages_count()
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)::int
  from public.messages x
  join public.matches m on m.id = x.match_id
  where auth.uid() in (m.lost_user_id, m.found_user_id)
    and x.sender_id <> auth.uid()
    and x.read_at is null;
$$;


-- ---------------------------------------------------------------------
-- confirm_ownership(p_match_id) -> ONLY the finder, only after chatting.
-- ---------------------------------------------------------------------
create or replace function public.confirm_ownership(p_match_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  m public.matches;
begin
  select * into m
  from public.matches
  where id = p_match_id
    and auth.uid() in (lost_user_id, found_user_id)
  for update;

  if not found then
    raise exception 'Match not found' using errcode = 'P0002';
  end if;

  if m.found_user_id <> auth.uid() then
    raise exception 'Only the finder can confirm ownership' using errcode = '42501';
  end if;

  if m.status <> 'chatting' then
    raise exception 'Match must be in chatting state' using errcode = '55000';
  end if;

  update public.matches
     set status = 'verified',
         ownership_verified = true,
         verified_at = now()
   where id = p_match_id;

  perform public._notify(m.lost_user_id, 'ownership_verified', m.id,
                         m.lost_report_id, public._display_name(auth.uid()));
end;
$$;


-- =====================================================================
-- PART F: Story #4 - Recovery
-- =====================================================================

-- ---------------------------------------------------------------------
-- mark_item_recovered(p_match_id) -> either user, after verification.
--   match -> recovered, both reports -> recovered,
--   other open matches on these reports -> rejected.
-- ---------------------------------------------------------------------
create or replace function public.mark_item_recovered(p_match_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  m  public.matches;
  o  public.matches;
begin
  select * into m
  from public.matches
  where id = p_match_id
    and auth.uid() in (lost_user_id, found_user_id)
  for update;

  if not found then
    raise exception 'Match not found' using errcode = 'P0002';
  end if;

  if not m.ownership_verified or m.status <> 'verified' then
    raise exception 'Ownership is not verified yet' using errcode = '55000';
  end if;

  update public.matches
     set status = 'recovered',
         recovered_at = now()
   where id = p_match_id;

  update public.reports
     set status = 'recovered'
   where id in (m.lost_report_id, m.found_report_id);

  -- the item is back: close every other open match on these 2 reports
  for o in
    update public.matches
       set status = 'rejected',
           rejected_by = auth.uid()
     where id <> p_match_id
       and status in ('potential', 'chatting', 'verified')
       and (lost_report_id  in (m.lost_report_id, m.found_report_id)
         or found_report_id in (m.lost_report_id, m.found_report_id))
    returning *
  loop
    perform public._refresh_report_status(o.lost_report_id);
    perform public._refresh_report_status(o.found_report_id);
  end loop;

  perform public._notify(m.lost_user_id,  'item_recovered', m.id, m.lost_report_id);
  perform public._notify(m.found_user_id, 'item_recovered', m.id, m.found_report_id);
end;
$$;


-- ---------------------------------------------------------------------
-- get_match_contact(p_match_id) -> the OTHER user's name / phone / email,
-- only after ownership is verified (Handover screen).
-- ---------------------------------------------------------------------
create or replace function public.get_match_contact(p_match_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  m public.matches;
  p public.profiles;
begin
  select * into m
  from public.matches
  where id = p_match_id
    and auth.uid() in (lost_user_id, found_user_id);

  if not found then
    raise exception 'Match not found' using errcode = 'P0002';
  end if;

  if not m.ownership_verified then
    raise exception 'Ownership is not verified yet' using errcode = '55000';
  end if;

  select * into p
  from public.profiles
  where id = case when auth.uid() = m.lost_user_id then m.found_user_id else m.lost_user_id end;

  return jsonb_build_object(
    'full_name', public._display_name(p.id),
    'phone',     p.phone,
    'email',     p.email
  );
end;
$$;


-- ---------------------------------------------------------------------
-- Feeds: show active + matching (a report that has a possible match is
-- still not found!). Recovered reports leave Home / Explore.
-- Same signatures as 07, only the status line changed.
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
    and d.status in ('active', 'matching')
    and (p_type is null or d.type = p_type)
  order by d.created_at desc
  limit least(greatest(p_limit, 1), 50)
  offset greatest(p_offset, 0);
$$;


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
    and d.status in ('active', 'matching')
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


-- =====================================================================
-- PART G: Story #5 - Notifications + push tokens
-- (the notifications LIST is a normal select on the table, see the docs)
-- =====================================================================

-- p_ids = null -> mark ALL as read ("Mark all read")
create or replace function public.mark_notifications_read(p_ids uuid[] default null)
returns void
language sql
security definer
set search_path = ''
as $$
  update public.notifications
     set read_at = now()
   where user_id = auth.uid()
     and read_at is null
     and (p_ids is null or id = any (p_ids));
$$;


create or replace function public.get_unread_notifications_count()
returns int
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)::int
  from public.notifications n
  where n.user_id = auth.uid()
    and n.read_at is null;
$$;


-- call after login, when the token refreshes, and when the language changes
create or replace function public.save_device_token(
  p_token     text,
  p_platform  text default 'android',
  p_lang      text default 'en'
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if auth.uid() is null then
    raise exception 'Not logged in' using errcode = '42501';
  end if;

  insert into public.device_tokens (token, user_id, platform, lang, updated_at)
  values (p_token, auth.uid(), p_platform, p_lang, now())
  on conflict (token) do update
    set user_id    = excluded.user_id,
        platform   = excluded.platform,
        lang       = excluded.lang,
        updated_at = now();
end;
$$;


-- call BEFORE signOut (it needs the logged-in user)
create or replace function public.delete_device_token(p_token text)
returns void
language sql
security definer
set search_path = ''
as $$
  delete from public.device_tokens
  where token = p_token
    and user_id = auth.uid();
$$;


-- =====================================================================
-- PART H: permissions
--   App functions -> logged-in users only.
--   Internal helpers + trigger functions -> nobody from the app.
-- =====================================================================
revoke execute on all functions in schema public from public, anon;
grant  execute on all functions in schema public to authenticated;

revoke execute on function public.handle_new_user()                    from authenticated;
revoke execute on function public.set_updated_at()                     from authenticated;
revoke execute on function public._display_name(uuid)                  from authenticated;
revoke execute on function public._report_summary(uuid)                from authenticated;
revoke execute on function public._match_json(public.matches)          from authenticated;
revoke execute on function public._similarity(boolean, int)            from authenticated;
revoke execute on function public._refresh_report_status(uuid)         from authenticated;
revoke execute on function public._notify(uuid, text, uuid, uuid, text, text) from authenticated;
revoke execute on function public.find_matches_for_new_report()        from authenticated;
revoke execute on function public.notify_new_match()                   from authenticated;
revoke execute on function public.on_new_message()                     from authenticated;
revoke execute on function public.close_matches_of_deleted_report()    from authenticated;
