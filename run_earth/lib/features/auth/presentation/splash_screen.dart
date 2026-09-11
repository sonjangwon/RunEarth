import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/supabase/supabase_config.dart';
import '../data/auth_config.dart';
import '../data/auth_providers.dart';
import '../data/user_repository.dart';

/// 스플래시 — 앱 실행 직후 브랜드 노출 + 세션 체크(auth-onboarding.md §3).
///
/// 이미지 에셋은 추후 작업 → 지금은 로고 텍스트 플레이스홀더.
/// 세션 체크가 너무 빨리 끝나 화면이 깜빡이지 않도록 최소 노출 시간을 둔다.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  // 최소 노출 시간(깜빡임 방지). auth-onboarding.md §3 [미확정] → 800ms 제안값.
  static const _minSplash = Duration(milliseconds: 800);

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final gate = AuthConfig.gateEnabled && SupabaseConfig.isConfigured;
    final loggedIn = currentSession() != null;

    // 이미 세션이 있는 유저(이 기능 도입 전에 로그인해둔 경우 포함)도 서버
    // users 행을 갖도록 보장한다. 최소 노출 시간과 병렬로 돌리고, 오프라인
    // 이면 조용히 넘어간다(다음 실행 때 재시도) — 앱 진입을 막지 않는다.
    final ensureRow = loggedIn && SupabaseConfig.isConfigured
        ? ref
            .read(userRepositoryProvider)
            .ensureUserRow()
            .timeout(const Duration(seconds: 5))
            .catchError((Object _) {})
        : Future<void>.value();

    await Future.wait([Future<void>.delayed(_minSplash), ensureRow]);
    if (!mounted) return;

    // 게이트가 켜져 있고 세션이 없으면 로그인, 그 외엔 홈.
    context.go(gate && !loggedIn ? '/login' : '/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('RUN EARTH',
                style: AppTextStyles.display(
                    fontSize: 34, letterSpacing: 2, color: AppColors.primary)),
            const SizedBox(height: 8),
            Text('달린 만큼, 지구 한 바퀴',
                style: AppTextStyles.sans(
                    fontSize: 12, color: AppColors.mutedForeground)),
            const SizedBox(height: 28),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
