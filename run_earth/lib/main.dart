import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/offline_banner.dart';
import 'services/supabase/supabase_config.dart';
import 'services/sync/run_sync_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Android 지도: 최신(LATEST) 렌더러를 요청한다. 구형 LEGACY 렌더러에선
  // GoogleMap 의 다크 스타일(style)이 무시되므로 러닝 지도가 밝게 나온다.
  final mapsImpl = GoogleMapsFlutterPlatform.instance;
  if (mapsImpl is GoogleMapsFlutterAndroid) {
    mapsImpl.initializeWithRenderer(AndroidMapRenderer.latest);
  }

  // Supabase 초기화. env.json(--dart-define-from-file) 이 주입됐을 때만.
  // 세션은 기기 보안 저장소에 자동 저장·자동 갱신(session-policy.md).
  if (SupabaseConfig.isConfigured) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.publishableKey,
    );
  }

  runApp(const ProviderScope(child: RunEarthApp()));
}

class RunEarthApp extends ConsumerWidget {
  const RunEarthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 앱 전역 배선: 연결이 돌아오는 순간 밀린 기록 업로드를 재시도한다.
    ref.watch(syncOnReconnectProvider);

    return MaterialApp.router(
      title: 'Run Earth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      routerConfig: appRouter,
      // 오프라인 배너는 라우터 바깥에서 감싼다 — shell(5탭) 밖의 스플래시·
      // 로그인 화면까지 덮기 위함(offline-handling.md 3 "모든 화면 공통").
      builder: (context, child) =>
          OfflineBanner(child: child ?? const SizedBox.shrink()),
    );
  }
}
