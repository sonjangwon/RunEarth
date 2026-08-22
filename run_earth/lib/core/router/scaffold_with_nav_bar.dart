import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// 5탭 하단 네비게이션 바를 두른 shell.
///
/// 문서 근거: 기능정의서 2장(탭 구성). 가운데 '달리기' 탭은
/// 네온그린 원형 강조 버튼으로 렌더한다.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _items = <({IconData icon, String label})>[
    (icon: Icons.home_rounded, label: '홈'),
    (icon: Icons.play_arrow_rounded, label: '달리기'),
    (icon: Icons.bar_chart_rounded, label: '기록'),
    (icon: Icons.map_rounded, label: '콘텐츠'),
    (icon: Icons.person_rounded, label: '프로필'),
  ];

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 62,
            child: Row(
              children: [
                for (var i = 0; i < _items.length; i++)
                  Expanded(
                    child: _NavItem(
                      icon: _items[i].icon,
                      label: _items[i].label,
                      selected: navigationShell.currentIndex == i,
                      isRunTab: i == 1,
                      onTap: () => _goBranch(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isRunTab,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool isRunTab;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.primary : AppColors.mutedForeground;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isRunTab)
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(0x50),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  size: 22, color: Colors.black),
            )
          else
            Icon(icon, size: 22, color: color),
          const SizedBox(height: 2),
          Text(label,
              style: AppTextStyles.sans(fontSize: 9, color: color)),
        ],
      ),
    );
  }
}
