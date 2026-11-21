-- =====================================================================
-- FOUND IT - 13: Story #6 test (run AFTER 12)
--
-- Uses the 2 oldest users, same as 10. Nothing to edit.
-- Run the whole block at once. It ENDS WITH AN ERROR ON PURPOSE:
-- the error undoes everything (no test data is left) and its message
-- shows the results.
--
-- Expected message:
--   TEST OK | bad questions=blocked | lost with questions=blocked |
--   owner sees answers=2 | others see answers=no | pending=yes |
--   must answer=yes | finder notified early=0 | chat before answer=blocked/blocked |
--   claimant sees answers=no | passed=true | chat after=yes | claim_passed notif=1 |
--   wrong answer=false | after wrong=rejected/failed | blocked flag=yes |
--   claim again=blocked | engine skipped=yes
-- Any OTHER error = something is wrong -> send it to Claude.
-- =====================================================================
do $$
declare
  v_a          uuid;   -- user A: lost a wallet (claims items)
  v_b          uuid;   -- user B: found things (asks the questions)
  v_cairo      uuid;
  v_maadi      uuid;
  v_wallet     uuid;
  v_other_cat  uuid;
  v_found1     public.report_details;
  v_found2     public.report_details;
  v_lost       public.report_details;
  v_lost2      public.report_details;
  v_dummy      public.report_details;
  v_bad        text;
  v_lost_q     text;
  v_owner_view jsonb;
  v_other_view jsonb;
  v_match      uuid;
  v_match2     uuid;
  v_claim      text;
  v_must       boolean;
  v_early      int;
  v_chat_a     text;
  v_chat_b     text;
  v_questions  jsonb;
  v_right      jsonb;
  v_wrong      jsonb;
  v_result     jsonb;
  v_result2    jsonb;
  v_chat_after text;
  v_passed_n   int;
  v_m2_status  text;
  v_m2_claim   text;
  v_blocked    boolean;
  v_again      text;
  v_engine     int;
  v_q_json     constant jsonb := '[
    {"question": "What color is the wallet?", "correct": "Black", "wrong": ["Brown", "Blue"]},
    {"question": "What is written inside?",   "correct": "A.K.",  "wrong": ["M.S.", "R.T.", "Nothing"]}
  ]';
