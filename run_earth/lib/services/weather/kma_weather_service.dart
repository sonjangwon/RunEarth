import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/models/weather.dart';
import 'kma_grid.dart';

/// 공공데이터포털(data.go.kr) 인증키. 기상청·에어코리아가 **같은 키 하나**를 쓴다.
///
/// `env.json` 의 `DATA_GO_KR_KEY`(Decoding 키). 키가 앱에 박히는 것은
/// 2026-09-20 결정이다 — 노출 피해가 "호출 한도 소진" 수준이라 MVP 에서는
/// 프록시를 두지 않는다(`run-flow.md` 10-1).
class PublicDataConfig {
  const PublicDataConfig._();

  static const serviceKey = String.fromEnvironment('DATA_GO_KR_KEY');
  static bool get isConfigured => serviceKey.isNotEmpty;
}

/// 받아온 날씨와, 그 값을 언제까지 다시 쓸지.
class WeatherFetch {
  const WeatherFetch(this.reading, this.expiresAt);

  final WeatherReading reading;

  /// 한국 시각(KST) 기준. 이 시각 전에는 다시 불러도 같은 값이 온다.
  final DateTime expiresAt;
}

/// 한국 시각. 기기 시간대와 무관하게 기상청 발표 시각을 맞춘다.
/// (UTC 객체에 9시간을 더한 "벽시계 값"이다 — 비교·포맷에만 쓴다.)
DateTime kstNow() => DateTime.now().toUtc().add(const Duration(hours: 9));

/// 초단기실황 발표 시각. 매시 정각 자료가 **40분 이후**에 나온다.
DateTime ncstBaseTime(DateTime kst) {
  final hour = DateTime.utc(kst.year, kst.month, kst.day, kst.hour);
  return kst.minute < 40 ? hour.subtract(const Duration(hours: 1)) : hour;
}

/// 초단기예보 발표 시각. 매시 30분 자료가 **45분 이후**에 나온다.
DateTime fcstBaseTime(DateTime kst) {
  final half = DateTime.utc(kst.year, kst.month, kst.day, kst.hour, 30);
  return kst.minute < 45 ? half.subtract(const Duration(hours: 1)) : half;
}

/// 다음 자료가 나오는 시각 — 그 전까지는 받은 값을 다시 쓴다.
///
/// 실황(다음 정시 + 40분)과 예보(다음 30분 + 45분) 중 **늦은 쪽**이다.
/// 이른 쪽에 맞추면 둘이 5분 간격으로 갱신돼 시간당 두 번 부르게 된다.
/// 늦은 쪽이면 대략 매시 45분에 한 번이다(2026-10-03 사용자 결정 —
/// "고정 30분"이 아니라 "다음 갱신 시각까지").
DateTime weatherExpiry(DateTime kst) {
  final ncstNext = ncstBaseTime(kst).add(const Duration(hours: 1, minutes: 40));
  final fcstNext = fcstBaseTime(kst).add(const Duration(hours: 1, minutes: 15));
  return ncstNext.isAfter(fcstNext) ? ncstNext : fcstNext;
}

/// 기상청 단기예보 조회서비스. 한 번에 두 건을 부른다.
/// - 초단기실황(`getUltraSrtNcst`) — 기온(T1H)·강수형태(PTY). **실패하면 전체 실패.**
/// - 초단기예보(`getUltraSrtFcst`) — 하늘상태(SKY). 실패하면 기온만 보인다.
class KmaWeatherService {
  KmaWeatherService({http.Client? client, DateTime Function()? now})
      : _client = client ?? http.Client(),
        _now = now ?? kstNow;

  static const _base =
      'https://apis.data.go.kr/1360000/VilageFcstInfoService_2.0';

  /// 공공데이터 API 는 가끔 15초 넘게 응답이 없다(2026-10-03 측정소 API 에서 확인).
  /// 기다리게 두지 않고 "불러오지 못했어요" 로 넘긴다.
  static const timeout = Duration(seconds: 10);

  final http.Client _client;
  final DateTime Function() _now;

