-- =====================================================================
-- FOUND IT - 12: Story #6 - Ownership verification questions
--
-- The finder adds 1-3 multiple-choice questions to a FOUND report.
-- Whoever claims the item (the "lost" side of a match) must answer ALL
-- of them before the chat opens. One chance only: any wrong answer
-- closes the match and blocks that user from the report forever.
--
-- What this adds / changes:
--   1) report_questions       -> the questions (+ correct answer), owner only
--   2) report_claim_blocks    -> who is blocked from which report
--   3) matches.claim_status   -> not_required | pending | passed | failed
--   4) notifications type     -> + 'claim_passed'
--   5) triggers               -> new match gets its claim_status,
--                                blocked users are never matched again,
--                                editing questions updates waiting matches
--   6) chat lock              -> no messages / photos until the claim passes
--   7) functions              -> create_report / update_report (+ p_questions),
--                                get_report_details, create_manual_match,
--                                get_claim_questions, submit_claim_answers
--
-- Run once, after 08 + 09 + 11. Safe to run again.
--
-- New error code the app can get:
--   22023 = invalid input (bad questions / answers). Message says why.
-- =====================================================================


-- =====================================================================
-- PART A: tables
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1) report_questions
--    options       = all choices, ALREADY SHUFFLED (3 or 4)
--    correct_index = 0-based index of the right choice inside options
--    Only the report owner can read / write them. The person claiming
--    the item gets the questions WITHOUT the answer through
--    get_claim_questions().
-- ---------------------------------------------------------------------
create table if not exists public.report_questions (
  id             uuid primary key default gen_random_uuid(),
  report_id      uuid not null references public.reports (id) on delete cascade,
  position       smallint not null check (position between 1 and 3),
  question       text not null check (char_length(question) between 3 and 150),
  options        text[] not null check (cardinality(options) between 3 and 4),
  correct_index  smallint not null,
  created_at     timestamptz not null default now(),

  constraint report_questions_position_key unique (report_id, position),
  constraint report_questions_correct_in_range
    check (correct_index >= 0 and correct_index < cardinality(options))
);

alter table public.report_questions enable row level security;

revoke all on public.report_questions from anon, authenticated;
grant select, insert, delete on public.report_questions to authenticated;

drop policy if exists "questions: owner only" on public.report_questions;
create policy "questions: owner only"
  on public.report_questions for all
  to authenticated
  using (exists (select 1 from public.reports r
                 where r.id = report_id and r.user_id = (select auth.uid())))
  with check (exists (select 1 from public.reports r
                      where r.id = report_id and r.user_id = (select auth.uid())));


-- ---------------------------------------------------------------------
-- 2) report_claim_blocks: a wrong answer adds a row here.
--    The app never reads it (get_report_details returns i_am_blocked).
-- ---------------------------------------------------------------------
create table if not exists public.report_claim_blocks (
  report_id   uuid not null references public.reports (id) on delete cascade,
  user_id     uuid not null references public.profiles (id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (report_id, user_id)
);

alter table public.report_claim_blocks enable row level security;
revoke all on public.report_claim_blocks from anon, authenticated;
-- no policies on purpose: only security-definer functions touch it.


-- ---------------------------------------------------------------------
-- 3) matches.claim_status
--    not_required -> no questions (or the match started from a Lost report)
--    pending      -> the lost-side user must answer before chatting
--    passed       -> answered correctly, chat is open
--    failed       -> a wrong answer, match closed + user blocked
-- ---------------------------------------------------------------------
alter table public.matches
  add column if not exists claim_status text not null default 'not_required',
  add column if not exists claim_answered_at timestamptz;

alter table public.matches drop constraint if exists matches_claim_status_check;
alter table public.matches add constraint matches_claim_status_check
  check (claim_status in ('not_required', 'pending', 'passed', 'failed'));


