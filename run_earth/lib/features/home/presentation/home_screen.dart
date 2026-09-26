import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/streak_day.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/images.dart';
import '../../../core/widgets/skeleton.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/data/user_repository.dart';
import '../../records/data/records_providers.dart';
import '../data/home_providers.dart';
import '../data/journey_master.dart';

// 여정 히어로 높이 — 화면이 남으면 히어로가 먹는다.
//
// Figma 정본의 폰 프레임은 320×640 이라 104 로도 홈이 거의 꽉 찬다. 그런데
// 요즘 기기(Pixel 9 는 411×923dp)에서는 같은 스택이 화면의 1/4 을 못 채워
// CTA 아래가 휑하게 빈다. Figma 에는 이 상황 자체가 없어 답이 없고,
// 남는 공간은 여정 카드가 먹기로 했다(figma-alignment 결정 ⑧) — 여정이
// 이 앱의 주인공이고, 104 에서는 도시 사진도 너무 낮게 잘린다.
const double _heroMin = 104; // Figma 정본 값
const double _heroMax = 220;

/// 히어로가 [_heroMin] 일 때 홈 전체가 차지하는 높이(Pixel 9·기본 글자 크기 실측).
///
/// 글자 크기 설정이나 언어가 다르면 어긋날 수 있다. 그래서 결과를
/// [_heroMin]~[_heroMax] 로 가둔다 — 추정이 틀려도 그 밖으로는 안 나간다.
const double _contentHeightAtHeroMin = 545;

/// 남는 세로 공간을 히어로 높이로 바꾼다.
double _heroHeightFor(double viewportHeight) =>
    (_heroMin + (viewportHeight - _contentHeightAtHeroMin))
        .clamp(_heroMin, _heroMax);

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
    // 세 값 모두 로컬 기록에서 계산되는데, 값이 없으면 0 으로 접힌다.
    // 그래서 '아직 못 읽었다' 와 '기록이 없다' 가 화면에서 같아 보인다 —
    // 뼈대를 세울지는 집계가 아니라 이 값으로 정한다(global-states.md 3).
    final loading = ref.watch(runsLoadingProvider);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Greeting(),
                const SizedBox(height: 16),
                if (loading) ...[
                  SkeletonCard(
                      height: _heroHeightFor(constraints.maxHeight) + 96),
                  const SizedBox(height: 12),
                  const SkeletonCard(height: 76),
                  const SizedBox(height: 12),
                  const SkeletonCard(height: 132),
                ] else ...[
                  _JourneyCard(journey,
                      heroHeight: _heroHeightFor(constraints.maxHeight)),
                  const SizedBox(height: 12),
                  _StatsRow(stats),
                  const SizedBox(height: 12),
                  _StreakCard(streak),
                ],
                const SizedBox(height: 16),
                // START 는 뼈대로 덮지 않는다 — 기록을 읽는 것과 무관하게
                // 언제나 눌러야 한다(오프라인에서도 러닝은 된다).
                const _StartCta(),
              ],
            ),
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

/// 도시 한 칸을 넘기는 데 필요한 가로 드래그 거리(px).
const double _kSlideThreshold = 56;

class _JourneyCard extends StatefulWidget {
  const _JourneyCard(this.journey, {required this.heroHeight});
  final JourneyProgress journey;

  /// 화면 크기에 따라 달라진다 — [_heroHeightFor] 참조.
  final double heroHeight;

  @override
  State<_JourneyCard> createState() => _JourneyCardState();
}

class _JourneyCardState extends State<_JourneyCard> {
  /// 🔧 **테스트용 미리보기 오프셋.** 현재 목적지에서 몇 칸 떨어진 도시를
  /// 보고 있는가. 0 이면 실제 목적지다.
  ///
  /// 22개 도시 이미지를 다 보려면 실제로 19,432km 를 달려야 해서, 배경이
  /// 제대로 들어갔는지 확인할 방법이 없었다. 좌우로 넘겨 확인한다.
  ///
  /// **디버그 빌드에서만 동작한다**(`kDebugMode`). 실서비스에서 여정 카드를
  /// 넘길 수 있으면 아직 도달하지 않은 도시를 미리 보게 돼 "달린 만큼
  /// 나아간다"는 앱의 전제가 깨진다.
  int _previewOffset = 0;

  /// 이번 드래그에서 누적으로 끈 가로 거리(px). [_kSlideThreshold] 를 넘으면
  /// 한 칸 넘기고 0 으로 되돌린다.
  double _dragDx = 0;

