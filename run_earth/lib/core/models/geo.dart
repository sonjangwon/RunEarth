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
/// [e] 는 같은 좌표의 **달린 시간** — 러닝 시작부터의 누적 밀리초이되
/// **일시정지 시간은 빠져 있다.** 구간 페이스는 이 값으로 계산한다.
///
/// [t] 를 두고도 [e] 가 필요한 이유: [t] 는 벽시계라 쉰 시간이 그대로 들어
/// 있다. 2km 에서 5분 쉬면 그 구간만 페이스가 11'20"(실제 6'20") 로 튀고,
/// 화면에 뜨는 총 시간(쉰 시간 제외)과도 어긋난다. 둘 다 달리는 순간에만
/// 적을 수 있는 값이라 함께 남긴다(2026-09-21 사용자 결정).
///
/// 이름이 한 글자인 이유: 경로 한 건이 좌표 수천 개고 JSON 문자열로 통째
/// 저장·업로드된다. 키 이름이 곧 용량이다.
@freezed
abstract class LatLngPoint with _$LatLngPoint {
  const factory LatLngPoint({
    required double lat,
    required double lng,
    int? t,
    int? e,
  }) = _LatLngPoint;

  factory LatLngPoint.fromJson(Map<String, dynamic> json) =>
      _$LatLngPointFromJson(json);
}
