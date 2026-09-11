-- users — 앱 사용자 프로필
-- 정본: docs/features/auth-onboarding.md 6, profile-settings.md 6
--
-- id 는 auth.users(id) 를 그대로 PK 로 참조한다. RLS 도 auth.uid() 기준이라
-- 소셜 계정 병합 정책(2026-08-30 결정)과 일관된다.
--
-- streak 컬럼은 두지 않는다 — 로컬 러닝 기록에서 계산되는 파생값이라
-- 서버에 복제하면 로컬 계산값과 어긋난다(2026-09-12 결정).
-- apple_watch / galaxy_watch 는 계산할 수 없는 저장 상태라 컬럼으로 둔다
-- (실제 사용은 wearable-sync.md, MVP 이후).

create table public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  avatar text not null default '',
  provider text not null,
  created_at timestamptz not null default now(),
  deleted_at timestamptz,
  apple_watch boolean not null default false,
  galaxy_watch boolean not null default false
);

alter table public.users enable row level security;

create policy users_select_own on public.users
  for select using (auth.uid() = id);
create policy users_insert_own on public.users
  for insert with check (auth.uid() = id);
create policy users_update_own on public.users
  for update using (auth.uid() = id) with check (auth.uid() = id);

-- delete 정책 없음 — 회원탈퇴는 deleted_at 소프트 삭제(profile-settings.md).
