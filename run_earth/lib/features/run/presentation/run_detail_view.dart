import 'package:flutter/material.dart';

import '../../../core/models/geo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'route_painter.dart';

/// 닫기 버튼 모양. 기능정의서 5 `RunDetailView.closeIcon`.
enum RunDetailClose {
  /// 막 끝낸 러닝(달리기 탭) — 닫으면 prerun 으로 초기화.
  x,

  /// 기록 탭에서 들어온 상세 — 닫으면 목록으로 복귀.
  back,
}

/// 러닝 결과 / 기록 상세 공용 화면 (기능정의서 5 `RunDetailView`).
///
/// 두 화면은 **같은 컴포넌트**다. 달라지는 건 닫기 버튼과 아래에 덧붙는
/// 내용뿐이라 [closeIcon] 과 [footer] 로 갈린다.
///
/// 대표 이미지는 저장된 PNG 를 읽지 않고 **[route] 좌표로 직접 그린다.**
/// 좌표만 있으면 어디서든 다시 그릴 수 있고(2026-09-11 결정), 렌더가 실패했거나
/// 파일이 사라진 기록도 정상적으로 보인다.
class RunDetailView extends StatelessWidget {
  const RunDetailView({
    super.key,
    required this.title,
    required this.route,
    required this.durStr,
    required this.distanceStr,
    required this.paceStr,
    required this.kcal,
    required this.onClose,
    this.closeIcon = RunDetailClose.back,
    this.headerTrailing,
    this.footer,
  });

  final String title;
  final List<LatLngPoint> route;
  final String durStr;
  final String distanceStr;
  final String paceStr;
  final int kcal;
  final VoidCallback onClose;
  final RunDetailClose closeIcon;

  /// 상단 줄 오른쪽에 붙는 것(러닝 타입·동기화 대기 뱃지 등).
  final Widget? headerTrailing;

  /// 수치 카드 아래에 붙는 것(완료 버튼·안내 문구 등).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final isBack = closeIcon == RunDetailClose.back;
    final closeButton = IconButton(
      onPressed: onClose,
      icon: Icon(isBack ? Icons.arrow_back : Icons.close,
          color: AppColors.foreground),
      // 기록 목록/달리기 화면으로 돌아가는 유일한 수단이라 이름을 붙여둔다.
      tooltip: isBack ? '기록 목록으로' : '닫기',
    );

    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                // ← 는 왼쪽, ✕ 는 오른쪽. 플랫폼 관례대로.
                if (isBack) closeButton else const Spacer(),
                if (headerTrailing != null) ...[
                  const Spacer(),
                  headerTrailing!,
                ],
                if (!isBack) closeButton,
              ],
            ),
            const SizedBox(height: 8),
            Text(title, style: AppTextStyles.display(fontSize: 26)),
            const SizedBox(height: 16),
            // 대표 이미지 = 경로 이미지 (사진 미등록 시 기본값. run-flow.md 4)
            AspectRatio(
              aspectRatio: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: route.length >= 2
                    ? CustomPaint(painter: RoutePainter(route: route))
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
                  _row('시간', durStr),
                  _row('거리', '$distanceStr km'),
                  _row('페이스', '$paceStr /km'),
                  _row('칼로리', kcal > 0 ? '$kcal kcal' : '-- kcal'),
                ],
              ),
            ),
            // 기록 수치는 읽기 전용이다. 수정·삭제 UI 는 두지 않는다
            // (records.md 4 — 버튼 자체를 만들지 않는 것이 정책).
            if (footer != null) ...[const SizedBox(height: 20), footer!],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
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