begin
  select id into v_a from public.profiles order by created_at limit 1;
  select id into v_b from public.profiles order by created_at offset 1 limit 1;
  if v_b is null then
    raise exception 'Create 2 test users first (Authentication -> Users -> Add user)';
  end if;

  select id into v_cairo     from public.cities     where name_en = 'Cairo';
  select id into v_wallet    from public.categories where name_en = 'Wallets';
  select id into v_other_cat from public.categories where id <> v_wallet limit 1;
  select id into v_maadi     from public.areas where city_id = v_cairo and name_en = 'Maadi';

  execute 'set local role authenticated';

  -- 1) B (finder) ----------------------------------------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_b, 'role', 'authenticated')::text, true);

  -- bad questions are refused (only 1 wrong answer)
  begin
    v_dummy := public.create_report(
      'found', 'Test bad questions', v_wallet, v_cairo, v_maadi,
      array['https://example.com/x.jpg'], current_date,
      p_questions => '[{"question": "Color?", "correct": "Black", "wrong": ["Brown"]}]');
    v_bad := 'NOT BLOCKED';
  exception when invalid_parameter_value then
    v_bad := 'blocked';
  end;

  -- a Lost report can't have questions
  begin
    v_dummy := public.create_report(
      'lost', 'Test lost with questions', v_wallet, v_cairo, v_maadi,
      array['https://example.com/x.jpg'], current_date, p_questions => v_q_json);
    v_lost_q := 'NOT BLOCKED';
  exception when invalid_parameter_value then
    v_lost_q := 'blocked';
  end;

  -- the real Found wallet with 2 questions
  v_found1 := public.create_report(
    'found', 'Test found wallet', v_wallet, v_cairo, v_maadi,
    array['https://example.com/b.jpg'], current_date - 1, p_questions => v_q_json);

  v_owner_view := public.get_report_details(v_found1.id);

  -- the correct answers (the owner can read his own questions)
  select jsonb_agg(jsonb_build_object('question_id', q.id, 'choice', q.correct_index)),
         jsonb_agg(jsonb_build_object('question_id', q.id,
                   'choice', (q.correct_index + 1) % cardinality(q.options)))
    into v_right, v_wrong
  from public.report_questions q
  where q.report_id = v_found1.id;

  -- 2) A (owner) reports the Lost wallet -> automatic match -------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_a, 'role', 'authenticated')::text, true);

  v_other_view := public.get_report_details(v_found1.id);

  v_lost := public.create_report(
    'lost', 'Test lost wallet', v_wallet, v_cairo, v_maadi,
    array['https://example.com/a.jpg'], current_date);

  select id, claim_status into v_match, v_claim
  from public.matches
  where lost_report_id = v_lost.id and found_report_id = v_found1.id;

  select (public.get_match_details(v_match) ->> 'i_must_answer')::boolean into v_must;

  -- A can't chat before answering
  begin
    insert into public.messages (match_id, body) values (v_match, 'Hi, it is mine');
    v_chat_a := 'NOT BLOCKED';
  exception when insufficient_privilege then
    v_chat_a := 'blocked';
  end;

  v_questions := public.get_claim_questions(v_match);

  -- 3) B can't chat either, and got no "potential match" yet ----------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_b, 'role', 'authenticated')::text, true);

  begin
    insert into public.messages (match_id, body) values (v_match, 'Describe it please');
    v_chat_b := 'NOT BLOCKED';
  exception when insufficient_privilege then
    v_chat_b := 'blocked';
  end;

  select count(*) into v_early from public.notifications
   where user_id = v_b and match_id = v_match and type = 'potential_match';

  -- 4) A answers correctly -> chat opens --------------------------------
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_a, 'role', 'authenticated')::text, true);

  v_result := public.submit_claim_answers(v_match, v_right);

  begin
    insert into public.messages (match_id, body) values (v_match, 'Thanks! When can we meet?');
    v_chat_after := 'yes';
  exception when insufficient_privilege then
    v_chat_after := 'NO';
  end;

  -- 5) B: second Found item (1 question). A taps "This is Mine" and fails
  perform set_config('request.jwt.claims',
    json_build_object('sub', v_b, 'role', 'authenticated')::text, true);

  select count(*) into v_passed_n from public.notifications
   where user_id = v_b and match_id = v_match and type = 'claim_passed';

  v_found2 := public.create_report(
    'found', 'Test found other item', v_other_cat, v_cairo, v_maadi,
    array['https://example.com/c.jpg'], current_date,
    p_questions => '[{"question": "What brand is it?", "correct": "Nokia", "wrong": ["Samsung", "Apple"]}]');

  select jsonb_agg(jsonb_build_object('question_id', q.id,
                   'choice', (q.correct_index + 1) % cardinality(q.options)))
    into v_wrong
  from public.report_questions q
  where q.report_id = v_found2.id;

  perform set_config('request.jwt.claims',
    json_build_object('sub', v_a, 'role', 'authenticated')::text, true);

  v_match2  := (public.create_manual_match(v_found2.id) ->> 'match_id')::uuid;
  v_result2 := public.submit_claim_answers(v_match2, v_wrong);

  select status, claim_status into v_m2_status, v_m2_claim
  from public.matches where id = v_match2;

  v_blocked := (public.get_report_details(v_found2.id) ->> 'i_am_blocked')::boolean;

  begin
    perform public.create_manual_match(v_found2.id);
    v_again := 'NOT BLOCKED';
  exception when insufficient_privilege then
    v_again := 'blocked';
  end;

  -- 6) A reports a matching Lost item -> the engine must skip him ------
  v_lost2 := public.create_report(
    'lost', 'Test lost other item', v_other_cat, v_cairo, v_maadi,
    array['https://example.com/d.jpg'], current_date);

  select count(*) into v_engine from public.matches
   where lost_report_id = v_lost2.id and found_report_id = v_found2.id;

  raise exception
    'TEST OK | bad questions=% | lost with questions=% | owner sees answers=% | others see answers=% | pending=% | must answer=% | finder notified early=% | chat before answer=%/% | claimant sees answers=% | passed=% | chat after=% | claim_passed notif=% | wrong answer=% | after wrong=%/% | blocked flag=% | claim again=% | engine skipped=%',
    v_bad,
    v_lost_q,
    jsonb_array_length(v_owner_view -> 'questions'),
    case when v_other_view -> 'questions' = 'null'::jsonb
          and (v_other_view ->> 'has_questions')::boolean then 'no' else 'YES' end,
    case when v_claim = 'pending' then 'yes' else coalesce(v_claim, 'NO MATCH') end,
    case when v_must then 'yes' else 'NO' end,
    v_early,
    v_chat_a, v_chat_b,
    case when jsonb_array_length(v_questions) = 2
          and not exists (select 1 from jsonb_array_elements(v_questions) e
                          where e ? 'correct' or e ? 'correct_index') then 'no' else 'YES' end,
    v_result ->> 'passed',
    v_chat_after,
    v_passed_n,
    v_result2 ->> 'passed',
    v_m2_status, v_m2_claim,
    case when v_blocked then 'yes' else 'NO' end,
    v_again,
    case when v_engine = 0 then 'yes' else 'NO' end;
end;
$$;
