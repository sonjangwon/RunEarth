import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'app_badge.freezed.dart';
part 'app_badge.g.dart';

/// 배지.
/// 정본: badges.md 5 (`Badge`).
/// (Material 위젯 `Badge` 와 이름 충돌을 피하려고 `AppBadge` 로 명명)
/// [refId] 는 type별 참조 대상: theme_course→ThemeRun.id,
/// marathon_monthly→Marathon.id(회차), milestone_city→MasterCity.id.
@freezed
abstract class AppBadge with _$AppBadge {
  const factory AppBadge({
    required String id,
    required BadgeType type,
    required String emoji,
    required String name,
    @Default(false) bool earned,
    String? earnedAt,
    required String refId,
  }) = _AppBadge;

  factory AppBadge.fromJson(Map<String, dynamic> json) =>
      _$AppBadgeFromJson(json);
}
