import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/db/app_database.dart';
import '../../../core/models/air_quality.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/geo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/sync/run_sync_service.dart';
import '../data/air_quality_provider.dart';
import '../data/run_tracker.dart';
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

  /// START 탭 → 알림 권한을 챙긴 뒤 러닝을 시작한다(run-flow.md 6 '알림 권한').
  ///
  /// 알림은 포그라운드 서비스가 돌고 있다는 유일한 표시이자, 제조사 절전이
  /// 서비스를 죽일지 고를 때 보는 신호다. 그래도 **거부가 러닝을 막지는
  /// 않는다** - 알림 없이도 추적 자체는 되므로(2026-09-18 실측) 경고만 하고
  /// 진행한다.
  Future<void> _onStart() async {
    final tracker = ref.read(runTrackerProvider.notifier);
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

    await tracker.start();
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
    tracker.stop(); // 결과 화면으로 즉시 전환

    // 대표 이미지(경로 렌더) 생성 후 로컬 DB 저장.
    final coverUrl = await renderRouteCover(route);
    final run = tracker.buildRun(coverImageUrl: coverUrl);
    await ref.read(appDatabaseProvider).upsertRun(run);
    // 정식 기록이 된 뒤에야 진행 중 스냅샷을 지운다(순서 중요).
    await tracker.clearSnapshot();
    // 저장 즉시 업로드 시도. 오프라인이면 대기 상태로 남아 이후 자동 재시도된다.
    unawaited(ref.read(runSyncServiceProvider).syncNow());
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
      RunSessionPhase.prerun =>
        _Prerun(runType: state.runType, onStart: _onStart),
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
          title: '러닝 완료',
          route: state.route,
          durStr: state.elapsedStr,
          distanceStr: state.distanceStr,
          paceStr: state.paceStr,
          kcal: state.kcal,
          closeIcon: RunDetailClose.x,
          onClose: tracker.reset,
          footer: _ResultFooter(onDone: tracker.reset),
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
}

// ── prerun ────────────────────────────────────────────────────
class _Prerun extends StatelessWidget {
  const _Prerun({required this.runType, required this.onStart});
  final RunType runType;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const Spacer(),
          _StartButton(onTap: onStart),
        ],
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
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: _RunMap(
                  route: state.route,
                  current: state.current,
                  recording: true,
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
        // ── 하단 패널 ────────────────────────────────────────
        DecoratedBox(
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
      ],
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
        if (widget.current == null)
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
        if (widget.recording)
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
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: AppColors.primary),
                  ),
                  const SizedBox(width: 6),
                  Text('GPS 기록 중',
                      style: AppTextStyles.mono(
                          fontSize: 9, color: AppColors.primary)),
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

class _RunTypeCard extends StatelessWidget {
  const _RunTypeCard(this.type);
  final RunType type;

  @override
  Widget build(BuildContext context) {
    final ({String emoji, String label, Color color}) meta = switch (type) {
      RunType.normal => (emoji: '🏃', label: '일반 러닝', color: AppColors.primary),
      RunType.theme => (emoji: '🗺️', label: '테마 러닝', color: AppColors.typeTheme),
      RunType.online => (
          emoji: '🏅',
          label: '온라인 마라톤',
          color: AppColors.typeOnline
        ),
    };
    return Container(
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
  }
}

class _WeatherCard extends StatelessWidget {
  const _WeatherCard();

  @override
  Widget build(BuildContext context) {
    return _MiniCard(
      child: Row(
        children: [
          const Text('☀️', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Column(
            // 기본값 MainAxisSize.max 로 두면 64 높이 카드를 세로로 꽉 채우고
            // 기본 정렬(start)이 글자를 위로 밀어붙인다. 그러면 Row 가 중앙에
            // 놓는 아이콘과 어긋나 보인다.
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('24°', style: AppTextStyles.display(fontSize: 20)),
              Text('체감 26°',
                  style: AppTextStyles.sans(
                      fontSize: 9, color: AppColors.mutedForeground)),
            ],
          ),
        ],
      ),
    );
  }
}

/// 미세먼지 카드 — 4단계 상태 바(기능정의서 4-2 섹션 B).
///
/// 값은 [airQualityProvider] 가 준다. 아직 에어코리아 연동 전이라 항상 null
/// 이고, 그때는 "불러오지 못했어요"(`offline-handling.md` §2-A)를 보인다.
class _DustCard extends ConsumerWidget {
  const _DustCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quality = ref.watch(airQualityProvider);
    if (quality == null) return const _MiniCard(child: _DustUnavailable());

    final color = _dustColor(quality);
    return _MiniCard(
      // 문서가 배경 활성을 '나쁨'·'매우나쁨' 으로 한정한다 — 좋음·보통까지
      // 물들이면 경고가 일상이 되어 정작 나쁜 날에 눈에 안 띈다.
      background: quality.needsAlertBackground
          ? AppColors.badgeBackground(color)
          : null,
      child: Column(
        // 위 _WeatherCard 와 같은 이유로 내용 높이만 차지하게 한다.
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('미세먼지',
              style: AppTextStyles.sans(
                  fontSize: 9, color: AppColors.mutedForeground)),
          const SizedBox(height: 3),
          Row(
            children: [
              Text(quality.label,
                  style: AppTextStyles.sans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: color)),
              const SizedBox(width: 8),
              _DustBar(step: quality.step, color: color),
            ],
          ),
        ],
      ),
    );
  }
}

/// 4단계 중 [step] 칸까지 채운 막대.
class _DustBar extends StatelessWidget {
  const _DustBar({required this.step, required this.color});

  final int step;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 4; i++) ...[
          if (i > 1) const SizedBox(width: 4),
          Container(
            width: 11,
            height: 6,
            decoration: BoxDecoration(
              color: i <= step ? color : AppColors.muted,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ],
      ],
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
  const _MiniCard({required this.child, this.background});
  final Widget child;

  /// 기본은 카드 색. 미세먼지 '나쁨' 이상에서만 경고색이 들어온다.
  final Color? background;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: background ?? AppColors.card,
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
                child: Text('START',
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
