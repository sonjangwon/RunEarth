import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';

part 'app_user.freezed.dart';
part 'app_user.g.dart';

/// 연동된 웨어러블 기기 상태 (auth-onboarding.md 6, profile-settings.md 6).
@freezed
abstract class ConnectedDevices with _$ConnectedDevices {
  const factory ConnectedDevices({
    @Default(false) bool appleWatch,
    @Default(false) bool galaxyWatch,
  }) = _ConnectedDevices;

  factory ConnectedDevices.fromJson(Map<String, dynamic> json) =>
      _$ConnectedDevicesFromJson(json);
}

/// 사용자.
///
/// 정본: auth-onboarding.md 6 + profile-settings.md 6.
/// (Supabase 의 `User` 와 이름 충돌을 피하려고 `AppUser` 로 명명)
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String name,
    required String avatar,
    @Default(0) int streak,
    required AuthProvider provider,
    required String createdAt,
    String? deletedAt,
    @Default(ConnectedDevices()) ConnectedDevices connectedDevices,
  }) = _AppUser;

  factory AppUser.fromJson(Map<String, dynamic> json) =>
      _$AppUserFromJson(json);
}
