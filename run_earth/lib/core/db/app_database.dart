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

  @override
  Set<Column> get primaryKey => {id};
}

/// 앱 로컬 데이터베이스 (drift).
@DriftDatabase(tables: [Runs])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          // v1 → v2: 추적 경로(route) 컬럼 추가.
          if (from < 2) {
            await m.addColumn(runs, runs.route);
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
