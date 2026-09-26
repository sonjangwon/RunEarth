import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/geo.dart';
import '../../../core/models/run.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/inline_error.dart';
import '../../../core/widgets/skeleton.dart';
import '../../run/presentation/route_painter.dart';
import '../../../services/sync/run_sync_service.dart';
import '../data/records_providers.dart';
import 'record_badges.dart';

/// 기록 탭 — 로컬 DB의 러닝 기록을 요약·필터·월별 그룹으로 표시.
/// 정본: records.md, 기능정의서 4-3.
class RecordsScreen extends ConsumerWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(runsStreamProvider);
    final filter = ref.watch(recordsFilterProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: runsAsync.when(
          // 스피너가 아니라 목록 모양 뼈대를 세운다(global-states.md 3).
          loading: () => const _RecordsSkeleton(),
          error: (_, _) => InlineError(
            // 다시 구독하면 drift 가 처음부터 다시 흘려준다.
            onRetry: () => ref.invalidate(runsStreamProvider),
          ),
          data: (allRuns) {
            final typed = filter == null
                ? allRuns
                : allRuns.where((r) => r.type == filter).toList();
            // 0km 기록 정책(2026-09-26 개정): 미완료 러닝은 **목록에 아예
            // 내보내지 않는다.** 2026-09-20~23 에는 접어두고 "N건 보기"
            // 토글로 펼칠 수 있었는데, 사용자 결정으로 토글을 없앴다.
            //
            // DB 에서 지우는 것은 아니다 — `records.md` 4 의 영구 보존은
            // 그대로다. 화면에 내보내지 않을 뿐이다.
            final runs = typed.where((r) => !r.isIncomplete).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text('내 기록', style: AppTextStyles.display(fontSize: 24)),
                ),
                _SummaryStats(runs),
                const _FilterBar(),
                Expanded(
                  child: runs.isEmpty
                      ? const _EmptyState()
                      : _RunList(runs),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// 기록 탭 로딩 뼈대. 제목 · 요약 카드 · 필터바 · 카드 3장으로, **실제 화면과
/// 같은 순서와 치수**로 세운다. 데이터가 도착할 때 화면이 튀지 않으려면
/// 뼈대가 실물과 같은 자리를 차지해야 한다.
class _RecordsSkeleton extends StatelessWidget {
  const _RecordsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text('내 기록', style: AppTextStyles.display(fontSize: 24)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: SkeletonCard(height: 86),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: SkeletonBox(width: 220, height: 32, radius: 16),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const NeverScrollableScrollPhysics(),
            children: const [
              SkeletonBox(width: 80, height: 14),
              SizedBox(height: 10),
              SkeletonCard(height: 96),
              SizedBox(height: 8),
              SkeletonCard(height: 96),
              SizedBox(height: 8),
              SkeletonCard(height: 96),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatTotalTime(List<Run> runs) {
  // 초 변환은 Run 확장(`durSeconds`)이 정본 — 같은 파싱을 여기·홈에 복제하지 않는다.
  var totalSeconds = 0;
  for (final r in runs) {
    totalSeconds += r.durSeconds;
  }
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  return '${h}h ${m}m';
}

/// 전체 기간 요약 — Figma 정본(App.tsx 1076-1093).
/// 카드로 감싸고 값은 네온그린, 우상단에 옅은 radial glow 를 깐다.
class _SummaryStats extends StatelessWidget {
  const _SummaryStats(this.runs);
  final List<Run> runs;

  @override
  Widget build(BuildContext context) {
    final totalKm =
        runs.fold<double>(0, (sum, r) => sum + r.km).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // 카드 밖으로 걸치는 원형 글로우. clipBehavior 로 잘려 모서리를 물들인다.
            Positioned(
              top: -24,
              right: -24,
              child: Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withAlpha(0x14),
                      AppColors.primary.withAlpha(0x00),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('전체 기간 요약',
                      style: AppTextStyles.mono(
                          fontSize: 9, color: AppColors.mutedForeground)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _stat('총 거리', totalKm, 'km')),
                      Expanded(
                          child: _stat('총 시간', _formatTotalTime(runs), '')),
                      Expanded(child: _stat('총 횟수', '${runs.length}', '회')),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value, String unit) => Column(
        children: [
          RichText(
            text: TextSpan(
              text: value,
              style: AppTextStyles.display(
                  fontSize: 20, color: AppColors.primary),
              children: [
                if (unit.isNotEmpty)
                  TextSpan(
                      text: unit,
                      style: AppTextStyles.sans(
                          fontSize: 9, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: AppTextStyles.sans(
                  fontSize: 9, color: AppColors.mutedForeground)),
        ],
      );
}

/// 필터 칩 색 — 타입 뱃지와 같은 색을 쓴다(Figma TYPE_BADGE). '전체'는 네온그린.
Color _filterColor(RecordType? type) => switch (type) {
      null => AppColors.primary,
      RecordType.normal => AppColors.typeNormal,
      RecordType.theme => AppColors.typeTheme,
      RecordType.online => AppColors.typeOnline,
    };

class _FilterBar extends ConsumerWidget {
  const _FilterBar();

  static const _options = <({String label, RecordType? value})>[
    (label: '전체', value: null),
    (label: '일반', value: RecordType.normal),
    (label: '테마', value: RecordType.theme),
    (label: '온라인', value: RecordType.online),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(recordsFilterProvider);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        itemCount: _options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final opt = _options[i];
          final isSel = selected == opt.value;
          return GestureDetector(
            onTap: () =>
                ref.read(recordsFilterProvider.notifier).state = opt.value,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // Figma: 비활성은 배경 없이 테두리만, 활성은 그 타입의 색을 쓴다
                // ('전체' 는 네온그린). 선택된 칩만으로 지금 무슨 타입을 보는지 안다.
                color: isSel
                    ? AppColors.badgeBackground(_filterColor(opt.value))
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: isSel
                        ? _filterColor(opt.value).withAlpha(0x50)
                        : AppColors.border),
              ),
              child: Text(opt.label,
                  style: AppTextStyles.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isSel
                          ? _filterColor(opt.value)
                          : AppColors.mutedForeground)),
            ),
          );
        },
      ),
    );
  }
}

class _RunList extends StatelessWidget {
  const _RunList(this.runs);
  final List<Run> runs;

  @override
  Widget build(BuildContext context) {
    // 연도·월·날짜 내림차순 정렬 후, 월 경계마다 그룹을 만든다.
    final sorted = [...runs]..sort((a, b) {
        if (a.year != b.year) return b.year - a.year;
        if (a.month != b.month) return b.month - a.month;
        return b.date.compareTo(a.date);
      });

    final groups = <({int year, int month, List<Run> runs})>[];
    for (final r in sorted) {
      final last = groups.isEmpty ? null : groups.last;
      if (last != null && last.year == r.year && last.month == r.month) {
        last.runs.add(r);
      } else {
        groups.add((year: r.year, month: r.month, runs: [r]));
      }
    }

    // 월 헤더를 스크롤 상단에 고정하려면 Sliver 가 필요하다(Figma: sticky).
    return CustomScrollView(
      slivers: [
        for (final g in groups) ...[
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyMonthHeader(year: g.year, month: g.month),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.builder(
              itemCount: g.runs.length,
              itemBuilder: (context, i) => _RunCard(g.runs[i]),
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

/// 스크롤 상단에 붙는 월 헤더. 아래쪽을 투명으로 빼 카드가 배경으로
/// 스며들며 지나가게 한다(Figma 1124-1134).
class _StickyMonthHeader extends SliverPersistentHeaderDelegate {
  const _StickyMonthHeader({required this.year, required this.month});

  final int year;
  final int month;

  static const _height = 28.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.background,
            Color(0x00070911),
          ],
          stops: [0, 0.7, 1],
        ),
      ),
      child: Text('$year년 ${month.toString().padLeft(2, '0')}월',
          style: AppTextStyles.mono(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.mutedForeground)),
    );
  }

  @override
  bool shouldRebuild(covariant _StickyMonthHeader old) =>
      old.year != year || old.month != month;
}

/// 기록 카드 — Figma 정본(App.tsx 1141-1171).
///
/// 좌측 44 경로 썸네일 → 날짜+뱃지 → 거리(큰 글자) → 시간·페이스·칼로리 순.
/// 썸네일은 **저장된 PNG 를 읽지 않고 `route` 좌표로 그린다** — 상세 화면과
/// 같은 `RoutePainter` 라 두 화면의 경로 모양이 어긋날 수 없고, PNG 가
/// 없는 기록(렌더 실패·재설치·서버 복원)도 항상 표시된다. 1080px PNG 를
/// 카드마다 디코딩하는 것보다 메모리도 훨씬 적게 든다.
///
/// > Figma 의 썸네일 path 는 카드 순번으로 모양을 바꾸는 **목업**이다.
/// > 크기·스타일만 가져오고 경로는 실제 좌표를 쓴다.
class _RunCard extends ConsumerWidget {
  const _RunCard(this.run);
  final Run run;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 아직 서버에 못 올린 기록인지. 판정 전(로딩)에는 붙이지 않는다 —
    // 딱지가 잠깐 나타났다 사라지는 깜빡임을 피하기 위해.
    final pending = ref
            .watch(pendingSyncRunIdsProvider)
            .valueOrNull
            ?.contains(run.id) ??
        false;
    return GestureDetector(
      // 카드 전체가 상세 진입점(기능정의서 4-3 섹션 D). 여백까지 눌리도록
      // behavior 를 opaque 로 둔다.
      behavior: HitTestBehavior.opaque,
      onTap: () => context.push('/records/${run.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _RouteThumb(route: run.route),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text('${run.date} (${run.day})',
                                style: AppTextStyles.sans(
                                    fontSize: 10,
                                    color: AppColors.mutedForeground)),
                            RecordTypeBadge(run.type),
                            if (run.isIncomplete) const IncompleteRunChip(),
                            if (pending) const PendingSyncChip(),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right,
                          size: 16, color: AppColors.mutedForeground),
                    ],
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: '${run.km}',
                      style: AppTextStyles.display(fontSize: 22),
                      children: [
                        TextSpan(
                            text: ' km',
                            style: AppTextStyles.sans(
                                fontSize: 10,
                                color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      _MetaItem(icon: Icons.schedule, text: run.dur),
                      const SizedBox(width: 10),
                      _MetaItem(icon: Icons.bolt, text: run.pace),
                      const SizedBox(width: 10),
                      // 칼로리는 아직 계산하지 않는다(체중 입력이 없다 —
                      // `run_tracker.dart` 의 [보류]). 상세 화면은 이미 '--'
                      // 로 비워 두는데 카드만 '0' 을 적고 있었다. 0 은 "태운
                      // 게 없다" 는 **값**으로 읽히고, 같은 기록을 카드와
                      // 상세에서 다르게 보여준다(2026-09-25).
                      _MetaItem(
                          icon: Icons.local_fire_department,
                          text: run.kcal > 0 ? '${run.kcal}' : '--'),
                    ],
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

/// 카드 좌측 44×44 경로 썸네일.
class _RouteThumb extends StatelessWidget {
  const _RouteThumb({required this.route});
  final List<LatLngPoint> route;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: route.length >= 2
          ? CustomPaint(
              painter: RoutePainter(
                route: route,
                // 카드 썸네일이라 배경은 카드 계열(muted)로 맞춘다.
                background: AppColors.muted,
              ),
            )
          // 경로가 없는 기록(미완료·GPS 실패)은 빈 칸 대신 옅은 표식을 둔다.
          : const Icon(Icons.remove,
              size: 14, color: AppColors.mutedForeground),
    );
  }
}

/// 카드 하단 메타 한 칸 — 아이콘 + 값.
/// Figma 는 이 줄만 이모지(⏱ ⚡ 🔥)를 쓰지만, 이모지→아이콘 방침
/// (2026-09-20 사용자 결정)에 따라 아이콘으로 통일한다.
class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.mutedForeground),
        const SizedBox(width: 3),
        Text(text,
            style: AppTextStyles.mono(
                fontSize: 10, color: AppColors.mutedForeground)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('아직 기록이 없어요',
          style: AppTextStyles.sans(
              fontSize: 14, color: AppColors.mutedForeground)),
    );
  }
}
