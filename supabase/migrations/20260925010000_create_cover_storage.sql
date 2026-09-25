-- run-covers — 사용자가 등록한 대표 이미지(사진) 보관용 Storage 버킷
-- 정본: camera-permission.md 6 · run-flow.md 6 (coverImageType/coverImageUrl)
--
-- 2026-09-12 에는 "커버 이미지를 서버에 올리지 않는다"고 정했다. 그때 근거는
-- "route 좌표만 있으면 어디서든 다시 렌더할 수 있다" 였는데, **사용자가 찍은
-- 사진에는 그 근거가 성립하지 않는다** — 좌표로 복원할 수 없어 기기를 잃거나
-- 앱 데이터를 지우면 영구 소실이다. 그래서 사진만 올린다(2026-09-23 결정).
-- 자동 생성 경로 이미지(route_*.png)는 여전히 올리지 않는다.
--
-- 지금 만드는 것은 **보존**이다. 서버에서 되받는 경로(기록 다운로드)는 아직
-- 없으므로, 기기를 바꿨을 때 사진이 되살아나지는 않는다. 복원 기능이 생길 때
-- 꺼내 쓸 수 있도록 먼저 쌓아둔다.
--
-- private 버킷이다. 개인 러닝 사진이고, 화면에 그릴 때는 로컬 파일을 쓰므로
-- 공개 URL 이 필요 없다. 복원 기능을 만들 때 signed URL 을 발급하면 된다.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'run-covers',
  'run-covers',
  false,
  2097152,                    -- 2MB. 긴 변 1080px · JPEG 85% 는 200~400KB 다
  array['image/jpeg']
)
on conflict (id) do nothing;

-- 객체 경로는 '{auth.uid()}/{run_id}.jpg' — 첫 칸이 자기 uid 인 것만 허용한다.
-- 사진을 바꾸면 같은 경로에 덮어쓰므로(upsert) insert 와 update 가 다 필요하다.

create policy run_covers_select_own on storage.objects
  for select using (
    bucket_id = 'run-covers'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy run_covers_insert_own on storage.objects
  for insert with check (
    bucket_id = 'run-covers'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy run_covers_update_own on storage.objects
  for update using (
    bucket_id = 'run-covers'
    and (storage.foldername(name))[1] = auth.uid()::text
  ) with check (
    bucket_id = 'run-covers'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

-- delete 정책 없음 — public.runs 와 같은 원칙이다("사용자는 과거 기록을
-- 삭제할 수 없다", records.md 22). 사진 교체는 덮어쓰기로 처리된다.
