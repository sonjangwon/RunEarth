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
