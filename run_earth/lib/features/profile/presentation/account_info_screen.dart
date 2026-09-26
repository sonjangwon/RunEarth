import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/enums.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_providers.dart';
import 'settings_page.dart';

/// 계정 정보 — 로그인 방식 · 가입일 · 닉네임 변경 진입점
/// (profile-settings.md 3 "계정 정보 화면").
class AccountInfoScreen extends ConsumerWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentAppUserProvider).valueOrNull;

    return SettingsPage(
      title: '계정 정보',
      children: [
        SettingsCard(children: [
          SettingsTile(
            label: '로그인 방식',
            valueWidget: _ProviderLabel(provider: user?.provider),
          ),
          SettingsTile(label: '가입일', value: formatJoinedAt(user?.createdAt)),
        ]),
        const SizedBox(height: 12),
        SettingsCard(children: [
          SettingsTile(
            label: '닉네임 변경',
            value: user?.name,
            onTap: () => context.push('/profile/nickname'),
          ),
        ]),
      ],
    );
  }
}

class _ProviderLabel extends StatelessWidget {
  const _ProviderLabel({required this.provider});

  final AuthProvider? provider;

  @override
  Widget build(BuildContext context) {
    if (provider == null) {
      return Text('—',
          style: AppTextStyles.sans(
              fontSize: 14, color: AppColors.mutedForeground));
    }
    final (icon, name) = switch (provider!) {
      // 브랜드 로고 에셋이 아직 없어 로그인 화면과 같은 대체 아이콘을 쓴다
      // (login_screen 의 `Icons.g_mobiledata`). 에셋이 들어오면 함께 교체.
      AuthProvider.google => (Icons.g_mobiledata, '구글'),
      AuthProvider.kakao => (Icons.chat_bubble, '카카오'),
      AuthProvider.naver => (Icons.circle, '네이버'),
    };
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.mutedForeground),
        const SizedBox(width: 6),
        Text('$name로 로그인함',
            style: AppTextStyles.sans(
                fontSize: 14, color: AppColors.mutedForeground)),
      ],
    );
  }
}

/// 가입일 표시. 서버가 주는 ISO8601 문자열을 기기 시간대로 바꿔
/// `2026.08.30` 으로 적는다 — 기록 화면의 `year.date` 와 같은 표기.
///
/// `intl` 의 `DateFormat` 을 쓰지 않는 이유: 한국어 로케일 초기화가 필요한데
/// 이 화면 하나 때문에 부팅 경로를 건드릴 이유가 없다.
String formatJoinedAt(String? raw) {
  if (raw == null || raw.isEmpty) return '—';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return '—';
  final d = parsed.toLocal();
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year}.$mm.$dd';
}
