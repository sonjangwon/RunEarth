import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/connectivity/connectivity_providers.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/data/user_repository.dart';
import 'settings_page.dart';

/// 닉네임 검증 (profile-settings.md 3 · 2026-09-26 확정).
///
/// 규칙: 앞뒤 공백을 떼고 **2~12자**, 중간 공백 금지. 그 밖의 문자는 막지
/// 않는다 — 한글·영문·숫자·이모지 모두 허용.
///
/// 부적절 단어 필터링은 **하지 않기로 했다**(2026-09-26). 금칙어 목록을 직접
/// 관리해야 하는데 닉네임이 아직 남에게 보이지 않는다(랭킹은 MVP 이후).
///
/// 길이는 `runes` 로 센다 — `length`(UTF-16 코드 단위)로 세면 이모지 하나가
/// 2자로 잡힌다. 새 패키지(`characters`)를 들이지 않는 선에서 이게 가장 가깝다.
///
/// 통과하면 null, 아니면 사용자에게 보일 문구를 준다.
String? validateNickname(String raw) {
  final name = raw.trim();
  if (name.isEmpty) return '닉네임을 입력해주세요';
  if (name.contains(RegExp(r'\s'))) return '중간에 띄어쓰기는 넣을 수 없어요';
  final length = name.runes.length;
  if (length < 2) return '2자 이상 입력해주세요';
  if (length > 12) return '12자까지 쓸 수 있어요';
  return null;
}

/// 닉네임 변경 (profile-settings.md 3 "닉네임 변경 화면").
class NicknameEditScreen extends ConsumerStatefulWidget {
  const NicknameEditScreen({super.key});

  @override
  ConsumerState<NicknameEditScreen> createState() => _NicknameEditScreenState();
}

class _NicknameEditScreenState extends ConsumerState<NicknameEditScreen> {
  late final TextEditingController _controller;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final current = ref.read(currentAppUserProvider).valueOrNull?.name ??
        sessionDisplayName();
    _controller = TextEditingController(text: current);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    final error = validateNickname(name);
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    try {
      await ref.read(userRepositoryProvider).updateName(name);
      // 홈·프로필·계정 정보가 모두 이 provider 를 보고 있어서, 여기서 한 번
      // 무효화하면 전역에 반영된다(완료 조건 "앱 전역에 즉시 반영된다").
      ref.invalidate(currentAppUserProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('닉네임이 변경됐어요')));
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/profile');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = '저장하지 못했어요. 잠시 후 다시 시도해주세요';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 이름은 서버 한 곳에만 살아서 오프라인에 저장할 데가 없다
    // (offline-handling.md 2 케이스 D).
    final online = ref.watch(isOnlineValueProvider);
    final canSave = online && !_saving;

    return SettingsPage(
      title: '닉네임 변경',
      children: [
        TextField(
          controller: _controller,
          maxLength: 20,
          style: AppTextStyles.sans(fontSize: 15),
          cursorColor: AppColors.primary,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.card,
            counterText: '',
            errorText: _error,
            hintText: '2~12자',
            hintStyle: AppTextStyles.sans(
                fontSize: 15, color: AppColors.mutedForeground),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => canSave ? _save() : null,
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 48,
          child: FilledButton(
            onPressed: canSave ? _save : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.muted,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.background),
                  )
                : Text('저장',
                    style: AppTextStyles.sans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: online
                            ? AppColors.background
                            : AppColors.mutedForeground)),
          ),
        ),
        if (!online) ...[
          const SizedBox(height: 10),
          Text('네트워크 연결 후 다시 시도해주세요',
              style: AppTextStyles.sans(
                  fontSize: 12, color: AppColors.mutedForeground)),
        ],
      ],
    );
  }
}
