// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Run _$RunFromJson(Map<String, dynamic> json) => _Run(
  id: json['id'] as String,
  date: json['date'] as String,
  day: json['day'] as String,
  km: (json['km'] as num).toDouble(),
  pace: json['pace'] as String,
  dur: json['dur'] as String,
  kcal: (json['kcal'] as num).toInt(),
  type: $enumDecode(_$RecordTypeEnumMap, json['type']),
  year: (json['year'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  coverImageType:
      $enumDecodeNullable(_$CoverImageTypeEnumMap, json['coverImageType']) ??
      CoverImageType.route,
  coverImageUrl: json['coverImageUrl'] as String?,
  marathonChallengeId: json['marathonChallengeId'] as String?,
  marathonCourseId: json['marathonCourseId'] as String?,
  gpsVerified: json['gpsVerified'] as bool?,
  source:
      $enumDecodeNullable(_$RunSourceEnumMap, json['source']) ?? RunSource.app,
);

Map<String, dynamic> _$RunToJson(_Run instance) => <String, dynamic>{
  'id': instance.id,
  'date': instance.date,
  'day': instance.day,
  'km': instance.km,
  'pace': instance.pace,
  'dur': instance.dur,
  'kcal': instance.kcal,
  'type': _$RecordTypeEnumMap[instance.type]!,
  'year': instance.year,
  'month': instance.month,
  'coverImageType': _$CoverImageTypeEnumMap[instance.coverImageType]!,
  'coverImageUrl': instance.coverImageUrl,
  'marathonChallengeId': instance.marathonChallengeId,
  'marathonCourseId': instance.marathonCourseId,
  'gpsVerified': instance.gpsVerified,
  'source': _$RunSourceEnumMap[instance.source]!,
};

const _$RecordTypeEnumMap = {
  RecordType.normal: '일반',
  RecordType.theme: '테마',
  RecordType.online: '온라인',
};

const _$CoverImageTypeEnumMap = {
  CoverImageType.photo: 'photo',
  CoverImageType.route: 'route',
};

const _$RunSourceEnumMap = {
  RunSource.app: 'app',
  RunSource.appleHealth: 'apple_health',
  RunSource.samsungHealth: 'samsung_health',
};
