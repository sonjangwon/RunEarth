import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_badge.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/data/user_repository.dart';
import '../../home/data/home_providers.dart';
import '../data/badge_providers.dart';
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
          children: [
            // 다른 탭('내 기록'·'콘텐츠')엔 다 있는데 여기만 빠져 있었다.
            Text('프로필', style: AppTextStyles.display(fontSize: 24)),
            const SizedBox(height: 12),
            const _UserCard(),
            const SizedBox(height: 16),
            const _StatsRow(),
            const SizedBox(height: 16),
            const _BadgeCollection(),
            const SizedBox(height: 16),
            const _SettingsSection(),
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

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Stack(
        children: [
          // 오른쪽 위 모서리에서 번지는 옅은 네온(Figma).
          Positioned(
            top: -24,
            right: -24,
            child: IgnorePointer(
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withAlpha(0x14),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    // Figma 는 원이 아니라 사각 라운드다.
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.muted,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: avatarUrl.isEmpty
                      ? const Text(profileAvatar,
                          style: TextStyle(fontSize: 26))
                      : Image.network(
                          avatarUrl,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          // 소셜 프로필 URL 은 만료될 수 있다 → 이모지로 조용히 폴백.
                          errorBuilder: (_, _, _) => const Text(profileAvatar,
                              style: TextStyle(fontSize: 26)),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.display(fontSize: 22)),
                      const SizedBox(height: 2),
                      Text('Run Earth',
                          style: AppTextStyles.sans(
                              fontSize: 10,
                              color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

class _BadgeCollection extends ConsumerWidget {
  const _BadgeCollection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 누적 거리로 계산된 여정 마일스톤 배지(badges.md 3).
    //
    // Figma 는 배지를 세 분류(여정 마일스톤·테마 코스·온라인 마라톤)로 나눠
    // 보여주지만 **아직 나누지 않는다** — 발급되는 배지가 마일스톤뿐이라
    // 나누면 빈 그룹 둘이 그대로 노출된다. 테마·마라톤 배지 발급이
    // 붙을 때 함께 한다(2026-09-21 결정).
    final badges = ref.watch(milestoneBadgesProvider);
    final earned = badges.where((b) => b.earned).length;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium_outlined,
                      size: 14, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text('배지 컬렉션',
                      style: AppTextStyles.sans(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              Text('$earned / ${badges.length} 획득',
                  style: AppTextStyles.mono(
                      fontSize: 10, color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 8,
            // 타일 아래 이름이 한 줄 붙어 세로가 길어진다.
            childAspectRatio: 0.72,
            children: [for (final b in badges) _BadgeTile(b)],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                // Figma 는 원이 아니라 사각 라운드다.
                borderRadius: BorderRadius.circular(8),
                color: AppColors.muted,
                border: Border.all(color: AppColors.border),
              ),
              child: badge.earned
                  ? Text(badge.emoji, style: const TextStyle(fontSize: 18))
                  : const Icon(Icons.lock,
                      size: 14, color: AppColors.mutedForeground),
            ),
          ),
          const SizedBox(height: 3),
          // 어떤 배지인지 이름이 있어야 알 수 있다. 도시 이름이 길면 줄인다.
          Text(badge.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.sans(
                  fontSize: 7, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}

/// 설정 메뉴 한 줄. [onTap] 이 null 이면 아직 배선되지 않은 항목이다.
typedef _SettingsItem = ({String label, VoidCallback? onTap});

class _SettingsSection extends ConsumerWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _group(const [
          (label: '계정 정보', onTap: null),
          (label: '닉네임 변경', onTap: null),
          // 기기 연동은 웨어러블 동기화(MVP 이후)와 함께 붙인다.
          (label: '기기 연동', onTap: null),
          (label: '알림 및 위치 권한', onTap: null),
        ]),
        const SizedBox(height: 12),
        // 콘텐츠 자체가 범위 밖이라 라벨만 둔다(profile-settings.md 3).
        _group(const [
          (label: '이용 약관 및 방침', onTap: null),
          (label: '자주 묻는 질문', onTap: null),
        ]),
        const SizedBox(height: 12),
        _group([
          (label: '로그아웃', onTap: () => _confirmSignOut(context, ref)),
        ]),
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

  Widget _group(List<_SettingsItem> items) => Container(
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

/// 로그아웃 확인 → 세션 삭제(profile-settings.md 3).
///
/// 로그인 화면으로 보내는 코드는 여기에 없다 — 라우터 세션 가드가
/// `onAuthStateChange` 를 듣고 있어서 세션이 사라지면 알아서 `/login` 으로
/// 간다(app_router.dart). 여기서 또 `go()` 하면 둘이 경쟁한다.
Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.card,
      title: Text('로그아웃 하시겠어요?',
          style: AppTextStyles.sans(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.foreground)),
      content: Text(
        '이 기기에서만 로그아웃됩니다.\n'
        '기록은 그대로 남아 있어요.',
        style:
            AppTextStyles.sans(fontSize: 13, color: AppColors.mutedForeground),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text('취소',
              style: AppTextStyles.sans(color: AppColors.mutedForeground)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text('로그아웃',
              style: AppTextStyles.sans(color: AppColors.accent)),
        ),
      ],
    ),
  );
  if (ok != true) return;

  try {
    await ref.read(authServiceProvider).signOut();
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('로그아웃에 실패했어요: $e')));
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow(this.item);
  final _SettingsItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.label, style: AppTextStyles.sans(fontSize: 14)),
            const Icon(Icons.chevron_right,
                size: 18, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
