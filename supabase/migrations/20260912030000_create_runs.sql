-- runs — 러닝 기록
-- 정본: docs/Run Earth_기능정의서.md 6-3 + run-flow.md 6 + records.md 5 + wearable-sync.md 6
--       (코드 정본은 run_earth/lib/core/models/run.dart)
--
-- id 는 앱이 만든다('run_<microsecondsSinceEpoch>'). 오프라인에서 러닝을
-- 끝내도 서버를 기다리지 않고 식별자가 확정돼야 하기 때문.
--
-- cover_image_url 은 현재 항상 null 로 올라온다 — 로컬 값이 이 기기의 파일
-- 경로라 다른 기기에서 의미가 없고, route 좌표만 있으면 다시 렌더할 수 있어
-- Storage 가 불필요하다(2026-09-12 결정). 사용자가 올린 사진을 지원할 때 재검토.

create table public.runs (
  id text primary key,
  user_id uuid not null references public.users(id) on delete cascade,
  date text not null,
  day text not null,
  km double precision not null,
  pace text not null,
  dur text not null,
  kcal integer not null,
  type text not null,
  year integer not null,
  month integer not null,
  cover_image_type text not null default 'route',
  cover_image_url text,
  marathon_challenge_id text,
  marathon_course_id text,
  gps_verified boolean,
  source text not null default 'app',
  route jsonb,
  created_at timestamptz not null default now()
);

create index runs_user_idx on public.runs(user_id);

alter table public.runs enable row level security;

create policy runs_select_own on public.runs
  for select using (auth.uid() = user_id);
create policy runs_insert_own on public.runs
  for insert with check (auth.uid() = user_id);
create policy runs_update_own on public.runs
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- delete 정책 없음 — "사용자는 과거 기록을 삭제할 수 없다"(records.md 22).
