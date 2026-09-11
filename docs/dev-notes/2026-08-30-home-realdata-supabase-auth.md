# 개발 노트 — 홈 실데이터 연결 + Supabase 착수(초기화·인증 준비)

**날짜**: 2026-08-30
**범위**: ① 홈 탭의 하드코딩을 로컬 DB 실데이터로 전환(완료). ② Supabase 프로젝트
생성 + 클라이언트 초기화 배선(완료). ③ 구글 로그인 — 코드 + Google OAuth 콘솔
설정 + **에뮬레이터 end-to-end 로그인 검증 완료**. ④ 실기기(갤럭시 노트8) 설치·로그인
검증 + 콘텐츠·홈 이미지 배선(Unsplash 임시) + 버그 2건 수정(결과 오버플로우·러닝 재시작).
**정본 문서**: `docs/features/home.md`·`journey.md`·`streak.md`,
`auth-onboarding.md`·`session-policy.md`, `CLAUDE.md`

---

## 1. 오늘 완성한 것

### 1-A. 홈 실데이터 연결 — 커밋 `116297b`
홈의 여정·통계·스트릭이 Figma 샘플 상수(`_totalKm=247.3` 등)였던 것을 **로컬
DB 기록(`runsStreamProvider`) 기반 계산**으로 전환. 에뮬레이터(Pixel 9 API35)
실행 검증 완료.

**신규**
- `lib/features/home/data/journey_master.dart` — journey.md §5 마스터 경로 22개
  도시(이름+누적km). 시작도시 기본값=서울.
- `lib/features/home/data/home_providers.dart` — 3개 provider:
  - `homeStatsProvider`: 총 거리(sum km)·총 시간(dur 파싱 합산)·총 횟수
  - `journeyProgressProvider`: 절대위치=시작km+총거리 → 현재 구간·진행률·남은
    거리·마일스톤 5개 윈도우
  - `streakProvider`: 이번 주 7일(월~일) `ran`/`consec` + 주 연속(A안)

**수정**
- `lib/features/home/presentation/home_screen.dart` — `StatelessWidget` →
  `ConsumerWidget`, 하드코딩 제거 → provider 바인딩.

**검증(에뮬)**: 여정 인천→전주·46.9km·147.4km 남음, 통계 4h16m·7회, 스트릭
0주(샘플 마지막 러닝이 6월이라 정상). `flutter analyze` No issues.

### 1-B. Supabase 클라이언트 초기화 배선 — 커밋 `ffb61af`
Supabase 프로젝트를 만들고 앱에 연결. 실행 검증에서 "Supabase init completed"
로그 확인.

**신규**
- `lib/services/supabase/supabase_config.dart` — URL·publishableKey 를
  `--dart-define-from-file` 로 주입, `supabaseClientProvider` 노출.
- `run_earth/env.example.json` — env.json 형식 문서화(커밋됨).

**수정**
- `lib/main.dart` — `async main` + `Supabase.initialize(publishableKey)`.
  (isConfigured 일 때만 초기화)
- `.gitignore` — `/env.json` 등록.

**신규(gitignore — 커밋에 키 노출 안 됨)**
- `run_earth/env.json` — 실제 SUPABASE_URL·SUPABASE_PUBLISHABLE_KEY.

> ⚠️ **실행 명령이 바뀜**: 이제 Supabase 키 주입을 위해
> `flutter run --dart-define-from-file=env.json` 로 실행해야 한다.
> (define 없이 실행하면 `isConfigured=false` 로 Supabase 초기화만 건너뜀 —
> 크래시는 안 나지만 서버 기능 불가)

### 1-C. 실기기(갤럭시 노트8, Android 9) 설치·검증 ✅
- USB 디버깅 연결 트러블슈팅: USB 모드→파일전송, 삼성 ADB 인터페이스 인식 후 `adb`가
  기기(SM-N950N)를 잡음.
- arm64 debug 빌드·설치. 실행:
  `flutter run -d <기기ID> --dart-define-from-file=env.json`.
- **실기기 구글 로그인 성공**(에뮬레이터 외 실제 기기 검증). 홈·달리기·콘텐츠 동작 확인.
- 실기기 GPS: **실내라 신호 미확보**(권한·위치서비스는 정상, 환경 문제) → 야외 테스트 필요.
- debug APK라 이 PC keystore 서명 = 등록된 SHA-1과 일치 → 지도·로그인 키 그대로 동작.

