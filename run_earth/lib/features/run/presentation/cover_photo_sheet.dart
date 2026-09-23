import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../data/cover_photo.dart';

/// 대표 이미지 등록 바텀시트 — "카메라로 촬영" / "갤러리에서 선택".
///
/// 정본: `camera-permission.md` 3. 두 옵션만 두고, 권한을 여기서 미리 묻지
/// 않는다 — 촬영을 고른 뒤에 OS 다이얼로그가 뜨는 순서다.
///
/// 고른 값을 돌려주고 닫는다. 그냥 닫으면 null.
Future<CoverPhotoSource?> showCoverPhotoSheet(BuildContext context) {
  return showModalBottomSheet<CoverPhotoSource>(
    context: context,
    // 탭 셸의 Navigator 를 쓰면 시트 아래쪽이 **탭 바에 가린다.**
    // 루트로 올려야 시트가 탭 바 위를 덮는다.
    useRootNavigator: true,
    backgroundColor: AppColors.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          // 끌어내리는 손잡이 — 시트라는 걸 알리는 최소 장치.
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(0x26),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 14),
          _SheetOption(
            icon: Icons.photo_camera_outlined,
            label: '카메라로 촬영',
            onTap: () => Navigator.pop(context, CoverPhotoSource.camera),
          ),
          _SheetOption(
            icon: Icons.photo_library_outlined,
            label: '갤러리에서 선택',
            onTap: () => Navigator.pop(context, CoverPhotoSource.gallery),
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 14),
            Text(label,
                style: AppTextStyles.sans(
                    fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
