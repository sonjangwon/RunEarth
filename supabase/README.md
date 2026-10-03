# Supabase 스키마

`migrations/` 의 SQL 이 서버 스키마의 정본이다. 새 환경(스테이징 등)을 만들 때
파일명 순서대로 실행하면 동일한 스키마가 재현된다.

## 지금까지의 적용 방식 ⚠️

MVP 는 serverless 라 Supabase CLI 를 아직 붙이지 않았다. 지금까지의 마이그레이션은
**대시보드 SQL Editor 에 직접 붙여넣어 실행**했고, 이 폴더의 파일은 그때 실행한
SQL 을 그대로 기록해둔 것이다.

따라서 **스키마를 바꿀 때는 두 가지를 반드시 같이 한다**:
1. 대시보드에서 SQL 실행
2. 같은 SQL 을 이 폴더에 새 파일로 추가하고 커밋

둘 중 하나를 빠뜨리면 저장소와 실제 서버가 어긋난다. (CLI 를 도입하면
`supabase db push` 로 이 수작업을 없앨 수 있다 — 아직 미도입.)

## 파일

| 파일 | 내용 | 적용일 |
|---|---|---|
| `20260912020000_create_users.sql` | `public.users` + RLS 3종 | 2026-09-12 |
| `20260912030000_create_runs.sql` | `public.runs` + 인덱스 + RLS 3종 | 2026-09-12 |
| `20260925010000_create_cover_storage.sql` | `run-covers` Storage 버킷(private) + `storage.objects` RLS 3종 | 2026-09-25 |
| `20261003010000_schedule_purge_deleted_users.sql` | pg_cron·pg_net + 매일 04:00 KST 에 `purge-deleted-users` 호출. **비밀값은 Vault 에 따로**(파일엔 자리표시만) | 2026-10-03 |

## Edge Functions

`functions/` 도 대시보드(Edge Functions → Via Editor)에 붙여넣어 배포했다. 코드를
바꾸면 **대시보드 재배포 + 이 폴더 커밋**을 같이 한다(마이그레이션과 같은 규칙).

| 함수 | 내용 | 설정 |
|---|---|---|
| `purge-deleted-users` | 탈퇴 30일 지난 계정의 사진 → auth 계정 삭제(users·runs cascade). `?dry=1` 은 대상 수만 | **Verify JWT 끔**. Secret `PURGE_SECRET` = Vault `purge_secret` 과 **같은 값**이어야 한다 |

> **⚠️ 비밀값이 어긋나면 조용히 실패한다 (2026-10-03 실제로 겪음).** Vault 에 자리표시
> 글자(7자)가 들어가 예약 호출이 매일 `403` 을 받을 뻔했다. 화면엔 오류가 안 뜬다.
> 바꾼 뒤에는 **예약과 같은 경로로** 확인한다:
> `select length(decrypted_secret) from vault.decrypted_secrets where name='purge_secret';` → 64,
> 마이그레이션 파일의 `net.http_post` 를 URL 에 `?dry=1` 을 붙여 실행 →
> `select status_code, content from net._http_response order by created desc limit 1;` → `200`.
> 실행 이력은 `cron.job_run_details`.
