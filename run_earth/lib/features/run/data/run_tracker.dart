import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/db/app_database.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/geo.dart';
import '../../../core/models/run.dart';
import '../../../core/theme/app_colors.dart';

/// 러닝 세션 상태 머신 단계. (기능정의서 4-2-C + run-flow.md)
enum RunSessionPhase { prerun, countdown, running, paused, stopped }

/// 러닝 세션 실시간 상태(불변). GPS·시간·거리·경로를 담는다.
class RunSessionState {
  const RunSessionState({
    required this.phase,
    required this.runType,
    this.countdown = 3,
    this.elapsed = Duration.zero,
    this.distanceKm = 0,
    this.route = const [],
    this.current,
    this.error,
  });

  final RunSessionPhase phase;
  final RunType runType;
  final int countdown;
  final Duration elapsed;
  final double distanceKm;
  final List<LatLngPoint> route;
  final LatLngPoint? current;

  /// 권한 거부·위치 서비스 꺼짐 등 사용자에게 보여줄 오류 메시지.
  final String? error;

  factory RunSessionState.initial(RunType type) =>
      RunSessionState(phase: RunSessionPhase.prerun, runType: type);

  bool get isPaused => phase == RunSessionPhase.paused;

  /// "0.00" 형식 거리.
  String get distanceStr => distanceKm.toStringAsFixed(2);

  /// "5'12\"" 형식 페이스(1km당). 거리가 거의 없으면 플레이스홀더.
  String get paceStr {
    if (distanceKm < 0.01) return "--'--\"";
    final secPerKm = (elapsed.inSeconds / distanceKm).round();
    final m = secPerKm ~/ 60;
    final s = secPerKm % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  /// "MM:SS" 또는 "H:MM:SS" 형식 경과시간.
  String get elapsedStr {
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = elapsed.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '${h.toString().padLeft(2, '0')}:$m:$s' : '$m:$s';
  }

  /// 소모 칼로리(kcal). 정확한 계산엔 체중이 필요한데 현재 입력 수단이 없어
  /// 0(미표시)으로 둔다. 프로필에 체중 입력이 생기면 계산식 연결. [보류]
  int get kcal => 0;

  RunSessionState copyWith({
    RunSessionPhase? phase,
    int? countdown,
    Duration? elapsed,
    double? distanceKm,
    List<LatLngPoint>? route,
    LatLngPoint? current,
    Object? error = _noChange,
  }) {
    return RunSessionState(
      phase: phase ?? this.phase,
      runType: runType,
      countdown: countdown ?? this.countdown,
      elapsed: elapsed ?? this.elapsed,
      distanceKm: distanceKm ?? this.distanceKm,
      route: route ?? this.route,
      current: current ?? this.current,
      error: identical(error, _noChange) ? this.error : error as String?,
    );
  }

  static const _noChange = Object();
}

/// GPS 추적 + 상태 머신 구동.
///
/// 화면을 꺼도 추적이 이어지도록 포그라운드 서비스로 실행하고(run-flow.md 6),
/// 그래도 앱이 죽는 경우에 대비해 진행 중 러닝을 10초마다 로컬에 스냅샷한다.
class RunTracker extends Notifier<RunSessionState> {
  Timer? _elapsedTimer;
  Timer? _countdownTimer;
  Timer? _snapshotTimer;
  StreamSubscription<Position>? _posSub;

  /// 현재 러닝 시작 시각. 스냅샷 저장·복원의 기준.
  DateTime? _startedAt;

  /// 진행 중 러닝 스냅샷 주기. 앱이 죽어도 이 간격만큼만 잃는다(약 30m).
  static const _snapshotInterval = Duration(seconds: 10);

  /// 이보다 오래된 스냅샷은 이어 뛰지 않고 기록으로 확정한다.
  /// 풀코스 완주자도 넉넉히 커버하는 값(2026-09-15 결정).
  static const _snapshotMaxAge = Duration(hours: 6);

  /// RESUME 직후 첫 좌표는 일시정지 중 이동분을 거리에 더하지 않도록 앵커로만 쓴다.
  bool _skipNextSegment = false;

  @override
  RunSessionState build() {
    ref.onDispose(_disposeAll);
    return RunSessionState.initial(RunType.normal);
  }

