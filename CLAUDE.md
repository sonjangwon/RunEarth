# Run Earth

러닝 습관화 앱. 달린 거리를 누적해 "지구 한 바퀴 여정"(서울→부산→베이징→…)을 진행하는 것이 핵심 컨셉.

## 문서 = 단일 출처
- 기능 작업 전 관련 `docs/features/{기능}.md`를 먼저 읽는다.
- 전체 현황은 `docs/feature-backlog.md` 참조.
- 로직·규칙은 docs에서, 화면·비주얼은 Figma에서 가져온다.
  (Figma Make fileKey: sl01MidlM08sxalbh5g43q)

### `docs/` 안에서 어디에 쓰는가 (2026-09-27 추가)
성격이 다른 문서가 한 폴더에 섞이면 **세션 노트처럼 보여서 아무도 안 고친다.**

| 폴더 | 무엇 | 수명 |
|---|---|---|
| `docs/features/` | 기능 스펙 (정본) | 계속 고침 |
| `docs/feature-backlog.md` | 전체 현황판 | 계속 고침 |
| `docs/dev-notes/` | `YYYY-MM-DD-주제.md` 세션 기록 | **한 번 쓰고 안 고침**. 낡으면 지우지 말고 ⛔ 로 표시하고 정본을 가리킨다 |
| `docs/reports/` | 팀·외부에 **내보내는** 산출물 (`YYYY-MM-DD-*.md` + 생성된 `.html`) | 계속 다시 만듦 |
| `docs/legal/` | 외부에 공개하는 법적 문서 (개인정보처리방침·이용약관) | 계속 고침. **시행일·변경 이력 필수**, 앱 동작이 바뀌면 함께 고친다 |
| `docs/assets/screenshots/{날짜}/` | 스크린샷 `순번-화면-상태.jpg` | **커밋 안 함**(.gitignore) |

- 팀 공유 리포트는 `docs/reports/` 다. **`dev-notes/` 에 두지 말 것** — 읽는
  사람도 수명도 다르다.
- 스크린샷이 커밋에서 빠지므로 `.md` 만으로는 저장소를 새로 받은 사람에게
  이미지가 깨진다. **리포트 `.html` 은 이미지를 내장한 아카이브**이므로 함께
  커밋한다. 생성: `python scripts/build-report.py <입력.md> <출력.html>`

### 끝냈으면 문서를 되돌려 고친다 (2026-09-25 추가)
코드만 고치고 문서를 두면 **다음 세션이 "미착수"로 읽고 이미 있는 걸 또 만들려
한다.** 2026-09-25 하루에만 다섯 번 났다 — 체크박스 미갱신 2건, 규칙이 문서에
아예 없어서 구현이 어긋난 걸 몰랐던 것 1건, 사유가 코드 주석에만 있어 화면마다
다르게 보이던 것 1건, 낡은 주석 1건.

- **완료 조건 체크박스를 함께 갱신한다** — 해당 `docs/features/*.md` 의
  '완료 조건' 과 `docs/figma-alignment.md`. 커밋과 같은 단위로 묶는다.
- **체크할 때 근거를 한 줄 적는다** (어느 커밋인지, 무엇으로 확인했는지).
  근거 없는 체크는 다음 사람이 처음부터 다시 확인해야 한다.
- **조건 자체가 낡았으면 체크가 아니라 정정한다.** 정책이 바뀌어 달성 대상이
  아니게 된 항목은 `- [~]` + 취소선 + 근거를 남긴다. 그냥 두면 영원히
  미완료로 보인다.
- **정해둔 규칙은 코드 주석이 아니라 문서에 적는다.** 주석에만 있으면 다른
  화면이 다르게 구현돼도 **맞는지 확인할 기준이 없다.**

## 멈추고 물어볼 것 (가정 금지)
- 문서에 `[미확정]`, 🟡, 🔴 표시가 있는 항목
- 문서끼리 충돌하거나 같은 타입이 다르게 정의된 경우 (임의 판단 말고 질문)
- 문서에 없는 새 필드·타입·패키지·라이브러리가 필요할 때
- 참고: 구 `docs/Run Earth_기능정의서.md`(2026-08-05)와 최신 `docs/features/*.md`(2026-08-15)가
  충돌하면 **최신 features 문서를 우선**한다.

## 아키텍처 원칙
- local-first: 로컬 DB(drift)가 1차 진실 소스. 서버 업로드는 후행 처리.
- feature-first: 기능 단위로 폴더를 나눈다.

## 기술 스택 (확정)
- **Flutter** (iOS·Android), 앱 코드는 `run_earth/`
- **Supabase** (Auth + Postgres + RLS + Storage) — MVP는 **serverless**(별도 서버 없음).
  경쟁(랭킹 5분 배치)·푸시는 이후 Edge Functions / pg_cron으로.
- 상태관리 **Riverpod**, 라우팅 **go_router**, 지도 **google_maps_flutter**, 로컬 DB **drift**
- 소셜 로그인: 구글 먼저(Supabase 네이티브) → 카카오·네이버는 이후 Edge Function 연동

## 소통
- 사용자와는 **한국어**로 답한다.

