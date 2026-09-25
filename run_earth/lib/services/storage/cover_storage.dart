/// 대표 이미지 사진의 **파일 이름 규칙과 서버 보관**.
///
/// 로컬 보관(고르기·복사)은 `features/run/data/cover_photo.dart` 가 한다.
/// 이름 규칙이 여기 있는 이유는 **동기화(`services/sync`)도 같은 판정이
/// 필요하기** 때문이다 — `lib/services` 가 `lib/features` 를 import 한 전례가
/// 없고 그 방향을 만들지 않는다.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 버킷 이름. 정본은 `supabase/migrations/20260925010000_create_cover_storage.sql`.
const _bucket = 'run-covers';

/// 앱이 보관하는 사진 파일 이름 앞에 붙는 말.
///
/// 경로 렌더 PNG(`route_*.png`, `route_image_renderer.dart`)와 같은 폴더에
/// 살아서 이름으로 가린다.
const _photoPrefix = 'photo_';

/// [runId] 기록의 사진 파일 이름.
String coverPhotoFileName(String runId) => '$_photoPrefix$runId.jpg';

/// [path] 가 **사용자가 등록한 사진**인지. 경로 렌더 PNG 면 false.
///
/// 대표 이미지를 경로로 되돌려도 `coverImageUrl` 은 지우지 않는다. 그래야
/// "사진 ↔ 경로 이미지 자유 전환"(`run-flow.md` 27-28)이 사진을 다시 고르지
/// 않고도 된다. 대신 지금 들고 있는 게 사진인지 알아야 해서 이 판정이 있다.
bool isCoverPhoto(String? path) =>
    path != null &&
    path.split(Platform.pathSeparator).last.startsWith(_photoPrefix);

/// 사진을 Storage 에 올리고 **객체 경로**를 돌려준다. 올릴 게 없으면 null.
///
/// 돌려주는 것은 URL 이 아니라 경로(`{uid}/{runId}.jpg`)다. 버킷이 private 이라
/// 공개 URL 이 없고, signed URL 은 만료돼 저장해둘 값이 아니다. 경로만 있으면
/// 나중에 어떤 방식으로든 꺼낼 수 있다.
///
/// **사진이 있으면 화면에 걸려 있지 않아도 올린다.** 대표 이미지를 경로로
/// 되돌려도 사진 파일은 남겨두는 정책(2026-09-23)이라, 지금 안 걸려 있다고
/// 건너뛰면 그 사진만 보존에서 빠진다.
///
/// 파일이 사라졌으면(앱 데이터 정리 등) **예외를 던지지 않고 null 을 준다.**
/// 여기서 던지면 기록 자체의 업로드가 막히고 재시도를 무한히 돈다 — 사진 한 장
/// 때문에 기록을 못 올리는 쪽이 더 나쁘다.
Future<String?> uploadCoverPhoto(
  SupabaseClient client, {
  required String userId,
  required String runId,
  required String? localPath,
}) async {
  if (!isCoverPhoto(localPath)) return null;

  final file = File(localPath!);
  if (!await file.exists()) {
    debugPrint('[cover] 사진 파일이 없어 건너뜀: $localPath');
    return null;
  }

  final objectPath = '$userId/$runId.jpg';
  await client.storage.from(_bucket).upload(
        objectPath,
        file,
        // 사진을 바꾸면 같은 경로에 덮어쓴다. 재시도도 멱등해진다.
        fileOptions: const FileOptions(
          contentType: 'image/jpeg',
          upsert: true,
        ),
      );
  return objectPath;
}
