import 'package:json_annotation/json_annotation.dart';

/// 정해진 선택지(enum)들. JSON 직렬화 시 저장되는 문자열은 @JsonValue 로 고정.
/// 정본: `docs/Run Earth_기능정의서.md` 6-1, 각 `docs/features/*.md`.

/// 기록에 저장되는 러닝 타입 (기능정의서 6-1).
enum RecordType {
  @JsonValue('일반')
  normal,
  @JsonValue('테마')
  theme,
  @JsonValue('온라인')
  online,
}

/// 달리기 진입 시 결정되는 러닝 타입 (기능정의서 3-2).
enum RunType {
  @JsonValue('일반 러닝')
  normal,
  @JsonValue('테마 러닝')
  theme,
  @JsonValue('온라인 마라톤')
  online,
}

/// 러닝 세션 상태 머신 (기능정의서 4-2-C).
enum RunPhase { idle, running, paused, stopped }

/// 소셜 로그인 제공자 (auth-onboarding.md 6).
enum AuthProvider {
  @JsonValue('kakao')
  kakao,
  @JsonValue('naver')
  naver,
  @JsonValue('google')
  google,
}

/// 러닝 기록 대표 이미지 종류 (run-flow.md 6).
enum CoverImageType {
  @JsonValue('photo')
  photo,
  @JsonValue('route')
  route,
}

/// 기록 출처 (wearable-sync.md 6).
enum RunSource {
  @JsonValue('app')
  app,
  @JsonValue('apple_health')
  appleHealth,
  @JsonValue('samsung_health')
  samsungHealth,
}

/// 배지 종류 (badges.md 5).
enum BadgeType {
  @JsonValue('theme_course')
  themeCourse,
  @JsonValue('marathon_monthly')
  marathonMonthly,
  @JsonValue('milestone_city')
  milestoneCity,
}

/// 위치 권한 상태 (global-states.md 6).
enum LocationPermissionState {
  @JsonValue('granted')
  granted,
  @JsonValue('denied')
  denied,
  @JsonValue('not_determined')
  notDetermined,
}
