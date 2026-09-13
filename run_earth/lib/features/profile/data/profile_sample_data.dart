import '../../../core/models/app_badge.dart';
import '../../../core/models/enums.dart';

/// 임시 샘플 (Figma App.tsx BADGES 기반).
/// 통계는 로컬 DB 집계(`homeStatsProvider`)로 대체 완료.
/// 배지는 아직 샘플 — 서버/DB 지급으로 대체 예정(badges.md).

/// 아바타 URL 이 없거나 만료됐을 때의 폴백 이모지.
const profileAvatar = '🏃';
const appVersion = 'v1.12.2';

const sampleBadges = <AppBadge>[
  // 여정 마일스톤
  AppBadge(id: 'ms-seoul', type: BadgeType.milestoneCity, emoji: '🏙', name: '서울 출발', earned: true, refId: 'seoul'),
  AppBadge(id: 'ms-incheon', type: BadgeType.milestoneCity, emoji: '🌊', name: '인천 도착', earned: true, refId: 'incheon'),
  AppBadge(id: 'ms-jeonju', type: BadgeType.milestoneCity, emoji: '🌾', name: '전주 도착', earned: true, refId: 'jeonju'),
  AppBadge(id: 'ms-busan', type: BadgeType.milestoneCity, emoji: '⚓', name: '부산 도착', earned: false, refId: 'busan'),
  AppBadge(id: 'ms-beijing', type: BadgeType.milestoneCity, emoji: '🏯', name: '베이징 도착', earned: false, refId: 'beijing'),
  AppBadge(id: 'ms-tokyo', type: BadgeType.milestoneCity, emoji: '🗼', name: '도쿄 도착', earned: false, refId: 'tokyo'),
  // 테마 코스 완주
  AppBadge(id: 'th-1', type: BadgeType.themeCourse, emoji: '🐟', name: '붕어빵런 완주', earned: false, refId: 'theme-1'),
  AppBadge(id: 'th-2', type: BadgeType.themeCourse, emoji: '🌉', name: '한강야경런 완주', earned: false, refId: 'theme-2'),
  AppBadge(id: 'th-3', type: BadgeType.themeCourse, emoji: '🗼', name: 'N서울타워런 완주', earned: false, refId: 'theme-3'),
  // 온라인 마라톤
  AppBadge(id: 'mr-1', type: BadgeType.marathonMonthly, emoji: '🥇', name: '7월 하프마라톤', earned: false, refId: 'm-1'),
  AppBadge(id: 'mr-2', type: BadgeType.marathonMonthly, emoji: '🥈', name: '6월 10K 마라톤', earned: false, refId: 'm-2'),
];
