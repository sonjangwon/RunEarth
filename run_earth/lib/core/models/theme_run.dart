import 'package:freezed_annotation/freezed_annotation.dart';

import 'geo.dart';

part 'theme_run.freezed.dart';
part 'theme_run.g.dart';

/// 테마 러닝 코스.
/// 정본: `Run Earth_기능정의서.md` 6-5 + theme-running.md 6(`courseRoute`) +
/// badges.md 5(고유 `id` 추가 필요).
@freezed
abstract class ThemeRun with _$ThemeRun {
  const factory ThemeRun({
    required String id,
    required String emoji, // "🐟"
    required String name, // "붕어빵런"
    required String desc,
    required double km,
    required String img, // Unsplash photo ID
    @Default(<LatLngPoint>[]) List<LatLngPoint> courseRoute, // 오버레이용 경로
  }) = _ThemeRun;

  factory ThemeRun.fromJson(Map<String, dynamic> json) =>
      _$ThemeRunFromJson(json);
}