  Future<WeatherFetch> fetch(KmaGrid grid) async {
    final kst = _now();
    final ncst = await _items('getUltraSrtNcst', grid, ncstBaseTime(kst));
    final temp = _value(ncst, 'T1H', 'obsrValue');
    if (temp == null) throw const FormatException('T1H 없음');
    final rainCondition = conditionFromPty(_value(ncst, 'PTY', 'obsrValue'));

    WeatherCondition? sky;
    if (rainCondition == null) {
      try {
        final fcst = await _items('getUltraSrtFcst', grid, fcstBaseTime(kst));
        sky = conditionFromSky(_earliestSky(fcst));
      } catch (_) {
        sky = null; // 기온만 보인다.
      }
    }

    final reading = WeatherReading(
      temperature: double.parse(temp).round(),
      condition: rainCondition ?? sky,
    );
    // 하늘상태를 못 받았으면 오래 묶어두지 않는다 — 10분 뒤 다시 시도.
    final expiresAt = (rainCondition == null && sky == null)
        ? kst.add(const Duration(minutes: 10))
        : weatherExpiry(kst);
    return WeatherFetch(reading, expiresAt);
  }

  Future<List<Map<String, dynamic>>> _items(
      String op, KmaGrid grid, DateTime base) async {
    String two(int v) => v.toString().padLeft(2, '0');
    final uri = Uri.parse('$_base/$op').replace(queryParameters: {
      'serviceKey': PublicDataConfig.serviceKey,
      'pageNo': '1',
      'numOfRows': '60',
      'dataType': 'JSON',
      'base_date': '${base.year}${two(base.month)}${two(base.day)}',
      'base_time': '${two(base.hour)}${two(base.minute)}',
      'nx': '${grid.nx}',
      'ny': '${grid.ny}',
    });
    final res = await _client.get(uri).timeout(timeout);
    if (res.statusCode != 200) throw HttpStatusError(res.statusCode);
    // 키 오류 등은 200 + XML 로 온다 → jsonDecode 가 FormatException 을 던진다.
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final response = body['response'] as Map<String, dynamic>;
    final code = (response['header'] as Map<String, dynamic>)['resultCode'];
    if (code != '00') throw FormatException('resultCode $code');
    final items = ((response['body'] as Map<String, dynamic>)['items']
        as Map<String, dynamic>)['item'] as List<dynamic>;
    return items.cast<Map<String, dynamic>>();
  }

  static String? _value(
      List<Map<String, dynamic>> items, String category, String field) {
    for (final item in items) {
      if (item['category'] == category) return '${item[field]}';
    }
    return null;
  }

  /// 예보는 6시간 치가 온다. 지금과 가장 가까운(가장 이른) 시각의 SKY 를 쓴다.
  static String? _earliestSky(List<Map<String, dynamic>> items) {
    final skies = items.where((i) => i['category'] == 'SKY').toList()
      ..sort((a, b) => '${a['fcstDate']}${a['fcstTime']}'
          .compareTo('${b['fcstDate']}${b['fcstTime']}'));
    return skies.isEmpty ? null : '${skies.first['fcstValue']}';
  }
}

/// 강수형태(PTY) → 상태. 0(없음)이나 모르는 값이면 null.
/// 1 비 · 2 비/눈 · 3 눈 · 5 빗방울 · 6 빗방울눈날림 · 7 눈날림
WeatherCondition? conditionFromPty(String? pty) => switch (pty) {
      '1' || '5' => WeatherCondition.rain,
      '2' || '6' => WeatherCondition.rainSnow,
      '3' || '7' => WeatherCondition.snow,
      _ => null,
    };

/// 하늘상태(SKY) → 상태. 1 맑음 · 3 구름많음 · 4 흐림.
WeatherCondition? conditionFromSky(String? sky) => switch (sky) {
      '1' => WeatherCondition.clear,
      '3' => WeatherCondition.partlyCloudy,
      '4' => WeatherCondition.cloudy,
      _ => null,
    };

/// HTTP 상태 오류. **URL 을 담지 않는다** — URL 에 인증키가 들어 있어
/// 로그에 찍히면 키가 새어 나간다.
class HttpStatusError implements Exception {
  const HttpStatusError(this.statusCode);
  final int statusCode;

  @override
  String toString() => 'HttpStatusError($statusCode)';
}
