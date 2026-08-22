// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_badge.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppBadge _$AppBadgeFromJson(Map<String, dynamic> json) => _AppBadge(
  id: json['id'] as String,
  type: $enumDecode(_$BadgeTypeEnumMap, json['type']),
  emoji: json['emoji'] as String,
  name: json['name'] as String,
  earned: json['earned'] as bool? ?? false,
  earnedAt: json['earnedAt'] as String?,
  refId: json['refId'] as String,
);

Map<String, dynamic> _$AppBadgeToJson(_AppBadge instance) => <String, dynamic>{
  'id': instance.id,
  'type': _$BadgeTypeEnumMap[instance.type]!,
  'emoji': instance.emoji,
  'name': instance.name,
  'earned': instance.earned,
  'earnedAt': instance.earnedAt,
  'refId': instance.refId,
};

const _$BadgeTypeEnumMap = {
  BadgeType.themeCourse: 'theme_course',
  BadgeType.marathonMonthly: 'marathon_monthly',
  BadgeType.milestoneCity: 'milestone_city',
};