  JourneyProgress get journey => widget.journey;

  /// 미리보기 중인 도시(테스트용). 오프셋이 0 이면 실제 목적지와 같다.
  JourneyCity get _shownCity {
    final i = (journey.toCityIndex + _previewOffset)
        .clamp(0, journeyRoute.length - 1);
    return journeyRoute[i];
  }

  bool get _previewing => _shownCity.name != journey.toCity.name;

  void _slide(int delta) {
    if (!kDebugMode) return;
    setState(() {
      final next = journey.toCityIndex + _previewOffset + delta;
      if (next < 0 || next >= journeyRoute.length) return;
      _previewOffset += delta;
    });
  }

  @override
  Widget build(BuildContext context) {
    final heroHeight = widget.heroHeight;
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
          // 히어로. 배경은 다음 목적지 도시 이미지(journey.md §4).
          //
          // 🔧 디버그 빌드에서만 좌우로 넘겨 다른 도시 이미지를 미리 볼 수
          // 있다 — 22개를 다 보려면 19,432km 를 달려야 하기 때문이다.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            // 속도가 아니라 **끈 거리**로 센다. 속도 기준은 `adb input swipe`
            // 로 넣은 제스처를 놓쳤고(2026-09-26 실기기), 천천히 미는 손가락도
            // 놓친다. 거리 기준이면 끌고 있는 동안 여러 칸을 연속으로
            // 넘길 수 있어 22개를 훑기에도 낫다.
            onHorizontalDragStart: kDebugMode ? (_) => _dragDx = 0 : null,
            onHorizontalDragUpdate: kDebugMode
                ? (d) {
                    _dragDx += d.delta.dx;
                    if (_dragDx <= -_kSlideThreshold) {
                      _dragDx = 0;
                      _slide(1); // 왼쪽으로 밀기 → 다음 도시
                    } else if (_dragDx >= _kSlideThreshold) {
                      _dragDx = 0;
                      _slide(-1); // 오른쪽으로 밀기 → 이전 도시
                    }
                  }
                : null,
            onHorizontalDragEnd: kDebugMode ? (_) => _dragDx = 0 : null,
            child: Container(
            height: heroHeight,
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
                // 배경은 **다음 목적지** 도시 것이다(journey.md §4) — 도시를
                // 지날 때마다 `toCity` 가 바뀌므로 그림도 따라 바뀐다.
                //
                // 실패해도 아무것도 그리지 않는다. 뒤에 카드의 기본
                // 그라디언트가 이미 깔려 있어 조용히 단색으로 남는다
                // (§7 "배경 이미지는 실패해도 카드 자체는 정상 작동").
                if (_shownCity.imageKey.isNotEmpty)
                  Positioned.fill(
                    child: Image.network(
                      unsplashUrl(_shownCity.imageKey, w: 800, h: 460),
                      // 도시마다 다른 그림이라 key 를 줘야 넘길 때 교체된다.
                      key: ValueKey(_shownCity.imageKey),
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
                      Text(_previewing ? '미리보기 (테스트)' : '현재 여정',
                          style: AppTextStyles.mono(
                              fontSize: 8,
                              color: _previewing
                                  ? AppColors.accent
                                  : AppColors.primary)),
                      // 미리보기 중에는 보고 있는 도시 이름을 그대로 쓴다.
                      // 실제 구간(`인천 → 전주`)을 그대로 두면 그림과 글이
                      // 어긋나 어느 쪽이 맞는지 알 수 없다.
                      Text(
                          _previewing
                              ? _shownCity.name
                              : '$segmentFrom → $segmentTo',
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
                    child: Text(
                        _previewing
                            ? '${journeyRoute.indexOf(_shownCity) + 1} / ${journeyRoute.length}  ← →'
                            : '$remainingKm km 남음',
                        style: AppTextStyles.mono(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: _previewing
                                ? AppColors.accent
                                : AppColors.foreground)),
                  ),
                ),
                // 미리보기를 끝내고 실제 목적지로 돌아가는 길.
                if (_previewing)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: GestureDetector(
                      onTap: () => setState(() => _previewOffset = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(0x80),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: AppColors.accent),
                        ),
                        child: Text('실제로 돌아가기',
                            style: AppTextStyles.mono(
                                fontSize: 10, color: AppColors.accent)),
                      ),
                    ),
                  ),
              ],
            ),
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
                _JourneyBar(pct: journey.segmentPct),
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

