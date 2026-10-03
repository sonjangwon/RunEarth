import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/air_quality.dart';
import '../../../services/weather/air_korea_service.dart';
import '../../../services/weather/kma_grid.dart';
import '../../../services/weather/kma_weather_service.dart';
import 'run_tracker.dart';
import 'weather_provider.dart';

/// 받아온 미세먼지와 근접 측정소를 기억한다. 날씨(`WeatherCache`)와 같은
/// 규칙이다 — 메모리에만, 다음 측정값이 올라올 때까지, 실패는 기억하지 않는다.
///
/// 측정소는 위치가 안 바뀌니 **격자가 바뀔 때만** 다시 찾는다. 그래서
/// 평소에는 측정값 1건만 부른다(에어코리아 한도가 일 500건이라 아낀다).
class AirQualityCache {
  AirQualityCache(this._service, {DateTime Function()? now}) : _now = now ?? kstNow;

  final AirKoreaService _service;
  final DateTime Function() _now;

  KmaGrid? _grid;
  List<String>? _stations;
  AirFetch? _last;
  Future<AirQualityReading?>? _inFlight;

  /// [grid] 는 바뀌었는지 보는 열쇠, [lat]·[lng] 는 측정소를 찾을 좌표.
  Future<AirQualityReading?> get(KmaGrid grid, double lat, double lng) {
    final last = _last;
    if (grid == _grid && last != null && _now().isBefore(last.expiresAt)) {
      return Future.value(last.reading);
    }
    return _inFlight ??=
        _fetch(grid, lat, lng).whenComplete(() => _inFlight = null);
  }

  Future<AirQualityReading?> _fetch(KmaGrid grid, double lat, double lng) async {
    try {
      if (grid != _grid || _stations == null) {
        _stations = await _service.nearbyStations(toTm(lat, lng));
        _grid = grid;
        _last = null;
      }
      final fetched = await _service.fetch(_stations!);
      _last = fetched;
      return fetched.reading;
    } catch (e) {
      // 예외 메시지에 요청 URL(=인증키)이 들어갈 수 있어 타입만 남긴다.
      debugPrint('[air] 불러오기 실패: ${e.runtimeType}');
      return null;
    }
  }
}

final airQualityCacheProvider =
    Provider<AirQualityCache>((ref) => AirQualityCache(AirKoreaService()));

/// 출발 전 미세먼지 카드의 값(PM10). null 이면 "불러오지 못했어요".
///
/// 에어코리아 연동(2026-10-03). 그전에는 Figma 샘플(`보통` · 42)을 채워두고
/// 있었다. 위치·실패 처리는 날씨와 같다 — 규칙은 `run-flow.md` 10.
final airQualityProvider =
    FutureProvider.autoDispose<AirQualityReading?>((ref) async {
  if (!PublicDataConfig.isConfigured) return null;
  final grid = ref.watch(prerunGridProvider);
  if (grid == null) return null;
  final p = ref.read(runTrackerProvider).current;
  if (p == null) return null;
  return ref.read(airQualityCacheProvider).get(grid, p.lat, p.lng);
});
