import 'package:freezed_annotation/freezed_annotation.dart';

part 'streak_day.freezed.dart';
part 'streak_day.g.dart';

/// 주간 스트릭의 하루.
/// 정본: `Run Earth_기능정의서.md` 6-4, streak.md 2.
@freezed
abstract class StreakDay with _$StreakDay {
  const factory StreakDay({
    required String name, // 요일명 "월"~"일"
    required String date, // 표시 날짜 "7/27"
    required bool ran, // 해당 날 러닝 여부
    int? consec, // 연속 러닝 일수 (ran=false면 null)
    @Default(false) bool today,
    @Default(false) bool future,
  }) = _StreakDay;

  factory StreakDay.fromJson(Map<String, dynamic> json) =>
      _$StreakDayFromJson(json);
}
