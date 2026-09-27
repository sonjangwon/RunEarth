import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/db/app_database.dart';
import '../../../core/models/air_quality.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/geo.dart';
import '../../../core/models/run.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/sync/run_sync_service.dart';
import '../../home/data/home_providers.dart';
import '../data/air_quality_provider.dart';
import '../data/run_tracker.dart';
import '../data/voice_guide.dart';
import 'cover_photo_sheet.dart';
import 'route_image_renderer.dart';
import 'run_detail_view.dart';

/// 달리기 탭 — 러닝 세션 상태머신 + 실제 GPS 추적/저장.
/// 상태·거리·경로는 [runTrackerProvider] 가 관리한다.
/// 정본: 기능정의서 4-2-C(상태머신), run-flow.md(추적·일시정지·대표 이미지).
class RunScreen extends ConsumerStatefulWidget {
  const RunScreen({super.key});

  @override
  ConsumerState<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends ConsumerState<RunScreen> {
  bool _showStopConfirm = false;

  /// 방금 끝내 **DB 에 저장까지 끝난** 기록.
  ///
  /// 결과 화면은 트래커 상태로 그려지고 DB 를 구독하지 않는다. 사진을 붙이려면
  /// 저장된 행이 있어야 하는데, 저장은 경로 PNG 렌더 뒤에 비동기로 일어난다.
  /// 그래서 저장이 끝나야 이 값이 차고, 그전까지는 카메라 버튼을 안 그린다 —
  /// 눌러도 아무 일 없는 버튼을 잠깐 보여주지 않으려는 것이다.
  Run? _savedRun;

  /// 위치 권한 2차 안내를 이미 보여줬는가(global-states.md 3).
  /// 최종 차단 팝업을 띄운 뒤 false 로 되돌려, 다음 START 는 다시 2차부터
  /// 시작하게 한다 — 그래서 기기에 저장하지 않는다.
  bool _locationRationaleShown = false;

  @override
  void initState() {
    super.initState();
    // 출발 전 지도를 캐시 위치로 채운다. 권한은 새로 묻지 않는다 —
    // 자세한 이유는 [RunTracker.primeMapPosition].
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(runTrackerProvider.notifier).primeMapPosition();
    });
  }

  /// START 탭 → 알림 권한을 챙긴 뒤 러닝을 시작한다(run-flow.md 6 '알림 권한').
  ///
  /// 알림은 포그라운드 서비스가 돌고 있다는 유일한 표시이자, 제조사 절전이
  /// 서비스를 죽일지 고를 때 보는 신호다. 그래도 **거부가 러닝을 막지는
  /// 않는다** - 알림 없이도 추적 자체는 되므로(2026-09-18 실측) 경고만 하고
  /// 진행한다.
  Future<void> _onStart() async {
    final tracker = ref.read(runTrackerProvider.notifier);

    // 위치 권한을 **가장 먼저** 챙긴다. 거부면 러닝이 아예 시작되지 않는데
    // 알림·절전부터 묻는 건 순서가 거꾸로다 — 다 허락해놓고 마지막에
    // "시작할 수 없어요"를 보게 된다.
    if (!await _ensureLocationPermission()) return;
    if (!mounted) return;

    var permission = await tracker.notificationPermission();

    // 아직 물어본 적 없으면 왜 필요한지 먼저 설명한다. 맥락 없이 팝업부터
    // 띄우면 반사적으로 거부하는데, 안드로이드는 두 번 거부당하면 영구 거부가
    // 돼 앱에서 다시 물어볼 수 없다.
    if (permission == NotificationPermission.askable) {
      final proceed = await _showNotificationRationale();
      if (!mounted) return;
      if (proceed) permission = await tracker.requestNotificationPermission();
    }
    if (!mounted) return;

    if (permission != NotificationPermission.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('알림을 허용하지 않으면 화면을 끈 사이 기록이 끊길 수 있어요'),
          duration: Duration(seconds: 4),
        ),
      );
    }

    // 절전 제외 — 화면을 끄면 안드로이드가 위치 갱신을 늦춰 GPS 가 튄다
    // (2026-09-23 야외 검증). 알림 권한과 같은 원칙으로 **거부해도 막지 않는다**.
    if (!await tracker.isBatteryOptimizationIgnored()) {
      if (!mounted) return;
      final proceed = await _showBatteryRationale();
      if (!mounted) return;
      if (proceed) await tracker.requestIgnoreBatteryOptimization();
      if (!mounted) return;
    }

    // 절전 모드 — 위 '절전 제외'와 다른 문제다. 그건 백그라운드 작업 제한을
    // 푸는 것이고, 이건 Android 9 이하에서 **OS 가 위치 자체를 정지**시키는
    // 것이라 앱이 막을 수 없다(run-flow.md 7). 그래서 알리기만 한다.
    //
    // Android 10+ 에서는 조건이 성립하지 않아 이 분기를 아예 타지 않는다.
    if (await tracker.isPowerSaveBlocking()) {
      if (!mounted) return;
      final openSettings = await _showPowerSaveWarning();
      if (!mounted) return;
      if (openSettings) {
        await tracker.openBatterySaverSettings();
        // 설정으로 보냈으면 START 는 하지 않는다. 끄고 돌아와서 다시 누르는
        // 게 맞다 — 여기서 그대로 시작하면 끄러 간 의미가 없다.
        return;
      }
    }

    await tracker.start();
  }

  /// 위치 권한 3단계 (global-states.md 3 표).
  ///
  /// | 단계 | 조건 | 화면 |
  /// |---|---|---|
  /// | 1차 | 아직 안 물어봄 | OS 시스템 다이얼로그 |
  /// | 2차 안내 | 거부 + 첫 START | 앱 모달(설정 이동 유도) |
  /// | 최종 차단 | 거부 + 재시도 | 블로킹 팝업(닫기만) |
  ///
  /// 진행해도 되면 true. false 면 START 를 멈춘다.
  Future<bool> _ensureLocationPermission() async {
    final tracker = ref.read(runTrackerProvider.notifier);

    // 권한과 별개로 기기 GPS 자체가 꺼져 있을 수 있다. 이건 앱이 손쓸 수
    // 없어 권한 흐름에 섞지 않고 따로 알린다.
    if (!await tracker.isLocationServiceEnabled()) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('위치 서비스가 꺼져 있어요. 설정에서 켜주세요.')),
      );
      return false;
    }

    var state = await tracker.locationPermission();

    // 1차 — 아직 물어본 적 없으면 OS 다이얼로그.
    if (state == LocationPermissionState.notDetermined) {
      state = await tracker.requestLocationPermission();
    }
    if (state == LocationPermissionState.granted) return true;
    if (!mounted) return false;

    // 2차 — 왜 필요한지 앱이 직접 설명하고 설정으로 보낸다.
    //
    // 여기서 `requestLocationPermission()` 을 다시 부르지 않는다. 한 번
    // 거부한 뒤에는 시스템 다이얼로그가 뜨지 않고 즉시 거부가 돌아오기
    // 때문이다(global-states.md 3 플랫폼 제약). 부르면 사용자에겐 아무 일도
    // 일어나지 않는 것처럼 보인다.
    if (!_locationRationaleShown) {
      _locationRationaleShown = true;
      final goSettings = await _showLocationRationale();
      if (goSettings) await openAppSettings();
      return false;
    }

    // 최종 차단 — 닫기만 하고 권한은 그대로다.
    await _showLocationBlocked();
    // 플래그를 되돌린다: "팝업을 닫고 다시 START 를 누르면 2차 안내부터
    // 반복된다"(global-states.md 8). 그래서 저장할 상태가 없다 — 앱을 껐다
    // 켜도 어차피 2차부터다.
    _locationRationaleShown = false;
    return false;
  }

  /// 2차 안내 모달. [true] 면 설정 앱으로 보낸다.
  Future<bool> _showLocationRationale() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('러닝 기록을 위해 위치 권한이 필요해요',
            style: AppTextStyles.sans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground)),
        content: Text(
          '달린 거리와 경로는 위치로만 기록할 수 있어요.\n'
          '설정에서 위치 권한을 허용해주세요.',
          style: AppTextStyles.sans(
              fontSize: 13, color: AppColors.mutedForeground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('취소',
                style: AppTextStyles.sans(color: AppColors.mutedForeground)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('설정으로 이동',
                style: AppTextStyles.sans(color: AppColors.primary)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  /// 최종 차단 팝업. 확인을 눌러도 권한 상태는 변하지 않는다.
  Future<void> _showLocationBlocked() async {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        content: Text(
          '위치 권한이 없으면 러닝을 시작할 수 없어요.',
          style: AppTextStyles.sans(
              fontSize: 14, color: AppColors.foreground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('확인',
                style: AppTextStyles.sans(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  /// 기기 절전 모드가 켜져 있을 때의 안내. [true] 면 절전 설정 화면으로 보낸다.
  ///
  /// **막지 않고 알리기만 한다** — 알림 권한·절전 제외와 같은 원칙이다
  /// (`run-flow.md` 7). 다만 이쪽은 앱이 손쓸 방법이 전혀 없어서, 문구에서
  /// 그 점을 분명히 말한다. Strava 등도 같은 대응을 한다(2026-09-26 조사).
  ///
  /// 이 안내는 **Android 9 이하 + 절전 켜짐**에서만 뜬다. 조건은
  /// `RunTracker.isPowerSaveBlocking` 이 판단한다.
  Future<bool> _showPowerSaveWarning() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('절전 모드가 켜져 있어요',
            style: AppTextStyles.sans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground)),
        content: Text(
          '이 기기는 절전 모드에서 화면을 끄면\n'
          '위치 기록이 끊겨요. 앱이 막을 수 없어요.\n'
          '설정에서 끄면 경로가 정확해집니다.',
          style: AppTextStyles.sans(
              fontSize: 13, color: AppColors.mutedForeground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('그냥 시작',
                style: AppTextStyles.sans(color: AppColors.mutedForeground)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('설정 열기',
                style: AppTextStyles.sans(color: AppColors.primary)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  /// 절전 제외가 왜 필요한지 설명하는 사전 안내. [true] 면 시스템 팝업으로 간다.
  ///
  /// 맥락 없이 시스템 팝업부터 띄우면 반사적으로 거부한다. 알림 권한과 같은
  /// 순서를 쓴다(`_showNotificationRationale`).
  Future<bool> _showBatteryRationale() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('절전 제외를 허용해주세요',
            style: AppTextStyles.sans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground)),
        content: Text(
          '화면을 끄면 폰이 위치 확인을 늦춰서,\n'
          '실제보다 거리가 길게 기록될 수 있어요.\n'
          '제외해두면 경로가 정확해집니다.',
          style: AppTextStyles.sans(
              fontSize: 13, color: AppColors.mutedForeground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('나중에',
                style: AppTextStyles.sans(color: AppColors.mutedForeground)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('계속',
                style: AppTextStyles.sans(color: AppColors.primary)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  /// 알림 권한이 왜 필요한지 설명하는 사전 안내. [true] 면 시스템 팝업으로 간다.
  Future<bool> _showNotificationRationale() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('알림을 허용해주세요',
            style: AppTextStyles.sans(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.foreground)),
        content: Text(
          '러닝 중 상단바에 기록 상태를 표시합니다.\n'
          '이 표시가 있어야 화면을 꺼도 기록이 끊기지 않아요.',
          style: AppTextStyles.sans(
              fontSize: 13, color: AppColors.mutedForeground),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('나중에',
                style: AppTextStyles.sans(color: AppColors.mutedForeground)),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('계속',
                style: AppTextStyles.sans(color: AppColors.primary)),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _onStopConfirmed() async {
    setState(() => _showStopConfirm = false);
    final tracker = ref.read(runTrackerProvider.notifier);
    final route = ref.read(runTrackerProvider).route;
    final distanceKm = ref.read(runTrackerProvider).distanceKm;
    // 여정 진행률은 **저장 전에** 읽는다. 저장 뒤에 읽으면 DB 스트림이 아직
    // 안 돌았을 수 있어 방금 뛴 거리가 반영됐는지 알 수 없다. 저장 전 값에서
    // 이번 거리를 직접 빼면 순서에 기대지 않아도 된다.
    final journey = ref.read(journeyProgressProvider);
    tracker.stop(); // 결과 화면으로 즉시 전환

    final remainingAfter = journey.remainingKm - distanceKm;
    ref.read(voiceGuideProvider).speak(finishMessage(
          cityName: journey.toCity.name,
          remainingKm: remainingAfter,
          arrived: remainingAfter <= 0,
        ));

    // 대표 이미지(경로 렌더) 생성 후 로컬 DB 저장.
    final coverUrl = await renderRouteCover(route);
    final run = tracker.buildRun(coverImageUrl: coverUrl);
    await ref.read(appDatabaseProvider).upsertRun(run);
    // 저장이 끝나야 결과 화면에서 사진을 붙일 수 있다.
    if (mounted) setState(() => _savedRun = run);
    // 정식 기록이 된 뒤에야 진행 중 스냅샷을 지운다(순서 중요).
    await tracker.clearSnapshot();
    // 저장 즉시 업로드 시도. 오프라인이면 대기 상태로 남아 이후 자동 재시도된다.
    unawaited(ref.read(runSyncServiceProvider).syncNow());
  }

  /// 결과 화면 대표 이미지 변경. 이 화면은 DB 를 구독하지 않아 직접 갱신한다.
  Future<void> _changeResultCover() async {
    final next = await changeCoverImage(context, ref, _savedRun!);
    if (next != null && mounted) setState(() => _savedRun = next);
  }

  /// 결과 화면을 닫고 prerun 으로. 다음 러닝에 지난 기록이 남지 않게 비운다.
  void _closeResult() {
    setState(() => _savedRun = null);
    final tracker = ref.read(runTrackerProvider.notifier);
    tracker.reset();
    // reset 이 current 까지 비우므로 출발 전 지도를 다시 채워준다.
    tracker.primeMapPosition();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(runTrackerProvider);
    final tracker = ref.read(runTrackerProvider.notifier);

    // 권한 거부·위치 꺼짐 등 오류 → 하단 토스트.
    ref.listen(runTrackerProvider.select((s) => s.error), (prev, next) {
      if (next != null && next != prev) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next)),
        );
      }
    });

    final Widget body = switch (state.phase) {
      // 출발 전에도 지도가 화면 위쪽을 차지한다 — Figma 는 지도를 항상 두고
      // 아래 패널만 출발 전 ↔ 달리는 중으로 바꾼다(App.tsx 853·869줄).
      RunSessionPhase.prerun => _MapWithPanel(
          state: state,
          recording: false,
          panel: _PrerunPanel(runType: state.runType, onStart: _onStart),
        ),
      RunSessionPhase.countdown =>
        const ColoredBox(color: AppColors.background),
      RunSessionPhase.running ||
      RunSessionPhase.paused =>
        _Running(
          state: state,
          onTogglePause: tracker.togglePause,
          onStop: () => setState(() => _showStopConfirm = true),
        ),
      // 결과 화면은 기록 상세와 같은 컴포넌트다(기능정의서 5). 여기서는
      // 닫기를 ✕ 로 두고 prerun 으로 초기화한다.
      RunSessionPhase.stopped => RunDetailView(
          // 워터마크용 날짜. 저장된 기록이 있으면 그 값을, 저장 전이면 오늘로
          // 낸다 — `buildRun` 도 종료 시각을 쓰므로 둘이 어긋나지 않는다.
          // 예전에는 `'러닝 완료'` 를 넘겨 워터마크가 `RUN EARTH · 러닝 완료`
          // 로 찍혔다(2026-09-25 발견).
          dateLabel: _savedRun != null
              ? '${_savedRun!.year}.${_savedRun!.date}'
              : _todayLabel(),
          route: state.route,
          durStr: state.elapsedStr,
          distanceStr: state.distanceStr,
          paceStr: state.paceStr,
          kcal: state.kcal,
          closeIcon: RunDetailClose.x,
          onClose: _closeResult,
          // 저장 전에는 null — 위 [_savedRun] 참조.
          photoPath: _savedRun?.coverImageType == CoverImageType.photo
              ? _savedRun?.coverImageUrl
              : null,
          onPickPhoto: _savedRun == null ? null : _changeResultCover,
          footer: _ResultFooter(onDone: _closeResult),
        ),
    };

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: body),
            if (state.phase == RunSessionPhase.countdown)
              _CountdownOverlay(count: state.countdown),
            if (_showStopConfirm)
              _StopConfirm(
                onCancel: () => setState(() => _showStopConfirm = false),
                onConfirm: _onStopConfirmed,
              ),
          ],
        ),
      ),
    );
  }

  /// 워터마크용 오늘 날짜 — `2026.09.23`. 저장이 끝나기 전에만 쓴다.
  static String _todayLabel() {
    final now = DateTime.now();
    final mm = now.month.toString().padLeft(2, '0');
    final dd = now.day.toString().padLeft(2, '0');
    return '${now.year}.$mm.$dd';
  }
}

// ── 지도 + 하단 패널 (출발 전·달리는 중 공용) ─────────────────

/// 화면을 **지도(위) + 패널(아래)** 로 나눈다.
///
/// Figma 는 달리기 탭에서 지도를 항상 띄워두고 아래 패널만 바꾼다
/// (`App.tsx` 853줄 MAP · 869줄 BOTTOM PANEL). 전에는 출발 전에 지도가 아예
/// 없어서, 어디서 달릴지 보지도 못한 채 START 를 눌러야 했다.
class _MapWithPanel extends StatelessWidget {
  const _MapWithPanel({
    required this.state,
    required this.recording,
    required this.panel,
  });

  final RunSessionState state;

  /// 달리는 중인지. 지도 GPS 뱃지 문구가 갈린다.
  final bool recording;

  final Widget panel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: _RunMap(
                  route: state.route,
                  current: state.current,
                  recording: recording,
                ),
              ),
              // 지도 아래쪽을 카드색으로 녹여 하단 패널과 이어 붙인다(Figma).
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 64,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          AppColors.card,
                          AppColors.card.withAlpha(0),
                        ],
                        stops: const [0.2, 1],
                      ),
                    ),
                  ),
                ),
              ),
              // Figma 에는 없지만 run-flow.md 3장이 요구하는 표시다.
              // 수치가 하단으로 내려가 상단이 비었으므로 위로 올린다.
              if (state.isPaused)
                const Positioned(
                  top: 12,
                  left: 0,
                  right: 0,
                  child: Center(child: _PausedBadge()),
                ),
            ],
          ),
        ),
        panel,
      ],
    );
  }
}

