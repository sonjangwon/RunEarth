// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ThemeRun _$ThemeRunFromJson(Map<String, dynamic> json) => _ThemeRun(
  id: json['id'] as String,
  emoji: json['emoji'] as String,
  name: json['name'] as String,
  desc: json['desc'] as String,
  km: (json['km'] as num).toDouble(),
  img: json['img'] as String,
  courseRoute:
      (json['courseRoute'] as List<dynamic>?)
          ?.map((e) => LatLngPoint.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <LatLngPoint>[],
);

Map<String, dynamic> _$ThemeRunToJson(_ThemeRun instance) => <String, dynamic>{
  'id': instance.id,
  'emoji': instance.emoji,
  'name': instance.name,
  'desc': instance.desc,
  'km': instance.km,
  'img': instance.img,
  'courseRoute': instance.courseRoute,
};
