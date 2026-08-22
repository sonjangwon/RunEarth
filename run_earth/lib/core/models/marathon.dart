import 'package:freezed_annotation/freezed_annotation.dart';

part 'marathon.freezed.dart';
part 'marathon.g.dart';

/// 온라인 마라톤 챌린지.
/// 정본: `Run Earth_기능정의서.md` 6-6 + records.md 5(`id`, `courseId` 추가).
/// `id` = 챌린지(회차) 고유 ID, `courseId` = 코스 고유 ID(여러 회차가 공유 가능).
@freezed
abstract class Marathon with _$Marathon {
  const factory Marathon({
    required String id,
    required String courseId,
    required String name,
    required String distance, // "21.1km"
    required String course, // "평지 코스"
    required String location, // "서울 · 반포한강공원"
    required String dday, // "D-12"
    required String prize, // "금메달 + 5,000P"
    required String prizeEmoji, // "🥇"
    @Default(false) bool joined,
    @Default(false) bool ended,
    required String participants, // "1,204"
    String? myRank, // "현재 1위" (미참가 시 null)
    String? myTime, // "1:31:22" (미참가 시 null) — 최고 기록 기준
    required String img,
  }) = _Marathon;

  factory Marathon.fromJson(Map<String, dynamic> json) =>
      _$MarathonFromJson(json);
}
