import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// 로딩 중 콘텐츠 자리를 채우는 회색 뼈대 (global-states.md 3 "로딩 상태").
///
/// 문서가 정한 것: **카드/리스트 아이템 모양 그대로** 회색 뼈대로 표시하고,
/// 데이터가 도착하면 실제 콘텐츠로 바꾼다. 그래서 이 위젯은 크기를 스스로
/// 정하지 않고 쓰는 쪽이 실제 요소와 같은 치수를 준다 — 뼈대가 실물과 다른
/// 크기면 데이터가 도착하는 순간 화면이 튄다.
///
/// 색은 `muted`(#151923) 다. `card`(#0D1018) 와 배경 사이라 어두운 테마에서
/// "자리는 있는데 아직 비었다"로 읽힌다.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return _Pulse(
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.muted,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

/// 카드 한 장 크기의 뼈대. 테두리까지 실제 카드와 같게 그린다.
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, required this.height, this.radius = 12});

  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return _Pulse(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: AppColors.border),
        ),
      ),
    );
  }
}

/// 뼈대를 천천히 밝아졌다 어두워지게 한다.
///
/// shimmer(빛줄기가 지나가는) 대신 불투명도만 흔드는 이유: 패키지가 필요 없고,
/// 배경이 거의 검정이라 빛줄기가 과하게 도드라진다. 주기는 1.1초 — 더 빠르면
/// 로컬 DB 처럼 금방 끝나는 로딩에서 깜빡임으로 보인다.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.45, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}
