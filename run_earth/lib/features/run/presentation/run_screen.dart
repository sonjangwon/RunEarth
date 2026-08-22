import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

enum _Phase { prerun, countdown, running, stopped }

/// 달리기 탭 — 러닝 세션 상태머신 UI.
/// 정본: 기능정의서 4-2-C(상태머신), run-flow.md(일시정지/종료 동작).
/// ⚠️ 실제 GPS 추적·지도·기록 저장은 다음 단위. 지금은 UI + 경과시간(실제)만.
class RunScreen extends StatefulWidget {
  const RunScreen({super.key});

  @override
  State<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends State<RunScreen> {
  /// 진입 경로로 결정되는 러닝 타입(변경 불가). 지금은 기본 '일반 러닝'.
  final RunType _runType = RunType.normal;

  _Phase _phase = _Phase.prerun;
  int _count = 3;
  bool _paused = false;
  bool _showStopConfirm = false;
  Duration _elapsed = Duration.zero;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() {
      _phase = _Phase.countdown;
      _count = 3;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_count <= 1) {
        t.cancel();
        _beginRun();
      } else {
        setState(() => _count--);
      }
    });
  }

  void _beginRun() {
    setState(() {
      _phase = _Phase.running;
      _paused = false;
      _elapsed = Duration.zero;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused) setState(() => _elapsed += const Duration(seconds: 1));
    });
  }

  void _reset() {
    _timer?.cancel();
    setState(() {
      _phase = _Phase.prerun;
      _paused = false;
      _elapsed = Duration.zero;
      _showStopConfirm = false;
    });
  }

  void _confirmStop() {
    _timer?.cancel();
    setState(() {
      _showStopConfirm = false;
      _phase = _Phase.stopped;
    });
  }

  String get _elapsedStr {
    final h = _elapsed.inHours;
    final m = _elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = _elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final Widget body = switch (_phase) {
      _Phase.prerun => _buildPrerun(),
      _Phase.countdown => const _MapPlaceholder(),
      _Phase.running => _buildRunning(),
      _Phase.stopped => _buildResult(),
    };

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: body),
            if (_phase == _Phase.countdown) _buildCountdownOverlay(),
            if (_showStopConfirm) _buildStopConfirm(),
          ],
        ),
      ),
    );
  }

  // ── prerun ──────────────────────────────────────────────────
  Widget _buildPrerun() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RunTypeCard(_runType),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(child: _WeatherCard()),
              SizedBox(width: 8),
              Expanded(child: _DustCard()),
            ],
          ),
          const Spacer(),
          _StartButton(onTap: _startCountdown),
        ],
      ),
    );
  }

  // ── running / paused ────────────────────────────────────────
  Widget _buildRunning() {
    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              const Positioned.fill(child: _MapPlaceholder(recording: true)),
              // 상단 실시간 수치
              Positioned(
                top: 12,
                left: 16,
                right: 16,
                child: _LiveStats(
                    distance: '0.00', pace: "--'--\"", time: _elapsedStr),
              ),
              if (_paused)
                Positioned(
                  top: 90,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(0x99),
                        borderRadius: BorderRadius.circular(999),
                        border:
                            Border.all(color: AppColors.accent.withAlpha(0x66)),
                      ),
                      child: Text('일시정지됨',
                          style: AppTextStyles.sans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent)),
                    ),
                  ),
                ),
            ],
          ),
        ),
        // 하단 컨트롤
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
                  label: _paused ? 'RESUME' : 'PAUSE',
                  icon: _paused ? Icons.play_arrow : Icons.pause,
                  filled: _paused,
                  onTap: () => setState(() => _paused = !_paused),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ControlButton(
                  label: 'STOP',
                  icon: Icons.stop,
                  danger: true,
                  onTap: () => setState(() => _showStopConfirm = true),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── stopped (간단 결과, 전체 RunDetailView는 이후 단위) ──────────
  Widget _buildResult() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: _reset,
              icon: const Icon(Icons.close, color: AppColors.foreground),
            ),
          ),
          const SizedBox(height: 8),
          Text('러닝 종료', style: AppTextStyles.display(fontSize: 26)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _resultRow('시간', _elapsedStr),
                _resultRow('거리', '0.00 km'),
                _resultRow('페이스', "--'--\" /km"),
                _resultRow('칼로리', '-- kcal'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('상세 결과(RunDetailView)와 기록 저장은 GPS 연동 단위에서 연결됩니다.',
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

  // ── countdown overlay ───────────────────────────────────────
  Widget _buildCountdownOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black,
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, anim) =>
                ScaleTransition(scale: anim, child: child),
            child: Text(
              '$_count',
              key: ValueKey(_count),
              style: AppTextStyles.display(
                  fontSize: 140, color: AppColors.primary),
            ),
          ),
        ),
      ),
    );
  }

  // ── stop confirm popup ──────────────────────────────────────
  Widget _buildStopConfirm() {
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
                        onTap: () =>
                            setState(() => _showStopConfirm = false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ControlButton(
                        label: '네',
                        filled: true,
                        onTap: _confirmStop,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('24°',
                  style: AppTextStyles.display(fontSize: 20)),
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
    // 좋음/보통 → 중립 배경 (기능정의서 4-2-B). 여기선 '보통'.
    return _MiniCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('미세먼지',
              style: AppTextStyles.sans(
                  fontSize: 9, color: AppColors.mutedForeground)),
          const SizedBox(height: 2),
          Text('보통',
              style: AppTextStyles.sans(
                  fontSize: 16, fontWeight: FontWeight.w700)),
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

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({this.recording = false});
  final bool recording;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0A1220), Color(0xFF040810)],
        ),
      ),
      child: Stack(
        children: [
          Center(
            child: Text('🛰  지도는 GPS 연동 단위에서 표시됩니다',
                style: AppTextStyles.sans(
                    fontSize: 12, color: AppColors.mutedForeground)),
          ),
          if (recording)
            Positioned(
              top: 12,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
      ),
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
                        fontSize: 20,
                        color: Colors.black,
                        letterSpacing: 1)),
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
