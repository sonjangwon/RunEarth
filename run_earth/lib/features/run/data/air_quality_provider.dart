import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/air_quality.dart';

/// 출발 전 화면의 미세먼지 값.
///
/// **아직 데이터 출처가 없다.** 미세먼지는 기상청이 아니라 에어코리아
/// (한국환경공단) API 소관이고, API 키가 나오기 전이다(2026-09-20 노트 §6).
///
/// `null` 은 "불러오지 못했어요" 상태를 뜻한다 — `offline-handling.md` §2-A 가
/// 날씨/미세먼지 카드에 지정한 바로 그 상태다. 값을 지어내는 것보다 없다고
/// 말하는 편이 정직하고, 연동할 때 이 provider 만 갈아끼우면 된다.
///
/// 붙일 때 같이 할 것: 위경도 → TM 좌표 → 근접 측정소 조회, 실패 시
/// "다시 시도" 버튼(`global-states.md` 인라인 에러 패턴).
final airQualityProvider = Provider<AirQuality?>((ref) => null);
