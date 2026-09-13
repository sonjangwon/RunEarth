import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 네트워크 연결 감지. 정본: offline-handling.md 3(전역 네트워크 상태 배너).
///
/// ⚠️ 한계: `connectivity_plus` 는 "네트워크 인터페이스에 붙어 있는가"만 알려주고
/// "인터넷이 실제로 도달하는가"는 모른다. 와이파이는 잡혔지만 공유기가 끊긴
/// 상태면 온라인으로 보고한다. 진짜 도달성 확인은 실제 요청을 보내야 해서
/// (배터리·트래픽 비용) 이번 범위에서는 두지 않는다.
///
/// 업로드는 이 한계의 영향을 받지 않는다 — 재연결 신호는 "지금 한번 올려봐" 라는
/// 힌트일 뿐이고, 실패하면 RunSyncService 의 재시도 타이머가 그대로 받아준다.

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());

/// 온라인 여부 스트림. 최초 1회 현재 상태를 내보낸 뒤 변화를 따라간다.
final isOnlineProvider = StreamProvider<bool>((ref) async* {
  final connectivity = ref.watch(connectivityProvider);
  yield _isOnline(await connectivity.checkConnectivity());
  yield* connectivity.onConnectivityChanged.map(_isOnline);
});

/// 화면에서 쓰기 좋은 동기 값.
///
/// 아직 판정 전(로딩)이거나 감지에 실패하면 **온라인으로 본다** — 앱을 켜는
/// 순간 오프라인 배너가 잠깐 번쩍이는 것이 더 나쁘기 때문.
final isOnlineValueProvider = Provider<bool>((ref) {
  return ref.watch(isOnlineProvider).valueOrNull ?? true;
});

/// `none` 만 있거나 아무 인터페이스도 없으면 오프라인.
bool _isOnline(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);
