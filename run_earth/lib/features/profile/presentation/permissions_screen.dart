import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import 'settings_page.dart';

/// 알림 및 위치 권한 — 두 권한의 현재 상태를 보여주고, 꺼져 있으면
/// 시스템 설정으로 보낸다 (profile-settings.md 3 "알림 및 위치 권한 화면").
///
/// **여기서 권한을 요청하지 않는다.** 위치 권한은 START 에서 묻는 것으로
/// 정해져 있고(`run-flow.md` 6, 2026-09-25 전수 감사에서 재확인), 설정 화면을
/// 구경하는 것만으로 팝업이 뜨면 그 정책과 어긋난다. 이 화면은 상태 표시와
/// 설정 앱으로 보내는 것까지만 한다.
class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen>
    with WidgetsBindingObserver {
  bool? _notification;
  bool? _location;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 설정 앱에서 권한을 켜고 돌아오면 다시 읽는다. 이게 없으면 방금 켠
    // 권한이 계속 '꺼짐'으로 보인다 — 이 화면의 존재 이유가 사라진다.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    // 알림은 OS 상태를 그대로 묻는다. `run_tracker` 는 안드로이드 외를 항상
    // granted 로 보는데, 그건 포그라운드 서비스가 뜨느냐는 판단이라 성격이
    // 다르다. 여기는 사용자에게 "지금 켜져 있나"를 보여주는 자리다.
    final notification = await Permission.notification.isGranted;
    final permission = await Geolocator.checkPermission();
    final location = permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
    if (!mounted) return;
    setState(() {
      _notification = notification;
      _location = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SettingsPage(
      title: '알림 및 위치 권한',
      children: [
        SettingsCard(children: [
          _PermissionTile(label: '알림 권한', granted: _notification),
          _PermissionTile(label: '위치 권한', granted: _location),
        ]),
        const SizedBox(height: 12),
        Text(
          '권한은 시스템 설정에서만 바꿀 수 있어요.',
          style:
              AppTextStyles.sans(fontSize: 12, color: AppColors.mutedForeground),
        ),
      ],
    );
  }
}

/// 권한 한 줄. [granted] 가 null 이면 아직 읽는 중이다.
class _PermissionTile extends StatelessWidget {
  const _PermissionTile({required this.label, required this.granted});

  final String label;
  final bool? granted;

  @override
  Widget build(BuildContext context) {
    if (granted == null) {
      return SettingsTile(label: label, value: '확인 중…');
    }
    if (granted!) {
      return SettingsTile(
        label: label,
        valueWidget: Text('켜짐',
            style: AppTextStyles.sans(fontSize: 14, color: AppColors.primary)),
      );
    }
    return SettingsTile(
      label: label,
      valueWidget: Row(
        children: [
          Text('꺼짐',
              style: AppTextStyles.sans(
                  fontSize: 14, color: AppColors.mutedForeground)),
          const SizedBox(width: 10),
          TextButton(
            onPressed: openAppSettings,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text('설정에서 켜기',
                style: AppTextStyles.sans(
                    fontSize: 13, color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}