-- ---------------------------------------------------------------------
-- 4) notifications: new type 'claim_passed' (sent to the finder)
-- ---------------------------------------------------------------------
do $$
declare
  c text;
begin
  -- drop the old "type in (...)" check, whatever its name is
  for c in
    select con.conname
    from pg_constraint con
    where con.conrelid = 'public.notifications'::regclass
      and con.contype = 'c'
      and pg_get_constraintdef(con.oid) like '%potential_match%'
  loop
    execute format('alter table public.notifications drop constraint %I', c);
  end loop;
end;
$$;

alter table public.notifications add constraint notifications_type_check
  check (type in (
    'potential_match',     -- new match for my report
    'new_message',         -- new chat message
    'ownership_verified',  -- finder confirmed ownership
    'match_rejected',      -- the other user rejected the match
    'item_recovered',      -- item marked recovered
    'claim_passed'         -- (finder) the owner answered my questions correctly
  ));


-- =====================================================================
-- PART B: triggers
-- =====================================================================

-- ---------------------------------------------------------------------
-- B1) Before a match is created:
--     - the lost-side user is blocked from this found report -> skip it
--       (returning NULL cancels the insert, nothing breaks)
--     - the found report has questions -> claim_status = 'pending'
-- ---------------------------------------------------------------------
create or replace function public.set_claim_status_on_new_match()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.found_report_id is not null and exists (
       select 1 from public.report_claim_blocks b
       where b.report_id = new.found_report_id
         and b.user_id = new.lost_user_id) then
    return null;
  end if;

  new.claim_status := case
    when new.found_report_id is not null and exists (
           select 1 from public.report_questions q
           where q.report_id = new.found_report_id)
    then 'pending'
    else 'not_required'
  end;

  return new;
end;
$$;

drop trigger if exists matches_set_claim_status on public.matches;
create trigger matches_set_claim_status
  before insert on public.matches
  for each row execute function public.set_claim_status_on_new_match();


-- ---------------------------------------------------------------------
-- B2) Questions added / removed -> update the matches waiting on them
--     questions now exist  -> untouched matches (no messages yet) become 'pending'
--     no questions anymore -> 'pending' matches become 'not_required'
-- ---------------------------------------------------------------------
create or replace function public.sync_claim_status_on_questions()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_report uuid;
begin
  v_report := case when tg_op = 'DELETE' then old.report_id else new.report_id end;

  if exists (select 1 from public.report_questions q where q.report_id = v_report) then
    update public.matches
       set claim_status = 'pending'
     where found_report_id = v_report
       and claim_status = 'not_required'
       and status = 'potential'
       and last_message_at is null;
  else
    update public.matches
       set claim_status = 'not_required'
     where found_report_id = v_report
       and claim_status = 'pending';
  end if;

  return null;
end;
$$;

drop trigger if exists report_questions_sync_claims on public.report_questions;
create trigger report_questions_sync_claims
  after insert or delete on public.report_questions
  for each row execute function public.sync_claim_status_on_questions();


-- ---------------------------------------------------------------------
-- B3) "Potential match" notification (same as 09) BUT the finder is not
--     notified while the claim is pending. He gets 'claim_passed' later.
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

  if (new.source = 'auto' or auth.uid() is distinct from new.found_user_id)
     and new.claim_status <> 'pending' then
    perform public._notify(new.found_user_id, 'potential_match', new.id,
                           new.found_report_id, v_actor);
  end if;

  return new;
end;
$$;


-- =====================================================================
-- PART C: chat lock (no messages / photos until the claim passes)
-- =====================================================================
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
      and m.claim_status in ('not_required', 'passed')
  );
$$;

-- uploading a chat photo = same rule as sending a message
create or replace function public.can_upload_chat_folder(p_folder text)
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
  return public.can_send_in_match(p_folder::uuid);
end;
$$;

drop policy if exists "chat-images: upload to own chats" on storage.objects;
create policy "chat-images: upload to own chats"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'chat-images'
    and public.can_upload_chat_folder((storage.foldername(name))[1])
  );