## 폴더 구조 (feature-first, `run_earth/lib/`)
```
lib/
 ├─ main.dart
 ├─ core/
 │   ├─ theme/     색상·폰트 토큰, ThemeData
 │   ├─ router/    go_router (5탭 shell)
 │   ├─ models/    Dart 데이터 모델 (Run/User/MasterCity …) ← 코드상 정본
 │   ├─ db/        drift 로컬 DB (스키마·DAO)
 │   └─ widgets/   화면에 안 매인 전역 공통 위젯 (스켈레톤·인라인 에러)
 │                 정본: docs/features/global-states.md
 ├─ features/      home / run / records / content / profile / auth
 └─ services/      supabase 클라이언트, 동기화 큐
```

## 자주 쓰는 명령 (`run_earth/`에서)

> **앱을 실행·빌드하는 명령에는 반드시 `--dart-define-from-file=env.json` 을 붙인다.**
> 빼면 `SupabaseConfig.isConfigured` 가 false 가 되어 `main.dart` 의 `Supabase.initialize()`
> 가 건너뛰어지고, `app_router.dart` 의 세션 가드(`_guard`)까지 **통째로 꺼진다.**
> 증상이 고약하다 — 앱은 정상 실행되고 local-first 라 기존 기록도 보여서 **로그인된 것처럼
> 보이지만**, 로그아웃·동기화·계정 정보·사진 업로드가 전부 실패한다. 빌드 로그에도
> 경고가 안 뜬다. (9/23 오프라인 검증 실패 · 9/27 릴리스 APK 로그아웃 실패 — 두 번 겪었다)

- `flutter run --dart-define-from-file=env.json` — 앱 실행 (기기/에뮬레이터)
- `flutter build apk --release --dart-define-from-file=env.json` — 릴리스 APK 빌드
  (산출물 `build/app/outputs/flutter-apk/app-release.apk`, 클린 빌드 약 14분)
- `flutter analyze` — 정적 분석 (커밋 전 필수). env 주입은 필요 없다
- `flutter test` — 테스트
- `dart run build_runner build` — freezed·drift 코드 생성 (충돌 시 `dart run build_runner clean` 후 재실행)
- `flutter pub get` — 의존성 동기화

### 실기기 설치 (안드로이드)
- `adb install -r <apk>` — **데이터 보존**. `uninstall` 은 러닝 기록·로그인이 날아가니 쓰지 않는다
  (보존 확인법: `adb shell dumpsys package com.runearth.run_earth | grep firstInstallTime` 가 그대로인지)
- **설치 전에 APK 에 env 가 박혔는지 검증한다** — 앱을 켜서는 알 수 없으니 파일에서 확인한다.
  **빌드 종류마다 방법이 다르다:**
  - **릴리스**: `grep -a "<SUPABASE_URL 호스트>" <apk>` 가 걸리지 않으면 위 함정에 빠진 것이다
    (Dart 코드가 `libapp.so` 로 무압축 저장돼 문자열이 그대로 보인다)
  - **디버그**: `grep -a` 는 **env 가 있어도 0건**이 나온다(거짓 음성). Dart 코드가
    `kernel_blob.bin` 안에 deflate 압축돼 있기 때문이다. zip 엔트리를 풀어서 찾는다
    (2026-10-01 노트 §4)

## 디자인 토큰 (정본: `docs/Run Earth_기능정의서.md` 7장, 매번 문서 안 뒤지게 요약)
| 토큰 | 값 | 용도 |
|---|---|---|
| background | `#070911` | 앱 배경 |
| card | `#0D1018` | 카드 |
| foreground | `#EDF0F7` | 기본 텍스트 |
| primary | `#00E87A` | 네온그린, 주요 액션 |
| accent | `#FF5F1F` | 오렌지, 보조 강조 |
| border | `rgba(255,255,255,0.07)` | 테두리 |
| muted / muted-fg | `#151923` / `#6B7280` | 비활성 배경/텍스트 |

- 러닝 타입 뱃지: 일반 `#00E87A` · 테마 `#3B82F6` · 온라인 `#FACC15`
- 스트릭: 1~3일 `#00E87A` · 4~6일 `#FF5F1F` · 7일 `#FF2D55`
- 폰트: Barlow Condensed(수치) · DM Sans(영문) · DM Mono(고정폭) · Noto Sans KR(한글)

## 데이터 모델 위치
- **스펙(원본)** 은 각 `docs/features/*.md` 안의 TypeScript 타입 정의.
  한 타입이 여러 문서에서 확장됨 — 예: `Run`은 run-flow / records / wearable-sync에서 필드 추가.
- **코드(정본)** 는 `run_earth/lib/core/models/`의 Dart 모델. 스펙을 여기로 합쳐 단일화한다.
- 새 필드가 필요하면 먼저 관련 docs 확인 → 없으면 질문(가정 금지).

## MVP 범위
- **포함**: 홈(여정·스트릭), 달리기(GPS·상태머신), 기록, local-first(drift), 구글 로그인, Supabase 동기화
- **이후**: 카카오·네이버 로그인, 온라인 마라톤 랭킹(5분 배치), 푸시 알림, 웨어러블 동기화, 서버 GPS 재검증
