import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/enums.dart';
import '../../../core/models/run.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/inline_error.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../services/sync/run_sync_service.dart';
import '../../run/presentation/cover_photo_sheet.dart';
import '../../run/presentation/run_detail_view.dart';
import '../data/records_providers.dart';
import 'record_badges.dart';

/// 기록 상세 — 기록 카드를 눌러 들어온다(기능정의서 3-1 · 4-3 섹션 E).
///
/// 달리기 종료 화면과 **같은 [RunDetailView]** 를 쓰고 닫기만 ← 로 바꾼다
/// (기능정의서 5 는 이 둘을 하나의 공유 컴포넌트로 정의한다).
///
/// 삭제·수치 수정 UI 는 두지 않는다 — records.md 4 가 "버튼/메뉴 자체를 UI 에
/// 두지 않음" 으로 못박은 정책이라, 비활성 버튼조차 만들지 않는다.
class RunDetailScreen extends ConsumerWidget {
  const RunDetailScreen({super.key, required this.runId});

  final String runId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(runsStreamProvider);
    // 판정 전(로딩)에는 붙이지 않는다 — 딱지가 깜빡이는 걸 피한다(기록 카드와 동일).
    final pending =
        ref.watch(pendingSyncRunIdsProvider).valueOrNull?.contains(runId) ??
            false;

    void close() {
      // 탭을 갈아탄 뒤 돌아온 경우처럼 스택이 비어 있을 수 있다.
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/records');
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: runsAsync.when(
          loading: () => _Missing(onClose: close, child: const _DetailSkeleton()),
          error: (_, _) => _Missing(
            onClose: close,
            // "찾을 수 없다"와 달리 에러는 다시 시도할 여지가 있다.
            child: InlineError(onRetry: () => ref.invalidate(runsStreamProvider)),
          ),
          data: (runs) {
            final run = _findById(runs, runId);
            // 기록은 삭제되지 않지만(records.md 4), 링크로 직접 들어오는 등
            // 없는 id 가 올 수 있다. 빈 화면 대신 돌아갈 길을 준다.
            if (run == null) {
              // 재시도 버튼을 달지 않는다 — 다시 읽어도 없는 id 는 없다.
              return _Missing(
                onClose: close,
                child: const InlineError(message: '기록을 찾을 수 없어요'),
              );
            }
            return RunDetailView(
              dateLabel: '${run.year}.${run.date}',
              // 사진 모드는 등록된 사진이 있을 때만(`run-flow.md` 6).
              photoPath: run.coverImageType == CoverImageType.photo
                  ? run.coverImageUrl
                  : null,
              // 저장하면 runsStreamProvider 가 알아서 새로 그린다.
              onPickPhoto: () => changeCoverImage(context, ref, run),
              route: run.route,
              durStr: run.dur,
              distanceStr: run.km.toStringAsFixed(2),
              paceStr: run.pace,
              kcal: run.displayKcal,
              onClose: close,
              headerTrailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RecordTypeBadge(run.type),
                  // 목록에서 접혀 있던 이유를 상세에서도 알 수 있게(카드와 같은 순서).
                  // 달리기 종료 화면은 headerTrailing 을 주지 않아 여기만 붙는다 —
                  // 방금 자기가 끝낸 러닝에 '미완료' 를 바로 띄우는 건 과하다.
                  if (run.isIncomplete) ...[
                    const SizedBox(width: 6),
                    const IncompleteRunChip(),
                  ],
                  if (pending) ...[
                    const SizedBox(width: 6),
                    const PendingSyncChip(),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Run? _findById(List<Run> runs, String id) {
    for (final r in runs) {
      if (r.id == id) return r;
    }
    return null;
  }
}

/// 상세를 못 그리는 동안에도 **돌아갈 길(<-)은 항상 남긴다.** 로딩·에러·없는
/// id 세 경우가 이 껍데기를 공유한다.
class _Missing extends StatelessWidget {
  const _Missing({required this.onClose, required this.child});

  final VoidCallback onClose;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.arrow_back, color: AppColors.foreground),
            tooltip: '기록 목록으로',
          ),
        ),
        Expanded(child: Center(child: child)),
      ],
    );
  }
}

/// 상세 화면 로딩 뼈대 — 대표 이미지 · 수치 줄 · 구간 목록 순서를 따른다.
class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: const [
        SkeletonCard(height: 200),
        SizedBox(height: 16),
        SkeletonCard(height: 88),
        SizedBox(height: 12),
        SkeletonCard(height: 120),
      ],
    );
  }
}