-- =====================================================================
-- PART D: helpers
-- =====================================================================

-- ---------------------------------------------------------------------
-- one match, seen from the CALLER's side (same as 09 + 3 new keys)
--   claim_status     not_required | pending | passed | failed
--   i_must_answer    true = I must answer the questions before chatting
--   questions_count  0..3
-- ---------------------------------------------------------------------
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
                                 then m.found_user_id else m.lost_user_id end),
    'claim_status',       m.claim_status,
    'i_must_answer',      m.claim_status = 'pending'
                          and m.status = 'potential'
                          and auth.uid() = m.lost_user_id,
    'questions_count',    (select count(*)::int from public.report_questions q
                           where q.report_id = m.found_report_id)
  );
$$;


-- ---------------------------------------------------------------------
-- _save_report_questions(report, questions)
--   Replaces ALL questions of a report. '[]' removes them.
--   Input (from the app):
--     [ { "question": "What color is it?",
--         "correct":  "Black",
--         "wrong":    ["Brown", "Blue"] }, ... ]
--   Rules: 0-3 questions, question 3-150 chars, every answer 1-80 chars,
--          2-3 wrong answers, all answers of one question different,
--          Found reports only.
--   Runs as the caller: RLS makes sure it is the report owner.
-- ---------------------------------------------------------------------
create or replace function public._save_report_questions(
  p_report_id  uuid,
  p_questions  jsonb
)
returns void
language plpgsql
set search_path = ''
as $$
declare
  v_type     text;
  v_item     jsonb;
  v_pos      int := 0;
  v_question text;
  v_correct  text;
  v_wrong    text[];
  v_options  text[];
begin
  if p_questions is null then
    return;
  end if;

  if jsonb_typeof(p_questions) <> 'array' then
    raise exception 'Questions must be a list' using errcode = '22023';
  end if;

  select r.type into v_type
  from public.reports r
  where r.id = p_report_id
    and r.user_id = auth.uid();

  if not found then
    raise exception 'Report not found' using errcode = 'P0002';
  end if;

  if jsonb_array_length(p_questions) > 3 then
    raise exception 'You can add at most 3 questions' using errcode = '22023';
  end if;

  if jsonb_array_length(p_questions) > 0 and v_type <> 'found' then
    raise exception 'Questions are only for Found reports' using errcode = '22023';
  end if;

  delete from public.report_questions where report_id = p_report_id;

  for v_item in select value from jsonb_array_elements(p_questions) loop
    v_pos := v_pos + 1;

    if jsonb_typeof(v_item) <> 'object'
       or jsonb_typeof(v_item -> 'wrong') is distinct from 'array' then
      raise exception 'Question %: needs "question", "correct" and a "wrong" list', v_pos
        using errcode = '22023';
    end if;

    v_question := btrim(v_item ->> 'question');
    v_correct  := btrim(v_item ->> 'correct');
    select array_agg(btrim(w)) into v_wrong
    from jsonb_array_elements_text(v_item -> 'wrong') w;

    if coalesce(char_length(v_question), 0) not between 3 and 150 then
      raise exception 'Question %: must be 3-150 characters', v_pos using errcode = '22023';
    end if;

    if coalesce(char_length(v_correct), 0) not between 1 and 80 then
      raise exception 'Question %: the correct answer must be 1-80 characters', v_pos
        using errcode = '22023';
    end if;

    if coalesce(cardinality(v_wrong), 0) not between 2 and 3 then
      raise exception 'Question %: add 2 or 3 wrong answers', v_pos using errcode = '22023';
    end if;

    if exists (select 1 from unnest(v_wrong) w
               where coalesce(char_length(w), 0) not between 1 and 80) then
      raise exception 'Question %: every wrong answer must be 1-80 characters', v_pos
        using errcode = '22023';
    end if;

    if (select count(distinct lower(a)) from unnest(v_wrong || v_correct) a)
       <> cardinality(v_wrong) + 1 then
      raise exception 'Question %: all answers must be different', v_pos
        using errcode = '22023';
    end if;

    -- shuffle, so the right answer is not always the first choice
    select array_agg(a order by random()) into v_options
    from unnest(v_wrong || v_correct) a;

    insert into public.report_questions (report_id, position, question, options, correct_index)
    values (p_report_id, v_pos, v_question, v_options,
            array_position(v_options, v_correct) - 1);
  end loop;
