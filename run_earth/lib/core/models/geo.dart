import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo.freezed.dart';
part 'geo.g.dart';

/// 좌표 한 점.
/// 정본: theme-running.md 6 (`courseRoute`), run-flow.md 6 (`route`).
///
/// [t] 는 **러닝 경로에만** 채운다 — 그 좌표를 지난 시각(UTC epoch 밀리초).
/// 구간 페이스(KM splits)를 내려면 좌표마다 시각이 있어야 하는데, 이건
/// 달리는 그 순간에 적어두지 않으면 나중에 복원할 방법이 없다(2026-09-21).
///
/// 테마 코스(`ThemeRun.courseRoute`)처럼 미리 정해둔 경로는 비워 둔다 —
/// 지도에 그릴 선일 뿐이라 '몇 시에 여기 있었나'가 성립하지 않는다.
/// 그래서 필수가 아니라 선택 필드다. 예전 기록도 이 값 없이 그대로 읽힌다.
///
/// 이름이 한 글자인 이유: 경로 한 건이 좌표 수천 개고 JSON 문자열로 통째
/// 저장·업로드된다. 키 이름이 곧 용량이다.
@freezed
abstract class LatLngPoint with _$LatLngPoint {
  const factory LatLngPoint({
    required double lat,
    required double lng,
    int? t,
  }) = _LatLngPoint;

  factory LatLngPoint.fromJson(Map<String, dynamic> json) =>
      _$LatLngPointFromJson(json);
}
