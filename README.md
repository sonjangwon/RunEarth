# Run Earth

달린 거리를 누적해 **서울에서 부에노스아이레스까지 22개 도시, 19,432 km의 "지구 한 바퀴 여정"**으로
바꿔주는 러닝 습관화 앱. 1인 개발로 **20개 기능의 Android MVP**를 완성했다.

## 핵심 설계

- **Local-first 아키텍처** — 기기 내 DB(drift)가 1차 저장소이고, 러닝 기록은 Supabase로
  무제한 재시도하며 동기화한다. 오프라인에서도 기록이 유실되지 않고, 새 기기나 재설치 시 복원된다.
- **신뢰할 수 있는 GPS 트래킹** — 화면이 꺼져도 트래킹이 계속되고, 강제 종료 후에도 이어서 복구된다.
- **전용 서버 없는 백엔드** — Supabase Edge Functions와 pg_cron으로 서버 로직과 예약 작업을 처리한다.

## 기술 스택

Flutter · Riverpod · drift (SQLite) · Supabase (Auth · Postgres · RLS · Edge Functions · pg_cron) · Google Maps

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