end;
$$;


-- =====================================================================
-- PART E: Story #1 functions (changed)
-- =====================================================================

-- ---------------------------------------------------------------------
-- get_report_details: same as 09 + 4 new keys
--   has_questions    true if the report has questions (everyone)
--   questions_count  0..3 (everyone)
--   questions        the owner only, same shape as the input:
--                    [{id, position, question, correct, wrong: [...]}]
--   i_am_blocked     (not the owner) I failed the questions -> hide
--                    "This is Mine"
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
  v_q_count       int;
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

  select count(*) into v_q_count
  from public.report_questions q
  where q.report_id = d.id;

  return to_jsonb(d) || jsonb_build_object(
    'is_mine',             v_mine,
    'owner_name',          public._display_name(d.user_id),
    'has_private_details', exists (select 1 from public.report_private_details p
                                   where p.report_id = d.id),
    'private_details',     case when v_mine then
                             (select p.details from public.report_private_details p
                              where p.report_id = d.id) end,
    'my_match_id',         v_match_id,
    'my_match_status',     v_match_status,
    'has_questions',       v_q_count > 0,
    'questions_count',     v_q_count,
    'questions',           case when v_mine then (
                             select coalesce(jsonb_agg(jsonb_build_object(
                                      'id',       q.id,
                                      'position', q.position,
                                      'question', q.question,
                                      'correct',  q.options[q.correct_index + 1],
                                      'wrong',    (select jsonb_agg(o.opt order by o.i)
                                                   from unnest(q.options) with ordinality o(opt, i)
                                                   where o.i <> q.correct_index + 1)
                                    ) order by q.position), '[]'::jsonb)
                             from public.report_questions q
                             where q.report_id = d.id) end,
    'i_am_blocked',        not v_mine and exists (
                             select 1 from public.report_claim_blocks b
                             where b.report_id = d.id and b.user_id = auth.uid())
  );
end;
$$;


-- ---------------------------------------------------------------------
-- create_report / update_report: same as 09 + p_questions
-- (Dart named params: old calls keep working)
-- ---------------------------------------------------------------------
drop function if exists public.create_report(text, text, uuid, uuid, uuid, text[], date, text, text);
drop function if exists public.update_report(uuid, text, text, text, uuid, uuid, uuid, date, text[], text);

