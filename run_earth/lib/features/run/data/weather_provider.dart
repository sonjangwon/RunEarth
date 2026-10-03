import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/weather.dart';
import '../../../services/weather/kma_grid.dart';
import '../../../services/weather/kma_weather_service.dart';
import 'run_tracker.dart';

/// 받아온 날씨를 다음 갱신 시각까지 들고 있는다. 앱이 켜져 있는 동안만
/// 기억한다(메모리) — 다시 켜면 한 번 새로 받는다(2026-10-03 사용자 결정).
class WeatherCache {
  WeatherCache(this._service, {DateTime Function()? now}) : _now = now ?? kstNow;

  final KmaWeatherService _service;
  final DateTime Function() _now;

  KmaGrid? _grid;
  WeatherFetch? _last;
  Future<WeatherReading?>? _inFlight;

  /// 같은 격자이고 아직 갱신 시각 전이면 받아둔 값을, 아니면 새로 받는다.
  /// 실패하면 null — 화면은 "불러오지 못했어요". **실패는 기억하지 않는다.**
  Future<WeatherReading?> get(KmaGrid grid) {
    final last = _last;
    if (grid == _grid && last != null && _now().isBefore(last.expiresAt)) {
      return Future.value(last.reading);
    }
    // 탭을 빠르게 오가도 한 번만 부른다.
    return _inFlight ??= _fetch(grid).whenComplete(() => _inFlight = null);
  }

  Future<WeatherReading?> _fetch(KmaGrid grid) async {
    try {
      final fetched = await _service.fetch(grid);
      _grid = grid;
      _last = fetched;
      return fetched.reading;
    } catch (e) {
      // 예외 메시지에 요청 URL(=인증키)이 들어갈 수 있어 타입만 남긴다.
      debugPrint('[weather] 불러오기 실패: ${e.runtimeType}');
      return null;
    }
  }
}

final weatherCacheProvider =
    Provider<WeatherCache>((ref) => WeatherCache(KmaWeatherService()));

/// 출발 전 날씨 카드의 값. null 이면 "불러오지 못했어요".
///
/// 위치는 출발 전 지도와 같은 값(`RunSessionState.current`, 기기의 마지막
/// 위치)을 쓴다. **위치를 모르면 null** — 서울 날씨로 대신하지 않는다
/// (2026-10-03 사용자 결정). 권한을 묻는 시점은 START 라 처음 설치한 사람은
/// 첫 달리기 전까지 이 상태다.
///
/// 격자(5km) 단위로만 다시 계산한다 — 좌표가 조금 흔들려도 다시 부르지 않는다.
final weatherProvider = FutureProvider.autoDispose<WeatherReading?>((ref) async {
  if (!PublicDataConfig.isConfigured) return null;
  final grid = ref.watch(runTrackerProvider.select((s) {
    final p = s.current;
    return p == null ? null : toKmaGrid(p.lat, p.lng);
  }));
  if (grid == null) return null;
  return ref.read(weatherCacheProvider).get(grid);
});
