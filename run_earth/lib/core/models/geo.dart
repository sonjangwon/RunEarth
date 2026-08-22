import 'package:freezed_annotation/freezed_annotation.dart';

part 'geo.freezed.dart';
part 'geo.g.dart';

/// 좌표 한 점 (테마 코스 경로 등에서 사용).
/// 정본: theme-running.md 6 (`courseRoute: { lat, lng }[]`).
@freezed
abstract class LatLngPoint with _$LatLngPoint {
  const factory LatLngPoint({
    required double lat,
    required double lng,
  }) = _LatLngPoint;

  factory LatLngPoint.fromJson(Map<String, dynamic> json) =>
      _$LatLngPointFromJson(json);
}
