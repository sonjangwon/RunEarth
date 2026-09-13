import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/connectivity/connectivity_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// 오프라인일 때 화면 맨 위에 얇은 띠를 얹는다.
/// 정본: offline-handling.md 3 — "모든 화면 공통".
///
/// `MaterialApp.builder` 에서 전체를 감싸므로 shell(5탭) 밖의 스플래시·로그인
/// 화면에도 함께 적용된다. 로그인은 오히려 네트워크가 꼭 필요한 화면이다.
class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 온라인이면 아무것도 끼우지 않는다 — 평상시 레이아웃을 건드리지 않기 위해.
    if (ref.watch(isOnlineValueProvider)) return child;

    return Column(
      children: [
        _Bar(topInset: MediaQuery.paddingOf(context).top),
        // 배너가 상태바 영역까지 덮었으므로 아래 화면이 같은 여백을 또 넣지
        // 않게 한다(SafeArea 중복 방지).
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: child,
          ),
        ),
      ],
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.topInset});

  final double topInset;

  @override
  Widget build(BuildContext context) {
    // 에러가 아니라 상태 안내라 빨강(#EF4444)을 쓰지 않는다.
    return Material(
      color: AppColors.muted,
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: SizedBox(
          height: 26,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded,
                  size: 13, color: AppColors.accent),
              const SizedBox(width: 6),
              Text('오프라인 상태예요',
                  style:
                      AppTextStyles.sans(fontSize: 11, color: AppColors.accent)),
            ],
          ),
        ),
      ),
    );
  }
}
