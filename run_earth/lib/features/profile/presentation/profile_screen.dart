import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_badge.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/data/user_repository.dart';
import '../../home/data/home_providers.dart';
import '../data/profile_sample_data.dart';

/// 프로필 탭 — 유저·통계·배지 컬렉션·설정.
/// 정본: profile-settings.md, badges.md, 기능정의서 4-5.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: const [
            _UserCard(),
            SizedBox(height: 16),
            _StatsRow(),
            SizedBox(height: 16),
            _BadgeCollection(),
            SizedBox(height: 16),
            _SettingsSection(),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends ConsumerWidget {
  const _UserCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAppUserProvider).valueOrNull;
    final name = user?.name ?? sessionDisplayName();
    final avatarUrl = user?.avatar ?? '';
    return Row(
      children: [
        Container(
          width: 56,
          height: 56,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.muted,
            border: Border.all(color: AppColors.border),
          ),
          child: avatarUrl.isEmpty
              ? const Text(profileAvatar, style: TextStyle(fontSize: 26))
              : Image.network(
                  avatarUrl,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                  // 소셜 프로필 URL 은 만료될 수 있다 → 이모지로 조용히 폴백.
                  errorBuilder: (_, _, _) =>
                      const Text(profileAvatar, style: TextStyle(fontSize: 26)),
                ),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: AppTextStyles.display(fontSize: 24)),
            Text('Run Earth',
                style: AppTextStyles.mono(
                    fontSize: 11, color: AppColors.mutedForeground)),
          ],
        ),
      ],
    );
  }
}

class _StatsRow extends ConsumerWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 홈과 같은 집계를 구독한다 — 두 화면의 숫자가 어긋나지 않게.
    final stats = ref.watch(homeStatsProvider);
    return Row(
      children: [
        Expanded(child: _stat('총 거리', stats.totalKm.toStringAsFixed(1), 'km')),
        const SizedBox(width: 8),
        Expanded(child: _stat('총 시간', stats.durationLabel, '')),
        const SizedBox(width: 8),
        Expanded(child: _stat('총 횟수', '${stats.count}', '회')),
      ],
    );
  }

  Widget _stat(String label, String value, String unit) => Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
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
        ),
      );
}

class _BadgeCollection extends StatelessWidget {
  const _BadgeCollection();

  @override
  Widget build(BuildContext context) {
    final earned = sampleBadges.where((b) => b.earned).length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('배지 컬렉션',
                  style: AppTextStyles.sans(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              Text('$earned / ${sampleBadges.length} 획득',
                  style: AppTextStyles.mono(
                      fontSize: 11, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [for (final b in sampleBadges) _BadgeTile(b)],
          ),
        ],
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile(this.badge);
  final AppBadge badge;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: badge.earned ? 1 : 0.4,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.muted,
          border: Border.all(color: AppColors.border),
        ),
        child: badge.earned
            ? Text(badge.emoji, style: const TextStyle(fontSize: 20))
            : const Icon(Icons.lock,
                size: 16, color: AppColors.mutedForeground),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _group(const ['계정 정보', '닉네임 변경', '기기 연동', '알림 및 위치 권한']),
        const SizedBox(height: 12),
        _group(const ['이용 약관 및 방침', '자주 묻는 질문']),
        const SizedBox(height: 12),
        _group(const ['로그아웃']),
        const SizedBox(height: 20),
        Text('회원탈퇴',
            style: AppTextStyles.sans(
                fontSize: 12, color: AppColors.mutedForeground)),
        const SizedBox(height: 12),
        Text(appVersion,
            style: AppTextStyles.mono(
                fontSize: 10, color: AppColors.mutedForeground)),
      ],
    );
  }

  Widget _group(List<String> items) => Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                const Divider(height: 1, color: AppColors.border),
              _SettingsRow(items[i]),
            ],
          ],
        ),
      );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {}, // 프로토타입: 탭 인터랙션만
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.sans(fontSize: 14)),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
