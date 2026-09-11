import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/app_user.dart';
import '../../../services/supabase/supabase_config.dart';
import 'auth_config.dart';
import 'user_repository.dart';

/// Supabase 인증 상태 스트림 (로그인/로그아웃/토큰 자동갱신 이벤트).
/// 라우터 세션 가드의 갱신 트리거로도 쓰인다.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// 현재 로그인 세션 (없으면 null). 동기 조회.
Session? currentSession() => Supabase.instance.client.auth.currentSession;

/// 구글 로그인 / 로그아웃 액션.
///
/// 흐름: 네이티브 google_sign_in(v7) 으로 idToken 획득 →
/// `supabase.auth.signInWithIdToken` 으로 Supabase 세션 발급.
class AuthService {
  AuthService(this._client, this._users);
  final SupabaseClient _client;
  final UserRepository _users;

  bool _gsiInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_gsiInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: AuthConfig.googleWebClientId,
    );
    _gsiInitialized = true;
  }

  Future<void> signInWithGoogle() async {
    final gsi = GoogleSignIn.instance;
    if (!gsi.supportsAuthenticate()) {
      throw const AuthException('이 플랫폼에서는 구글 로그인을 지원하지 않습니다.');
    }
    await _ensureGoogleInitialized();

    final account = await gsi.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthException('구글 idToken을 받지 못했습니다.');
    }

    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );

    // 최초 로그인이면 서버 users 행 생성. 오프라인 등으로 실패해도 로그인
    // 자체는 성공시킨다(스플래시에서 다음 실행 때 다시 시도).
    try {
      await _users.ensureUserRow();
    } catch (_) {}
  }

  Future<void> signOut() async {
    await GoogleSignIn.instance.signOut();
    await _client.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.watch(supabaseClientProvider),
    ref.watch(userRepositoryProvider),
  ),
);

/// 현재 로그인 유저(서버 `users` 행). 세션이 없으면 null.
/// 로그인/로그아웃 이벤트마다 자동으로 다시 조회한다.
final currentAppUserProvider = FutureProvider<AppUser?>((ref) async {
  ref.watch(authStateChangesProvider);
  return ref.watch(userRepositoryProvider).loadCurrentUser();
});
