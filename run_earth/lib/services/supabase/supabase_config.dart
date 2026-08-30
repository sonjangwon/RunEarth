import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase 접속 설정.
///
/// 값은 gitignore된 `env.json` 에서 `--dart-define-from-file` 로 주입한다.
/// 실행: `flutter run --dart-define-from-file=env.json`
/// (키를 소스에 하드코딩하지 않기 위함 — Google Maps secrets 와 동일한 원칙)
class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  /// env.json 이 주입돼 접속 값이 채워졌는지.
  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;
}

/// 앱 전역에서 공유하는 Supabase 클라이언트.
/// [Supabase.initialize] (main.dart) 완료 후에만 접근 가능.
final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);
