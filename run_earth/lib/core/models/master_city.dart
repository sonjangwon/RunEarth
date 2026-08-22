import 'package:freezed_annotation/freezed_annotation.dart';

part 'master_city.freezed.dart';
part 'master_city.g.dart';

/// 여정 마스터 경로의 도시.
/// 정본: journey.md 6 (`MasterCity`).
@freezed
abstract class MasterCity with _$MasterCity {
  const factory MasterCity({
    required String id,
    required String name,
    String? countryName,
    required double lat,
    required double lng,
    required double cumulativeKm, // 서울시청 기준 누적 거리
    @Default(false) bool isStartCandidate,
    required String backgroundImageUrl, // 도시별 랜드마크 이미지
  }) = _MasterCity;

  factory MasterCity.fromJson(Map<String, dynamic> json) =>
      _$MasterCityFromJson(json);
}

/// 사용자의 여정 진행 상태.
/// 정본: journey.md 6 (`JourneyState`).
/// 절대 위치 = assignedStartCity.cumulativeKm + totalDistanceKm.
@freezed
abstract class JourneyState with _$JourneyState {
  const factory JourneyState({
    required String assignedStartCityId,
    required bool startResolvedFromGPS,
    required String startedAt,
    @Default(0) double totalDistanceKm,
    @Default(0) int currentMilestoneIndex,
  }) = _JourneyState;

  factory JourneyState.fromJson(Map<String, dynamic> json) =>
      _$JourneyStateFromJson(json);
}
