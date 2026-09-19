import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/db/app_database.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/geo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/sync/run_sync_service.dart';
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
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: _LiveStats(
                  distance: state.distanceStr,
                  pace: state.paceStr,
                  time: state.elapsedStr,
                ),
              ),
              if (state.isPaused)
                const Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Center(child: _PausedBadge()),
                ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          decoration: const BoxDecoration(
            color: AppColors.card,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ControlButton(
                  label: state.isPaused ? 'RESUME' : 'PAUSE',
                  icon: state.isPaused ? Icons.play_arrow : Icons.pause,
                  filled: state.isPaused,
                  onTap: onTogglePause,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ControlButton(
                  label: 'STOP',
                  icon: Icons.stop,
                  danger: true,
                  onTap: onStop,
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
class _CountdownOverlay extends StatelessWidget {
  const _CountdownOverlay({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              '$count',
              key: ValueKey(count),
              style:
                  AppTextStyles.display(fontSize: 140, color: AppColors.primary),
            ),
          ),
        ),
      ),
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
                      child: _ControlButton(label: '아니요', onTap: onCancel),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ControlButton(
                          label: '네', filled: true, onTap: onConfirm),
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

class _DustCard extends StatelessWidget {
  const _DustCard();

  @override
  Widget build(BuildContext context) {
    return _MiniCard(
      child: Column(
        // 위 _WeatherCard 와 같은 이유로 내용 높이만 차지하게 한다.
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('미세먼지',
              style: AppTextStyles.sans(
                  fontSize: 9, color: AppColors.mutedForeground)),
          const SizedBox(height: 2),
          Text('보통',
              style:
                  AppTextStyles.sans(fontSize: 16, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard({required this.child});
  final Widget child;

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

class _LiveStats extends StatelessWidget {
  const _LiveStats(
      {required this.distance, required this.pace, required this.time});
  final String distance;
  final String pace;
  final String time;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(0x80),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha(0x14)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _item('거리', distance, 'km'),
          _item('페이스', pace, '/km'),
          _item('시간', time, ''),
        ],
      ),
    );
  }

  Widget _item(String label, String value, String unit) => Column(
        children: [
          Text(label,
              style: AppTextStyles.sans(
                  fontSize: 9, color: AppColors.mutedForeground)),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              text: value,
              style: AppTextStyles.display(fontSize: 22),
              children: [
                if (unit.isNotEmpty)
                  TextSpan(
                      text: ' $unit',
                      style: AppTextStyles.sans(
                          fontSize: 9, color: AppColors.mutedForeground)),
              ],
            ),
          ),
        ],
      );
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

class _ControlButton extends StatelessWidget {
  const _ControlButton({
    required this.label,
    this.icon,
    this.filled = false,
    this.danger = false,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool filled;
  final bool danger;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color fg = danger
        ? const Color(0xFFEF4444)
        : filled
            ? Colors.black
            : AppColors.foreground;
    return Material(
      color: filled ? AppColors.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: filled
                ? null
                : Border.all(
                    color: danger
                        ? const Color(0xFFEF4444).withAlpha(0x66)
                        : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(label,
                  style: AppTextStyles.display(
                      fontSize: 16, color: fg, letterSpacing: 0.5)),
            ],
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