### 1-D. 러닝 결과 화면 세로 오버플로우 수정 — 커밋 `998a90e`
- 노트8(세로 짧은 화면)에서 STOP 후 결과 화면이 `bottom overflowed by 41px`.
- `_Result`(스크롤 없던 Column)을 `SingleChildScrollView` 로 감쌈. 정사각 커버
  이미지가 커서 넘쳤던 것.

### 1-E. 콘텐츠·홈 이미지 배선 (Unsplash 임시) — 커밋 `60e4756`
- **Figma App.tsx 조사**: 디자인 이미지는 전부 **Unsplash 스톡 플레이스홀더 + 이모지**
  (자체 최종 에셋 아님). 매핑: 여정 히어로 / 콘텐츠 테마런·마라톤 썸네일 / 기록 사진.
- 그 스톡 URL을 그대로 `Image.network` 로 붙임(개발용 임시).
- 신규 `lib/core/util/images.dart`(`unsplashUrl`). 테마런 3·마라톤 2 `img` 키 채움,
  스크림 오버레이(텍스트 가독성), 실패 시 그라디언트 조용히 폴백.
- `AndroidManifest` 에 `INTERNET` 권한 명시(네트워크 이미지·릴리즈 대비).
- 에뮬 검증: 홈 여정 히어로(도시 스카이라인)·콘텐츠 테마 카드 이미지 정상.

### 1-F. 러닝 재시작 버그 → 결과 화면 '완료' 버튼 — 커밋 `9480718`
- 신고: "러닝 1회 후 더 이상 러닝 시작 안 됨". 원인은 결과 화면 탈출구가 우상단 작은
  X 뿐 → 놓치면(또는 탭 전환) 결과 화면에 stuck.
- 하단에 명확한 **'완료' 버튼** 추가(reset→prerun). `reset()` 은 `build()` 와 동일한
  초기 상태를 만들므로 이후 START 는 첫 실행과 동일 동작(상태머신 로직 버그 아님).

---

## 2. 오늘 내린 결정 (승인받음)

| 항목 | 결정 | 이유 |
|---|---|---|
| 여정 시작 도시 | **서울(0km)** 기본값 | journey.md "위치 거부 시 서울" 폴백. 인증 GPS 배정 도입 시 교체(임시) |
| 주 연속 뱃지 계산 | **A안** = 주당 1회↑ 달린 연속 주 수(진행 중인 주는 이미 달렸으면 포함) | streak.md에 주 단위 계산식 미정의. 일일 스트릭이 이미 엄격(매일)이라 주간은 너그럽게 = 습관화 앱에 적합 |
| 마스터 도시 좌표 | 이름+누적km만 담고 좌표 제외 | journey.md에 해외 도시 좌표 없음 → 추측 안 함. 홈 계산엔 불필요 |
| Supabase 키 형식 | `publishableKey`(sb_publishable_) | 새 형식. `anonKey` 파라미터는 deprecated |
| Supabase 프로젝트 | RunEarth, Region=Seoul(ap-northeast-2), **automatic RLS 켬** | 새 테이블에 RLS 자동 적용 = 데이터 전체공개 사고 방지 안전망 |
| 소셜 로그인 범위 | **구글만** (카카오·네이버 이후) | CLAUDE.md MVP 범위 |
| 콘텐츠·홈 이미지 | Unsplash 스톡 URL을 **임시로** `Image.network` 사용 | 디자인이 쓰던 플레이스홀더 그대로 붙여 화면 채움. 최종 에셋은 방침 확정 후 교체 |
| 계정 병합 정책 | 이메일 병합 "지향"하되 **자동병합 아님**(검증이메일 한정/명시 연결), `auth.uid()` 기준 스키마 | auth-onboarding.md §7 [미확정]. 카카오는 이메일이 선택동의라 부재 가능 + 자동 링크는 탈취 위험. MVP엔 구글뿐이라 지금 확정 불필요 |

---

## 3. ⚠️ 진행 중 / 향후 염두

### 3-1. 구글 로그인 — ✅ 완료·검증 (커밋 `375f713`)
Part 1~4 전부 완료. 에뮬레이터에서 dev 계정(`runearth.dev@gmail.com`)으로
로그인 성공 + 콜드 재시작 시 세션 유지(로그인 건너뛰고 홈) 확인.

