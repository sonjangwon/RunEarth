// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'geo.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LatLngPoint _$LatLngPointFromJson(Map<String, dynamic> json) => _LatLngPoint(
  lat: (json['lat'] as num).toDouble(),
  lng: (json['lng'] as num).toDouble(),
  t: (json['t'] as num?)?.toInt(),
  e: (json['e'] as num?)?.toInt(),
);

Map<String, dynamic> _$LatLngPointToJson(_LatLngPoint instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      't': instance.t,
      'e': instance.e,
    };
