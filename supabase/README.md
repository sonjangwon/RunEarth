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
| `20260925010000_create_cover_storage.sql` | `run-covers` Storage 버킷(private) + `storage.objects` RLS 3종 | **대시보드 실행 대기** |