- **Part 1: OAuth 동의 화면** ✅ — External, App name "Run Earth", Test users에
  dev 계정 등록(Testing 모드).
- **Part 2: 클라이언트 ID 2개** ✅ — 웹(serverClientId 용) + 안드로이드
  (패키지 `com.runearth.run_earth` + SHA-1 `56:AE:87:...:F9:E4`).
  웹 클라이언트 ID = `1033274218745-9reeior1irjjd662m066gr3kdqk9s9d8.apps.googleusercontent.com`
- **Part 3: Supabase Google provider** ✅ — 웹 클라이언트 ID/시크릿 입력.
- **Part 4: 코드** ✅ — 스플래시·로그인 화면 + `signInWithGoogle`(google_sign_in
  v7 → idToken → `supabase.auth.signInWithIdToken`) + 라우터 세션 가드.

> env.json(gitignore)에 `GOOGLE_WEB_CLIENT_ID` 채우고 `AUTH_GATE=true` 로 켠 상태.
> 카카오·네이버는 MVP 이후. iOS는 별도 클라이언트 ID + Info.plist URL scheme 필요(미완).

### 3-2. 로그인 강제 게이트 — ✅ 켜짐(AUTH_GATE=true)
스플래시→세션체크→세션 없으면 로그인(우회 불가). 세션은 Supabase가 기기
보안 저장소에 자동 저장·자동 갱신(session-policy.md). 개발 중 우회가 필요하면
env.json 에서 `AUTH_GATE=false`.

### 3-3. Supabase Free 플랜 — 자동 일시정지 주의
약 1주일 무활동 시 프로젝트가 pause 됨(데이터 보존, 대시보드에서 Resume).
개발·MVP 검증까진 무료 한도로 충분(DB 500MB/Storage 1GB/대역폭 5GB/MAU 5만).

### 3-4. (이전 노트에서 이어짐) 여전히 미해결
- **여정 카드 히어로에 탭 라벨이 희미하게 비침** — 08-30 홈 검증 중 발견. 이번
  변경(홈 데이터)과 무관(히어로/shell 미수정). 달리기 탭 GoogleMap(SurfaceView
  플랫폼뷰)의 에뮬 컴포지팅 문제로 추정 → 실기기 확인 필요. **원인 미확정.**
  (히어로에 배경 이미지 넣은 뒤에도 재확인 필요)
- 08-23/08-28 미해결 잔존: 백그라운드 추적, 칼로리(몸무게 필요), 경로 일시정지
  세그먼트 미분리, 날씨/미세먼지 하드코딩, RunType 고정, gpsVerified=false,
  iOS 지도 키(Mac 필요), 홈 CTA `onTap` 비어있음, `_userName` 하드코딩(인증 후 교체).

### 3-5. 이미지 = Unsplash 임시 (향후 교체)
- 현재 콘텐츠·홈 이미지는 Unsplash 스톡 URL 직접 참조 → **실서비스 부적합**
  (라이선스 불명확 + URL 삭제/변경 시 깨짐).
- journey.md §4 방침(실사진 vs 일러스트, 라이선스 확인 스톡/자체 제작 [미확정]) 확정
  후 `assets/` 로 교체. 여정은 "다음 목적지 도시별 이미지"라 도시별 에셋 필요(현재 단일 임시).
- release 빌드 시 `INTERNET` 권한 필요(추가 완료). 커버 이미지(러닝 결과)는 여전히
  캔버스 렌더(사진 아님).

---

## 4. 다음 이어서 할 일

1. ~~구글 로그인~~ ✅ 완료(3-1 참고).
2. **Supabase 동기화** ← 다음 유력. 서버 테이블(users·runs)+RLS(`auth.uid()` 기준),
   로컬→서버 업로드 큐, 커버 이미지 Storage(로컬경로→URL 치환).
   커버는 이미지 대신 route 좌표만 올리고 재생성하는 방식도 검토(Storage 절약).
3. 로그인 후 프로필/유저: `_userName` 하드코딩 → 로그인 유저 이름으로 교체,
   최초 로그인 시 users 행 생성(닉네임=소셜 프로필 이름, profile-settings.md).
4. iOS 구글 로그인 배선(별도 클라이언트 ID + URL scheme) — Mac 필요.

## 메모 반영
- 계정 병합 정책 → 자동메모 `auth-account-merge-policy.md` 저장됨.
