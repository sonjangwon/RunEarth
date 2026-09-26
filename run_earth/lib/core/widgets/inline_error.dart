import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// 인라인 에러 + "다시 시도" (global-states.md 3 "에러 상태").
///
/// 문서가 정한 것: 중립 아이콘 + "불러오지 못했어요" + "다시 시도" 버튼, 그리고
/// **화면 전체를 덮지 않고 실패한 영역만** 표시한다. 그래서 이 위젯은 Scaffold
/// 를 만들지 않고 자기 자리만 채운다.
///
/// [onRetry] 가 null 이면 버튼을 그리지 않는다. 재호출할 요청이 없는데 버튼만
/// 두면 눌러도 아무 일도 안 하는 버튼이 된다 — 출발 전 화면의 미세먼지가
/// 그런 경우다(`run_screen.dart` `_DustUnavailable`, 에어코리아 연동 대기).
///
/// **문구는 원인별로 나누지 않는다.** `global-states.md` 7 이 네트워크 에러와
/// 서버 에러(4xx/5xx)를 구분할지 [미확정]으로 남겼는데, 지금 이 앱의 조회는
/// 로컬 DB(drift) 한 곳뿐이라 **구분할 대상 자체가 없다.** 서버에서 직접
/// 읽어오는 화면이 생길 때 정한다.
class InlineError extends StatelessWidget {
  const InlineError({
    super.key,
    this.message = '불러오지 못했어요',
    this.onRetry,
    this.compact = false,
  });

  final String message;
  final VoidCallback? onRetry;

  /// 카드 안처럼 좁은 자리에 넣을 때. 아이콘과 글자를 한 줄로 줄인다.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 14, color: AppColors.mutedForeground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(message,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sans(
                    fontSize: 12, color: AppColors.mutedForeground)),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 6),
            _RetryButton(onRetry: onRetry!, fontSize: 12),
          ],
        ],
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline,
              size: 28, color: AppColors.mutedForeground),
          const SizedBox(height: 10),
          Text(message,
              style: AppTextStyles.sans(
                  fontSize: 14, color: AppColors.mutedForeground)),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            _RetryButton(onRetry: onRetry!, fontSize: 14),
          ],
        ],
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  const _RetryButton({required this.onRetry, required this.fontSize});

  final VoidCallback onRetry;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onRetry,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text('다시 시도',
          style: AppTextStyles.sans(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: AppColors.primary)),
    );
  }
}