// ── prerun ────────────────────────────────────────────────────

/// 출발 전 하단 패널 — 러닝 타입 · 날씨 · 미세먼지 · 시작 버튼.
class _PrerunPanel extends StatelessWidget {
  const _PrerunPanel({required this.runType, required this.onStart});
  final RunType runType;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _RunTypeCard(runType),
            const SizedBox(height: 12),
            const Row(
              children: [
                Expanded(child: _WeatherCard()),
                SizedBox(width: 8),
                Expanded(child: _DustCard()),
              ],
            ),
            const SizedBox(height: 12),
            _StartButton(onTap: onStart),
          ],
        ),
      ),
    );
  }
}

// ── running / paused ──────────────────────────────────────────
class _Running extends StatelessWidget {
  const _Running({
    required this.state,
    required this.onTogglePause,
    required this.onStop,
  });

  final RunSessionState state;
  final VoidCallback onTogglePause;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    return _MapWithPanel(
      state: state,
      recording: true,
      panel: DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.card,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Column(
            children: [
              _LiveStats(
                time: state.elapsedStr,
                distance: state.distanceStr,
                pace: state.paceStr,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                // 두 상태 모두 **한 줄**이다 — 일시정지할 때 패널 높이가
                // 변하면 지도가 출렁이고, 누르려던 자리도 달라진다.
                // Figma 는 일시정지 중 '재개' 하나만 두지만, 멈춰서 숨 고르다
                // 끝내는 흐름이 흔해 종료 경로를 남긴다. 재개를 거쳐야만
                // 끝낼 수 있으면 막다른 길이 된다(2026-09-21 사용자 결정).
                // 대신 폭을 7:3 으로 나눠 재개가 여전히 주인공이게 둔다.
                child: state.isPaused
                    ? Row(
                        children: [
                          Expanded(
                            flex: 7,
                            child: _ControlButton(
                              label: '달리기 재개',
                              icon: Icons.play_arrow,
                              style: _ControlStyle.gradient,
                              onTap: onTogglePause,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 3,
                            child: _ControlButton(
                              label: '종료',
                              icon: Icons.stop,
                              style: _ControlStyle.danger,
                              onTap: onStop,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _ControlButton(
                              label: '일시정지',
                              icon: Icons.pause,
                              style: _ControlStyle.outline,
                              onTap: onTogglePause,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _ControlButton(
                              label: '종료',
                              icon: Icons.stop,
                              style: _ControlStyle.danger,
                              onTap: onStop,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
    );
  }
}

class _PausedBadge extends StatelessWidget {
  const _PausedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(0x99),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.accent.withAlpha(0x66)),
      ),
      child: Text('일시정지됨',
          style: AppTextStyles.sans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.accent)),
    );
  }
}

// ── stopped (결과) ────────────────────────────────────────────
class _RunMap extends StatefulWidget {
  const _RunMap({
    required this.route,
    required this.current,
    this.recording = false,
  });

  final List<LatLngPoint> route;
  final LatLngPoint? current;
  final bool recording;

  @override
  State<_RunMap> createState() => _RunMapState();
}

class _RunMapState extends State<_RunMap> {
  GoogleMapController? _controller;

  /// 현재 위치를 아직 못 잡았을 때 초기 카메라(서울 시청). 곧 실제 위치로 이동.
  static const _fallback = LatLng(37.5665, 126.9780);

  @override
  void didUpdateWidget(covariant _RunMap old) {
    super.didUpdateWidget(old);
    final c = widget.current;
    if (c != null && c != old.current) {
      _controller?.animateCamera(
        CameraUpdate.newLatLng(LatLng(c.lat, c.lng)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.current;
    final initial = c != null ? LatLng(c.lat, c.lng) : _fallback;

    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(target: initial, zoom: 17),
            // 하단 페이드가 구글 로고를 덮지 않게 지도 안쪽 여백을 준다 —
            // 지도 표시 약관상 로고는 가리면 안 된다.
            padding: const EdgeInsets.only(bottom: 56),
            onMapCreated: (ctrl) {
              _controller = ctrl;
              // style 파라미터는 최신 렌더러에서만 먹으므로, 구형 LEGACY
              // 렌더러에서도 다크 스타일이 적용되도록 setMapStyle 을 쓴다.
              // ignore: deprecated_member_use
              ctrl.setMapStyle(_darkMapStyle);
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            polylines: {
              if (widget.route.length >= 2)
                Polyline(
                  polylineId: const PolylineId('run'),
                  points: [
                    for (final p in widget.route) LatLng(p.lat, p.lng),
                  ],
                  color: AppColors.primary,
                  width: 5,
                ),
            },
          ),
        ),
        // 좌표를 하나라도 잡았으면 내린다. 예전 조건은 route.length < 2 였는데,
        // 출발선에 서 있으면 두 번째 점이 안 찍혀 신호가 멀쩡한데도 계속
        // '기다리는 중'으로 보였다(2026-09-19).
        //
        // **달리는 중에만** 띄운다. 출발 전에는 위치 스트림을 돌리지 않아서
        // 기다려도 채워지지 않는다 — 그때는 좌상단 'GPS 연결 중…' 뱃지가
        // 같은 사실을 더 조용히 말한다(2026-09-23 실기기에서 드러났다).
        if (widget.recording && widget.current == null)
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(0x99),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text('🛰  GPS 신호를 기다리는 중…',
                  style: AppTextStyles.sans(
                      fontSize: 12, color: AppColors.mutedForeground)),
            ),
          ),
        // 뱃지는 출발 전에도 띄운다(Figma). 문구만 상태에 따라 갈린다 —
        // 아직 위치를 못 잡았으면 '연결됨' 이라고 말하지 않는다.
        Positioned(
            top: 12,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(0x99),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withAlpha(0x1A)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.current == null
                            ? AppColors.mutedForeground
                            : AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  Text(
                      widget.recording
                          ? 'GPS 기록 중'
                          : widget.current == null
                              ? 'GPS 연결 중…'
                              : 'GPS 연결됨',
                      style: AppTextStyles.mono(
                          fontSize: 9,
                          color: widget.current == null
                              ? AppColors.mutedForeground
                              : AppColors.primary)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 앱 다크 팔레트에 맞춘 Google Map 스타일(POI/대중교통 라벨 최소화).
const String _darkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#0d1018"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#6b7280"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#070911"}]},
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#1b2130"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#0d1018"}]},
  {"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#070911"}]}
]
''';

// ── countdown overlay ─────────────────────────────────────────
/// 카운트다운 — 숫자 네온 글로우 3겹 + 뒤에서 퍼지는 펄스 링 2개(Figma).
///
/// Figma 는 0 에서 `GO!` 를 700ms 보여주지만 넣지 않았다 — 트래커가
/// 1 다음 바로 running 으로 넘어가서, 넣으려면 상태 머신에 단계를 하나
/// 더 만들고 시작을 0.7초 늦춰야 한다. 화면이 아니라 로직 변경이다.
class _CountdownOverlay extends StatefulWidget {
  const _CountdownOverlay({required this.count});
  final int count;

  @override
  State<_CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<_CountdownOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 950),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _PulseRing(
              controller: _pulse,
              size: 200,
              color: const Color(0x3000E87A),
              maxScale: 1.5,
              maxOpacity: 0.3,
            ),
            _PulseRing(
              controller: _pulse,
              size: 280,
              color: const Color(0x1500E87A),
              maxScale: 1.4,
              maxOpacity: 0.2,
              delay: 0.2,
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                '${widget.count}',
                key: ValueKey(widget.count),
                style: AppTextStyles.display(
                  fontSize: 140,
                  color: AppColors.primary,
                ).copyWith(shadows: const [
                  Shadow(color: Color(0xFF00E87A), blurRadius: 40),
                  Shadow(color: Color(0x6000E87A), blurRadius: 90),
                  Shadow(color: Color(0x3000E87A), blurRadius: 160),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 숫자 뒤에서 커졌다 옅어지는 링. 두 개가 시차를 두고 돈다.
class _PulseRing extends StatelessWidget {
  const _PulseRing({
    required this.controller,
    required this.size,
    required this.color,
    required this.maxScale,
    required this.maxOpacity,
    this.delay = 0,
  });

  final AnimationController controller;
  final double size;
  final Color color;
  final double maxScale;
  final double maxOpacity;

  /// 0~1 회 단위 시차. 두 링이 겹쳐 보이지 않게 한다.
  final double delay;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final t = (controller.value + delay) % 1.0;
        // 0 → 1 → 0. 커졌다 제자리로 돌아오며 그 사이 투명해진다.
        final p = t < 0.5 ? t * 2 : (1 - t) * 2;
        return Opacity(
          opacity: maxOpacity * (1 - p),
          child: Transform.scale(
            scale: 1 + (maxScale - 1) * p,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: color),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── stop confirm popup ────────────────────────────────────────
class _StopConfirm extends StatelessWidget {
  const _StopConfirm({required this.onCancel, required this.onConfirm});
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withAlpha(0xB3),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('달리기를 종료하시겠습니까?',
                    style: AppTextStyles.sans(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ControlButton(
                        label: '아니요',
                        style: _ControlStyle.ghost,
                        dense: true,
                        onTap: onCancel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ControlButton(
                        label: '네',
                        style: _ControlStyle.gradient,
                        dense: true,
                        onTap: onConfirm,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── 하위 위젯 ──────────────────────────────────────────────────

class _RunTypeCard extends ConsumerWidget {
  const _RunTypeCard(this.type);
  final RunType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ({String emoji, String label, Color color}) meta = switch (type) {
      RunType.normal => (emoji: '🏃', label: '일반 러닝', color: AppColors.primary),
      RunType.theme => (emoji: '🗺️', label: '테마 러닝', color: AppColors.typeTheme),
      RunType.online => (
          emoji: '🏅',
          label: '온라인 마라톤',
          color: AppColors.typeOnline
        ),
    };
    final card = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(meta.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('러닝 타입',
                  style: AppTextStyles.mono(
                      fontSize: 8, color: AppColors.mutedForeground)),
              Text(meta.label,
                  style: AppTextStyles.sans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: meta.color)),
            ],
          ),
        ],
      ),
    );

    // 🔧 음성 안내 미리듣기 — **디버그 빌드 전용**(`kDebugMode`).
    //
    // 구간 안내는 원래 1km 를 뛰어야 들리는데, 문구를 다듬을 때마다 밖에
    // 나갈 수는 없다. 길게 눌러 네 문장을 이어서 듣는다.
    // 스와이프 미리보기(2026-09-26)와 같은 방식이다 — 릴리즈엔 안 들어간다.
    if (!kDebugMode) return card;
    return GestureDetector(
      onLongPress: () => _previewVoice(ref),
      child: card,
    );
  }

  Future<void> _previewVoice(WidgetRef ref) async {
    final voice = ref.read(voiceGuideProvider);
    for (final line in [
      startMessage(),
      kmMessage(km: 1, splitSeconds: 388, avgSeconds: 388),
      kmMessage(km: 2, splitSeconds: 388, avgSeconds: 401),
      finishMessage(cityName: '전주', remainingKm: 142.63),
      finishMessage(cityName: '전주', remainingKm: 0, arrived: true),
    ]) {
      // `awaitSpeakCompletion(true)` 라 한 문장이 끝나야 다음으로 넘어간다.
      await voice.speak(line);
    }
  }
}

/// 출발 전 날씨 카드. **정본은 Figma**(`App.tsx` 904-907줄).
///
/// 구조: `날씨` 라벨 + `☀️ 28°C 맑음` **한 줄**. 2026-09-27 에 미세먼지와 함께
/// Figma 구조로 맞췄다 — 그전에는 라벨 없이 `24°` / `체감 26°` 두 줄이었다
/// (`figma-alignment.md` 3번).
///
/// 🟢 **체감온도를 빼고 날씨 상태(맑음)를 넣는다**(2026-09-27 사용자 결정).
/// 기능정의서 4-2 섹션 B 는 "아이콘 + 기온 + 체감온도" 라고 적어뒀지만
/// **Figma 에는 체감온도가 없고 대신 상태 텍스트가 있다.** 미세먼지 배경
/// (결정 ⑥)과 같은 판단으로 Figma 를 따른다.
///
/// 🔴 **값은 샘플이다. 실제 관측값이 아니다.** 기상청 API 키가 나오기 전이라
/// 화면만 만들어둔 상태다(`feature-backlog.md`). 미세먼지
/// (`air_quality_provider.dart`)도 같은 이유로 샘플이다.
///
/// ⚠️ 시연에서 진짜처럼 보인다. 팀에 보여줄 때 연동 전이라고 말할 것.
class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    return _MiniCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('날씨',
              style: AppTextStyles.sans(
                  fontSize: 9, color: AppColors.mutedForeground)),
          const SizedBox(height: 4),
          // 이모지·기온·상태가 한 줄이다. Figma 샘플값(28°C 맑음)을 그대로 쓴다.
          Text('☀️ 28°C 맑음',
              style: AppTextStyles.sans(
                  fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// 미세먼지 카드. **정본은 Figma**(`App.tsx` 678-685 · 908-930줄) 다.
///
/// 구조: `미세먼지 42` 라벨 + 단계 pill / 그라데이션 게이지 + 흰 마커 /
/// 4단계 레이블. 2026-09-27 에 Figma 구조로 다시 맞췄다 —
/// 그전에는 점 4개짜리 막대였다(`figma-alignment.md` 3번).
///
/// 🟢 **카드 배경은 단계와 무관하게 그대로 둔다**(2026-09-27 사용자 결정).
/// 기능정의서 4-2 섹션 B 는 "나쁨=주황 배경·매우나쁨=빨강 배경" 이라고
/// 적어뒀지만 **Figma 는 배경을 안 바꾸고 pill 색만 바꾼다.** CLAUDE.md 의
/// "화면·비주얼은 Figma" 원칙과 2026-09-20 결정 ②(미세먼지 색은 Figma)를
/// 따라 Figma 쪽으로 통일했다. 경고는 pill 이 맡는다.
class _DustCard extends ConsumerWidget {
  const _DustCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reading = ref.watch(airQualityProvider);
    if (reading == null) return const _MiniCard(child: _DustUnavailable());

    final level = reading.level;
    final color = _dustColor(level);
    // Figma: 나쁨·매우나쁨만 단계 색 pill, 나머지는 무채색이다.
    final isBad = level.needsAlertBackground;
    final pillColor = isBad ? color : AppColors.mutedForeground;

    return _MiniCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 농도 수치는 Figma 에 없지만 함께 보여준다(2026-09-27 결정) —
              // 게이지 마커만으로는 '얼마나' 를 읽을 수 없다. 단위(㎍/㎥)는
              // 좁은 카드에서 자리를 많이 먹어 숫자만 쓴다.
              Text('미세먼지 ${reading.value}',
                  style: AppTextStyles.sans(
                      fontSize: 9, color: AppColors.mutedForeground)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isBad
                      ? AppColors.badgeBackground(color)
                      : Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isBad
                        ? color.withValues(alpha: 0.21)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Text(level.label,
                    style: AppTextStyles.sans(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: pillColor)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          _DustGauge(ratio: reading.gaugeRatio),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final l in AirQuality.values)
                Text(l.label,
                    style: AppTextStyles.sans(
                        fontSize: 7,
                        fontWeight: FontWeight.w500,
                        // 현재 단계만 제 색으로, 나머지는 가라앉힌다.
                        color: l == level ? _dustColor(l) : _dustLabelOff)),
            ],
          ),
        ],
      ),
    );
  }
}

/// 꺼진 단계 레이블 색(Figma `#4B5563`).
const _dustLabelOff = Color(0xFF4B5563);

/// 4단계 색이 이어지는 그라데이션 바 + 현재 농도 위치의 흰 마커.
///
/// 정지점(0 · 0.4 · 0.7 · 1.0)은 Figma 그대로다 — 등간격이 아니라
/// **'좋음' 구간이 넓다.** 실제 농도 분포가 그쪽에 몰려 있어서다.
class _DustGauge extends StatelessWidget {
  const _DustGauge({required this.ratio});

  /// 0~1. 마커를 놓을 위치.
  final double ratio;

  static const _height = 6.0;
  static const _marker = 8.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 마커가 바 밖으로 나가지 않게 반지름만큼 안쪽으로 당긴다.
        final usable = constraints.maxWidth - _marker;
        return SizedBox(
          height: _marker,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: _height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_height / 2),
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.dustGood,
                      AppColors.dustModerate,
                      AppColors.dustBad,
                      AppColors.dustVeryBad,
                    ],
                    stops: [0, 0.4, 0.7, 1],
                  ),
                ),
              ),
              Positioned(
                left: usable * ratio,
                child: Container(
                  width: _marker,
                  height: _marker,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border:
                        Border.all(color: Colors.black.withValues(alpha: 0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 값을 못 가져왔을 때. `global-states.md` 의 인라인 에러 패턴 —
/// 중립 아이콘 + "불러오지 못했어요".
///
/// "다시 시도" 버튼은 **아직 붙이지 않았다.** 재호출할 요청 자체가 없어
/// 누르면 아무 일도 하지 않는 버튼이 된다. 에어코리아 연동 때 함께 만든다
/// (2026-09-19 의 '대표 이미지 변경' 버튼과 같은 판단).
class _DustUnavailable extends StatelessWidget {
  const _DustUnavailable();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('미세먼지',
            style: AppTextStyles.sans(
                fontSize: 9, color: AppColors.mutedForeground)),
        const SizedBox(height: 3),
        Row(
          children: [
            const Icon(Icons.error_outline,
                size: 13, color: AppColors.mutedForeground),
            const SizedBox(width: 4),
            Flexible(
              child: Text('불러오지 못했어요',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.sans(
                      fontSize: 11, color: AppColors.mutedForeground)),
            ),
          ],
        ),
      ],
    );
  }
}

Color _dustColor(AirQuality quality) => switch (quality) {
      AirQuality.good => AppColors.dustGood,
      AirQuality.moderate => AppColors.dustModerate,
      AirQuality.bad => AppColors.dustBad,
      AirQuality.veryBad => AppColors.dustVeryBad,
    };

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.child});
  final Widget child;

  // 예전에는 배경색을 받는 파라미터가 있었다. 미세먼지 '나쁨' 이상에서 카드를
  // 물들이는 용도였는데, 2026-09-27 에 **Figma 대로 배경을 안 바꾸기로** 해서
  // 쓰는 곳이 없어졌다(_DustCard 주석 참조).
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

/// 달리는 중 하단 패널의 3열 수치 — Figma 순서는 **시간 → 거리 → 페이스**다.
/// 거리만 네온그린이라 눈이 먼저 가고, 나머지는 보조로 읽힌다.
///
/// Figma 는 시간 뒤에 `.43`(1/100초)을 작게 붙이지만 **넣지 않는다.**
/// 그리려면 달리는 내내 50ms 타이머로 다시 그려야 하는데, 포그라운드
/// 서비스로 몇십 분씩 도는 화면이라 배터리 값이 얻는 것보다 크다
/// (2026-09-21 사용자 결정).
class _LiveStats extends StatelessWidget {
  const _LiveStats({
    required this.time,
    required this.distance,
    required this.pace,
  });

  final String time;
  final String distance;
  final String pace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 12),
      // 구분선이 세 칸 중 가장 높은 칸만큼 늘어나야 해서 높이를 먼저 잰다.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _item('시간', time)),
            const _StatDivider(),
            Expanded(
              child: _item('거리', distance,
                  unit: 'km', color: AppColors.primary),
            ),
            const _StatDivider(),
            Expanded(child: _item('페이스', pace, unit: '/km')),
          ],
        ),
      ),
    );
  }

  Widget _item(
    String label,
    String value, {
    String? unit,
    Color color = AppColors.foreground,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: AppTextStyles.sans(
                    fontSize: 9, color: AppColors.mutedForeground)),
            const SizedBox(height: 6),
            // 한 시간을 넘기면 "1:02:33" 이 되어 한 칸 폭을 넘길 수 있다.
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(value,
                  style: AppTextStyles.display(fontSize: 32, color: color)),
            ),
            if (unit != null) ...[
              const SizedBox(height: 3),
              Text(unit,
                  style: AppTextStyles.mono(
                      fontSize: 9, color: AppColors.mutedForeground)),
            ],
          ],
        ),
      );
}

/// 수치 칸 사이 세로 구분선.
class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) =>
      const VerticalDivider(width: 1, thickness: 1, color: AppColors.border);
}

class _StartButton extends StatelessWidget {
  const _StartButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF00E87A), Color(0xFF00C060)],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                // Figma 정본은 한글 '달리기 시작' 이다(App.tsx 940줄).
                child: Text('달리기 시작',
                    style: AppTextStyles.display(
                        fontSize: 20, color: Colors.black, letterSpacing: 1)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 버튼 꼴(Figma).
enum _ControlStyle {
  /// 일시정지 — 어두운 채움 + 외곽선
  outline,

  /// 종료 — 빨강 반투명
  danger,

  /// 재개·확인 — 네온 그라데이션
  gradient,

  /// 취소 — 배경 없이 외곽선만, 글자도 흐리게
  ghost,
}

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    this.icon,
    required this.style,
    required this.onTap,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final _ControlStyle style;
  final VoidCallback onTap;

  /// 팝업 안처럼 세로 여유가 없는 자리에서 한 단계 작게.
  final bool dense;

  /// 배경·테두리는 순수 빨강에서, 글자는 한 단계 밝은 값에서 온다 —
  /// 어두운 반투명 위에서 #EF4444 는 읽기 어렵다(Figma 도 같은 두 값).
  static const _dangerBase = Color(0xFFEF4444);
  static const _dangerText = Color(0xFFF87171);

  @override
  Widget build(BuildContext context) {
    final Color fg = switch (style) {
      _ControlStyle.gradient => Colors.black,
      _ControlStyle.danger => _dangerText,
      _ControlStyle.outline => AppColors.foreground,
      _ControlStyle.ghost => AppColors.mutedForeground,
    };
    final BoxDecoration decoration = switch (style) {
      _ControlStyle.gradient => BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF00E87A), Color(0xFF00C060)],
          ),
        ),
      _ControlStyle.danger => BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: _dangerBase.withAlpha(0x1F),
          border: Border.all(color: _dangerBase.withAlpha(0x4D)),
        ),
      _ControlStyle.outline => BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF161923),
          border: Border.all(color: AppColors.border),
        ),
      _ControlStyle.ghost => BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
    };

    return DecoratedBox(
      decoration: decoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            // 꼴이 달라도 높이는 같아야 한다 — 같은 줄에 나란히 서고,
            // 달리는 중 ↔ 일시정지 중에 패널 높이가 변하면 안 된다.
            padding: EdgeInsets.symmetric(vertical: dense ? 12 : 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: fg),
                  const SizedBox(width: 6),
                ],
                // 라벨이 한글이라 Barlow Condensed(Figma)는 못 쓴다 —
                // 한글 글리프가 없어 폴백되면 자간만 어색해진다.
                Text(label,
                    style: AppTextStyles.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 결과 화면 하단 — 안내 문구 + '완료' 버튼.
/// 기록 상세에는 없는 부분이라 [RunDetailView.footer] 로 끼워 넣는다.
class _ResultFooter extends StatelessWidget {
  const _ResultFooter({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('기록 탭에서 경로 이미지를 확인할 수 있어요.',
            style: AppTextStyles.sans(
                fontSize: 11, color: AppColors.mutedForeground)),
        const SizedBox(height: 20),
        // 완료 → prerun 으로 초기화(다시 달리기 가능). 상단 ✕ 와 같은 동작.
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
                colors: [Color(0xFF00E87A), Color(0xFF00C060)]),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onDone,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text('완료',
                      style: AppTextStyles.display(
                          fontSize: 16, color: Colors.black)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
