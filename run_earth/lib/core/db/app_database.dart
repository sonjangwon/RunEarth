import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/enums.dart';
import '../models/geo.dart';
import '../models/run.dart';

part 'app_database.g.dart';

/// 러닝 기록 로컬 테이블.
///
/// local-first 의 1차 진실 소스. 모델 [Run] 과 1:1 대응한다.
/// enum 은 index(정수)로 저장한다. 생성되는 행 클래스는 모델 `Run` 과
/// 이름이 겹치지 않도록 `RunRow` 로 명명한다.
@DataClassName('RunRow')
class Runs extends Table {
  TextColumn get id => text()();
  TextColumn get date => text()();
  TextColumn get day => text()();
  RealColumn get km => real()();
  TextColumn get pace => text()();
  TextColumn get dur => text()();
  IntColumn get kcal => integer()();
  IntColumn get type => intEnum<RecordType>()();
  IntColumn get year => integer()();
  IntColumn get month => integer()();
  IntColumn get coverImageType => intEnum<CoverImageType>()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get marathonChallengeId => text().nullable()();
  TextColumn get marathonCourseId => text().nullable()();
  BoolColumn get gpsVerified => boolean().nullable()();
  IntColumn get source => intEnum<RunSource>()();

  /// 추적된 GPS 경로. `[{"lat":..,"lng":..}, ...]` JSON 문자열로 저장.
  TextColumn get route => text().nullable()();

  /// 서버 업로드 완료 시각. null 이면 아직 안 올라간 것 = 동기화 대기.
  ///
  /// offline-handling.md 4 의 별도 `SyncQueueItem` 테이블 대신 이 플래그로
  /// 대기 목록을 표현한다(2026-09-12 결정) — 지금 올릴 종류가 러닝 하나뿐이라
  /// 큐 테이블은 같은 데이터를 두 곳에 두는 비용만 생긴다.
  DateTimeColumn get syncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 진행 중인 러닝의 스냅샷 (항상 0개 또는 1개 행).
///
/// STOP 확인을 눌러야만 [Runs] 에 저장되는 구조라, 그 전에 앱 프로세스가
/// 죽으면 러닝이 통째로 사라졌다(2026-09-13 발견). 추적 중 10초마다 이 행을
/// 덮어써서, 앱이 죽어도 다음 실행 때 이어서 뛸 수 있게 한다.
///
/// 좌표를 한 행씩 쌓지 않고 통째로 덮어쓰는 이유(2026-09-15 결정): 쓰기량은
/// append 가 유리하지만(풀코스 기준 ~750KB vs ~200MB) 절대량이 둘 다 문제되지
/// 않는 수준이고, 일시정지 구간을 뺀 거리는 좌표만으로 복원할 수 없어 어차피
/// 세션 메타를 따로 관리해야 한다. 유실을 막으려는 기능이 복잡해 버그가 나면
/// 본말전도다. run-flow.md 7.
@DataClassName('ActiveRunRow')
class ActiveRuns extends Table {
  /// 항상 0. 단일 행임을 스키마로 강제한다.
  IntColumn get id => integer()();

  DateTimeColumn get startedAt => dateTime()();

  /// 마지막 스냅샷 시각. 너무 오래됐으면 복원하지 않고 기록으로 확정한다.
  DateTimeColumn get updatedAt => dateTime()();

  IntColumn get elapsedSeconds => integer()();
  RealColumn get distanceKm => real()();

  /// [Runs.route] 와 같은 형식의 JSON 문자열.
  TextColumn get route => text().nullable()();

  IntColumn get runType => intEnum<RunType>()();

  /// 죽은 시점이 일시정지 중이었으면 일시정지 상태로 되살린다.
  BoolColumn get paused => boolean()();

