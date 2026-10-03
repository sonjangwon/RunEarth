-- 탈퇴 30일 후 영구 삭제 — 매일 04:00 KST 에 Edge Function `purge-deleted-users` 를 부른다.
-- 정본: docs/features/profile-settings.md 3 '회원탈퇴 플로우' · 8 완료 조건.
--
-- ⚠️ 이 파일에는 비밀값이 없다. 실행 전에 아래 [1] 을 **실제 값으로 따로** 실행하고,
--    그 값은 저장소에 커밋하지 않는다(Vault 에만 둔다).
--
-- pg_cron 은 UTC 로 돈다. 04:00 KST = 전날 19:00 UTC.

create extension if not exists pg_cron;
create extension if not exists pg_net;

-- [1] 비밀값 — SQL Editor 에서 실제 값으로 바꿔 **한 번만** 실행. (여기엔 자리표시만 둔다)
-- select vault.create_secret('<PURGE_SECRET 과 같은 값>', 'purge_secret');
-- select vault.create_secret('https://<project-ref>.supabase.co/functions/v1/purge-deleted-users', 'purge_url');

-- [2] 예약
select cron.schedule(
  'purge-deleted-users',
  '0 19 * * *',
  $$
  select net.http_post(
    url := (select decrypted_secret from vault.decrypted_secrets where name = 'purge_url'),
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'x-purge-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'purge_secret')
    ),
    body := '{}'::jsonb,
    timeout_milliseconds := 60000
  );
  $$
);

-- 확인: select * from cron.job where jobname = 'purge-deleted-users';
-- 실행 이력: select * from cron.job_run_details order by start_time desc limit 5;
-- 해제: select cron.unschedule('purge-deleted-users');
