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

/// 로컬 기록이 아직 **첫 값을 못 준** 상태인가.
///
/// `homeStatsProvider` 같은 집계는 값이 없을 때 0 으로 접는다 — 계산을 단순히
/// 두려는 선택이지만, 그러면 화면에서 **로딩 중과 "기록이 하나도 없다"가
/// 구분되지 않는다.** 스켈레톤을 띄울지 판단하는 쪽은 집계가 아니라 이 값을
/// 본다(global-states.md 3).
///
/// `hasValue` 를 같이 보는 이유: 스트림이 재구독될 때 이미 값을 들고 있으면서
/// `isLoading` 이 참인 구간이 있다. 그때 뼈대로 되돌리면 화면이 깜빡인다.
final runsLoadingProvider = Provider<bool>((ref) {
  final runs = ref.watch(runsStreamProvider);
  return runs.isLoading && !runs.hasValue;
});

/// 기록 탭 타입 필터 (null = 전체). 정본: records.md / 기능정의서 4-3-B.
final recordsFilterProvider = StateProvider<RecordType?>((ref) => null);

/// 미완료 러닝(거리 0)을 목록에 함께 보일지. 기본은 숨김.
///
/// 0km 기록 정책(2026-09-20) — 기록을 **지우는 게 아니라 접어두는** 것이므로
/// 사용자가 언제든 펼쳐 볼 수 있어야 한다. `records.md` 4 의 영구 보존 원칙이
/// 사용자 눈에도 지켜진 것으로 보이려면 이 토글이 필요하다.
final showIncompleteRunsProvider = StateProvider<bool>((ref) => false);
