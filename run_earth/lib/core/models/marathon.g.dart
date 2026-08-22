// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marathon.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Marathon _$MarathonFromJson(Map<String, dynamic> json) => _Marathon(
  id: json['id'] as String,
  courseId: json['courseId'] as String,
  name: json['name'] as String,
  distance: json['distance'] as String,
  course: json['course'] as String,
  location: json['location'] as String,
  dday: json['dday'] as String,
  prize: json['prize'] as String,
  prizeEmoji: json['prizeEmoji'] as String,
  joined: json['joined'] as bool? ?? false,
  ended: json['ended'] as bool? ?? false,
  participants: json['participants'] as String,
  myRank: json['myRank'] as String?,
  myTime: json['myTime'] as String?,
  img: json['img'] as String,
);

Map<String, dynamic> _$MarathonToJson(_Marathon instance) => <String, dynamic>{
  'id': instance.id,
  'courseId': instance.courseId,
  'name': instance.name,
  'distance': instance.distance,
  'course': instance.course,
  'location': instance.location,
  'dday': instance.dday,
  'prize': instance.prize,
  'prizeEmoji': instance.prizeEmoji,
  'joined': instance.joined,
  'ended': instance.ended,
  'participants': instance.participants,
  'myRank': instance.myRank,
  'myTime': instance.myTime,
  'img': instance.img,
};
