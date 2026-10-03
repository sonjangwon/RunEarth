// 탈퇴 30일이 지난 계정을 영구 삭제한다. 정본: docs/features/profile-settings.md 3 '회원탈퇴 플로우'.
//
// 앱은 탈퇴 시 users.deleted_at 만 찍는다(소프트 삭제). 30일 안에 다시 로그인하면
// 복구되고(user_repository.dart), 30일이 지나면 이 함수가 지운다.
//
// 순서: ① Storage 사진 `{uid}/` 삭제 → ② auth 계정 삭제.
//   - 사진은 SQL 로 지울 수 없어(Storage API 전용) 여기서 지운다. 남기면 개인정보가
//     고아 파일로 남는다.
//   - auth 계정을 지우면 public.users → public.runs 가 FK cascade 로 함께 지워진다.
//   - 중간에 실패해도 deleted_at 이 그대로라 다음 날 다시 시도된다(멱등).
//
// 호출: pg_cron 이 매일 04:00 KST 에 부른다(supabase/migrations/20261003010000_*.sql).
//   - `x-purge-secret` 헤더가 PURGE_SECRET 과 같아야 한다. 대시보드에서 이 함수의
//     "Verify JWT" 는 끈다 — 비밀 헤더로 대신 막는다.
//   - `?dry=1` 이면 지우지 않고 대상 수만 돌려준다.
//   - 로그·응답에 이메일을 남기지 않는다. 사용자 id 도 응답에는 수만 싣는다.

import { createClient } from "jsr:@supabase/supabase-js@2";

const RETENTION_DAYS = 30;
const BUCKET = "run-covers";

Deno.serve(async (req) => {
  const secret = Deno.env.get("PURGE_SECRET");
  if (!secret || req.headers.get("x-purge-secret") !== secret) {
    return new Response("forbidden", { status: 403 });
  }
  const dry = new URL(req.url).searchParams.get("dry") === "1";

  const admin = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
    { auth: { persistSession: false } },
  );

  const cutoff = new Date(Date.now() - RETENTION_DAYS * 86_400_000).toISOString();
  const { data: targets, error } = await admin
    .from("users")
    .select("id")
    .not("deleted_at", "is", null)
    .lt("deleted_at", cutoff);
  if (error) return json({ error: "select users failed" }, 500);

  if (dry) return json({ dry: true, cutoff, targets: targets.length });

  let purged = 0;
  const failed: { step: string }[] = [];
  for (const { id } of targets) {
    // ① 사진 — 폴더가 비어 있어도 정상.
    const removed = await removePhotos(admin, id);
    if (!removed) {
      failed.push({ step: "storage" });
      continue; // 사진을 못 지웠으면 계정도 남긴다 — 내일 다시.
    }
    // ② 계정 → users·runs cascade.
    const { error: delErr } = await admin.auth.admin.deleteUser(id);
    if (delErr) {
      failed.push({ step: "auth" });
      continue;
    }
    purged++;
  }
  console.log(`[purge] cutoff=${cutoff} targets=${targets.length} purged=${purged} failed=${failed.length}`);
  return json({ dry: false, cutoff, targets: targets.length, purged, failed });
});

// deno-lint-ignore no-explicit-any
async function removePhotos(admin: any, uid: string): Promise<boolean> {
  for (;;) {
    const { data: files, error } = await admin.storage.from(BUCKET).list(uid, { limit: 1000 });
    if (error) return false;
    if (!files || files.length === 0) return true;
    const paths = files.map((f: { name: string }) => `${uid}/${f.name}`);
    const { error: rmErr } = await admin.storage.from(BUCKET).remove(paths);
    if (rmErr) return false;
    if (files.length < 1000) return true;
  }
}

function json(body: unknown, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { "Content-Type": "application/json" },
  });
}
