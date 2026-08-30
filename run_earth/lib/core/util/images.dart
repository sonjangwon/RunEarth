/// Unsplash 스톡 이미지 URL 빌더 (개발용 임시 이미지).
///
/// Figma 디자인(App.tsx)이 목업에 쓰던 Unsplash 스톡 사진을 그대로 사용한다.
/// **임시**다 — 실서비스용 최종 에셋(라이선스 확인 스톡/자체 제작)으로 교체 예정.
/// (journey.md §4 이미지 방침 [미확정]) key 예: "photo-1534430480872-...".
String unsplashUrl(String key, {int w = 600, int h = 400}) {
  if (key.isEmpty) return '';
  return 'https://images.unsplash.com/$key?w=$w&h=$h&fit=crop&auto=format';
}
