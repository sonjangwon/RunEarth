/// 여정 마스터 경로 (홈 화면 진행률 계산용).
///
/// 정본: `docs/features/journey.md` §5 전체 마스터 경로.
/// 도시 순서는 서울시청 기준 누적거리(cumulativeKm) 오름차순으로 고정.
///
/// 홈 계산엔 이름 + 누적거리만 필요하다. 해외 도시는 journey.md 에 좌표(lat/lng)가
/// 없으므로(§3 는 누적거리만 제공) 좌표는 담지 않는다 — 추측하지 않음.
/// 좌표가 필요한 기능(배지 지급·시작도시 GPS 배정)이 생기면 그때 확장한다.
library;

/// 마스터 경로 위의 도시 1개.
class JourneyCity {
  const JourneyCity(
    this.name,
    this.cumulativeKm, {
    this.isStartCandidate = false,
  });

  /// 도시명 (표시용).
  final String name;

  /// 서울시청(0km) 기준 누적 거리.
  final double cumulativeKm;

  /// 국내 시작 후보 도시 여부 (journey.md §2).
  final bool isStartCandidate;
}

/// 고정 마스터 경로 (서울 → 부에노스아이레스). 정본: journey.md §5.
///
/// 로마/파리는 반올림 동률(8,966km)이나 journey.md §3 표 순서(로마→파리)를 따른다.
/// (§7 "정밀 계산 후 순서 확정 권장"은 미해결이나 홈 표시엔 영향 미미)
const journeyRoute = <JourneyCity>[
  // 국내 시작 후보 (§2)
  JourneyCity('서울', 0, isStartCandidate: true),
  JourneyCity('인천', 27.0, isStartCandidate: true),
  JourneyCity('전주', 194.3, isStartCandidate: true),
  JourneyCity('부산', 325.1, isStartCandidate: true),
  // 해외 구간 — G20 수도 (§3)
  JourneyCity('베이징', 952),
  JourneyCity('도쿄', 1149),
  JourneyCity('뉴델리', 4687),
  JourneyCity('자카르타', 5296),
  JourneyCity('모스크바', 6606),
  JourneyCity('리야드', 7550),
  JourneyCity('앙카라', 7745),
  JourneyCity('베를린', 8127),
  JourneyCity('캔버라', 8416),
  JourneyCity('런던', 8857),
  JourneyCity('로마', 8966),
  JourneyCity('파리', 8966),
  JourneyCity('오타와', 10512),
  JourneyCity('워싱턴 D.C.', 11164),
  JourneyCity('멕시코시티', 12052),
  JourneyCity('프리토리아', 12446),
  JourneyCity('브라질리아', 17546),
  JourneyCity('부에노스아이레스', 19432),
];

/// 시작 도시 인덱스(기본값 = 서울).
///
/// 시작 도시 배정은 GPS/인증에 의존하나 아직 미구현 → journey.md 의 "위치 거부 시
/// 서울 기본값" 폴백을 임시로 사용한다(2026-08-30 결정). 인증 도입 시 교체.
const kDefaultStartCityIndex = 0;