  @override
  Set<Column> get primaryKey => {id};
}

/// 앱 로컬 데이터베이스 (drift).
@DriftDatabase(tables: [Runs, ActiveRuns])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 → v2: 추적 경로(route) 컬럼 추가.
          if (from < 2) {
            await m.addColumn(runs, runs.route);
          }
          // v2 → v3: 동기화 플래그 추가 + 개발용 샘플 기록 제거.
          // 서버 동기화를 켜기 전에 가짜 데이터를 올리지 않기 위함(2026-09-12).
          // 실제 러닝으로 저장된 기록('run_*')은 건드리지 않는다.
          if (from < 3) {
            await m.addColumn(runs, runs.syncedAt);
            await (delete(runs)..where((t) => t.id.like('seed-%'))).go();
          }
          // v3 → v4: 진행 중 러닝 스냅샷 테이블 추가.
          if (from < 4) {
            await m.createTable(activeRuns);
          }
        },
      );

  /// 기록 목록의 정렬 — **최신 순**(records.md 3-1).
  ///
  /// 세 칸을 순서대로 본다. 예전에는 `date` 하나만 봤는데 두 가지가 어긋났다
  /// (2026-09-25 사용자 발견).
  ///
  /// - `date` 는 `"09.23"` 같은 **문자열**이라 연도를 못 본다. `"12.31"` >
  ///   `"01.01"` 이므로 해가 바뀌면 **작년 12월 기록이 목록 맨 위로 온다.**
  ///   그래서 [year] 를 먼저 본다
  /// - 같은 날 기록은 정렬 키가 **완전히 같아** 순서가 정해지지 않고, SQLite 가
  ///   저장 순서(= 오래된 것부터)로 돌려준다. 하루에 두 번 뛰면 **먼저 뛴 것이
  ///   위에** 있었다. 그래서 [id] 를 마지막에 본다
  ///
  /// ⚠️ **마지막 칸은 `id` 가 시각을 들고 있다는 데 기댄다.** 앱이 만드는 id 는
  /// `run_<microsecondsSinceEpoch>`(자릿수가 같아 문자열 비교로도 시간순)이다.
  /// 이 전제가 깨지는 기록이 들어오면 — **웨어러블 동기화**로 워치 기록을
  /// 가져오는 때가 그렇다 — 같은 날 순서가 다시 어긋난다. 그때는 `startedAt`
  /// 시각 칼럼이 필요하다. `wearable-sync.md` 4 의 "시간대가 겹치는 워크아웃"
  /// 판정도 어차피 그 값을 요구하므로 선행 조건으로 적어뒀다.
  ///
  /// (2026-09-23 에 직접 넣은 시드 기록 `seed_1`~`seed_6` 도 이 규칙 밖이지만
  /// 날짜가 서로 겹치지 않아 지금은 드러나지 않는다.)
  List<OrderClauseGenerator<$RunsTable>> get _latestFirst => [
        (t) => OrderingTerm.desc(t.year),
        (t) => OrderingTerm.desc(t.date),
        (t) => OrderingTerm.desc(t.id),
      ];

  /// 전체 기록 (최신순). 삭제 정책 없음(records.md) — 조회/추가만 제공.
  Future<List<Run>> getAllRuns() async {
    final rows = await (select(runs)..orderBy(_latestFirst)).get();
    return rows.map((r) => r.toModel()).toList();
  }

  /// 기록 변경을 실시간 관찰 (기록 탭 자동 갱신용).
  Stream<List<Run>> watchAllRuns() {
    return (select(runs)..orderBy(_latestFirst))
        .watch()
        .map((rows) => rows.map((r) => r.toModel()).toList());
  }

  /// 기록 저장(신규/갱신). id 기준 upsert.
  Future<void> upsertRun(Run run) =>
      into(runs).insertOnConflictUpdate(run.toCompanion());

  /// 아직 서버에 올리지 못한 기록 (오래된 것부터).
  Future<List<Run>> getUnsyncedRuns() async {
    final rows = await (select(runs)
          ..where((t) => t.syncedAt.isNull())
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
    return rows.map((r) => r.toModel()).toList();
  }

  /// 아직 서버에 못 올린 기록의 id 집합을 실시간 관찰.
  ///
  /// 기록 카드의 '동기화 대기' 표시용(offline-handling.md 2 케이스 B).
  /// `Run` 모델에 동기화 상태를 싣지 않고 id 명단만 따로 흘려보낸다 —
  /// 모델에 실으면 대표 이미지 수정(records.md 3)이 `upsertRun` 을 탈 때
  /// 옛 `syncedAt` 이 함께 덮어써져, 수정본이 서버에 영영 반영되지 않는다.
  Stream<Set<String>> watchUnsyncedIds() {
    final q = selectOnly(runs)
      ..addColumns([runs.id])
      ..where(runs.syncedAt.isNull());
    return q.watch().map((rows) => rows.map((r) => r.read(runs.id)!).toSet());
  }

  /// 서버에서 내려받은 기록을 넣고, 새로 들어간 건수를 돌려준다.
  ///
  /// **로컬에 이미 있는 id 는 건너뛴다**(offline-handling.md §4-1). 기록은
  /// 삭제·수치 수정이 없어 같은 id 면 내용도 같고, 다른 수 있는 건 대표 이미지
  /// 하나라 로컬(1차 진실 소스) 쪽을 남긴다. 들어간 행은 `syncedAt` 을 채워
  /// 업로드 대상에서 뺀다 — 이미 서버에 있는 기록이다.
  Future<int> insertDownloadedRuns(List<Run> downloaded) =>
      transaction(() async {
        final existing = (await (selectOnly(runs)..addColumns([runs.id]))
                .get())
            .map((r) => r.read(runs.id)!)
            .toSet();
        final fresh =
            downloaded.where((r) => !existing.contains(r.id)).toList();
        if (fresh.isEmpty) return 0;

        final syncedAt = Value(DateTime.now());
        await batch((b) => b.insertAll(runs, [
              for (final r in fresh)
                r.toCompanion().copyWith(syncedAt: syncedAt),
            ]));
        return fresh.length;
      });

  /// 업로드 성공 표시.
  ///
  /// 로컬 데이터는 지우지 않는다(2026-09-12 결정) — 로컬이 1차 진실 소스이고
  /// 기록 탭은 오프라인에서도 전부 보여야 한다(offline-handling.md 2 케이스 C).
  Future<void> markSynced(String id) =>
      (update(runs)..where((t) => t.id.equals(id)))
          .write(RunsCompanion(syncedAt: Value(DateTime.now())));

  /// 이미 올라간 기록을 고친 뒤 **다시 업로드 대기로 돌린다.**
  ///
  /// [upsertRun] 만으로는 안 된다. `toCompanion()` 에 `syncedAt` 이 없어서
  /// `insertOnConflictUpdate` 가 그 칸을 SET 절에 넣지 않고, 옛 업로드 시각이
  /// 그대로 남는다. 일부러 그렇게 뒀다 — 모델에 `syncedAt` 을 실으면 수정이
  /// 옛 값을 덮어써 업로드 성공 표시를 잃는다([watchUnsyncedIds] 주석).
  ///
  /// 그래서 "고쳤으니 다시 올려라"는 **따로 말해준다.** 지금 쓰는 곳은 대표
  /// 이미지 변경(`cover_photo_sheet.dart`) 한 곳이다.
  Future<void> markUnsynced(String id) =>
      (update(runs)..where((t) => t.id.equals(id)))
          .write(const RunsCompanion(syncedAt: Value(null)));

  // ── 진행 중 러닝 스냅샷 ──────────────────────────────────────

  /// 진행 중 러닝 스냅샷 저장(덮어쓰기). 항상 id=0 한 행만 유지한다.
  Future<void> saveActiveRun({
    required DateTime startedAt,
    required Duration elapsed,
    required double distanceKm,
    required List<LatLngPoint> route,
    required RunType runType,
    required bool paused,
  }) =>
      into(activeRuns).insertOnConflictUpdate(
        ActiveRunsCompanion.insert(
          id: const Value(0),
          startedAt: startedAt,
          updatedAt: DateTime.now(),
          elapsedSeconds: elapsed.inSeconds,
          distanceKm: distanceKm,
          route: Value(_encodeRoute(route)),
          runType: runType,
          paused: paused,
        ),
      );

  /// 저장된 스냅샷. 없으면 null.
  Future<ActiveRunRow?> loadActiveRun() =>
      (select(activeRuns)..where((t) => t.id.equals(0))).getSingleOrNull();

  /// 스냅샷 삭제. 러닝이 정식 기록으로 확정된 뒤에만 호출한다.
  Future<void> clearActiveRun() =>
      (delete(activeRuns)..where((t) => t.id.equals(0))).go();
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}run_earth.sqlite');
    return NativeDatabase.createInBackground(file);
  });
}

