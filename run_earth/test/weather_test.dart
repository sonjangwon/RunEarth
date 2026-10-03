import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:run_earth/core/models/weather.dart';
import 'package:run_earth/features/run/data/weather_provider.dart';
import 'package:run_earth/services/weather/kma_grid.dart';
import 'package:run_earth/services/weather/kma_weather_service.dart';

DateTime kst(int h, int m) => DateTime.utc(2026, 10, 3, h, m);

String _ncst({String t1h = '15.8', String pty = '0'}) => jsonEncode({
      'response': {
        'header': {'resultCode': '00', 'resultMsg': 'NORMAL_SERVICE'},
        'body': {
          'items': {
            'item': [
              {'category': 'PTY', 'obsrValue': pty},
              {'category': 'T1H', 'obsrValue': t1h},
            ]
          }
        }
      }
    });

String _fcst() => jsonEncode({
      'response': {
        'header': {'resultCode': '00'},
        'body': {
          'items': {
            'item': [
              {'category': 'SKY', 'fcstDate': '20261003', 'fcstTime': '1200', 'fcstValue': '4'},
              {'category': 'SKY', 'fcstDate': '20261003', 'fcstTime': '1100', 'fcstValue': '1'},
            ]
          }
        }
      }
    });

/// 오퍼레이션 이름으로 응답을 고른다. 부른 횟수를 센다.
MockClient _client(Map<String, http.Response Function()> byOp, List<String> calls) =>
    MockClient((req) async {
      final op = req.url.pathSegments.last;
      calls.add(op);
      final f = byOp[op];
      return f == null ? http.Response('', 500) : f();
    });

void main() {
  group('격자 변환', () {
    test('서울시청은 (60, 127)', () {
      expect(toKmaGrid(37.5665, 126.9780), const KmaGrid(60, 127));
    });
    test('부산시청은 (98, 76)', () {
      expect(toKmaGrid(35.1796, 129.0756), const KmaGrid(98, 76));
    });
  });

  group('발표 시각', () {
    test('실황은 40분 전이면 앞 시각', () {
      expect(ncstBaseTime(kst(10, 39)), kst(9, 0));
      expect(ncstBaseTime(kst(10, 40)), kst(10, 0));
    });
    test('예보는 45분 전이면 앞 30분', () {
      expect(fcstBaseTime(kst(10, 44)), kst(9, 30));
      expect(fcstBaseTime(kst(10, 45)), kst(10, 30));
    });
    test('자정 직후는 전날로 넘어간다', () {
      expect(ncstBaseTime(kst(0, 10)), DateTime.utc(2026, 10, 2, 23));
    });
    test('다음 갱신은 둘 중 늦은 쪽 — 대략 매시 45분', () {
      expect(weatherExpiry(kst(10, 10)), kst(10, 45));
      expect(weatherExpiry(kst(10, 46)), kst(11, 45));
    });
  });

  test('PTY·SKY 코드 매핑', () {
    expect(conditionFromPty('0'), isNull);
    expect(conditionFromPty('5'), WeatherCondition.rain);
    expect(conditionFromPty('6'), WeatherCondition.rainSnow);
    expect(conditionFromPty('7'), WeatherCondition.snow);
    expect(conditionFromSky('1'), WeatherCondition.clear);
    expect(conditionFromSky('3'), WeatherCondition.partlyCloudy);
    expect(conditionFromSky('4'), WeatherCondition.cloudy);
  });

  group('KmaWeatherService', () {
    test('기온은 반올림, 상태는 가장 이른 예보 시각의 SKY', () async {
      final calls = <String>[];
      final svc = KmaWeatherService(
        client: _client({
          'getUltraSrtNcst': () => http.Response(_ncst(), 200),
          'getUltraSrtFcst': () => http.Response(_fcst(), 200),
        }, calls),
        now: () => kst(10, 50),
      );
      final f = await svc.fetch(const KmaGrid(60, 127));
      expect(f.reading.temperature, 16);
      expect(f.reading.condition, WeatherCondition.clear); // 11시(1) > 12시(4)
      expect(f.expiresAt, kst(11, 45));
    });

    test('비가 오면 예보를 부르지 않는다', () async {
      final calls = <String>[];
      final svc = KmaWeatherService(
        client: _client({
          'getUltraSrtNcst': () => http.Response(_ncst(pty: '1'), 200),
        }, calls),
        now: () => kst(10, 50),
      );
      final f = await svc.fetch(const KmaGrid(60, 127));
      expect(f.reading.condition, WeatherCondition.rain);
      expect(calls, ['getUltraSrtNcst']);
    });

    test('예보만 실패하면 기온만, 10분 뒤 다시', () async {
      final svc = KmaWeatherService(
        client: _client({
          'getUltraSrtNcst': () => http.Response(_ncst(), 200),
        }, []),
        now: () => kst(10, 50),
      );
      final f = await svc.fetch(const KmaGrid(60, 127));
      expect(f.reading.condition, isNull);
      expect(f.expiresAt, kst(11, 0));
    });

    test('키 오류는 XML 로 온다 → 실패', () async {
      final svc = KmaWeatherService(
        client: _client({
          'getUltraSrtNcst': () => http.Response(
              '<OpenAPI_ServiceResponse><cmmMsgHeader>SERVICE_KEY_IS_NOT_REGISTERED_ERROR</cmmMsgHeader></OpenAPI_ServiceResponse>',
              200),
        }, []),
      );
      expect(svc.fetch(const KmaGrid(60, 127)), throwsA(isA<FormatException>()));
    });
  });

  group('WeatherCache', () {
    test('갱신 시각 전·같은 격자면 다시 부르지 않는다', () async {
      final calls = <String>[];
      var now = kst(10, 50);
      final cache = WeatherCache(
        KmaWeatherService(
          client: _client({
            'getUltraSrtNcst': () => http.Response(_ncst(), 200),
            'getUltraSrtFcst': () => http.Response(_fcst(), 200),
          }, calls),
          now: () => now,
        ),
        now: () => now,
      );
      const seoul = KmaGrid(60, 127);
      await cache.get(seoul);
      now = kst(11, 44);
      await cache.get(seoul);
      expect(calls.length, 2); // 첫 번째 한 번(실황+예보)뿐

      now = kst(11, 46);
      await cache.get(seoul);
      expect(calls.length, 4); // 갱신 시각이 지나 다시

      await cache.get(const KmaGrid(98, 76));
      expect(calls.length, 6); // 격자가 바뀌어 다시
    });

    test('실패하면 null, 실패는 기억하지 않는다', () async {
      final calls = <String>[];
      var fail = true;
      final cache = WeatherCache(
        KmaWeatherService(
          client: _client({
            'getUltraSrtNcst': () =>
                fail ? http.Response('', 503) : http.Response(_ncst(), 200),
            'getUltraSrtFcst': () => http.Response(_fcst(), 200),
          }, calls),
          now: () => kst(10, 50),
        ),
        now: () => kst(10, 50),
      );
      expect(await cache.get(const KmaGrid(60, 127)), isNull);
      fail = false;
      expect((await cache.get(const KmaGrid(60, 127)))?.temperature, 16);
    });
  });
}
