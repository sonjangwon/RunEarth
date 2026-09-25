import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/db/app_database.dart';
import '../../core/models/run.dart';
import '../connectivity/connectivity_providers.dart';
import '../storage/cover_storage.dart';
import '../supabase/supabase_config.dart';

/// 로컬 기록을 서버 `public.runs` 로 올리는 동기화.
///
/// local-first: 로컬 DB 가 1차 진실 소스이고 업로드는 후행 처리다.
/// 대기 목록은 별도 큐 테이블이 아니라 `runs.synced_at IS NULL` 로 표현한다.
///
/// 정책 (offline-handling.md 4·5 의 [미확정] 항목, 2026-09-12 확정):
/// 1. 재시도는 포기하지 않는다. 간격만 30초 → 1분 → 5분 으로 늘린다(앱 실행 중에만).
/// 2. 업로드에 성공해도 로컬 기록은 지우지 않는다.
/// 3. 한 건이 실패해도 다음 건으로 넘어간다 — 깨진 한 건이 나머지를 막지 않게.
class RunSyncService {
  RunSyncService(this._db, this._client);

  final AppDatabase _db;
  final SupabaseClient _client;

  /// 재시도 간격. 마지막 값(5분)을 계속 반복한다.
  static const _backoff = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 5),
  ];

  Timer? _retryTimer;
  int _failStreak = 0;
  bool _running = false;

  /// 미동기화 기록을 모두 올린다. 중복 실행은 무시한다.
  Future<void> syncNow() async {
    if (_running) return;
    if (!SupabaseConfig.isConfigured) return;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return; // 로그인 전에는 올릴 곳이 없다.

    _running = true;
    try {
      final pending = await _db.getUnsyncedRuns();
      if (pending.isEmpty) {
        _cancelRetry();
        return;
      }

      var failed = 0;
      for (final run in pending) {
        try {
          // 사진을 먼저 올린다. 기록 행이 가리키는 경로가 실제로 있어야
          // 한다 — 행은 올라갔는데 사진이 없는 상태를 만들지 않는다.
          // 파일이 사라졌거나 사진이 아니면 null 이 와서 그냥 넘어간다.
          final coverPath = await uploadCoverPhoto(
            _client,
            userId: userId,
            runId: run.id,
            localPath: run.coverImageUrl,
          );
          await _client.from('runs').upsert(_payload(run, userId, coverPath));
          await _db.markSynced(run.id);
        } catch (e) {
          // 정책 3 — 실패한 건은 대기 상태로 남겨두고 다음 건을 계속 올린다.
          failed++;
          debugPrint('[sync] 업로드 실패 ${run.id}: $e');
        }
      }

      if (failed == 0) {
        _cancelRetry();
      } else {
        _scheduleRetry();
      }
    } catch (e) {
      debugPrint('[sync] 동기화 실패: $e');
      _scheduleRetry();
    } finally {
      _running = false;
    }
  }

  /// 정책 1 — 횟수 제한 없이 재시도하되 간격을 늘려 배터리를 아낀다.
  void _scheduleRetry() {
    _retryTimer?.cancel();
    final delay = _backoff[_failStreak.clamp(0, _backoff.length - 1)];
    _failStreak++;
    _retryTimer = Timer(delay, syncNow);
  }

  void _cancelRetry() {
    _retryTimer?.cancel();
    _retryTimer = null;
    _failStreak = 0;
  }

  /// 서버 컬럼(snake_case)으로 변환.
  ///
  /// enum 문자열은 모델의 JSON 값을 그대로 쓴다(코드 정본과 어긋나지 않도록).
  Map<String, dynamic> _payload(Run run, String userId, String? coverPath) {
    final json = run.toJson();
    return {
      'id': run.id,
      'user_id': userId,
      'date': run.date,
      'day': run.day,
      'km': run.km,
      'pace': run.pace,
      'dur': run.dur,
      'kcal': run.kcal,
      'type': json['type'],
      'year': run.year,
      'month': run.month,
      'cover_image_type': json['coverImageType'],
      // **사용자가 찍은 사진만** 올린다(2026-09-23 결정). 2026-09-12 에 "커버
      // 이미지를 올리지 않는다"고 정한 근거는 "route 좌표만 있으면 어디서든 다시
      // 렌더할 수 있다" 였는데, 사진은 좌표로 복원할 수 없어 그 근거가 성립하지
      // 않는다. 자동 생성 경로 이미지(route_*.png)는 여전히 안 올린다.
      //
      // 들어가는 값은 URL 이 아니라 **Storage 객체 경로**(`{uid}/{id}.jpg`)다.
      // 버킷이 private 이라 공개 URL 이 없고 signed URL 은 만료된다.
      // 로컬의 `coverImageUrl` 도 파일 경로를 담고 있어 성격이 같다.
      'cover_image_url': coverPath,
      'marathon_challenge_id': run.marathonChallengeId,
      'marathon_course_id': run.marathonCourseId,
      'gps_verified': run.gpsVerified,
      'source': json['source'],
      'route': run.route.map((p) => p.toJson()).toList(),
    };
  }

  void dispose() => _cancelRetry();
}

final runSyncServiceProvider = Provider<RunSyncService>((ref) {
  final service = RunSyncService(
    ref.watch(appDatabaseProvider),
    ref.watch(supabaseClientProvider),
  );
  ref.onDispose(service.dispose);
  return service;
});

/// 아직 서버에 못 올린 기록의 id 집합.
///
/// 기록 카드가 '동기화 대기' 딱지를 붙일지 판단하는 데 쓴다. 기록 자체가
/// 아니라 id 명단만 따로 흘려보내는 이유는 `watchUnsyncedIds` 주석 참고.
/// 화면(features) 이 아니라 서비스 계층에 두어 기록 탭 밖에서도 쓸 수 있게 한다.
final pendingSyncRunIdsProvider = StreamProvider<Set<String>>((ref) {
  return ref.watch(appDatabaseProvider).watchUnsyncedIds();
});

/// 오프라인 → 온라인으로 **바뀌는 순간에만** 밀린 업로드를 시도한다.
///
/// 기존 트리거는 앱 시작·러닝 저장 직후 둘뿐이라, 앱을 켜둔 채로 연결이
/// 돌아오면 재시도 타이머(최대 5분)를 기다려야 했다.
/// 정본: offline-handling.md 3 — "재연결되면 대기 중인 동기화 큐가 있으면
/// 자동 처리 시작".
///
/// 앱 루트(main.dart)에서 watch 해 앱이 살아있는 동안 유지한다.
final syncOnReconnectProvider = Provider<void>((ref) {
  ref.listen<AsyncValue<bool>>(isOnlineProvider, (prev, next) {
    // 온라인 상태가 이어지는 동안 반복 호출되지 않게 '전환'만 본다.
    final wasOffline = prev?.valueOrNull == false;
    final isOnline = next.valueOrNull == true;
    if (wasOffline && isOnline) {
      debugPrint('[sync] 재연결 감지 — 밀린 업로드 시도');
      unawaited(ref.read(runSyncServiceProvider).syncNow());
    }
  });
});