/// 여정 진행바 — 채움은 그라데이션, 끝에는 현재 위치를 가리키는 흰 점(Figma).
///
/// `LinearProgressIndicator` 로는 마커를 바깥으로 못 내보낸다. 마커(12)가
/// 바(6)보다 커서 위아래로 삐져나오기 때문에 직접 그린다.
class _JourneyBar extends StatelessWidget {
  const _JourneyBar({required this.pct});

  /// 0~1 구간 진행률.
  final double pct;

  static const _barHeight = 6.0;
  static const _markerSize = 12.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final full = constraints.maxWidth;
        final filled = full * pct.clamp(0.0, 1.0);
        return SizedBox(
          height: _markerSize,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              Container(
                height: _barHeight,
                decoration: BoxDecoration(
                  color: AppColors.muted,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              Container(
                width: filled,
                height: _barHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00A854), AppColors.primary],
                  ),
                ),
              ),
              Positioned(
                // 점의 중심을 채움 끝에 맞추되 양 끝에서 잘리지 않게 가둔다.
                left: (filled - _markerSize / 2)
                    .clamp(0.0, full - _markerSize),
                child: Container(
                  width: _markerSize,
                  height: _markerSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: AppColors.primary, width: 2),
                    boxShadow: const [
                      BoxShadow(color: AppColors.primary, blurRadius: 8),
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
    // 이번 주 최고 연속 색이 카드 전체의 기준색이다 — 불꽃·빛·오늘 표시가
    // 다 이 색을 따라간다(Figma). 아직 한 번도 안 달렸으면 네온그린.
    final peak = AppColors.streakFill(streak.maxConsec) ?? AppColors.primary;
    final flameSize = 15 + streak.maxConsec * 1.4;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // 카드 아래쪽에서 올라오는 옅은 빛.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0, 1.2),
                    radius: 0.9,
                    colors: [peak.withAlpha(0x12), Colors.transparent],
                    stops: const [0, 0.65],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // 연속이 길수록 크고 밝게 탄다.
                        Text('🔥',
                            style: TextStyle(
                              fontSize: flameSize,
                              shadows: [
                                Shadow(
                                    color: peak,
                                    blurRadius: streak.maxConsec * 2.0),
                              ],
                            )),
                        const SizedBox(width: 6),
                        Text('달리기 스트릭',
                            style: AppTextStyles.sans(
                                fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.badgeBackground(AppColors.primary),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                            color: AppColors.primary.withAlpha(0x35)),
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
                    for (final d in streak.week) _StreakDot(d, peak: peak),
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

class _StreakDot extends StatelessWidget {
  const _StreakDot(this.day, {required this.peak});

  final StreakDay day;

  /// 이번 주 최고 연속 색 — 오늘 표시(점·날짜 글자)에만 쓴다.
  final Color peak;

  @override
  Widget build(BuildContext context) {
    final fill = AppColors.streakFill(day.consec);
    final isEmpty = fill == null;
    final lit = fill != null && !day.future;

    return Column(
      children: [
        Stack(
          // 오늘 점이 원 밖 아래에 붙는다.
          clipBehavior: Clip.none,
          alignment: Alignment.center,
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
                // 연속이 쌓일수록 번짐이 넓어진다. Figma 는 안쪽 그림자도
                // 함께 쓰지만 Flutter BoxShadow 에는 inset 이 없어 뺐다.
                boxShadow: lit
                    ? [
                        BoxShadow(
                          color: fill.withAlpha(0x70),
                          blurRadius: (day.consec ?? 0) * 6.0,
                        ),
                      ]
                    : null,
              ),
              child: (day.ran && !day.future)
                  ? const Icon(Icons.check, size: 12, color: Colors.black)
                  : Center(
                      child: Text(day.name,
                          style: AppTextStyles.sans(
                              fontSize: 8,
                              color: Colors.white
                                  .withAlpha(isEmpty ? 0x4D : 0xFF))),
                    ),
            ),
            // 오늘인데 아직 안 달렸으면 원 아래 점으로 "네 차례"를 알린다.
            if (day.today && !day.ran)
              Positioned(
                bottom: -2,
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: peak,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 3),
        Text(day.date,
            style: TextStyle(
                fontSize: 7,
                color: day.today ? peak : Colors.white.withAlpha(0x33))),
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
            // 달리기 탭(shell branch 1)으로 이동. goBranch 는 탭의 스택·
            // 스크롤 상태를 보존한다. 러닝 타입 '일반' 지정은 RunType 이
            // 아직 고정값이라 별도 작업 단위.
            onTap: () => StatefulNavigationShell.of(context).goBranch(1),
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
