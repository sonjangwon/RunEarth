import 'package:go_router/go_router.dart';

import '../../features/content/presentation/content_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/records/presentation/records_screen.dart';
import '../../features/run/presentation/run_screen.dart';
import 'scaffold_with_nav_bar.dart';

/// 앱 전역 라우터.
///
/// 5개 메인 탭을 [StatefulShellRoute]로 구성해 탭 전환 시에도 각 탭의
/// 네비게이션 스택과 스크롤 상태가 보존되게 한다. 문서 근거: 기능정의서 2·3장.
final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
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
          ),
        ]),
      ],
    ),
  ],
);
