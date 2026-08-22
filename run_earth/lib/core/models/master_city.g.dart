// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'master_city.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MasterCity _$MasterCityFromJson(Map<String, dynamic> json) => _MasterCity(
  id: json['id'] as String,
  name: json['name'] as String,
  countryName: json['countryName'] as String?,
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  cumulativeKm: (json['cumulativeKm'] as num).toDouble(),
  isStartCandidate: json['isStartCandidate'] as bool? ?? false,
  backgroundImageUrl: json['backgroundImageUrl'] as String,
);

Map<String, dynamic> _$MasterCityToJson(_MasterCity instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'countryName': instance.countryName,
      'lat': instance.lat,
      'lng': instance.lng,
      'cumulativeKm': instance.cumulativeKm,
      'isStartCandidate': instance.isStartCandidate,
      'backgroundImageUrl': instance.backgroundImageUrl,
    };

_JourneyState _$JourneyStateFromJson(Map<String, dynamic> json) =>
    _JourneyState(
      assignedStartCityId: json['assignedStartCityId'] as String,
      startResolvedFromGPS: json['startResolvedFromGPS'] as bool,
      startedAt: json['startedAt'] as String,
      totalDistanceKm: (json['totalDistanceKm'] as num?)?.toDouble() ?? 0,
      currentMilestoneIndex:
          (json['currentMilestoneIndex'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$JourneyStateToJson(_JourneyState instance) =>
    <String, dynamic>{
      'assignedStartCityId': instance.assignedStartCityId,
      'startResolvedFromGPS': instance.startResolvedFromGPS,
      'startedAt': instance.startedAt,
      'totalDistanceKm': instance.totalDistanceKm,
      'currentMilestoneIndex': instance.currentMilestoneIndex,
    };