create or replace function public.create_report(
  p_type             text,
  p_title            text,
  p_category_id      uuid,
  p_city_id          uuid,
  p_area_id          uuid,
  p_images           text[],
  p_item_date        date  default null,
  p_description      text  default null,
  p_private_details  text  default null,
  p_questions        jsonb default null
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

  perform public._save_report_questions(v_id, p_questions);

  select * into v_row from public.report_details where id = v_id;
  return v_row;
end;
$$;


-- p_private_details: null = don't change, '' = remove, text = save
-- p_questions:       null = don't change, '[]' = remove all, list = replace all
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
  p_private_details  text   default null,
  p_questions        jsonb  default null
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

  perform public._save_report_questions(p_report_id, p_questions);

  -- changed to a Lost report -> questions don't apply anymore
  if exists (select 1 from public.reports r where r.id = p_report_id and r.type = 'lost') then
    delete from public.report_questions where report_id = p_report_id;
  end if;

  select * into v_row from public.report_details where id = p_report_id;
  return v_row;
end;
$$;


-- =====================================================================
-- PART F: Story #2 functions (changed)
-- =====================================================================

-- ---------------------------------------------------------------------
-- create_manual_match(p_report_id): same as 09 +
--   - blocked users can't claim (42501)
--   - returns claim_status ('pending' -> open the Verify Ownership screen)
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
  v_claim   text;
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

  if exists (select 1 from public.report_claim_blocks b
             where b.report_id = r.id and b.user_id = auth.uid()) then
    raise exception 'You are blocked from this report' using errcode = '42501';
  end if;

  -- already have one? (open ones first)
  select m.id, m.status, m.claim_status into v_id, v_status, v_claim
  from public.matches m
  where p_report_id in (m.lost_report_id, m.found_report_id)
    and auth.uid() in (m.lost_user_id, m.found_user_id)
  order by (m.status in ('potential', 'chatting', 'verified')) desc, m.created_at desc
  limit 1;

  if v_id is not null then
    return jsonb_build_object('match_id', v_id, 'status', v_status,
                              'claim_status', v_claim, 'is_new', false);
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
  returning id, claim_status into v_id, v_claim;

  perform public._refresh_report_status(r.id);

  return jsonb_build_object('match_id', v_id, 'status', 'potential',
                            'claim_status', v_claim, 'is_new', true);
end;
$$;


-- =====================================================================
-- PART G: Story #6 functions (new)
-- =====================================================================

-- ---------------------------------------------------------------------
-- get_claim_questions(p_match_id) -> the questions WITHOUT the answers
--   [ { "question_id": "...", "position": 1, "question": "What color?",
--       "options": ["Brown", "Black", "Blue"] }, ... ]
--   Only the lost-side user, only while claim_status = 'pending'.
-- ---------------------------------------------------------------------
create or replace function public.get_claim_questions(p_match_id uuid)
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

  if m.lost_user_id <> auth.uid() then
    raise exception 'Only the person claiming the item answers the questions'
      using errcode = '42501';
  end if;

  if m.claim_status <> 'pending' or m.status <> 'potential' then
    raise exception 'No questions to answer for this match' using errcode = '55000';
  end if;

  return (
    select coalesce(jsonb_agg(jsonb_build_object(
             'question_id', q.id,
             'position',    q.position,
             'question',    q.question,
             'options',     to_jsonb(q.options)
           ) order by q.position), '[]'::jsonb)
    from public.report_questions q
    where q.report_id = m.found_report_id
  );
end;
$$;


-- ---------------------------------------------------------------------
-- submit_claim_answers(p_match_id, p_answers) -> { passed, match_id }
--   p_answers: [ { "question_id": "...", "choice": 1 }, ... ]
--              choice = 0-based index inside "options"
--   Every question must be answered exactly once (else 22023).
--   ONE chance:
--     all correct -> claim 'passed', chat opens, finder gets 'claim_passed'
--     any wrong   -> claim 'failed', match 'rejected', user blocked from
--                    this report, his other open matches on it closed.
--   It never says which answer was wrong.
-- ---------------------------------------------------------------------
create or replace function public.submit_claim_answers(
  p_match_id  uuid,
  p_answers   jsonb
)
returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  m          public.matches;
  o          public.matches;
  v_total    int;
  v_rows     int;
  v_distinct int;
  v_right    int;
begin
  select * into m
  from public.matches
  where id = p_match_id
    and auth.uid() in (lost_user_id, found_user_id)
  for update;

  if not found then
    raise exception 'Match not found' using errcode = 'P0002';
  end if;

  if m.lost_user_id <> auth.uid() then
    raise exception 'Only the person claiming the item answers the questions'
      using errcode = '42501';
  end if;

  if m.claim_status <> 'pending' or m.status <> 'potential' then
    raise exception 'No questions to answer for this match' using errcode = '55000';
  end if;

  if p_answers is null or jsonb_typeof(p_answers) <> 'array' then
    raise exception 'Answers must be a list' using errcode = '22023';
  end if;

  select count(*) into v_total
  from public.report_questions q
  where q.report_id = m.found_report_id;

  -- the finder removed all questions meanwhile -> nothing to answer
  if v_total = 0 then
    update public.matches set claim_status = 'not_required' where id = m.id;
    return jsonb_build_object('passed', true, 'match_id', m.id);
  end if;

  with a as (
    select (e ->> 'question_id')::uuid as question_id,
           (e ->> 'choice')::int       as choice
    from jsonb_array_elements(p_answers) e
  )
  select count(*),
         count(distinct q.id),
         count(*) filter (where a.choice = q.correct_index)
    into v_rows, v_distinct, v_right
  from a
  left join public.report_questions q
         on q.id = a.question_id
        and q.report_id = m.found_report_id;

  if v_rows <> v_total or v_distinct <> v_total then
    raise exception 'Answer every question exactly once' using errcode = '22023';
  end if;

  -- all correct -------------------------------------------------------
  if v_right = v_total then
    update public.matches
       set claim_status = 'passed',
           claim_answered_at = now()
     where id = m.id;

    perform public._notify(m.found_user_id, 'claim_passed', m.id,
                           m.found_report_id, public._display_name(auth.uid()));

    return jsonb_build_object('passed', true, 'match_id', m.id);
  end if;

  -- at least one wrong ------------------------------------------------
  update public.matches
     set claim_status = 'failed',
         claim_answered_at = now(),
         status = 'rejected',
         rejected_by = auth.uid()
   where id = m.id;

  insert into public.report_claim_blocks (report_id, user_id)
  values (m.found_report_id, auth.uid())
  on conflict do nothing;

  -- close my other open matches with this same found report
  for o in
    update public.matches
       set status = 'rejected',
           rejected_by = auth.uid()
     where found_report_id = m.found_report_id
       and lost_user_id = auth.uid()
       and status in ('potential', 'chatting', 'verified')
    returning *
  loop
    perform public._refresh_report_status(o.lost_report_id);
  end loop;

  perform public._refresh_report_status(m.lost_report_id);
  perform public._refresh_report_status(m.found_report_id);

  return jsonb_build_object('passed', false, 'match_id', m.id);
end;
$$;


-- =====================================================================
-- PART H: permissions
--   New / re-created functions only (the rest keep their grants from 09).
-- =====================================================================
revoke execute on function public.create_report(text, text, uuid, uuid, uuid, text[], date, text, text, jsonb)
  from public, anon;
revoke execute on function public.update_report(uuid, text, text, text, uuid, uuid, uuid, date, text[], text, jsonb)
  from public, anon;
revoke execute on function public._save_report_questions(uuid, jsonb)   from public, anon;
revoke execute on function public.get_claim_questions(uuid)             from public, anon;
revoke execute on function public.submit_claim_answers(uuid, jsonb)     from public, anon;
revoke execute on function public.can_upload_chat_folder(text)          from public, anon;

grant execute on function public.create_report(text, text, uuid, uuid, uuid, text[], date, text, text, jsonb)
  to authenticated;
grant execute on function public.update_report(uuid, text, text, text, uuid, uuid, uuid, date, text[], text, jsonb)
  to authenticated;
-- runs as the caller and RLS checks the owner, so the app may call it
-- (create_report / update_report need it)
grant execute on function public._save_report_questions(uuid, jsonb)    to authenticated;
grant execute on function public.get_claim_questions(uuid)              to authenticated;
grant execute on function public.submit_claim_answers(uuid, jsonb)      to authenticated;
grant execute on function public.can_upload_chat_folder(text)           to authenticated;

-- trigger functions: nobody calls them from the app
revoke execute on function public.set_claim_status_on_new_match()  from public, anon, authenticated;
revoke execute on function public.sync_claim_status_on_questions() from public, anon, authenticated;
