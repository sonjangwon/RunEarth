/// 미세먼지 4단계. 정본: `기능정의서` 4-2 섹션 B.
///
/// 문서가 정의하는 건 **4단계와 배경색 활성 조건**까지다. 단계별 색은
/// `AppColors` 의 미세먼지 섹션에 있다(에어코리아 표준 색계, 2026-09-20 확정).
enum AirQuality {
  good('좋음', 1),
  moderate('보통', 2),
  bad('나쁨', 3),
  veryBad('매우나쁨', 4);

  const AirQuality(this.label, this.step);

  /// 화면에 그대로 쓰는 한글 표기.
  final String label;

  /// 4단계 중 몇 번째인지(1~4). 상태 바 채움 칸 수로 쓴다.
  final int step;

  /// 카드 배경색을 켤 단계인지 — 문서상 `나쁨`·`매우나쁨` 만 해당한다.
  /// `좋음`·`보통` 은 중립(무채색) 배경을 유지한다.
  bool get needsAlertBackground => this == bad || this == veryBad;
}

/// 미세먼지 측정값 한 건 — 단계 + 농도.
///
/// **왜 단계만으로는 부족한가**: Figma 의 미세먼지 카드는 그라데이션 게이지
/// 위에 흰 마커를 놓는데, 그 위치가 `농도 / 150` 이다(`App.tsx` 685줄).
/// 4단계만 있으면 마커를 네 자리에만 찍을 수 있어, 실제 농도를 이어서
/// 보여주려고 만든 게이지의 의미가 없어진다.
///
/// 에어코리아 API 도 PM 수치를 주므로 **연동하면 그대로 채워진다.**
class AirQualityReading {
  const AirQualityReading({required this.level, required this.value});

  /// 4단계 중 어디인가.
  final AirQuality level;

  /// 미세먼지 농도(㎍/㎥). 화면에는 단위 없이 숫자만 보인다.
  final int value;

  /// 게이지 위 마커 위치(0~1). 상한 150 은 Figma 기준이다 —
  /// 그 위는 어차피 '매우나쁨' 이라 더 밀어봐야 구분이 안 된다.
  double get gaugeRatio => (value / 150).clamp(0.0, 1.0);
}
