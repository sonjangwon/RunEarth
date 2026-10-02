// 내려받기 합치는 규칙 — offline-handling.md §4-1 의 문장을 그대로 건다.
import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:run_earth/core/db/app_database.dart';
import 'package:run_earth/core/models/enums.dart';
import 'package:run_earth/services/storage/cover_storage.dart';
import 'package:run_earth/services/sync/run_sync_service.dart';

const _uid = '6f1c2a9e-3b4d-4e5f-8a7b-0c1d2e3f4a5b';

Map<String, dynamic> _serverRow(String id, {String pace = "6'00\""}) => {
      'id': id,
      'user_id': _uid,
      'date': '10.01',
      'day': '수',
      'km': 2.56,
      'pace': pace,
      'dur': '24:12',
      'kcal': 0,
      'type': '일반',
      'year': 2026,
      'month': 10,
      'cover_image_type': 'photo',
      'cover_image_url': '$_uid/$id.jpg',
      'marathon_challenge_id': null,
      'marathon_course_id': null,
      'gps_verified': null,
      'source': 'app',
      'route': [
        {'lat': 37.5, 'lng': 127.0},
        {'lat': 37.6, 'lng': 127.1},
      ],
      'created_at': '2026-10-01T12:00:00Z',
    };

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('서버 행을 모델로 되돌린다 — 경로·사진 경로 포함', () {
    final run = runFromServerRow(_serverRow('run_1'));
    expect(run.id, 'run_1');
    expect(run.km, 2.56);
    expect(run.type, RecordType.normal);
    expect(run.coverImageType, CoverImageType.photo);
    expect(run.coverImageUrl, '$_uid/run_1.jpg');
    expect(run.route, hasLength(2));
  });

  test('null route 도 빈 경로로 받는다', () {
    final run = runFromServerRow(_serverRow('run_1')..['route'] = null);
    expect(run.route, isEmpty);
  });

  test('로컬에 없는 id 만 추가한다', () async {
    final n = await db.insertDownloadedRuns([
      runFromServerRow(_serverRow('run_1')),
      runFromServerRow(_serverRow('run_2')),
    ]);
    expect(n, 2);
    expect(await db.getAllRuns(), hasLength(2));
  });

  test('이미 로컬에 있는 기록은 덮어쓰지 않는다', () async {
    final local = runFromServerRow(_serverRow('run_1', pace: "9'28\""));
    await db.upsertRun(local);

    final n = await db.insertDownloadedRuns(
        [runFromServerRow(_serverRow('run_1', pace: "7'58\""))]);

    expect(n, 0);
    final runs = await db.getAllRuns();
    expect(runs.single.pace, "9'28\"");
  });

  test('내려받은 기록은 업로드 대상이 아니다', () async {
    await db.insertDownloadedRuns([runFromServerRow(_serverRow('run_1'))]);
    expect(await db.getUnsyncedRuns(), isEmpty);
  });

  test('Storage 경로와 이 기기의 파일 경로를 가린다', () {
    expect(isRemoteCoverPath('$_uid/run_1.jpg'), isTrue);
    expect(isCoverPhoto('$_uid/run_1.jpg'), isTrue);
    expect(
        isRemoteCoverPath(
            '/data/user/0/com.runearth.run_earth/app_flutter/photo_run_1.jpg'),
        isFalse);
    expect(isRemoteCoverPath(null), isFalse);
  });
}
