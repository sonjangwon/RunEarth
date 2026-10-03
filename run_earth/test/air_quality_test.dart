import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:run_earth/core/models/air_quality.dart';
import 'package:run_earth/features/run/data/air_quality_provider.dart';
import 'package:run_earth/services/weather/air_korea_service.dart';
import 'package:run_earth/services/weather/kma_grid.dart';

/// 한글이 든 본문은 `http.Response(String)` 이 latin1 로 인코딩하다 실패한다.
http.Response _utf8(String body) => http.Response.bytes(utf8.encode(body), 200);

DateTime kst(int h, int m) => DateTime.utc(2026, 10, 3, h, m);

String _ok(List<Map<String, dynamic>> items) => jsonEncode({
      'response': {
        'header': {'resultCode': '00', 'resultMsg': 'NORMAL_CODE'},
        'body': {'items': items, 'totalCount': items.length},
      }
    });

String _nearby() => _ok([
      {'stationName': '종로구', 'tm': 1.4},
      {'stationName': '중구', 'tm': 0.5},
      {'stationName': '청계천로', 'tm': 1.5},
    ]);

String _measure(String pm10, {String time = '2026-10-03 10:00'}) =>
    _ok([{'pm10Value': pm10, 'pm10Grade': '1', 'dataTime': time}]);

void main() {
  test('TM 변환 — 서울시청은 측정소 API 예시 좌표 근처', () {
    final p = toTm(37.5665, 126.9780);
    expect(p.x, closeTo(198056, 5));
    expect(p.y, closeTo(451885, 5));
  });

  test('PM10 → 단계 (환경부 구간 경계)', () {
    expect(AirQuality.fromPm10(30), AirQuality.good);
    expect(AirQuality.fromPm10(31), AirQuality.moderate);
    expect(AirQuality.fromPm10(80), AirQuality.moderate);
    expect(AirQuality.fromPm10(81), AirQuality.bad);
    expect(AirQuality.fromPm10(150), AirQuality.bad);
    expect(AirQuality.fromPm10(151), AirQuality.veryBad);
  });

  test('자정은 24:00 으로 온다 → 다음 날 0시', () {
    expect(parseAirKoreaTime('2026-10-02 24:00'), DateTime.utc(2026, 10, 3));
    expect(parseAirKoreaTime('2026-10-03 10:00'), kst(10, 0));
  });

  test('다음 갱신은 측정 시각 + 1시간 15분, 이미 지났으면 10분 뒤', () {
    expect(airExpiry(kst(10, 0), kst(10, 20)), kst(11, 15));
    expect(airExpiry(kst(10, 0), kst(11, 20)), kst(11, 30));
  });

  test('측정소는 가까운 순으로 정렬한다', () async {
    final svc = AirKoreaService(
      client: MockClient((_) async => _utf8(_nearby())),
    );
    expect(await svc.nearbyStations(const TmPoint(0, 0)),
        ['중구', '종로구', '청계천로']);
  });

  test('가장 가까운 측정소가 점검 중(-)이면 두 번째를 쓴다', () async {
    final asked = <String>[];
    final svc = AirKoreaService(
      client: MockClient((req) async {
        final st = req.url.queryParameters['stationName']!;
        asked.add(st);
        return http.Response(_measure(st == '중구' ? '-' : '85'), 200);
      }),
      now: () => kst(10, 20),
    );
    final f = await svc.fetch(['중구', '종로구', '청계천로']);
    expect(asked, ['중구', '종로구']);
    expect(f.reading.value, 85);
    expect(f.reading.level, AirQuality.bad); // API 등급(1)이 아니라 숫자로
  });

  test('캐시 — 측정소는 격자가 바뀔 때만 다시 찾는다', () async {
    final ops = <String>[];
    var now = kst(10, 20);
    final cache = AirQualityCache(
      AirKoreaService(
        client: MockClient((req) async {
          final op = req.url.pathSegments.last;
          ops.add(op);
          return _utf8(op == 'getNearbyMsrstnList' ? _nearby() : _measure('13'));
        }),
        now: () => now,
      ),
      now: () => now,
    );
    const seoul = KmaGrid(60, 127);
    expect((await cache.get(seoul, 37.5665, 126.978))?.value, 13);
    expect(ops, ['getNearbyMsrstnList', 'getMsrstnAcctoRltmMesureDnsty']);

    now = kst(11, 0); // 갱신 전 → 안 부른다
    await cache.get(seoul, 37.5665, 126.978);
    expect(ops.length, 2);

    now = kst(11, 16); // 갱신 후 → 측정값만
    await cache.get(seoul, 37.5665, 126.978);
    expect(ops.last, 'getMsrstnAcctoRltmMesureDnsty');
    expect(ops.length, 3);

    await cache.get(const KmaGrid(98, 76), 35.1796, 129.0756); // 격자 변경
    expect(ops.sublist(3),
        ['getNearbyMsrstnList', 'getMsrstnAcctoRltmMesureDnsty']);
  });

  test('실패하면 null', () async {
    final cache = AirQualityCache(
      AirKoreaService(client: MockClient((_) async => http.Response('', 503))),
    );
    expect(await cache.get(const KmaGrid(60, 127), 37.5665, 126.978), isNull);
  });
}
