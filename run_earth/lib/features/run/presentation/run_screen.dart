import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/db/app_database.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/geo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/run_tracker.dart';
import 'route_image_renderer.dart';
import 'route_painter.dart';

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

  Future<void> _onStopConfirmed() async {
    setState(() => _showStopConfirm = false);
    final tracker = ref.read(runTrackerProvider.notifier);
    final route = ref.read(runTrackerProvider).route;
    tracker.stop(); // 결과 화면으로 즉시 전환

    // 대표 이미지(경로 렌더) 생성 후 로컬 DB 저장.
    final coverUrl = await renderRouteCover(route);
    final run = tracker.buildRun(coverImageUrl: coverUrl);
    await ref.read(appDatabaseProvider).upsertRun(run);
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
        _Prerun(runType: state.runType, onStart: tracker.start),
      RunSessionPhase.countdown =>
        const ColoredBox(color: AppColors.background),
      RunSessionPhase.running ||
      RunSessionPhase.paused =>
        _Running(
          state: state,
          onTogglePause: tracker.togglePause,
          onStop: () => setState(() => _showStopConfirm = true),
        ),
      RunSessionPhase.stopped => _Result(state: state, onClose: tracker.reset),
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
class _Result extends StatelessWidget {
  const _Result({required this.state, required this.onClose});
  final RunSessionState state;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final hasKcal = state.kcal > 0;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: onClose,
              icon: const Icon(Icons.close, color: AppColors.foreground),
            ),
          ),
          const SizedBox(height: 8),
          Text('러닝 종료', style: AppTextStyles.display(fontSize: 26)),
          const SizedBox(height: 16),
          // 대표 이미지 = 경로 렌더 (사진 미등록 기본값).
          AspectRatio(
            aspectRatio: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: state.route.length >= 2
                  ? CustomPaint(painter: RoutePainter(route: state.route))
                  : const _NoRoutePlaceholder(),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _resultRow('시간', state.elapsedStr),
                _resultRow('거리', '${state.distanceStr} km'),
                _resultRow('페이스', '${state.paceStr} /km'),
                _resultRow('칼로리', hasKcal ? '${state.kcal} kcal' : '-- kcal'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text('기록 탭에서 방금 러닝을 확인할 수 있어요.',
              style: AppTextStyles.sans(
                  fontSize: 11, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }

  Widget _resultRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: AppTextStyles.sans(
                    fontSize: 13, color: AppColors.mutedForeground)),
            Text(value, style: AppTextStyles.display(fontSize: 20)),
          ],
        ),
      );
}

class _NoRoutePlaceholder extends StatelessWidget {
  const _NoRoutePlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.card,
      child: Center(
        child: Text('경로가 기록되지 않았어요',
            style: AppTextStyles.sans(
                fontSize: 12, color: AppColors.mutedForeground)),
      ),
    );
  }
}

// ── 러닝 중 지도 (GoogleMap 실지도) ───────────────────────────
/// 러닝 중 실제 지도 위에 경로를 네온그린 폴리라인으로 그린다.
/// 커버 이미지(결과 화면)는 여전히 [RoutePainter] 캔버스를 쓴다(결정사항 #2).
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
            style: _darkMapStyle,
            onMapCreated: (ctrl) => _controller = ctrl,
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
        if (widget.route.length < 2)
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
