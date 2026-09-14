import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/supabase/supabase_config.dart';
import '../../../services/sync/run_sync_service.dart';
import '../../run/data/run_tracker.dart';
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
    // 어떤 이유로 예외가 나더라도 라우팅만은 반드시 실행한다.
    // 스플래시는 사용자가 빠져나올 수단이 없는 화면이라, 여기서 예외가
    // 그대로 새면 앱이 스피너인 채로 영구히 갇힌다(2026-09-13).
    try {
      await _bootInner();
    } catch (e) {
      debugPrint('[splash] 부팅 실패 — 홈으로 진행: $e');
      if (mounted) context.go('/home');
    }
  }

  Future<void> _bootInner() async {
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

    // 밀린 기록 업로드 시작. 결과를 기다리지 않는다(홈 진입을 막지 않기 위해).
    if (loggedIn) unawaited(ref.read(runSyncServiceProvider).syncNow());

    // 게이트가 켜져 있고 세션이 없으면 로그인.
    if (gate && !loggedIn) {
      context.go('/login');
      return;
    }

    // 앱이 죽어 중단됐던 러닝이 있으면 되살려 달리기 탭으로 바로 보낸다.
    // 실패해도, 응답이 없어도 홈 진입은 막지 않는다 — 스플래시는 빠져나올
    // 수단이 없는 화면이다(2026-09-13). 행 하나 읽는 일이라 3초면 넉넉하다.
    var restored = false;
    try {
      restored = await ref
          .read(runTrackerProvider.notifier)
          .restoreIfAny()
          .timeout(const Duration(seconds: 3));
    } catch (e) {
      debugPrint('[splash] 러닝 복원 실패 — 홈으로 진행: $e');
    }
    if (!mounted) return;
    context.go(restored ? '/run' : '/home');
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
