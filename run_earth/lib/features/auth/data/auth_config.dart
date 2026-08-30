/// 인증 관련 설정. 값은 gitignore된 `env.json`(--dart-define-from-file) 에서 주입.
class AuthConfig {
  const AuthConfig._();

  /// 구글 OAuth **웹** 클라이언트 ID. 네이티브 로그인의 serverClientId 로 쓰여
  /// Supabase 가 검증할 idToken 을 발급받는 데 필요하다.
  /// (Google Cloud Console → Credentials → OAuth 2.0 Client IDs → Web)
  static const googleWebClientId =
      String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  /// 로그인 강제 게이트. true 면 세션 없을 때 로그인 화면으로 강제 이동.
  /// 개발 중 구글 자격증명이 아직 없으면 env.json 에서 false 로 두어 우회한다.
  static const gateEnabled = bool.fromEnvironment('AUTH_GATE', defaultValue: true);

  static bool get isGoogleConfigured => googleWebClientId.isNotEmpty;
}
