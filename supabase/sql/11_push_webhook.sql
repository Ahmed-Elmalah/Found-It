-- =====================================================================
-- FOUND IT - 11: Push webhook
--
-- Every new row in public.notifications calls the Edge Function
-- "send-push" (which sends the push notification with Firebase).
--
-- BEFORE running this file, save the webhook secret in Vault ONCE
-- (run it alone, and never save it in a file):
--
--   select vault.create_secret('<the text in D:\secrets\webhook_secret.txt>', 'webhook_secret');
--
-- It must be the SAME text as the Edge Function secret WEBHOOK_SECRET.
-- Run once, after 08 + 09. Safe to run again.
-- =====================================================================

-- pg_net = lets the database send HTTP requests (in the background,
-- only after the transaction commits).
create extension if not exists pg_net;


create or replace function public.send_push_on_notification()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_secret text;
begin
  select s.decrypted_secret into v_secret
  from vault.decrypted_secrets s
  where s.name = 'webhook_secret'
  limit 1;

  -- no secret yet -> skip the push, but never break the insert
  if v_secret is null then
    raise warning 'send-push: Vault secret "webhook_secret" is missing';
    return new;
  end if;

  perform net.http_post(
    url := 'https://hvhjddtfojwojqiubknu.supabase.co/functions/v1/send-push',
    body := jsonb_build_object(
      'type',   'INSERT',
      'table',  'notifications',
      'schema', 'public',
      'record', to_jsonb(new)
    ),
    headers := jsonb_build_object(
      'Content-Type',     'application/json',
      'x-webhook-secret', v_secret
    ),
    timeout_milliseconds := 5000
  );

  return new;
end;
$$;

revoke execute on function public.send_push_on_notification() from public, anon, authenticated;

drop trigger if exists notifications_send_push on public.notifications;
create trigger notifications_send_push
  after insert on public.notifications
  for each row execute function public.send_push_on_notification();
