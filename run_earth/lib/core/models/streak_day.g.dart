// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'streak_day.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StreakDay _$StreakDayFromJson(Map<String, dynamic> json) => _StreakDay(
  name: json['name'] as String,
  date: json['date'] as String,
  ran: json['ran'] as bool,
  consec: (json['consec'] as num?)?.toInt(),
  today: json['today'] as bool? ?? false,
  future: json['future'] as bool? ?? false,
);

Map<String, dynamic> _$StreakDayToJson(_StreakDay instance) =>
    <String, dynamic>{
      'name': instance.name,
      'date': instance.date,
      'ran': instance.ran,
      'consec': instance.consec,
      'today': instance.today,
      'future': instance.future,
    };
