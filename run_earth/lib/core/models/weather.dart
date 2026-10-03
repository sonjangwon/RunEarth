/// 출발 전 날씨 카드의 날씨 상태. 정본: Figma `☀️ 28°C 맑음`(`figma-alignment.md` ⑨).
///
/// 비·눈은 기상청 초단기실황의 강수형태(PTY), 맑음·구름많음·흐림은
/// 초단기예보의 하늘상태(SKY)에서 온다. 비·눈이 오면 하늘상태보다 우선한다.
enum WeatherCondition {
  clear('맑음', '☀️'),
  partlyCloudy('구름많음', '⛅'),
  cloudy('흐림', '☁️'),
  rain('비', '🌧️'),
  rainSnow('비/눈', '🌨️'),
  snow('눈', '❄️');

  const WeatherCondition(this.label, this.emoji);

  final String label;
  final String emoji;
}

/// 날씨 한 건 — 지금 기온과 상태.
class WeatherReading {
  const WeatherReading({required this.temperature, this.condition});

  /// 기온(°C), 정수로 반올림. Figma 표기가 `28°C` 라 소수점을 보이지 않는다.
  final int temperature;

  /// 날씨 상태. 하늘상태 조회만 실패했으면 null — 기온만 보인다.
  final WeatherCondition? condition;
}
