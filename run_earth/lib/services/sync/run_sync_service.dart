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

  bool _pulling = false;

  /// 한 번에 읽는 행 수. Supabase API 기본 상한(1000)과 같다 — 더 크게 잡아도
  /// 서버가 1000 에서 자르므로, 넘는 기록은 페이지를 넘겨 받는다.
  static const _pageSize = 1000;

  /// 서버의 내 기록을 내려받아 로컬에 없는 것만 넣는다(offline-handling.md §4-1).
  ///
  /// 재설치·기기 변경 후에도 같은 기록이 보이게 하는 쪽이다. 실패해도
  /// 재시도 타이머를 걸지 않는다 — 다음 앱 시작·로그인·재연결 때 다시 돈다.
  Future<void> pullNow() async {
    if (_pulling) return;
    if (!SupabaseConfig.isConfigured) return;

    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;

    _pulling = true;
    try {
      final downloaded = <Run>[];
      var total = 0;
      for (var from = 0;; from += _pageSize) {
        final rows = await _client
            .from('runs')
            .select()
            .eq('user_id', userId)
            .order('id')
            .range(from, from + _pageSize - 1);
        total += rows.length;
        for (final row in rows) {
          try {
            downloaded.add(runFromServerRow(row));
          } catch (e) {
            // 업로드 정책 3 과 같다 — 깨진 한 건이 나머지를 막지 않게.
            debugPrint('[sync] 내려받기 변환 실패 ${row['id']}: $e');
          }
        }
        if (rows.length < _pageSize) break;
      }

      // 받는 사이에 로그아웃했으면 넣지 않는다 — 비운 로컬에 앞 계정 기록이
      // 다시 들어온다(profile-settings.md '로그아웃').
      if (_client.auth.currentUser?.id != userId) return;
      final inserted = await _db.insertDownloadedRuns(downloaded);
      debugPrint('[sync] 내려받기 — 서버 $total건 중 새 기록 $inserted건');
    } catch (e) {
      debugPrint('[sync] 내려받기 실패: $e');
    } finally {
      _pulling = false;
    }
  }

  /// 로그아웃 직전 — 밀린 기록을 한 번 올려보고 **그래도 남은 건수**를 준다.
  ///
  /// 0 이 아니면 로그아웃이 그 기록을 지운다는 경고를 띄운다
  /// (profile-settings.md '로그아웃'). 오프라인에서 오래 붙잡지 않게 시간을 끊는다.
  Future<int> uploadThenCountPending() async {
    try {
      await syncNow().timeout(const Duration(seconds: 10));
    } catch (_) {
      // 남은 건수로 판단한다.
    }
    return (await _db.getUnsyncedRuns()).length;
  }

  /// 이 기기의 기록 사본(행·스냅샷·이미지 파일)을 비운다. 로그아웃·탈퇴 뒤에 부른다.
  ///
  /// 로컬 기록에 소유자가 없어 다음 로그인 계정에 섞이고, 못 올린 기록은 그
  /// 계정으로 올라가 버린다. 서버에 있는 기록은 다시 로그인하면 돌아온다.
  Future<void> clearLocal() async {
    _cancelRetry();
    await _db.clearLocalRuns();
    await deleteLocalRunImages();
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

/// 서버 행(snake_case) → 모델. [RunSyncService._payload] 의 역방향이다.
///
/// enum 은 업로드 때 모델의 JSON 값 그대로 올렸으므로 `Run.fromJson` 에
/// 그대로 넘긴다. `cover_image_url` 은 파일 경로가 아니라 **Storage 객체
/// 경로**(`{uid}/{runId}.jpg`)다 — 화면은 `isRemoteCoverPath` 로 가려 서버에서
/// 읽는다(`cover_storage.dart`).
Run runFromServerRow(Map<String, dynamic> row) => Run.fromJson({
      'id': row['id'],
      'date': row['date'],
      'day': row['day'],
      'km': row['km'],
      'pace': row['pace'],
      'dur': row['dur'],
      'kcal': row['kcal'],
      'type': row['type'],
      'year': row['year'],
      'month': row['month'],
      'coverImageType': row['cover_image_type'],
      'coverImageUrl': row['cover_image_url'],
      'marathonChallengeId': row['marathon_challenge_id'],
      'marathonCourseId': row['marathon_course_id'],
      'gpsVerified': row['gps_verified'],
      'source': row['source'],
      'route': row['route'],
    });

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
      debugPrint('[sync] 재연결 감지 — 밀린 업로드·내려받기 시도');
      final sync = ref.read(runSyncServiceProvider);
      unawaited(sync.syncNow());
      // 오프라인으로 앱을 켜면 시작 시 내려받기가 실패한다 — 연결되면 채운다
      // (offline-handling.md §4-1 '한계').
      unawaited(sync.pullNow());
    }
  });
});
