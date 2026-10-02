import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 설정 하단의 앱 버전 — `v1.0.0 (1)` 형식. 규칙 정본: profile-settings.md 3.
///
/// 값은 설치된 빌드에서 읽는다(`pubspec.yaml` 의 `version` 이 빌드에 박힌 것).
final appVersionProvider = FutureProvider<String>((ref) async {
  final info = await PackageInfo.fromPlatform();
  return 'v${info.version} (${info.buildNumber})';
});
