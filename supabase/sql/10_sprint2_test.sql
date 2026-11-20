-- =====================================================================
-- FOUND IT - 10: Sprint 2 test (run AFTER 08 and 09)
--
-- Needs 2 users in Authentication -> Users (any test accounts).
-- It picks the 2 oldest profiles by itself, nothing to edit.
--
-- Run the whole block at once. It ENDS WITH AN ERROR ON PURPOSE:
-- the error undoes everything (no test data is left) and its message
-- shows the results.
--
-- Expected message:
--   TEST OK | private hidden=yes | matches=1 | similarity=95 | count=yes |
--   lost status=matching | chatting=yes | unread=1->0 | lost user confirm=blocked |
--   verified=yes | contact=yes | recovered=recovered/recovered | in feed=0 |
--   manual=new then same | after reject=active | notif A=3 B=3
-- Any OTHER error = something is wrong -> send it to Claude.
-- =====================================================================
do $$
declare
  v_a            uuid;   -- user A: lost the wallet
  v_b            uuid;   -- user B: found it
  v_cairo        uuid;
  v_maadi        uuid;
  v_wallet       uuid;
  v_other_cat    uuid;
  v_lost         public.report_details;
  v_found        public.report_details;
  v_keys         public.report_details;
  v_details      jsonb;
  v_matches      jsonb;
  v_match        uuid;
  v_count        int;
  v_status       text;
  v_unread_1     int;
  v_unread_2     int;
  v_confirm      text;
  v_contact      jsonb;
  v_lost_status  text;
  v_matching     text;
  v_found_status text;
  v_feed         int;
  v_manual_1     jsonb;
  v_manual_2     jsonb;
  v_keys_status  text;
  v_notif_a      int;
  v_notif_b      int;
begin
  select id into v_a from public.profiles order by created_at limit 1;
  select id into v_b from public.profiles order by created_at offset 1 limit 1;
  if v_b is null then
    raise exception 'Create 2 test users first (Authentication -> Users -> Add user)';
  end if;

  select id into v_cairo  from public.cities     where name_en = 'Cairo';
  select id into v_wallet from public.categories where name_en = 'Wallets';
  select id into v_other_cat from public.categories where id <> v_wallet limit 1;
  select id into v_maadi  from public.areas where city_id = v_cairo and name_en = 'Maadi';

  execute 'set local role authenticated';

  -- 1) A reports a LOST wallet with a secret detail ------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_a, 'role', 'authenticated')::text, true);

  v_lost := public.create_report(
    'lost', 'Test black wallet', v_wallet, v_cairo, v_maadi,
    array['https://example.com/a.jpg'], current_date, null, 'Initials A.K. inside');

  -- 2) B sees A's report: the secret must be hidden ----------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_b, 'role', 'authenticated')::text, true);

  v_details := public.get_report_details(v_lost.id);

  -- 3) B reports a FOUND wallet (1 day apart) -> the engine matches --
  v_found := public.create_report(
    'found', 'Test wallet found', v_wallet, v_cairo, v_maadi,
    array['https://example.com/b.jpg'], current_date - 1);

  -- (real reports in the database may also match, so pick OUR pair)
  v_matches := public.get_my_matches(v_found.id);
  select id into v_match from public.matches
   where lost_report_id = v_lost.id and found_report_id = v_found.id;
  v_count   := public.get_my_matches_count();
  select status into v_matching from public.reports where id = v_lost.id;

  -- 4) A sends a message -> match becomes "chatting" ---------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_a, 'role', 'authenticated')::text, true);

  insert into public.messages (match_id, body) values (v_match, 'Is it black with A.K. inside?');
  select status into v_status from public.matches where id = v_match;

  -- the LOST user can NOT confirm ownership
  begin
    perform public.confirm_ownership(v_match);
    v_confirm := 'NOT BLOCKED';
  exception when insufficient_privilege then
    v_confirm := 'blocked';
  end;

  -- 5) B (finder) reads the message and confirms ownership ----------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_b, 'role', 'authenticated')::text, true);

  v_unread_1 := public.get_unread_messages_count();
  perform public.mark_messages_read(v_match);
  v_unread_2 := public.get_unread_messages_count();
  perform public.confirm_ownership(v_match);

  -- 6) A sees B's contact and marks the item recovered --------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_a, 'role', 'authenticated')::text, true);

  v_contact := public.get_match_contact(v_match);
  perform public.mark_item_recovered(v_match);

  select status into v_lost_status  from public.reports where id = v_lost.id;
  select status into v_found_status from public.reports where id = v_found.id;
  select count(*) into v_feed
  from public.get_home_feed(v_cairo)
  where id in (v_lost.id, v_found.id);

  -- 7) manual match: B taps "I Found This" on A's other report ------
  v_keys := public.create_report(
    'lost', 'Test other item', v_other_cat, v_cairo, v_maadi,
    array['https://example.com/c.jpg']);

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_b, 'role', 'authenticated')::text, true);

  v_manual_1 := public.create_manual_match(v_keys.id);
  v_manual_2 := public.create_manual_match(v_keys.id);
  perform public.reject_match((v_manual_1 ->> 'match_id')::uuid);
  select status into v_keys_status from public.reports where id = v_keys.id;

  -- 8) notifications ------------------------------------------------
  --   A: potential_match, ownership_verified, item_recovered (+ match_rejected)
  --   B: potential_match, new_message, item_recovered
  --   (each user can only read their OWN notifications -> switch user)
  select count(*) into v_notif_b from public.notifications
   where user_id = v_b and match_id = v_match;

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_a, 'role', 'authenticated')::text, true);

  select count(*) into v_notif_a from public.notifications
   where user_id = v_a and match_id = v_match;

  raise exception
    'TEST OK | private hidden=% | matches=% | similarity=% | count=% | lost status=% | chatting=% | unread=%->% | lost user confirm=% | verified=% | contact=% | recovered=%/% | in feed=% | manual=% | after reject=% | notif A=% B=%',
    case when v_details ->> 'private_details' is null
          and (v_details ->> 'has_private_details')::boolean then 'yes' else 'NO' end,
    (select count(*) from public.matches
      where lost_report_id = v_lost.id and found_report_id = v_found.id),
    (select e ->> 'similarity' from jsonb_array_elements(v_matches) e
      where (e ->> 'match_id')::uuid = v_match),
    case when v_count >= 1 then 'yes' else 'NO' end,
    v_matching,
    case when v_status = 'chatting' then 'yes' else v_status end,
    v_unread_1, v_unread_2,
    v_confirm,
    (select case when ownership_verified then 'yes' else 'NO' end from public.matches where id = v_match),
    case when v_contact ->> 'email' is not null then 'yes' else 'NO' end,
    v_lost_status, v_found_status,
    v_feed,
    case when (v_manual_1 ->> 'is_new')::boolean
          and not (v_manual_2 ->> 'is_new')::boolean then 'new then same' else 'WRONG' end,
    v_keys_status,
    v_notif_a, v_notif_b;
end;
$$;
