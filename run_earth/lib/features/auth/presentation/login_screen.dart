import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/auth_providers.dart';

/// 로그인 화면 (auth-onboarding.md §3).
///
/// MVP 는 구글 로그인만 배선한다(카카오·네이버는 이후). 로그인 성공 시
/// 라우터 세션 가드가 홈으로 전환한다(refreshListenable).
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
      // 성공 → onAuthStateChange 로 라우터가 홈으로 리다이렉트.
    } on GoogleSignInException catch (e) {
      // 사용자가 직접 취소한 경우는 조용히 무시(에러 토스트 생략).
      if (e.code != GoogleSignInExceptionCode.canceled) {
        _showError('로그인에 실패했어요. 다시 시도해주세요');
      }
    } catch (_) {
      _showError('네트워크 연결을 확인해주세요');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 3),
              Text('RUN EARTH',
                  style: AppTextStyles.display(
                      fontSize: 34,
                      letterSpacing: 2,
                      color: AppColors.primary)),
              const SizedBox(height: 8),
              Text('달린 만큼, 지구 한 바퀴',
                  style: AppTextStyles.sans(
                      fontSize: 12, color: AppColors.mutedForeground)),
              const Spacer(flex: 4),
              _GoogleButton(loading: _loading, onTap: _signInWithGoogle),
              const SizedBox(height: 16),
              Text('로그인하면 서비스 이용약관에 동의하게 됩니다.',
                  style: AppTextStyles.sans(
                      fontSize: 10, color: AppColors.mutedForeground)),
              const Spacer(flex: 1),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.loading, required this.onTap});
  final bool loading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: loading ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.black54),
                  )
                else ...[
                  const Icon(Icons.g_mobiledata, size: 24, color: Colors.black87),
                  const SizedBox(width: 8),
                  Text('Google로 계속하기',
                      style: AppTextStyles.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
