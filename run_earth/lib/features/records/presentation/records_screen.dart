import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/run.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
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
          loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.primary)),
          error: (_, _) => Center(
              child: Text('불러오지 못했어요',
                  style: AppTextStyles.sans(color: AppColors.mutedForeground))),
          data: (allRuns) {
            final runs = filter == null
                ? allRuns
                : allRuns.where((r) => r.type == filter).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text('기록', style: AppTextStyles.display(fontSize: 24)),
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

String _formatTotalTime(List<Run> runs) {
  var totalSeconds = 0;
  for (final r in runs) {
    final parts = r.dur.split(':').map(int.tryParse).toList();
    if (parts.contains(null)) continue;
    if (parts.length == 2) {
      totalSeconds += parts[0]! * 60 + parts[1]!;
    } else if (parts.length == 3) {
      totalSeconds += parts[0]! * 3600 + parts[1]! * 60 + parts[2]!;
    }
  }
  final h = totalSeconds ~/ 3600;
  final m = (totalSeconds % 3600) ~/ 60;
  return '${h}h ${m}m';
}

class _SummaryStats extends StatelessWidget {
  const _SummaryStats(this.runs);
  final List<Run> runs;

  @override
  Widget build(BuildContext context) {
    final totalKm =
        runs.fold<double>(0, (sum, r) => sum + r.km).toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(child: _stat('총 거리', totalKm, 'km')),
          Expanded(child: _stat('총 시간', _formatTotalTime(runs), '')),
          Expanded(child: _stat('총 횟수', '${runs.length}', '회')),
        ],
      ),
    );
  }

  Widget _stat(String label, String value, String unit) => Column(
        children: [
          RichText(
            text: TextSpan(
              text: value,
              style: AppTextStyles.display(fontSize: 20),
              children: [
                if (unit.isNotEmpty)
                  TextSpan(
                      text: ' $unit',
                      style: AppTextStyles.sans(
                          fontSize: 9, color: AppColors.mutedForeground)),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.sans(
                  fontSize: 10, color: AppColors.mutedForeground)),
        ],
      );
}

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
                color: isSel
                    ? AppColors.badgeBackground(AppColors.primary)
                    : AppColors.muted,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                    color: isSel ? AppColors.primary : AppColors.border),
              ),
              child: Text(opt.label,
                  style: AppTextStyles.sans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isSel ? AppColors.primary : AppColors.mutedForeground)),
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
    // 연도·월·날짜 내림차순 정렬 후, 월 경계마다 헤더 삽입.
    final sorted = [...runs]..sort((a, b) {
        if (a.year != b.year) return b.year - a.year;
        if (a.month != b.month) return b.month - a.month;
        return b.date.compareTo(a.date);
      });

    final items = <Widget>[];
    int? lastYear;
    int? lastMonth;
    for (final r in sorted) {
      if (r.year != lastYear || r.month != lastMonth) {
        items.add(_MonthHeader(year: r.year, month: r.month));
        lastYear = r.year;
        lastMonth = r.month;
      }
      items.add(_RunCard(r));
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      children: items,
    );
  }
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({required this.year, required this.month});
  final int year;
  final int month;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Text('$year년 ${month.toString().padLeft(2, '0')}월',
          style: AppTextStyles.mono(
              fontSize: 11, color: AppColors.mutedForeground)),
    );
  }
}

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
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 날짜 / 요일
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(run.date, style: AppTextStyles.display(fontSize: 18)),
                Text(run.day,
                    style: AppTextStyles.sans(
                        fontSize: 10, color: AppColors.mutedForeground)),
              ],
            ),
            const SizedBox(width: 12),
            RecordTypeBadge(run.type),
            if (pending) ...[
              const SizedBox(width: 6),
              const PendingSyncChip(),
            ],
            const Spacer(),
            // 수치
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    text: '${run.km}',
                    style: AppTextStyles.display(fontSize: 20),
                    children: [
                      TextSpan(
                          text: ' km',
                          style: AppTextStyles.sans(
                              fontSize: 10, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text('${run.pace}  ·  ${run.dur}  ·  ${run.kcal}kcal',
                    style: AppTextStyles.mono(
                        fontSize: 10, color: AppColors.mutedForeground)),
              ],
            ),
          ],
        ),
      ),
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
