import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/app_user.dart';
import '../../../core/models/enums.dart';
import '../../../services/supabase/supabase_config.dart';

/// 서버 `public.users` 테이블 접근.
///
/// 정본: auth-onboarding.md 6(User 타입) + profile-settings.md 6.
/// 스키마는 `auth.users.id` 를 PK 로 참조하고 RLS 는 `auth.uid() = id` 기준
/// (2026-08-30 결정 — 계정 병합 정책).
///
/// `streak` 는 서버에 두지 않는다 — 로컬 기록에서 계산되는 파생값이라
/// 서버에 복제하면 로컬 계산값과 어긋난다(2026-09-12 결정).
class UserRepository {
  UserRepository(this._client);
  final SupabaseClient _client;

  static const _table = 'users';

  /// 로그인 직후 호출. 서버에 내 행이 **없을 때만** 만든다.
  ///
  /// upsert 가 아닌 이유: 프로필에서 닉네임을 바꿔도 다음 로그인 때
  /// 소셜 프로필 이름으로 덮어써지는 것을 막기 위함(profile-settings.md).
  Future<void> ensureUserRow() async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final existing = await _client
        .from(_table)
        .select('id')
        .eq('id', user.id)
        .maybeSingle();
    if (existing != null) return;

    await _client.from(_table).insert({
      'id': user.id,
      'name': _nameOf(user),
      'avatar': _avatarOf(user),
      'provider': _providerRawOf(user),
    });
  }

  /// 현재 로그인 유저. 세션이 없으면 null.
  ///
  /// 서버 조회에 실패하면(오프라인·프로젝트 일시정지 등) 세션 메타데이터로
  /// 폴백한다 — 이름이 아예 안 뜨는 상황을 만들지 않기 위함
  /// (offline-handling.md 2 케이스 C 의 "캐시 표시" 원칙).
  Future<AppUser?> loadCurrentUser() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    try {
      final row = await _client
          .from(_table)
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (row != null) return _fromRow(row);
    } catch (_) {
      // 아래 세션 폴백으로 진행.
    }
    return sessionUser(user);
  }

  /// 닉네임 변경. 서버 `users.name` 만 고친다.
  ///
  /// 로컬 미러가 없다 — 이름은 러닝 기록과 달리 서버 한 곳에만 산다.
  /// 그래서 오프라인에서는 저장할 방법이 없고, 화면에서 막는다
  /// (offline-handling.md 2 케이스 D).
  Future<void> updateName(String name) async {
    final user = _client.auth.currentUser;
    if (user == null) throw StateError('로그인 상태가 아닙니다.');
    await _client.from(_table).update({'name': name}).eq('id', user.id);
  }

  AppUser _fromRow(Map<String, dynamic> row) => AppUser(
        id: row['id'] as String,
        name: row['name'] as String? ?? '러너',
        avatar: row['avatar'] as String? ?? '',
        provider: _providerFrom(row['provider'] as String?),
        createdAt: row['created_at'] as String? ?? '',
        deletedAt: row['deleted_at'] as String?,
        connectedDevices: ConnectedDevices(
          appleWatch: row['apple_watch'] as bool? ?? false,
          galaxyWatch: row['galaxy_watch'] as bool? ?? false,
        ),
      );
}

/// 세션 메타데이터만으로 만든 유저(서버 조회 전/실패 시 폴백).
AppUser sessionUser(User user) => AppUser(
      id: user.id,
      name: _nameOf(user),
      avatar: _avatarOf(user),
      provider: _providerFrom(_providerRawOf(user)),
      createdAt: user.createdAt,
    );

/// 서버 조회를 기다리지 않고 즉시 얻는 표시 이름(첫 프레임 깜빡임 방지).
///
/// Supabase 미초기화 시에도 던지지 않고 기본값을 준다(홈·프로필이 이 값을
/// 폴백으로 쓴다).
String sessionDisplayName() {
  if (!SupabaseConfig.isConfigured) return '러너';
  final user = Supabase.instance.client.auth.currentUser;
  return user == null ? '러너' : _nameOf(user);
}

/// 구글 프로필 이름 → 이메일 앞부분 → 기본값 순으로 폴백.
String _nameOf(User user) {
  final meta = user.userMetadata ?? const <String, dynamic>{};
  final name = (meta['full_name'] ?? meta['name']) as String?;
  if (name != null && name.isNotEmpty) return name;
  final email = user.email;
  if (email != null && email.contains('@')) return email.split('@').first;
  return '러너';
}

/// 소셜 프로필 사진 URL. MVP 는 Storage 복사 없이 원본 URL 을 그대로 쓴다
/// (2026-09-12 결정 — 만료되면 이니셜/이모지 폴백으로 충분).
String _avatarOf(User user) {
  final meta = user.userMetadata ?? const <String, dynamic>{};
  return (meta['avatar_url'] ?? meta['picture']) as String? ?? '';
}

String _providerRawOf(User user) =>
    user.appMetadata['provider'] as String? ?? 'google';

AuthProvider _providerFrom(String? raw) => switch (raw) {
      'kakao' => AuthProvider.kakao,
      'naver' => AuthProvider.naver,
      _ => AuthProvider.google,
    };

final userRepositoryProvider = Provider<UserRepository>(
  (ref) => UserRepository(ref.watch(supabaseClientProvider)),
);
