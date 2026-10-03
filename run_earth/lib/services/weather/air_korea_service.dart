import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;

import '../../core/models/air_quality.dart';
import 'kma_weather_service.dart';

/// 에어코리아 근접 측정소 조회가 받는 TM 좌표(m).
class TmPoint {
  const TmPoint(this.x, this.y);
  final double x;
  final double y;
}

/// 위경도(WGS84) → TM 중부원점(GRS80, 원점 38°N 127°E, 가산 200000/500000).
///
/// 횡메르카토르 표준식(Snyder). 2026-10-03 실제 API 로 검증했다 — 서울시청은
/// 중구 측정소(0.5km), 부산시청은 연산동 측정소(0.3km)가 가장 가깝게 나온다.
TmPoint toTm(double lat, double lng) {
  const a = 6378137.0;
  const f = 1 / 298.257222101;
  const e2 = f * (2 - f);
  const ep2 = e2 / (1 - e2);
  const lat0 = 38.0 * math.pi / 180;
  const lon0 = 127.0 * math.pi / 180;
  const fe = 200000.0;
  const fn = 500000.0;

  double meridian(double p) =>
      a *
      ((1 - e2 / 4 - 3 * e2 * e2 / 64 - 5 * e2 * e2 * e2 / 256) * p -
          (3 * e2 / 8 + 3 * e2 * e2 / 32 + 45 * e2 * e2 * e2 / 1024) *
              math.sin(2 * p) +
          (15 * e2 * e2 / 256 + 45 * e2 * e2 * e2 / 1024) * math.sin(4 * p) -
          (35 * e2 * e2 * e2 / 3072) * math.sin(6 * p));

  final p = lat * math.pi / 180;
  final l = lng * math.pi / 180;
  final sinP = math.sin(p);
  final n = a / math.sqrt(1 - e2 * sinP * sinP);
  final t = math.tan(p) * math.tan(p);
  final c = ep2 * math.cos(p) * math.cos(p);
  final aa = (l - lon0) * math.cos(p);

  final x = fe +
      n *
          (aa +
              (1 - t + c) * math.pow(aa, 3) / 6 +
              (5 - 18 * t + t * t + 72 * c - 58 * ep2) * math.pow(aa, 5) / 120);
  final y = fn +
      (meridian(p) -
          meridian(lat0) +
          n *
              math.tan(p) *
              (aa * aa / 2 +
                  (5 - t + 9 * c + 4 * c * c) * math.pow(aa, 4) / 24 +
                  (61 - 58 * t + t * t + 600 * c - 330 * ep2) *
                      math.pow(aa, 6) /
                      720));
  return TmPoint(x, y);
}

/// 측정소 한 곳의 최신 PM10.
class StationReading {
  const StationReading(this.pm10, this.dataTime);

  /// ㎍/㎥. 점검·통신장애로 값이 없으면 null.
  final int? pm10;

  /// 측정 시각(KST). 에어코리아는 자정을 `24:00` 으로 적는다.
  final DateTime dataTime;
}

/// 받아온 미세먼지와, 그 값을 언제까지 다시 쓸지.
class AirFetch {
  const AirFetch(this.reading, this.expiresAt);
  final AirQualityReading reading;
  final DateTime expiresAt;
}

/// 다음 측정값이 올라오는 시각. 매시 측정값이 약 15분 뒤에 올라온다.
/// 이미 지났으면(발표가 늦는 중) 10분 뒤 다시 본다 — 연달아 부르지 않게.
DateTime airExpiry(DateTime dataTime, DateTime kst) {
  final next = dataTime.add(const Duration(hours: 1, minutes: 15));
  final floor = kst.add(const Duration(minutes: 10));
  return next.isAfter(floor) ? next : floor;
}

/// `2026-10-03 10:00` → DateTime(KST 벽시계). `24:00` 은 다음 날 0시.
DateTime parseAirKoreaTime(String s) {
  final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2})$').firstMatch(s);
  if (m == null) throw FormatException('dataTime $s');
  int g(int i) => int.parse(m.group(i)!);
  return DateTime.utc(g(1), g(2), g(3)).add(Duration(hours: g(4), minutes: g(5)));
}

/// 에어코리아 측정소정보 + 대기오염정보. 인증키는 기상청과 같다.
class AirKoreaService {
  AirKoreaService({http.Client? client, DateTime Function()? now})
      : _client = client ?? http.Client(),
        _now = now ?? kstNow;

  static const _base = 'https://apis.data.go.kr/B552584';

  final http.Client _client;
  final DateTime Function() _now;

  /// 가까운 순 측정소 이름(최대 3곳).
  Future<List<String>> nearbyStations(TmPoint tm) async {
    final items = await _items('MsrstnInfoInqireSvc/getNearbyMsrstnList', {
      'tmX': tm.x.toStringAsFixed(1),
      'tmY': tm.y.toStringAsFixed(1),
      'ver': '1.1',
    });
    final sorted = [...items]
      ..sort((a, b) => (num.tryParse('${a['tm']}') ?? 1e9)
          .compareTo(num.tryParse('${b['tm']}') ?? 1e9));
    return [for (final i in sorted) '${i['stationName']}'];
  }

  /// 측정소의 가장 최근 측정값.
  Future<StationReading> latest(String station) async {
    final items =
        await _items('ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty', {
      'stationName': station,
      'dataTerm': 'DAILY',
      'numOfRows': '1',
      'pageNo': '1',
      'ver': '1.0',
    });
    if (items.isEmpty) throw const FormatException('측정값 없음');
    final item = items.first;
    // 점검·장애 때는 값이 '-' 이거나 비어 있다.
    final pm10 = int.tryParse('${item['pm10Value']}'.trim());
    return StationReading(pm10, parseAirKoreaTime('${item['dataTime']}'));
  }

  /// 가장 가까운 측정소부터 값이 있는 곳을 찾는다(앞 두 곳까지).
  Future<AirFetch> fetch(List<String> stations) async {
    for (final station in stations.take(2)) {
      final r = await latest(station);
      final pm10 = r.pm10;
      if (pm10 == null) continue;
      return AirFetch(
        AirQualityReading(level: AirQuality.fromPm10(pm10), value: pm10),
        airExpiry(r.dataTime, _now()),
      );
    }
    throw const FormatException('가까운 측정소에 값이 없음');
  }

  Future<List<Map<String, dynamic>>> _items(
      String path, Map<String, String> params) async {
    final uri = Uri.parse('$_base/$path').replace(queryParameters: {
      'serviceKey': PublicDataConfig.serviceKey,
      'returnType': 'json',
      ...params,
    });
    final res = await _client.get(uri).timeout(KmaWeatherService.timeout);
    if (res.statusCode != 200) throw HttpStatusError(res.statusCode);
    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    final response = body['response'] as Map<String, dynamic>;
    final code = (response['header'] as Map<String, dynamic>)['resultCode'];
    if (code != '00') throw FormatException('resultCode $code');
    final items = (response['body'] as Map<String, dynamic>)['items'] as List<dynamic>;
    return items.cast<Map<String, dynamic>>();
  }
}
