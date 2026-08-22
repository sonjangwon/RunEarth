import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'run.freezed.dart';
part 'run.g.dart';

/// 러닝 기록 1건.
///
/// 4개 문서에 분산 정의된 필드를 병합:
/// - 기본: `Run Earth_기능정의서.md` 6-3 (date, day, km, pace, dur, kcal, type, year, month)
///   · `photoUrl` 은 run-flow.md 의 coverImage 로 대체됨
/// - run-flow.md 6: coverImageType, coverImageUrl
/// - records.md 5: marathonChallengeId?, marathonCourseId?, gpsVerified?
/// - wearable-sync.md 6: source
///
/// [id] 는 문서에 없는 기술 필드 — 로컬 DB/서버 동기화용 고유 식별자.
@freezed
abstract class Run with _$Run {
  const factory Run({
    required String id,
    required String date, // "06.30"
    required String day, // "화"
    required double km, // 8.4
    required String pace, // "5'12\""
    required String dur, // "43:41"
    required int kcal, // 498
    required RecordType type,
    required int year, // 2026
    required int month, // 6
    @Default(CoverImageType.route) CoverImageType coverImageType,
    String? coverImageUrl,
    String? marathonChallengeId,
    String? marathonCourseId,
    bool? gpsVerified,
    @Default(RunSource.app) RunSource source,
  }) = _Run;

  factory Run.fromJson(Map<String, dynamic> json) => _$RunFromJson(json);
}
