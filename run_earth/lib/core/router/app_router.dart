import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/auth_config.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/content/presentation/content_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/account_info_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/records/presentation/records_screen.dart';
import '../../features/records/presentation/run_detail_screen.dart';
import '../../features/run/presentation/run_screen.dart';
import '../../services/supabase/supabase_config.dart';
import 'scaffold_with_nav_bar.dart';

/// 앱 전역 라우터.
///
/// `/splash`·`/login` 은 shell(하단 탭바) 밖의 전체화면 라우트.
/// 5개 메인 탭은 [StatefulShellRoute]로 구성해 탭 전환 시에도 각 탭의
/// 네비게이션 스택과 스크롤 상태가 보존되게 한다. 문서 근거: 기능정의서 2·3장,
/// auth-onboarding.md.
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: _authRefresh,
  redirect: _guard,
  routes: [
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/run',
            builder: (context, state) => const RunScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/records',
            builder: (context, state) => const RecordsScreen(),
            routes: [
              // 기록 카드 탭 → 상세. shell 안쪽 자식이라 하단 탭바가 유지되고
              // ← 로 목록에 돌아온다(기능정의서 3-1).
              GoRoute(
                path: ':id',
                builder: (context, state) =>
                    RunDetailScreen(runId: state.pathParameters['id']!),
              ),
            ],
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/content',
            builder: (context, state) => const ContentScreen(),
          ),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              // 설정 하위 화면. 기록 상세와 같이 shell 안쪽 자식이라
              // 하단 탭바가 유지되고 <- 로 프로필에 돌아온다
              // (profile-settings.md 3).
              GoRoute(
                path: 'account',
                builder: (context, state) => const AccountInfoScreen(),
              ),
            ],
          ),
        ]),
      ],
    ),
  ],
);

/// 세션 가드. 게이트가 켜져 있고 Supabase 가 설정된 경우에만 동작한다.
/// - 스플래시는 자체적으로 라우팅하므로 통과시킨다.
/// - 세션 없이 보호 화면 접근 → 로그인으로.
/// - 세션 있는데 로그인 화면 → 홈으로.
String? _guard(BuildContext context, GoRouterState state) {
  if (!AuthConfig.gateEnabled || !SupabaseConfig.isConfigured) return null;

  final loc = state.matchedLocation;
  if (loc == '/splash') return null;

  final loggedIn = Supabase.instance.client.auth.currentSession != null;
  final atLogin = loc == '/login';

  if (!loggedIn && !atLogin) return '/login';
  if (loggedIn && atLogin) return '/home';
  return null;
}

/// Supabase 인증 상태 변화 시 라우터를 재평가시키는 Listenable.
/// (게이트 미사용/미설정이면 스트림을 구독하지 않는다.)
final _authRefresh = _AuthRefreshListenable();

class _AuthRefreshListenable extends ChangeNotifier {
  _AuthRefreshListenable() {
    if (AuthConfig.gateEnabled && SupabaseConfig.isConfigured) {
      _sub = Supabase.instance.client.auth.onAuthStateChange
          .listen((_) => notifyListeners());
    }
  }

  StreamSubscription<AuthState>? _sub;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
