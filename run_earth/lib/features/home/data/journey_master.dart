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
    this.imageKey = '',
  });

  /// 도시명 (표시용).
  final String name;

  /// 서울시청(0km) 기준 누적 거리.
  final double cumulativeKm;

  /// 국내 시작 후보 도시 여부 (journey.md §2).
  final bool isStartCandidate;

  /// 홈 여정 카드 배경에 쓸 랜드마크 이미지 (journey.md §4).
  ///
  /// Unsplash 사진 ID — `unsplashUrl()` 이 URL 로 조립한다. **개발용 임시**다:
  /// journey.md §4 는 최종 에셋을 콘텐츠팀 소싱으로 정해뒀고, 실사진이냐
  /// 일러스트냐도 아직 [미확정]이다. 여기 값은 그때 통째로 갈린다.
  ///
  /// 빈 문자열이면 배경 없이 카드의 기본 그라디언트만 보인다(§7 "조용한 폴백").
  final String imageKey;
}

/// 고정 마스터 경로 (서울 → 부에노스아이레스). 정본: journey.md §5.
///
/// 로마/파리는 반올림 동률(8,966km)이나 journey.md §3 표 순서(로마→파리)를 따른다.
/// (§7 "정밀 계산 후 순서 확정 권장"은 미해결이나 홈 표시엔 영향 미미)
/// 이미지는 2026-09-26 에 Unsplash 에서 **검색해 고르고 URL 로딩까지 확인**한
/// 것이다(22개 전부 200). 사진 ID 만 보고 추측하지 않았다 — 도시명 검색은
/// 무관한 사진을 자주 섞어 낸다(`incheon` -> 미국 베닝턴 기념비,
/// `gwangan bridge busan` -> 금문교).
///
/// 주석의 `[확실]`/`[추정]` 은 사진 설명(alt)으로 판단한 것이다. **[추정]은
/// 실기기에서 눈으로 봐야 한다** — 도시 분위기는 맞지만 그 도시라고 단정할
/// 근거가 사진 설명에 없었다.
const journeyRoute = <JourneyCity>[
  // 국내 시작 후보 (§2)
  JourneyCity('서울', 0,
      isStartCandidate: true,
      imageKey: 'photo-1570191913384-7b4ff11716e7'), // [확실] 남산타워
  JourneyCity('인천', 27.0,
      isStartCandidate: true,
      imageKey: 'photo-1742644349414-11b2dd184284'), // [추정] 야간 조명 다리
  JourneyCity('전주', 194.3,
      isStartCandidate: true,
      imageKey: 'photo-1653230675261-fe00bde32c8e'), // [추정] 한옥 지붕 조감
  JourneyCity('부산', 325.1,
      isStartCandidate: true,
      imageKey: 'photo-1672671187899-a10f547341f1'), // [확실] 감천문화마을
  // 해외 구간 — G20 수도 (§3)
  JourneyCity('베이징', 952,
      imageKey: 'photo-1590301729964-23833732ee04'), // [추정] 붉은 사원
  JourneyCity('도쿄', 1149,
      imageKey: 'photo-1513407030348-c983a97b98d8'), // [확실] 도쿄타워 황혼
  JourneyCity('뉴델리', 4687,
      imageKey: 'photo-1587474260584-136574528ed5'), // [확실] 인디아 게이트
  JourneyCity('자카르타', 5296,
      imageKey: 'photo-1635924201021-e8ae80c2bdc0'), // [확실] 모나스 기념탑
  JourneyCity('모스크바', 6606,
      imageKey: 'photo-1576753092415-f4c74e4edc99'), // [확실] 성 바실리 대성당
  JourneyCity('리야드', 7550,
      imageKey: 'photo-1694018359679-49465b4c0d61'), // [확실] 킹덤 센터
  JourneyCity('앙카라', 7745,
      imageKey: 'photo-1771738841091-49dda284e8fe'), // [추정] 대형 모스크
  JourneyCity('베를린', 8127,
      imageKey: 'photo-1587330979470-3595ac045ab0'), // [확실] 브란덴부르크 문
  JourneyCity('캔버라', 8416,
      imageKey: 'photo-1672264597620-d792bb6de88d'), // [추정] 국회의사당
  JourneyCity('런던', 8857,
      imageKey: 'photo-1519773483179-fa089c182a4a'), // [확실] 밤의 빅벤
  JourneyCity('로마', 8966,
      imageKey: 'photo-1663143050642-69240b347b2b'), // [확실] 콜로세움
  JourneyCity('파리', 8966,
      imageKey: 'photo-1626985249964-4fa612df0274'), // [확실] 야간 에펠탑
  JourneyCity('오타와', 10512,
      imageKey: 'photo-1635394075897-38bd158f0b8e'), // [추정] 언덕 위 의사당
  JourneyCity('워싱턴 D.C.', 11164,
      imageKey: 'photo-1594581979864-36977b15d0dc'), // [확실] 미 국회의사당
  JourneyCity('멕시코시티', 12052,
      imageKey: 'photo-1776291691285-74ee376be883'), // [확실] 독립 천사 기념비
  JourneyCity('프리토리아', 12446,
      imageKey: 'photo-1646502408270-7eb6e19681dd'), // [추정] 언덕에서 본 시가
  JourneyCity('브라질리아', 17546,
      imageKey: 'photo-1686150360446-ee7eae8026cf'), // [추정] 브라질리아 대성당
  JourneyCity('부에노스아이레스', 19432,
      imageKey: 'photo-1672588371953-2accc9eb0d01'), // [확실] 오벨리스코
];

/// 시작 도시 인덱스(기본값 = 서울).
///
/// 시작 도시 배정은 GPS/인증에 의존하나 아직 미구현 → journey.md 의 "위치 거부 시
/// 서울 기본값" 폴백을 임시로 사용한다(2026-08-30 결정). 인증 도입 시 교체.
const kDefaultStartCityIndex = 0;
