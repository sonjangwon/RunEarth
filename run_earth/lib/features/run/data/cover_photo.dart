import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// 대표 이미지로 쓸 사진을 고르고 앱 폴더에 보관한다.
///
/// 정본: `camera-permission.md`(촬영/갤러리 두 갈래) · `run-flow.md` 6
/// (`coverImageType: photo`, `coverImageUrl`).
///
/// **리사이즈·압축 기준은 긴 변 1080px · JPEG 85%** (2026-09-23 사용자 결정,
/// `camera-permission.md` 6 의 [미확정] 을 닫은 값). 경로 PNG 도 1080 으로
/// 렌더하고 있어 기준이 같고, 한 장이 대략 200~400KB 라 Storage 업로드에도
/// 부담이 없다. 별도 이미지 패키지 없이 picker 옵션으로 처리한다.
const double _maxSide = 1080;
const int _quality = 85;

/// 사진을 가져올 곳.
enum CoverPhotoSource {
  /// 카메라로 촬영 — OS 권한 다이얼로그가 뜬다.
  camera,

  /// 갤러리에서 선택 — 시스템 선택기라 별도 권한이 필요 없다.
  gallery,
}

/// [source] 에서 사진 1장을 골라 앱 문서 폴더에 복사하고 그 경로를 돌려준다.
///
/// 사용자가 취소하면 null. 권한 거부도 null 로 돌아온다 — `camera-permission.md`
/// 4 가 "차단 팝업 없이 갤러리로 우회 가능" 으로 정한 정책이라 여기서 막지
/// 않는다.
///
/// picker 가 주는 파일은 **캐시 폴더**에 있어 OS 가 언제든 지울 수 있다.
/// 문서 폴더로 복사해야 기록이 사진을 계속 들고 있다(경로 PNG 와 같은 자리).
Future<String?> pickCoverPhoto(CoverPhotoSource source, {String? id}) async {
  final picked = await ImagePicker().pickImage(
    source: source == CoverPhotoSource.camera
        ? ImageSource.camera
        : ImageSource.gallery,
    // 가로·세로 상한을 같이 주면 비율을 지키며 긴 변이 1080 에 맞춰진다.
    maxWidth: _maxSide,
    maxHeight: _maxSide,
    imageQuality: _quality,
  );
  if (picked == null) return null;

  final dir = await getApplicationDocumentsDirectory();
  final name = 'photo_${id ?? DateTime.now().millisecondsSinceEpoch}.jpg';
  final dest = File('${dir.path}${Platform.pathSeparator}$name');
  await dest.writeAsBytes(await picked.readAsBytes());
  return dest.path;
}