/// route JSON 문자열 ↔ 좌표 배열 변환 헬퍼.
List<LatLngPoint> _decodeRoute(String? json) {
  if (json == null || json.isEmpty) return const [];
  final list = jsonDecode(json) as List<dynamic>;
  return list
      .map((e) => LatLngPoint.fromJson(e as Map<String, dynamic>))
      .toList();
}

String? _encodeRoute(List<LatLngPoint> route) {
  if (route.isEmpty) return null;
  return jsonEncode(route.map((p) => p.toJson()).toList());
}

/// 스냅샷 행의 좌표 배열. 디코딩 헬퍼가 이 파일 안에만 있어 여기서 노출한다.
extension ActiveRunRowMapper on ActiveRunRow {
  List<LatLngPoint> get routePoints => _decodeRoute(route);
}

/// drift 행(RunRow) ↔ 모델(Run) 변환.
extension RunRowMapper on RunRow {
  Run toModel() => Run(
        id: id,
        date: date,
        day: day,
        km: km,
        pace: pace,
        dur: dur,
        kcal: kcal,
        type: type,
        year: year,
        month: month,
        coverImageType: coverImageType,
        coverImageUrl: coverImageUrl,
        marathonChallengeId: marathonChallengeId,
        marathonCourseId: marathonCourseId,
        gpsVerified: gpsVerified,
        source: source,
        route: _decodeRoute(route),
      );
}

extension RunCompanionMapper on Run {
  RunsCompanion toCompanion() => RunsCompanion(
        id: Value(id),
        date: Value(date),
        day: Value(day),
        km: Value(km),
        pace: Value(pace),
        dur: Value(dur),
        kcal: Value(kcal),
        type: Value(type),
        year: Value(year),
        month: Value(month),
        coverImageType: Value(coverImageType),
        coverImageUrl: Value(coverImageUrl),
        marathonChallengeId: Value(marathonChallengeId),
        marathonCourseId: Value(marathonCourseId),
        gpsVerified: Value(gpsVerified),
        source: Value(source),
        route: Value(_encodeRoute(route)),
      );
}

/// 앱 전역에서 공유하는 DB 인스턴스.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});
