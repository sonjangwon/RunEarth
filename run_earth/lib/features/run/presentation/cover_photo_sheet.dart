import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/run.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../services/storage/cover_storage.dart';
import '../../../services/sync/run_sync_service.dart';
import '../data/cover_photo.dart';

/// 대표 이미지 바텀시트에서 고를 수 있는 것.
enum _CoverChoice { camera, gallery, toRoute, toPhoto }

/// 대표 이미지를 바꾼다 — 시트를 띄우고, 고른 대로 [run] 을 갱신해 저장한다.
///
/// 정본 둘을 합친 것이다. `camera-permission.md` 3 이 등록 시트(촬영/갤러리)를,
/// `run-flow.md` 47-48 이 변경 시트(사진/경로 이미지)를 정의한다. camera 문서가
/// "기존 '사진으로 변경' 자리에 촬영 옵션을 더한다" 는 취지라 한 시트에 모았다.
///
/// 아무것도 안 바뀌면(취소·권한 거부) 조용히 돌아온다 —
/// `camera-permission.md` 4 가 "차단 팝업 없이 갤러리로 우회 가능" 으로 정했다.
///
/// 바뀐 기록을 돌려준다(달리기 결과 화면처럼 DB 를 구독하지 않는 화면에서 쓴다).
/// 기록 탭은 스트림이 알아서 새로 그리므로 반환값을 안 써도 된다.
Future<Run?> changeCoverImage(
  BuildContext context,
  WidgetRef ref,
  Run run,
) async {
  // 경로로 되돌려도 사진 경로는 지우지 않아서, 사진이 있었는지 알 수 있다.
  final hasPhoto = isCoverPhoto(run.coverImageUrl);
  final choice = await _showSheet(
    context,
    showingPhoto: run.coverImageType == CoverImageType.photo,
    hasStoredPhoto: hasPhoto,
  );
  if (choice == null) return null;

  Run? next;
  switch (choice) {
    case _CoverChoice.camera:
    case _CoverChoice.gallery:
      final path = await pickCoverPhoto(
        choice == _CoverChoice.camera
            ? CoverPhotoSource.camera
            : CoverPhotoSource.gallery,
        id: run.id,
      );
      if (path == null) return null;
      next = run.copyWith(
        coverImageType: CoverImageType.photo,
        coverImageUrl: path,
      );
    case _CoverChoice.toRoute:
      // 경로 이미지는 좌표로 그린다(2026-09-11 결정). 파일을 만들 필요가
      // 없어 **타입만 바꾸고 사진 경로는 남긴다** — 그래야 되돌릴 수 있다.
      next = run.copyWith(coverImageType: CoverImageType.route);
    case _CoverChoice.toPhoto:
      next = run.copyWith(coverImageType: CoverImageType.photo);
  }

  final db = ref.read(appDatabaseProvider);
  await db.upsertRun(next);

  // 이미 서버에 올라간 기록을 고친 것이면 **다시 업로드 대기로 돌린다.**
  // `toCompanion()` 은 `syncedAt` 을 건드리지 않아(그래야 업로드 성공 표시가
  // 살아 있다) 대표 이미지만 바꿔서는 재업로드를 타지 않았다 — 서버의
  // `cover_image_type`·`cover_image_url` 이 옛 값으로 남았다(2026-09-23 실측).
  await db.markUnsynced(next.id);

  // 사용자가 방금 누른 변경이라 바로 올린다. 결과는 기다리지 않는다 —
  // 오프라인이면 큐에 남고 재연결 때 올라간다(offline-handling.md 2 케이스 D).
  unawaited(ref.read(runSyncServiceProvider).syncNow());

  return next;
}

Future<_CoverChoice?> _showSheet(
  BuildContext context, {
  required bool showingPhoto,
  required bool hasStoredPhoto,
}) {
  return showModalBottomSheet<_CoverChoice>(
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
            onTap: () => Navigator.pop(context, _CoverChoice.camera),
          ),
          _SheetOption(
            icon: Icons.photo_library_outlined,
            label: '갤러리에서 선택',
            onTap: () => Navigator.pop(context, _CoverChoice.gallery),
          ),
          // 지금 보고 있는 모드로는 못 바꾼다 — 한 쪽만 뜬다.
          if (showingPhoto)
            _SheetOption(
              icon: Icons.timeline,
              label: '경로 이미지로 변경',
              onTap: () => Navigator.pop(context, _CoverChoice.toRoute),
            )
          else if (hasStoredPhoto)
            _SheetOption(
              icon: Icons.image_outlined,
              label: '등록한 사진으로 되돌리기',
              onTap: () => Navigator.pop(context, _CoverChoice.toPhoto),
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
