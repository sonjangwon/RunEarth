import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/app_database.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/run.dart';

/// 로컬 DB 의 전체 기록을 실시간 관찰한다.
///
/// 개발용 샘플 시드는 제거했다(2026-09-12) — 서버 동기화가 켜지면서
/// 가짜 기록이 업로드되면 안 되기 때문. 기존 샘플은 DB 마이그레이션 v3 에서 삭제된다.
final runsStreamProvider = StreamProvider<List<Run>>((ref) {
  return ref.watch(appDatabaseProvider).watchAllRuns();
});

/// 기록 탭 타입 필터 (null = 전체). 정본: records.md / 기능정의서 4-3-B.
final recordsFilterProvider = StateProvider<RecordType?>((ref) => null);
