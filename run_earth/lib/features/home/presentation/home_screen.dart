import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/streak_day.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/images.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/data/user_repository.dart';
import '../data/home_providers.dart';

// 여정 히어로 배경 (개발용 임시 Unsplash). journey.md 는 "다음 목적지 도시"별
// 이미지를 규정하나 도시별 에셋이 [미확정] → 우선 단일 임시 이미지.
const _journeyHeroImg = 'photo-1534430480872-3498386e7856';

String _greeting() {
  final h = DateTime.now().hour;
  if (h >= 5 && h <= 10) return '좋은 아침이에요,';
  if (h >= 11 && h <= 16) return '오늘도 힘내요,';
  if (h >= 17 && h <= 20) return '좋은 저녁이에요,';
  return '야간 러너시네요,';
}

/// 홈 탭 — 여정·스트릭·통계·CTA.
/// 정본: home.md(인사말/빈상태), journey.md(여정), streak.md(스트릭).
/// 여정·통계·스트릭은 로컬 DB 기록(runsStreamProvider)에서 계산된다.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(homeStatsProvider);
    final journey = ref.watch(journeyProgressProvider);
    final streak = ref.watch(streakProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Greeting(),
              const SizedBox(height: 16),
              _JourneyCard(journey),
              const SizedBox(height: 12),
              _StatsRow(stats),
              const SizedBox(height: 12),
              _StreakCard(streak),
              const SizedBox(height: 16),
              const _StartCta(),
            ],
          ),
        ),
      ),
    );
  }
}