  /// START → 권한 확인 후 카운트다운 시작.
  Future<void> start() async {
    final permitted = await _ensurePermission();
    if (!permitted) return; // 오류 메시지는 _ensurePermission 에서 세팅

    _countdownTimer?.cancel();
    state = state.copyWith(
      phase: RunSessionPhase.countdown,
      countdown: 3,
      error: null,
    );
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.countdown <= 1) {
        t.cancel();
        _beginRun();
      } else {
        state = state.copyWith(countdown: state.countdown - 1);
      }
    });
  }

  void _beginRun() {
    state = state.copyWith(
      phase: RunSessionPhase.running,
      elapsed: Duration.zero,
      distanceKm: 0,
      route: const [],
    );
    _startedAt = DateTime.now();
    _startElapsedTimer();
    _startLocationStream();
    _startSnapshotTimer();
  }

  void _startElapsedTimer() {
    _elapsedTimer?.cancel();
    _elapsedTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.phase == RunSessionPhase.running) {
        state = state.copyWith(elapsed: state.elapsed + const Duration(seconds: 1));
      }
    });
  }

  void _startLocationStream() {
    _posSub?.cancel();
    _posSub = Geolocator.getPositionStream(locationSettings: _locationSettings())
        .listen(_onPosition);
  }

  /// 플랫폼별 추적 설정.
  /// run-flow.md 6: 3초 간격 + 최소 이동거리 5m 필터(정지 시 GPS 노이즈 누적 방지).
  /// 두 값 모두 2026-09-13 야외 실측(2.61km/383점 = 3.1초·6.8m)으로 검증됨.
  LocationSettings _locationSettings() {
    if (Platform.isAndroid) {
      // 포그라운드 서비스 알림을 띄워 화면을 꺼도 위치 업데이트가 이어지게 한다.
      // run-flow.md 6 '백그라운드 위치 추적'.
      return AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
        intervalDuration: const Duration(seconds: 3),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Run Earth',
          notificationText: '러닝을 기록하는 중이에요',
          notificationChannelName: '러닝 기록',
          // TODO: 알림 전용 단색 아이콘이 나오면 교체. ic_launcher 는 임시.
          notificationIcon:
              AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
          enableWakeLock: true, // 화면이 꺼져도 좌표를 놓치지 않게.
          setOngoing: true, // 러닝 중에는 알림을 지울 수 없게.
          color: AppColors.primary,
        ),
      );
    }
    if (Platform.isIOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5,
        activityType: ActivityType.fitness,
        allowBackgroundLocationUpdates: true,
        pauseLocationUpdatesAutomatically: false, // 신호등 대기 중 멈추면 곤란.
        showBackgroundLocationIndicator: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 5,
    );
  }

  void _onPosition(Position pos) {
    final point = LatLngPoint(lat: pos.latitude, lng: pos.longitude);

    // running 이 아닐 때(paused)는 현재 위치만 갱신, 거리·경로 누적 없음.
    if (state.phase != RunSessionPhase.running) {
      state = state.copyWith(current: point);
      return;
    }

    var distance = state.distanceKm;
    final last = state.route.isNotEmpty ? state.route.last : null;
    if (last != null && !_skipNextSegment) {
      distance += Geolocator.distanceBetween(
            last.lat,
            last.lng,
            point.lat,
            point.lng,
          ) /
          1000;
    }
    _skipNextSegment = false;

    state = state.copyWith(
      route: [...state.route, point],
      distanceKm: distance,
      current: point,
    );
  }

  /// PAUSE ↔ RESUME 토글.
  void togglePause() {
    if (state.phase == RunSessionPhase.running) {
      state = state.copyWith(phase: RunSessionPhase.paused);
    } else if (state.phase == RunSessionPhase.paused) {
      _skipNextSegment = true; // 일시정지 구간은 거리에서 제외
      state = state.copyWith(phase: RunSessionPhase.running);
    }
  }

  /// STOP → 추적 종료. 결과 화면으로 넘어간다(저장은 화면에서).
  void stop() {
    _elapsedTimer?.cancel();
    _snapshotTimer?.cancel();
    _posSub?.cancel();
    _posSub = null;
    // 스냅샷은 여기서 지우지 않는다. 정식 기록으로 저장된 걸 확인한 뒤
    // [clearSnapshot] 으로 지운다 — 저장 직전에 죽어도 잃지 않도록.
    state = state.copyWith(phase: RunSessionPhase.stopped);
  }

  /// 결과 화면에서 다시 prerun 으로 초기화.
  void reset() {
    _disposeAll();
    _skipNextSegment = false;
    state = RunSessionState.initial(state.runType);
  }

  /// 현재 세션을 저장용 [Run] 으로 변환. [coverImageUrl] 은 렌더된 경로 이미지 경로.
  Run buildRun({String? coverImageUrl, DateTime? at}) {
    final now = at ?? DateTime.now();
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    final recordType = switch (state.runType) {
      RunType.normal => RecordType.normal,
      RunType.theme => RecordType.theme,
      RunType.online => RecordType.online,
    };
    return Run(
      id: 'run_${now.microsecondsSinceEpoch}',
      date:
          '${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}',
      day: days[now.weekday - 1],
      km: double.parse(state.distanceKm.toStringAsFixed(2)),
      pace: state.paceStr,
      dur: state.elapsedStr,
      kcal: state.kcal,
      type: recordType,
      year: now.year,
      month: now.month,
      coverImageType: CoverImageType.route,
      coverImageUrl: coverImageUrl,
      gpsVerified: false,
      source: RunSource.app,
      route: state.route,
    );
  }

  // ── 진행 중 러닝 스냅샷 (run-flow.md 7) ──────────────────────

  void _startSnapshotTimer() {
    _snapshotTimer?.cancel();
    unawaited(_saveSnapshot()); // 시작 직후 죽는 경우도 덮는다.
    _snapshotTimer =
        Timer.periodic(_snapshotInterval, (_) => unawaited(_saveSnapshot()));
  }

  Future<void> _saveSnapshot() async {
    final startedAt = _startedAt;
    if (startedAt == null) return;
    if (state.phase != RunSessionPhase.running &&
        state.phase != RunSessionPhase.paused) {
      return;
    }
    // 스냅샷 저장 실패가 러닝을 방해해선 안 된다 — 다음 주기에 다시 시도한다.
    try {
      await ref.read(appDatabaseProvider).saveActiveRun(
            startedAt: startedAt,
            elapsed: state.elapsed,
            distanceKm: state.distanceKm,
            route: state.route,
            runType: state.runType,
            paused: state.isPaused,
          );
    } catch (e) {
      debugPrint('[run] 스냅샷 저장 실패: $e');
    }
  }

  /// 정식 기록으로 저장된 뒤 스냅샷을 지운다. 저장을 확인한 쪽에서 호출한다.
  Future<void> clearSnapshot() async {
    _startedAt = null;
    try {
      await ref.read(appDatabaseProvider).clearActiveRun();
    } catch (e) {
      debugPrint('[run] 스냅샷 삭제 실패: $e');
    }
  }

  /// 앱 시작 시 호출. 남아 있는 러닝을 되살렸으면 true.
  ///
  /// 사용자에게 묻지 않고 조용히 이어붙인다(2026-09-15 결정) — 포그라운드
  /// 서비스가 붙은 뒤로는 드물게만 발생하는 경로라, 확인 팝업은 정상 동작을
  /// 비정상처럼 보이게 만든다.
  Future<bool> restoreIfAny() async {
    final ActiveRunRow? row;
    try {
      row = await ref.read(appDatabaseProvider).loadActiveRun();
    } catch (e) {
      debugPrint('[run] 스냅샷 조회 실패: $e');
      return false;
    }
    if (row == null) return false;

    if (DateTime.now().difference(row.updatedAt) > _snapshotMaxAge) {
      await _finalizeExpired(row);
      return false;
    }

    state = RunSessionState(
      phase: row.paused ? RunSessionPhase.paused : RunSessionPhase.running,
      runType: row.runType,
      elapsed: Duration(seconds: row.elapsedSeconds),
      distanceKm: row.distanceKm,
      route: row.routePoints,
    );
    _startedAt = row.startedAt;
    // 앱이 죽어 있는 동안 이동했더라도 그 구간은 거리에 더하지 않는다.
    // 추적하지 못한 이동이라 경로에도 없고, 더하면 페이스만 왜곡된다.
    _skipNextSegment = true;

    _startElapsedTimer();
    _startSnapshotTimer();
    if (await _ensurePermission()) _startLocationStream();
    return true;
  }

  /// 너무 오래된 스냅샷을 기록으로 확정하고 지운다.
  ///
  /// 커버 이미지는 만들지 않는다 — `route` 좌표만 있으면 어디서든 다시 그릴
  /// 수 있고(2026-09-11 결정), 렌더는 화면 계층의 일이다.
  Future<void> _finalizeExpired(ActiveRunRow row) async {
    state = RunSessionState(
      phase: RunSessionPhase.stopped,
      runType: row.runType,
      elapsed: Duration(seconds: row.elapsedSeconds),
      distanceKm: row.distanceKm,
      route: row.routePoints,
    );
    try {
      await ref.read(appDatabaseProvider).upsertRun(buildRun(at: row.startedAt));
      await ref.read(appDatabaseProvider).clearActiveRun();
    } catch (e) {
      debugPrint('[run] 만료 스냅샷 확정 실패: $e'); // 스냅샷은 남겨 다음에 재시도.
    }
    _startedAt = null;
    state = RunSessionState.initial(row.runType);
  }

  Future<bool> _ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      state = state.copyWith(error: '위치 서비스가 꺼져 있어요. 설정에서 켜주세요.');
      return false;
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      state = state.copyWith(error: '위치 권한이 필요해요. 설정에서 허용해주세요.');
      return false;
    }
    return true;
  }

  void _disposeAll() {
    _elapsedTimer?.cancel();
    _countdownTimer?.cancel();
    _snapshotTimer?.cancel();
    _posSub?.cancel();
    _posSub = null;
  }
}

/// 러닝 세션 전역 상태.
final runTrackerProvider =
    NotifierProvider<RunTracker, RunSessionState>(RunTracker.new);
