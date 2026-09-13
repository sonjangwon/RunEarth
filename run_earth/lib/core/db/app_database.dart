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

/// 앱 로컬 데이터베이스 (drift).
@DriftDatabase(tables: [Runs])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 3;

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
        },
      );

  /// 전체 기록 (최신순). 삭제 정책 없음(records.md) — 조회/추가만 제공.
  Future<List<Run>> getAllRuns() async {
    final rows = await (select(runs)
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
    return rows.map((r) => r.toModel()).toList();
  }

  /// 기록 변경을 실시간 관찰 (기록 탭 자동 갱신용).
  Stream<List<Run>> watchAllRuns() {
    return (select(runs)..orderBy([(t) => OrderingTerm.desc(t.date)]))
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

  /// 업로드 성공 표시.
  ///
  /// 로컬 데이터는 지우지 않는다(2026-09-12 결정) — 로컬이 1차 진실 소스이고
  /// 기록 탭은 오프라인에서도 전부 보여야 한다(offline-handling.md 2 케이스 C).
  Future<void> markSynced(String id) =>
      (update(runs)..where((t) => t.id.equals(id)))
          .write(RunsCompanion(syncedAt: Value(DateTime.now())));
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
