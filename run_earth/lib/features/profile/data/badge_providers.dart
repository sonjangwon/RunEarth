import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_badge.dart';
import '../../../core/models/enums.dart';
import '../../home/data/home_providers.dart';
import '../../home/data/journey_master.dart';

/// 여정 마일스톤 배지 — 정본: badges.md 3 ("전체 누적 거리가 해당 도시의
/// cumulativeKm 도달").
///
/// 마스터 경로(journey_master.dart)의 22개 도시(국내 4 + 해외 G20 수도 18)에서 그대로 생성한다. 지급 판정에
/// 서버가 필요 없다 — 로컬 기록 합계만으로 결정되는 파생값이라 저장하지 않고
/// 매번 계산한다(`User.streak` 을 서버에 두지 않은 것과 같은 이유).
///
/// 기준값은 홈 여정과 **같은** 절대 위치(`journeyProgressProvider`)를 쓴다.
/// 시작 도시가 서울이 아니게 되면(journey.md 2) 두 화면이 어긋나지 않도록.
///
/// 테마 코스·월별 마라톤 배지는 여기 없다 — 테마 러닝과 온라인 마라톤 기능
/// 자체가 아직 없어 지급 조건을 판정할 데이터가 존재하지 않는다. 해당 기능이
/// 생길 때 같은 방식으로 합친다(badges.md 4 의 "총 배지 수는 동적 계산").
final milestoneBadgesProvider = Provider<List<AppBadge>>((ref) {
  final absoluteKm = ref.watch(journeyProgressProvider).absolutePositionKm;
  return [
    for (final city in journeyRoute)
      AppBadge(
        id: 'ms-${city.name}',
        type: BadgeType.milestoneCity,
        emoji: cityBadgeEmoji(city.name),
        // 출발점(0km)만 '출발', 나머지는 '도착'.
        name: '${city.name} ${city.cumulativeKm == 0 ? '출발' : '도착'}',
        earned: absoluteKm >= city.cumulativeKm,
        // badges.md 5 는 refId 를 MasterCity.id 로 규정하나 JourneyCity 에 id 가
        // 없다. 도시 id 를 새로 지어내지 않고 이름을 그대로 쓴다
        // (마스터 경로 안에서 이름은 고유하다).
        refId: city.name,
      ),
  ];
});

/// 도시별 배지 이모지.
///
/// 배지 아이콘은 콘텐츠 제작 대상(feature-backlog.md "범위 밖")이라 임의로
/// 정하지 않는다. 기존에 정해져 있던 6개만 쓰고 나머지는 공통 기본값을 쓴다
/// (2026-09-13 결정). 에셋이 나오면 이 표만 교체하면 된다.
String cityBadgeEmoji(String cityName) => _cityEmoji[cityName] ?? '📍';

const _cityEmoji = <String, String>{
  '서울': '🏙',
  '인천': '🌊',
  '전주': '🌾',
  '부산': '⚓',
  '베이징': '🏯',
  '도쿄': '🗼',
};
