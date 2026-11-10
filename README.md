# Run Earth

> MVP 완료 · 스토어 미출시

달린 거리를 누적해 서울에서 부에노스아이레스까지 "**지구 한 바퀴 여정**"을 진행하는 러닝 습관화 앱.
1인 개발 · Flutter + Supabase. 기기 DB를 1차 저장소로 두는 **local-first** 설계로
"**기록은 절대 잃지 않는다**"를 핵심 원칙으로 삼았다.

| Journey | Stack | Scope |
|:-:|:-:|:-:|
| **22 cities** · 19,432km | **Flutter + Supabase** · 별도 서버 없음 | **20 features** · MVP 완료 |

## 실제 화면

| <img src="docs/screenshots/01-login.jpg" width="200"> | <img src="docs/screenshots/04-home-journey-incheon-jeonju.jpg" width="200"> | <img src="docs/screenshots/05-home-preview-tokyo.jpg" width="200"> | <img src="docs/screenshots/07-home-preview-buenos-aires.jpg" width="200"> |
|:-:|:-:|:-:|:-:|
| 구글 로그인 | 홈 · 여정 진행도 | 도시 미리보기 · 도쿄 | 도시 미리보기 · 부에노스아이레스 |
| <img src="docs/screenshots/08-run-ready.jpg" width="200"> | <img src="docs/screenshots/09-run-tracking-map.jpg" width="200"> | <img src="docs/screenshots/10-run-finish-photo.jpg" width="200"> | <img src="docs/screenshots/11-run-finish-splits.jpg" width="200"> |
| 출발 전 확인 | 실시간 경로 추적 | 사진 위 기록과 경로 | 1km 구간별 페이스 |
| <img src="docs/screenshots/16-records-detail-day-photo.jpg" width="200"> | <img src="docs/screenshots/17-records-detail-day-splits.jpg" width="200"> | <img src="docs/screenshots/18-records-detail-night-photo.jpg" width="200"> | <img src="docs/screenshots/19-records-detail-night-splits.jpg" width="200"> |
| 기록 상세 · 낮 | 기록 상세 · 낮 (구간) | 기록 상세 · 밤 | 기록 상세 · 밤 (구간) |
| <img src="docs/screenshots/20-content-theme-list.jpg" width="200"> | <img src="docs/screenshots/22-content-theme-detail-bungeoppang.jpg" width="200"> | <img src="docs/screenshots/23-content-marathon-list.jpg" width="200"> | <img src="docs/screenshots/24-profile-top-badges.jpg" width="200"> |
| 테마 러닝 코스 | 코스 상세 · 붕어빵런 | 온라인 마라톤 (샘플 값) | 도시 배지 22종 |

## 핵심 설계

- **Local-first** — 기기 DB(drift)가 1차 저장소, 서버는 연결될 때 무제한 재시도로 동기화.
  오프라인에서도 기록이 남고, 새 기기·재설치 시 복원된다.
- **끊기지 않는 GPS 추적** — 화면이 꺼져도 포그라운드 서비스로 추적하고, 강제 종료 시 10초 스냅샷으로 복원.
  야외 실측으로 GPS 노이즈(거리 35% 과대 측정)를 잡아냈다.
- **서버 없는 백엔드** — Supabase Auth · Postgres + RLS · Storage, 예약 작업은 pg_cron → Edge Function.

## 기술 스택

Flutter · Riverpod · go_router · drift (SQLite) · Google Maps · Supabase · 기상청 · 에어코리아 API

> 의사결정과 검증 과정 등 자세한 내용은 [포트폴리오 페이지](https://sonjangwon.github.io/run-earth.html) 참고.

- 앱 코드: [`run_earth/`](run_earth/)

---

## 로컬 개발 준비 ★

저장소를 새로 받으면 **비밀 키 파일 2개가 없어서 그대로는 정상 동작하지 않는다.**
둘 다 `.gitignore` 에 있어 GitHub 에 올라가지 않는다.

### 1. `run_earth/env.json`

[`run_earth/env.example.json`](run_earth/env.example.json) 을 복사해 실제 값을 채운다.

```bash
cp run_earth/env.example.json run_earth/env.json
```

| 키 | 어디서 얻나 |
|---|---|
| `SUPABASE_URL` · `SUPABASE_PUBLISHABLE_KEY` | Supabase 대시보드 → Project Settings → API |
| `GOOGLE_WEB_CLIENT_ID` | Google Cloud Console → OAuth 2.0 클라이언트(웹) |
| `AUTH_GATE` | `true` = 로그인 필수, `false` = 로그인 없이 진입 |

### 2. `run_earth/android/secrets.properties`

```properties
MAPS_API_KEY=<Google Maps Android API 키>
```

없으면 러닝 화면 지도가 회색으로 뜬다.

### 3. 실행할 때 반드시 키를 주입한다

```bash
cd run_earth
flutter run --dart-define-from-file=env.json
```

> ⚠️ **`--dart-define-from-file` 를 빼면** Supabase 가 초기화되지 않아 로그인·동기화가
> 전부 죽는다. (스플래시에 갇히는 문제는 2026-09-13 에 수정됐고, 지금은 로그인 없이
> 홈으로 진입한 뒤 로컬 기록만 보인다.)

### 4. 새 PC 라면 — 구글 로그인·지도가 안 될 수 있다

릴리즈 빌드가 **debug 키로 서명**되도록 설정돼 있는데(`android/app/build.gradle.kts`
의 `TODO`), **debug 키스토어는 PC 마다 다르다.** 기존에 등록된 SHA-1 지문과 달라져
구글 로그인과 지도 키 제한에 걸린다.

해결: 새 PC 의 지문을 확인해 Google Cloud 의 OAuth 클라이언트·지도 API 키에 **추가 등록**한다.

```bash
keytool -list -v -alias androiddebugkey -keystore ~/.android/debug.keystore \
  -storepass android -keypass android | grep SHA1
```

---

## 자주 쓰는 명령 (`run_earth/` 에서)

```bash
flutter pub get                          # 의존성 동기화
flutter run --dart-define-from-file=env.json   # 실행
flutter analyze                          # 정적 분석 (커밋 전 필수)
flutter test                             # 테스트
dart run build_runner build              # freezed·drift 코드 생성
```

릴리즈 APK (실기기 설치용):

```bash
flutter build apk --release --dart-define-from-file=env.json
adb install -r build/app/outputs/flutter-apk/app-release.apk
```

> Play 스토어 배포는 **불가**. 별도 릴리즈 키스토어를 만들고 그 지문을 Google Cloud 에
> 등록해야 한다(debug 키로 서명된 APK 는 Play Console 이 거부한다).

---

## 문서 = 단일 출처

- 기능 작업 전 [`docs/features/{기능}.md`](docs/features/) 를 먼저 읽는다.
- 전체 현황은 [`docs/feature-backlog.md`](docs/feature-backlog.md)
- 세션별 작업 기록·미해결 문제는 [`docs/dev-notes/`](docs/dev-notes/) — **최신 노트부터 읽으면
  지금 어디까지 왔는지 파악된다.**
- 서버 스키마 SQL 은 [`supabase/migrations/`](supabase/migrations/) 에 기록만 해둔다
  (CLI 미도입 — 대시보드에서 실행 후 파일도 추가할 것).

## 폴더 구조 (`run_earth/lib/`)

```
lib/
 ├─ main.dart
 ├─ core/        theme · router · models(코드상 정본) · db(drift) · widgets
 ├─ features/    home / run / records / content / profile / auth
 └─ services/    supabase · sync(동기화 큐) · connectivity
```
