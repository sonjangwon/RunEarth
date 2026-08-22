// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ConnectedDevices _$ConnectedDevicesFromJson(Map<String, dynamic> json) =>
    _ConnectedDevices(
      appleWatch: json['appleWatch'] as bool? ?? false,
      galaxyWatch: json['galaxyWatch'] as bool? ?? false,
    );

Map<String, dynamic> _$ConnectedDevicesToJson(_ConnectedDevices instance) =>
    <String, dynamic>{
      'appleWatch': instance.appleWatch,
      'galaxyWatch': instance.galaxyWatch,
    };

_AppUser _$AppUserFromJson(Map<String, dynamic> json) => _AppUser(
  id: json['id'] as String,
  name: json['name'] as String,
  avatar: json['avatar'] as String,
  streak: (json['streak'] as num?)?.toInt() ?? 0,
  provider: $enumDecode(_$AuthProviderEnumMap, json['provider']),
  createdAt: json['createdAt'] as String,
  deletedAt: json['deletedAt'] as String?,
  connectedDevices: json['connectedDevices'] == null
      ? const ConnectedDevices()
      : ConnectedDevices.fromJson(
          json['connectedDevices'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$AppUserToJson(_AppUser instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatar': instance.avatar,
  'streak': instance.streak,
  'provider': _$AuthProviderEnumMap[instance.provider]!,
  'createdAt': instance.createdAt,
  'deletedAt': instance.deletedAt,
  'connectedDevices': instance.connectedDevices,
};

const _$AuthProviderEnumMap = {
  AuthProvider.kakao: 'kakao',
  AuthProvider.naver: 'naver',
  AuthProvider.google: 'google',
};
