import 'package:flutter/material.dart';

import '../../../core/models/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// 러닝 타입 뱃지(일반/테마/온라인). 색은 기능정의서 7 디자인 토큰.
///
/// 기록 카드와 기록 상세가 함께 쓴다.
class RecordTypeBadge extends StatelessWidget {
  const RecordTypeBadge(this.type, {super.key});

  final RecordType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      RecordType.normal => ('일반', AppColors.typeNormal),
      RecordType.theme => ('테마', AppColors.typeTheme),
      RecordType.online => ('온라인', AppColors.typeOnline),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.badgeBackground(color),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(0x40)),
      ),
      child: Text(label,
          style: AppTextStyles.sans(
              fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

/// '동기화 대기' 딱지 — 로컬에만 있고 아직 서버에 올라가지 않은 기록.
///
/// 정본: offline-handling.md 2 케이스 B. 문서가 지정한 자리는 결과 화면
/// (RunDetailView)인데 그 화면이 없어 2026-09-13 에 기록 카드에 먼저 붙였고,
/// 상세 화면이 생긴 2026-09-19 부터는 양쪽에서 쓴다.
/// 성취 배지가 아니라 일시적 상태라 records.md 3 의 '미인정' 과 같은 무채색.
class PendingSyncChip extends StatelessWidget {
  const PendingSyncChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text('동기화 대기',
          style: AppTextStyles.sans(
              fontSize: 11, color: AppColors.mutedForeground)),
    );
  }
}

/// '미완료' 칩 — 거리 0 · 1분 미만 기록(0km 정책, 2026-09-20).
///
/// 목록에서 기본으로 접히지만, 펼쳐 봤을 때 **왜 접혀 있었는지** 알 수 있어야
/// 한다. 성취가 아니라 상태이므로 `PendingSyncChip` 과 같은 무채색.
class IncompleteRunChip extends StatelessWidget {
  const IncompleteRunChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Text('미완료',
          style: AppTextStyles.sans(
              fontSize: 11, color: AppColors.mutedForeground)),
    );
  }
}