class _Greeting extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 서버 조회가 끝나기 전에는 세션 메타데이터의 이름을 먼저 보여준다.
    final name =
        ref.watch(currentAppUserProvider).valueOrNull?.name ??
            sessionDisplayName();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(_greeting(),
            style: AppTextStyles.sans(
                fontSize: 11, color: AppColors.mutedForeground)),
        const SizedBox(height: 2),
        Row(
          children: [
            Text('$name님 ',
                style: AppTextStyles.display(fontSize: 24, letterSpacing: 0.5)),
            const Text('🔥', style: TextStyle(fontSize: 20)),
          ],
        ),
      ],
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard(this.journey);
  final JourneyProgress journey;

  @override
  Widget build(BuildContext context) {
    final segmentFrom = journey.fromCity.name;
    final segmentTo = journey.toCity.name;
    final fromKm = journey.fromCity.cumulativeKm.toStringAsFixed(0);
    final toKm = journey.toCity.cumulativeKm.toStringAsFixed(0);
    final remainingKm = journey.remainingKm.toStringAsFixed(1);
    final positionKm = journey.absolutePositionKm.toStringAsFixed(1);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0E1120), Color(0xFF0A0D16)],
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 히어로 (배경 이미지는 journey.md [미확정] → 그라디언트 플레이스홀더)
          Container(
            height: 104,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
                colors: [Color(0xFF101522), Color(0xFF1A2336)],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.network(
                    unsplashUrl(_journeyHeroImg, w: 600, h: 240),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Colors.black.withAlpha(0xCC),
                          Colors.black.withAlpha(0x59),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  bottom: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('현재 여정',
                          style: AppTextStyles.mono(
                              fontSize: 8, color: AppColors.primary)),
                      Text('$segmentFrom → $segmentTo',
                          style: AppTextStyles.display(fontSize: 18)),
                    ],
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(0x80),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withAlpha(0x1A)),
                    ),
                    child: Text('$remainingKm km 남음',
                        style: AppTextStyles.mono(
                            fontSize: 10, fontWeight: FontWeight.w500)),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('$segmentFrom ${fromKm}km',
                        style: AppTextStyles.mono(
                            fontSize: 8, color: AppColors.mutedForeground)),
                    Text('${positionKm}km ▲',
                        style: AppTextStyles.mono(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary)),
                    Text('$segmentTo ${toKm}km',
                        style: AppTextStyles.mono(
                            fontSize: 8, color: AppColors.mutedForeground)),
                  ],
                ),
                const SizedBox(height: 8),
                // 진행률 바
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: journey.segmentPct,
                    minHeight: 6,
                    backgroundColor: AppColors.muted,
                    valueColor:
                        const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(height: 10),
                // 마일스톤 도시
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (final m in journey.milestones)
                      _MilestoneDot(
                          city: m.name, done: m.done, current: m.current),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MilestoneDot extends StatelessWidget {
  const _MilestoneDot(
      {required this.city, required this.done, required this.current});
  final String city;
  final bool done;
  final bool current;

  @override
  Widget build(BuildContext context) {
    final Color labelColor = done
        ? AppColors.primary
        : current
            ? AppColors.foreground
            : AppColors.mutedForeground;
    return Column(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? AppColors.primary : AppColors.muted,
            border: Border.all(
              color: (done || current) ? AppColors.primary : AppColors.border,
              width: current ? 2 : 1,
            ),
          ),
          child: done
              ? const Icon(Icons.check, size: 9, color: Colors.black)
              : current
                  ? Center(
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: AppColors.primary),
                      ),
                    )
                  : null,
        ),
        const SizedBox(height: 2),
        Text(city, style: AppTextStyles.sans(fontSize: 8, color: labelColor)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow(this.stats);
  final HomeStats stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
              icon: Icons.timeline,
              label: '총 거리',
              value: stats.totalKm.toStringAsFixed(1),
              unit: 'km'),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
              icon: Icons.schedule,
              label: '총 시간',
              value: stats.durationLabel,
              unit: ''),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
              icon: Icons.directions_run,
              label: '총 횟수',
              value: '${stats.count}',
              unit: '회'),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.unit});
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 11, color: AppColors.primary),
              const SizedBox(width: 3),
              Text(label,
                  style: AppTextStyles.sans(
                      fontSize: 9, color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              text: value,
              style: AppTextStyles.display(fontSize: 17),
              children: [
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: AppTextStyles.sans(
                        fontSize: 9, color: AppColors.mutedForeground),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard(this.streak);
  final StreakInfo streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 15)),
                  const SizedBox(width: 6),
                  Text('달리기 스트릭',
                      style: AppTextStyles.sans(
                          fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.badgeBackground(AppColors.primary),
                  borderRadius: BorderRadius.circular(999),
                  border:
                      Border.all(color: AppColors.primary.withAlpha(0x35)),
                ),
                child: Text('${streak.weekStreakCount}주 연속',
                    style: AppTextStyles.mono(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final d in streak.week) _StreakDot(d),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakDot extends StatelessWidget {
  const _StreakDot(this.day);
  final StreakDay day;

  @override
  Widget build(BuildContext context) {
    final fill = AppColors.streakFill(day.consec);
    final isEmpty = fill == null;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: day.future
                ? Colors.white.withAlpha(0x08)
                : (fill ?? Colors.white.withAlpha(0x0D)),
            border: Border.all(
              color: day.future
                  ? Colors.white.withAlpha(0x10)
                  : (fill ?? Colors.white.withAlpha(0x1A)),
              width: 1.5,
            ),
          ),
          child: (day.ran && !day.future)
              ? const Icon(Icons.check, size: 12, color: Colors.black)
              : Center(
                  child: Text(day.name,
                      style: AppTextStyles.sans(
                          fontSize: 8,
                          color: Colors.white.withAlpha(isEmpty ? 0x4D : 0xFF))),
                ),
        ),
        const SizedBox(height: 3),
        Text(day.date,
            style: TextStyle(
                fontSize: 7,
                color: day.today
                    ? AppColors.primary
                    : Colors.white.withAlpha(0x33))),
      ],
    );
  }
}

class _StartCta extends StatelessWidget {
  const _StartCta();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Color(0xFF00E87A), Color(0xFF00C060)],
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {}, // 이후 단위: 달리기 탭 이동 + 러닝 타입 '일반'
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, size: 18, color: Colors.black),
                  const SizedBox(width: 6),
                  Text('지금 달리기 시작',
                      style: AppTextStyles.display(
                          fontSize: 16,
                          color: Colors.black,
                          letterSpacing: 0.5)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
