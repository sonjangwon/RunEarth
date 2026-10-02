import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/app_user.dart';
import '../../../services/supabase/supabase_config.dart';
import '../../../services/sync/run_sync_service.dart';
import 'auth_config.dart';
import 'user_repository.dart';

/// Supabase 인증 상태 스트림 (로그인/로그아웃/토큰 자동갱신 이벤트).
/// 라우터 세션 가드의 갱신 트리거로도 쓰인다.
///
/// env.json 미주입 등으로 Supabase 가 초기화되지 않았으면 빈 스트림 —
/// `Supabase.instance` 는 초기화 전에 접근하면 단언(assert)으로 던진다.
final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  if (!SupabaseConfig.isConfigured) return const Stream<AuthState>.empty();
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// 현재 로그인 세션 (없으면 null). 동기 조회.
///
/// Supabase 미초기화 시 던지지 않고 null 을 준다 — 이 함수는 스플래시 부팅
/// 경로에서 불리므로, 여기서 예외가 나면 앱이 스플래시에 갇힌다.
Session? currentSession() {
  if (!SupabaseConfig.isConfigured) return null;
  return Supabase.instance.client.auth.currentSession;
}

/// 구글 로그인 / 로그아웃 액션.
///
/// 흐름: 네이티브 google_sign_in(v7) 으로 idToken 획득 →
/// `supabase.auth.signInWithIdToken` 으로 Supabase 세션 발급.
class AuthService {
  AuthService(this._client, this._users, this._sync);
  final SupabaseClient _client;
  final UserRepository _users;
  final RunSyncService _sync;

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

    // 밀린 기록 업로드. 로그인을 **막 끝낸** 참은 기존 호출 지점 셋(앱 시작 ·
    // 러닝 종료 · 재연결) 어디에도 걸리지 않아, 첫 화면에 '동기화 대기' 딱지가
    // 그대로 보였다(2026-09-23 실기기). 앱을 껐다 켜야 올라갔다.
    //
    // 화면이 아니라 여기에 두는 이유는 카카오·네이버가 붙어도 이 한 곳을
    // 지나가기 때문이다. 결과를 기다리지 않는다 — 로그인 버튼의 스피너가
    // 업로드가 끝날 때까지 돌면 안 된다.
    unawaited(_sync.syncNow());
    // 서버의 내 기록을 내려받는다 — 재설치·기기 변경 후 로그인하면 여기서
    // 기록이 돌아온다(offline-handling.md §4-1).
    unawaited(_sync.pullNow());
  }

  /// 로그아웃 — 해당 기기의 세션만 삭제한다(session-policy.md 4, 다기기 유지).
  Future<void> signOut() async {
    await _clearGoogleCache();
    await _client.auth.signOut();
  }

  /// 회원탈퇴 — `deleted_at` 소프트 삭제 후 **전체 기기** 세션 무효화.
  ///
  /// 로그아웃은 해당 기기만, 회원탈퇴는 전체다(session-policy.md 4).
  /// 다른 기기에 세션이 남아 있으면 탈퇴한 계정으로 계속 앱을 쓸 수 있다.
  ///
  /// 순서가 중요하다 — 세션을 먼저 지우면 `deleted_at` 을 쓸 권한
  /// (RLS `auth.uid() = id`)이 사라져 탈퇴가 서버에 남지 않는다.
  Future<void> deleteAccount() async {
    await _users.markDeleted();
    await _clearGoogleCache();
    await _client.auth.signOut(scope: SignOutScope.global);
  }

  /// 구글 쪽 캐시 정리. **실패해도 넘어간다** — 앱을 껐다 켜서 세션이
  /// 복원된 상태면 `_gsiInitialized` 가 false 라 `signOut()` 이 "초기화되지
  /// 않았다"로 던지고, 그대로 두면 **Supabase 세션 삭제까지 막힌다.**
  /// 로그아웃·탈퇴를 누르는 경로가 대개 이 상황이다.
  Future<void> _clearGoogleCache() async {
    try {
      await _ensureGoogleInitialized();
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }
}

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(
    ref.watch(supabaseClientProvider),
    ref.watch(userRepositoryProvider),
    ref.watch(runSyncServiceProvider),
  ),
);

/// 현재 로그인 유저(서버 `users` 행). 세션이 없으면 null.
/// 로그인/로그아웃 이벤트마다 자동으로 다시 조회한다.
final currentAppUserProvider = FutureProvider<AppUser?>((ref) async {
  ref.watch(authStateChangesProvider);
  return ref.watch(userRepositoryProvider).loadCurrentUser();
});
