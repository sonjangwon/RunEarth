import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/run.dart';
import 'records_sample_data.dart';

/// 로컬 DB 가 비어 있으면 샘플 기록을 1회 심는다. (개발용)
final _seedRunsProvider = FutureProvider<void>((ref) async {
  final db = ref.watch(appDatabaseProvider);
  final existing = await db.getAllRuns();
  if (existing.isEmpty) {
    for (final run in sampleRuns) {
      await db.upsertRun(run);
    }
  }
});

/// 로컬 DB 의 전체 기록을 실시간 관찰한다.
final runsStreamProvider = StreamProvider<List<Run>>((ref) {
  ref.watch(_seedRunsProvider); // 최초 진입 시 시드 보장
  return ref.watch(appDatabaseProvider).watchAllRuns();
});

/// 기록 탭 타입 필터 (null = 전체). 정본: records.md / 기능정의서 4-3-B.
final recordsFilterProvider = StateProvider<RecordType?>((ref) => null);
