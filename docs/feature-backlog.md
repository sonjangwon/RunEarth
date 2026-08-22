# Run Earth — 전체 기능 백로그 & 정의 현황

> ✅ 앱 이름: **Run Earth**로 확정 및 코드 레벨 반영 완료 (2026-08-15) —
> `index.html`, `package.json`, `README.md`, Drive 폴더명까지 변경됨.
> **단, Figma 파일 자체의 이름(`RunnuR_UIUX`)은 Figma 프로젝트 안에서
> 직접 변경 필요.**
>
> 이 문서는 `RUNNA_KR_기능정의서.md`(2026-08-05 기준)를 감사(audit)한 결과입니다.
> 상태 범례: 🟢 상세 정의됨 · 🟡 부분 정의(구멍 있음) · 🔴 전혀 없음

---

## 🎉 6개 탭 모두 기능 정의 완료 + 여정 마스터 경로 전체 확정

---

## 1. 인증 / 온보딩 — ✅ `features/auth-onboarding.md`, `features/session-policy.md`

| 항목 | 상태 |
|---|---|
| 스플래시 / 로그인 화면 | 🟡 플로우 확정, 비주얼 디자인은 개발과 병행 |
| 회원가입 / 온보딩 / 로그아웃 / 세션 정책 / 닉네임 변경 | 🟢 전부 확정 |

## 2. 홈 (Home) — ✅ `features/journey.md`, `features/streak.md`, `features/home.md`

| 항목 | 상태 |
|---|---|
| 주간 스트릭 UI / CTA / 인사말 / 빈 상태 | 🟢 확정 |
| 여정(누적거리 마일스톤) | 🟢 **전체 마스터 경로 확정** — 국내(서울0/인천27/전주194/부산325km) + 해외 G20 수도 18개(베이징952km~부에노스아이레스19,432km) |

## 3. 달리기 (Run) — ✅ `features/run-flow.md`, `features/offline-handling.md`, `features/camera-permission.md`

| 항목 | 상태 |
|---|---|
| 상태 머신 / 백그라운드 추적 / GPS 샘플링 / 일시정지 / 대표 이미지 / 위치·카메라 권한 / 오프라인 처리 | 🟢 전부 확정 |

## 4. 기록 (Records) — ✅ `features/records.md`

| 항목 | 상태 |
|---|---|
| 요약·필터·카드·상세 / 삭제·수정 정책 / 뱃지 / 빈 상태 / 오프라인 조회 | 🟢 전부 확정 |

## 5. 콘텐츠 (Content) — ✅ `features/theme-running.md`, `features/online-marathon.md`

| 항목 | 상태 |
|---|---|
| 테마 러닝 / 온라인 마라톤 로직 | 🟢 확정. **코스 실측 GPS 좌표는 콘텐츠팀 작업 필요** (답사 또는 지도 툴로 경로 추출) |

## 6. 프로필 (Profile) — ✅ `features/profile-settings.md`, `features/badges.md`, `features/wearable-sync.md`

| 항목 | 상태 |
|---|---|
| 계정 정보 / 닉네임 변경 / 알림·위치 권한 / 로그아웃 / 회원탈퇴 / 기기 연동 / 배지 컬렉션 | 🟢 확정 |
| 배지 아이콘/디자인 에셋 | 🔴 콘텐츠 제작 필요 (범위 밖) |
| 이용약관/FAQ | 🟡 진입점만 (범위 밖) |

## 7. 공통 / 전역 — ✅ 다수 문서

| 항목 | 상태 |
|---|---|
| 에러 / 로딩 / 위치 권한 / 오프라인 / 카메라 권한 / 세션 정책 | 🟢 전부 확정 |
| 푸시 알림 시스템 | 🟡 1차 스코프 확정, 확장 예정 |

---

## 저와의 대화로는 해결 안 되는 남은 영역 (콘텐츠/디자인/실측/외부 작업)

| 항목 | 필요한 작업 |
|---|---|
| 코스 실측 데이터 | 실제 답사(GPX 기록) 또는 지도 툴(네이버지도/카카오맵/Google My Maps)로 경로를 그려 좌표 목록 추출 — 남산런/한강야경런/N서울타워런/고구마런 |
| 배지 아이콘/비주얼 에셋 | 디자인 제작 |
| 이용약관/FAQ 실제 콘텐츠 | 법무/콘텐츠 작성 |
| Figma 파일 자체 이름 변경 | Figma 프로젝트 내에서 직접 변경 |
| 각 소셜 로그인 앱 키·시크릿 발급 | 카카오 디벨로퍼스 / 네이버 개발자센터 / Google Cloud Console |

## 전체 문서 목록 (`docs/features/`)

`auth-onboarding.md` · `session-policy.md` · `global-states.md` ·
`push-notifications.md` · `run-flow.md` · `offline-handling.md` ·
`camera-permission.md` · `theme-running.md` · `online-marathon.md` ·
`records.md` · `journey.md` · `streak.md` · `home.md` ·
`profile-settings.md` · `badges.md` · `wearable-sync.md`

각 항목은 하나씩 대화로 정의하면서, 확정될 때마다 `features/{기능명}.md`로 개별 파일을 만듭니다.
