import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

/// 프로필 설정 하위 화면(계정 정보 · 닉네임 변경 · 알림/위치 권한)의 공용 껍데기.
///
/// 셋이 같은 제목줄·여백·뒤로가기를 쓴다. 기록 상세와 같은 이유로 shell 안쪽
/// 자식 라우트라 하단 탭바가 유지되고 ← 로 프로필에 돌아온다.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Row(
              children: [
                // 탭을 갈아탄 뒤 돌아온 경우처럼 스택이 비어 있을 수 있다
                // (run_detail_screen 과 같은 처리).
                IconButton(
                  onPressed: () => context.canPop()
                      ? context.pop()
                      : context.go('/profile'),
                  icon: const Icon(Icons.arrow_back,
                      size: 20, color: AppColors.foreground),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                Text(title, style: AppTextStyles.display(fontSize: 22)),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// 설정 하위 화면의 카드 한 장. 안에 [SettingsTile] 들을 넣는다.
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.border),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// 라벨 + 값 한 줄. [onTap] 이 있으면 오른쪽에 > 가 붙는다.
class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.onTap,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.sans(fontSize: 14)),
            Row(
              children: [
                if (valueWidget != null)
                  valueWidget!
                else if (value != null)
                  Text(value!,
                      style: AppTextStyles.sans(
                          fontSize: 14, color: AppColors.mutedForeground)),
                if (onTap != null) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.mutedForeground),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
