# Run Earth

> MVP 완료 · 스토어 미출시

달린 거리를 누적해 서울에서 출발, 부산 → 베이징 → … → 부에노스아이레스까지 "**지구 한 바퀴 여정**"을
진행하는 러닝 습관화 앱입니다. 1인 개발 · Flutter + Supabase. 기기 DB를 1차 저장소로 두는
**local-first** 설계로, "**기록은 절대 잃지 않는다**"를 여러 결정의 공통 근거로 삼았습니다.

| Journey | Stack | Scope |
|:-:|:-:|:-:|
| **22 cities** | **Flutter + Supabase** | **20 features** |
| 서울 → 부에노스아이레스 19,432km | 별도 서버 없음 | MVP 완료 |

- 앱 코드: [`run_earth/`](run_earth/)

## Problem — 콘셉트가 먼저, 기능은 그 위에

타깃은 러닝을 습관으로 만들고 싶은 20~40대입니다.

기존 러닝 앱은 훈련과 기록에 집중합니다. 누적 레벨 같은 장치가 있어도 숫자나 색깔로 보여주는
**기록 기능의 부가 요소**에 가깝습니다.

Run Earth는 반대로 "**내가 달린 거리만큼 지구를 여행한다**"는 하나의 콘셉트를 먼저 정하고 기능을
그 위에 올렸습니다. 홈의 다음 도시까지 남은 거리, 도시마다 바뀌는 배경, 도시 배지 22종, 종료 때
남은 여정 거리를 읽어주는 음성 안내까지 모두 이 여정 하나를 중심으로 설계했습니다.

## Concept — 달린 거리가 곧 여정

한 번 달릴 때의 기록이 아니라, 지금까지 쌓인 거리가 지구 위 어디쯤에 와 있는지를 보여줍니다.
서울에서 출발해 국내 도시를 지나 해외 G20 수도 18곳을 거쳐 부에노스아이레스에 도착하면 한 바퀴가 끝납니다.

| | 내용 |
|---|---|
| **01 — Journey**<br>22 cities | **도시 단위로 쪼갠 긴 목표** — 서울 0 → 인천 27 → 전주 194 → 부산 325km, 이어서 베이징 952km부터 부에노스아이레스 19,432km까지. 홈 화면에 현재 구간과 다음 도시까지 남은 거리가 보입니다. |
| **02 — Habit**<br>7칸 주간 스트릭 | **주간 스트릭과 도시 배지** — 달린 날은 주간 7칸에 체크가 들어가고 연속 주수가 쌓입니다. 도시에 도착할 때마다 그 도시의 배지가 하나씩 열립니다. |
| **03 — Voice**<br>1km 마다 | **여정을 읽어주는 음성 안내** — 1km마다 구간·평균 페이스를 읽고, 종료 때는 화면에 이미 있는 거리·시간 대신 "**전주까지 142.6km 남았습니다**"처럼 여정 잔여 거리를 읽습니다. 기기 내장 음성 합성이라 오프라인에서도 동작합니다. |

## Data Flow — 기록이 흘러가는 길

달리는 순간부터 계정을 지울 때까지, 기록 한 건이 기기와 서버 사이를 어떻게 오가는지입니다.

```
🏃 Run              →  📱 Local DB          →  🔁 Sync                         →  ☁️ Supabase
GPS 추적                1차 저장소              연결되면 업로드                      Postgres + RLS
화면 꺼도 계속          오프라인 조회           실패해도 재시도                      Storage
```

| 상황 | 동작 |
|---|---|
| **새 기기 · 재설치** — 서버 기록 내려받기 | 기기를 바꾸거나 앱을 다시 설치해도 서버에 있는 기록을 내려받아 그대로 돌아옵니다. |
| **로그아웃** — 기기 기록 비우기 | 한 폰에서 계정을 바꿔도 기록이 섞이지 않도록 기기 사본을 비웁니다. 아직 못 올린 기록이 있으면 업로드를 한 번 시도하고, 남은 건수를 경고합니다. |
| **회원탈퇴** — 30일 후 영구 삭제 | 매일 새벽 예약 작업(pg_cron → Edge Function)이 탈퇴 30일이 지난 계정의 사진·계정·기록을 지웁니다. |

## Scope — MVP 구현 범위

MVP에서 완료한 기능과, 그 이후 진행할 단계입니다.

| 영역 | 기능 |
|---|---|
| **Run** | GPS 추적 · 화면 꺼짐 추적 (포그라운드 서비스) · 강제 종료 복원 (10초 스냅샷) · GPS 노이즈 필터 · 1km 구간 페이스 (경계 보간) · 음성 안내 · 날씨 · 미세먼지 · 절전 모드 경고 |
| **Journey · Habit** | 22개 도시 여정 · 주간 스트릭 · 도시 배지 22종 |
| **Record · Data** | local-first 동기화 (무제한 재시도) · 새 기기 기록 복구 · 사진 모드 · 대표 이미지 · 0km 미완료 처리 · 칼로리 추정 |
| **Account** | 구글 로그인 · 프로필 · 로그아웃 시 기기 사본 삭제 · 탈퇴 30일 후 영구 삭제 |

**다음 단계**

1. **베타 출시 준비** — 릴리스 서명 키 교체, 에어코리아 운영계정 전환, 개인정보처리방침 확정.
2. **비공개 베타** — Play 내부 테스트로 실사용자를 받아, 다양한 기기의 GPS 데이터와 사용 피드백을 모읍니다.
3. **온라인 마라톤** — 샘플 데이터를 실제 대회 데이터로 바꾸고, 5분 주기 랭킹을 Edge Functions · pg_cron으로 붙입니다.

## Product — 실제 화면

시안이 아니라 설치하면 보이는 화면입니다. 다크 톤 디자인 시스템을 정하고 Figma 시안과 맞춰 구현했습니다.

### 01 — Login · Home · Journey

구글 계정 하나로 로그인하고, 홈에서 여정 진행도를 확인합니다. 홈 배경은 현재 구간의 도시에 따라 바뀝니다.

| <img src="docs/screenshots/01-login.jpg" width="200" alt="로그인 화면"> | <img src="docs/screenshots/04-home-journey-incheon-jeonju.jpg" width="200" alt="홈 화면 — 인천에서 전주 구간"> | <img src="docs/screenshots/05-home-preview-tokyo.jpg" width="200" alt="도시 미리보기 — 도쿄"> | <img src="docs/screenshots/07-home-preview-buenos-aires.jpg" width="200" alt="도시 미리보기 — 부에노스아이레스"> |
|:-:|:-:|:-:|:-:|
| **로그인**<br>구글 로그인 하나. 계정 선택 창은 안드로이드 기본 시트라 앱이 비밀번호를 받지 않습니다. | **달린 거리가 곧 여정**<br>현재 구간(인천 → 전주)과 다음 도시까지 남은 거리, 누적 통계, 주간 스트릭. | **도시 미리보기 · 도쿄 6/22**<br>22개 도시를 다 달려보지 않아도 도시별 화면을 검수할 수 있게 넣은 개발·검수용 테스트 UI입니다. | **도시 미리보기 · 부에노스아이레스 22/22**<br>"미리보기 (테스트)" 라벨과 "실제로 돌아가기" 버튼으로 실제 진행 상태와 구분합니다. |

### 02 — Run · Finish

출발 전 GPS · 날씨 · 미세먼지를 확인하고 달립니다. START → 3초 카운트다운 → 추적 → 일시정지/재개 → 종료까지 한 흐름입니다.

| <img src="docs/screenshots/08-run-ready.jpg" width="200" alt="출발 전 화면"> | <img src="docs/screenshots/09-run-tracking-map.jpg" width="200" alt="달리는 중 — 실시간 경로"> | <img src="docs/screenshots/10-run-finish-photo.jpg" width="200" alt="종료 요약 — 사진 위 기록과 경로"> | <img src="docs/screenshots/11-run-finish-splits.jpg" width="200" alt="종료 요약 하단 — 구간별 페이스"> |
|:-:|:-:|:-:|:-:|
| **출발 전 확인**<br>GPS 연결 상태를 먼저 보여주고, 러닝 타입 · 날씨 · 미세먼지를 확인한 뒤 시작. | **실시간 경로 추적**<br>Google Maps 다크 스타일 위에 경로를 실시간으로 그립니다. 화면을 끄거나 앱을 내려도 추적이 계속됩니다. | **사진 위에 기록과 경로**<br>달리며 찍은 사진 위에 거리 · 페이스 · 시간과 경로 선을 얹습니다. 사진이 없으면 경로 그림만 보여줍니다. | **1km 구간별 페이스**<br>상세 기록과 경로, 1km 단위로 자동 분할한 구간 페이스. |

### 03 — Record Detail · Day / Night

지난 기록은 종료 요약과 같은 구성에 러닝 타입 뱃지와 대표 사진 교체 버튼이 더해집니다. 낮과 밤 기록을
나란히 둔 이유는, 사진이 밝든 어둡든 흰 글씨와 네온그린 경로가 읽히는지가 이 화면의 가장 큰 위험이기
때문입니다. 기기 DB에서 읽으므로 오프라인에서도 열립니다.

| <img src="docs/screenshots/16-records-detail-day-photo.jpg" width="200" alt="기록 상세 — 낮 러닝"> | <img src="docs/screenshots/17-records-detail-day-splits.jpg" width="200" alt="기록 상세 — 낮 러닝 아래쪽"> | <img src="docs/screenshots/18-records-detail-night-photo.jpg" width="200" alt="기록 상세 — 밤 러닝"> | <img src="docs/screenshots/19-records-detail-night-splits.jpg" width="200" alt="기록 상세 — 밤 러닝 아래쪽"> |
|:-:|:-:|:-:|:-:|
| **낮 러닝 0.72km**<br>밝은 사진 위에서도 기록과 경로가 읽힙니다. 우상단 카메라 버튼으로 대표 사진을 나중에 바꿀 수 있습니다. | **같은 기록 아래쪽**<br>상세 기록, 달린 구간, 구간별 페이스. | **밤 러닝 2.41km**<br>어두운 사진에서도 흰 글씨와 네온그린 경로가 구분됩니다. | **같은 기록 아래쪽**<br>20분 2.41km를 1km 단위 네 구간으로 나눈 페이스. |

### 04 — Content · Profile

테마 러닝과 온라인 마라톤은 여정 콘셉트를 넓히는 콘텐츠로, 기획과 화면 설계까지 완료했습니다. 온라인
마라톤은 GPS 인정 기준과 재도전 시 최고 기록 반영 규칙을 정했고, 테마 러닝은 코스를 지도에 겹쳐
보여주되 경쟁 없이 코스를 벗어나도 막지 않는 방식입니다. 랭킹과 코스 실측 좌표는 MVP 이후에 붙입니다.

| <img src="docs/screenshots/20-content-theme-list.jpg" width="200" alt="테마 러닝 코스 목록"> | <img src="docs/screenshots/22-content-theme-detail-bungeoppang.jpg" width="200" alt="테마 코스 상세 — 붕어빵런"> | <img src="docs/screenshots/23-content-marathon-list.jpg" width="200" alt="온라인 마라톤 목록"> | <img src="docs/screenshots/24-profile-top-badges.jpg" width="200" alt="프로필 — 도시 배지"> |
|:-:|:-:|:-:|:-:|
| **테마 러닝 코스**<br>코스 목록에서 상세로, 상세에서 "달리러 가기"로 바로 이어집니다. | **코스 상세 · 붕어빵런**<br>코스 소개와 "달리러 가기".<br><sub>가운데 칸은 코스 실측 좌표가 들어오면 경로가 그려지는 자리로, 지금은 비어 있습니다.</sub> | **온라인 마라톤**<br>대회 목록과 참여 화면.<br><sub>화면만 구현한 상태로, 참가자 수 · 순위 · D-day는 모두 샘플 값입니다. 랭킹은 MVP 이후로 잡혀 있습니다.</sub> | **도시 배지 22종**<br>도시마다 하나씩, 도착하면 열립니다. 캡처한 계정은 서울 출발 배지 하나만 얻은 상태(1 / 22)입니다. |

## Core Design — local-first, 기기가 먼저 서버는 뒤따라

러닝은 산속이나 지하처럼 통신이 끊기는 곳에서도 합니다. 서버 저장이 먼저면 그때 뛴 기록은 사라집니다.

Run Earth는 **기기 안의 로컬 DB를 1차 저장소**로 둡니다. 달리기가 끝나면 기록은 먼저 기기에 저장되고,
서버(Supabase)에는 연결될 때 뒤따라 올라갑니다. 그래서 비행기 모드로 뛰어도 기록이 남고, 지난 기록도
서버 없이 열립니다.

서버는 기록을 **잃지 않게 하는 두 번째 사본**이자 기기를 바꿨을 때 기록을 되돌려 주는 곳입니다.
로그인·DB·권한 규칙·사진 저장·예약 작업을 모두 Supabase로 처리해 **별도 서버 없이** 운영합니다.

> **Principle — "기록은 절대 잃지 않는다."**
> 동기화 정책, 백그라운드 추적, 0km 기록 처리까지 — 아래 의사결정들은 모두 이 한 문장에서 출발했습니다.

| 영역 | 기술 |
|---|---|
| **App** | Flutter · Riverpod · go_router · drift (SQLite) · Google Maps · 기기 내장 TTS |
| **Backend · Supabase** | Auth · Postgres + RLS · Storage · Edge Functions · pg_cron |
| **External API** | 기상청 단기예보 · 에어코리아 실시간 측정 |

## Decisions — 의사결정과 트레이드오프

"기록은 절대 잃지 않는다"를 실제 동작으로 옮기면서 마주친 분기점들입니다.

### D-01. 기기 DB 먼저 vs 서버 저장 먼저

통신이 끊긴 곳에서 뛴 기록을 지키기 위해 기기 DB를 1차 저장소로 두고 서버는 뒤따라 올리도록 했습니다.
동기화 정책에서는 두 가지를 정했습니다. **업로드가 실패해도 재시도를 포기하지 않고**, **한 건이 실패해도
다음 건은 막지 않는다**.

재시도를 포기하면 오래 오프라인이던 기록이 영영 올라가지 못하고, 깨진 한 건이 뒤의 모든 기록을 붙잡게
되기 때문입니다. 올릴 대상이 러닝 기록 하나뿐이라 별도의 동기화 큐는 만들지 않았습니다 — 같은 데이터를
두 곳에 두는 비용만 생기기 때문입니다.

### D-02. 백그라운드 추적 먼저 vs 강제 종료 대비 복원 먼저

야외 테스트는 성공했지만, 화면을 켜고 뛰었기 때문이었습니다. 폰을 주머니에 넣으면 거리가 쌓이지
않았습니다. 원래는 앱이 강제 종료됐을 때를 대비한 복원(스냅샷)을 먼저 만들 계획이었지만, 순서를 뒤집어
**화면이 꺼져도 추적을 이어가는 포그라운드 서비스를 먼저** 붙였습니다.

복원은 손실을 *줄이고*, 포그라운드 서비스는 손실을 *막습니다*. 앱이 죽어 있는 동안에는 GPS도 꺼져
있어서, 복원해도 경로에 구멍이 남습니다. 복원은 그 뒤에 안전망으로 추가했고, 실측값을 바탕으로 두 가지
저장 방식을 계산해 비교한 끝에 더 단순한 쪽을 택했습니다. 유실을 막으려는 기능이 복잡해서 버그가 나면
본말전도이기 때문입니다.

### D-03. 0km 기록은 저장하고 세는 것만 바꾸기 vs 저장 막기

거리 0km 기록에는 성격이 다른 두 가지가 섞여 있었습니다. **잘못 눌렀다 바로 끈 것**과 **뛰었는데 GPS를
못 잡은 것**. 데이터만으로는 구분되지 않습니다. 다른 러닝 앱처럼 저장을 막으면 GPS 실패 기록까지
사라지고, "뛰었는데 앱이 안 세줬다"는 최악의 경험이 됩니다.

그래서 전부 저장하고, 거리가 사실상 0이면서 1분도 안 된 기록만 '미완료'로 보아 통계와 스트릭에서
뺐습니다. 시간 조건이 두 유형을 가릅니다. 이 과정에서 코드를 열어보니 **스트릭에 거리 조건이 아예
없었습니다.** "매일 뛰었다"가 "매일 START를 눌렀다"가 되어 앱의 핵심 동기 장치가 무력화되어 있던 것을
함께 고쳤습니다.

## Verification — 실측으로 잡은 문제들

정적 분석과 테스트를 통과한 뒤에도, 야외에서 직접 달리며 측정해야 드러난 문제들입니다.

### V-01. 화면을 끄자 거리가 35% 부풀었다

화면을 끄면 안드로이드가 위치 갱신을 3초에서 8~11초로 늦췄고, 그 사이 GPS 흔들림이 몰려 들어와
시속 65km 같은 불가능한 구간이 25개 생겼습니다.

**초속 6m를 넘는 좌표는 버리고, 30초 넘게 끊긴 뒤 돌아온 구간은 거리에서 뺐습니다.** 5.14km로 잘못
기록됐던 러닝이 3.52km로 바로잡혔습니다.

### V-02. 거리는 맞는데 경로가 틀렸다

같은 기기 · 같은 빌드에서 절전 모드만 바꿔 대조 측정했습니다.

| | 절전 ON | 절전 OFF |
|---|:-:|:-:|
| 정확도 중앙값 | 20m | 4m |
| 30m 넘게 튄 점프 | 19건 | 0건 |
| 최대 샘플 간격 | 205초 | 7초 |

원인을 절전 모드로 확정한 뒤, **필터를 더하지 않고 START 전에 경고하는 방식**을 택했습니다. 정상
데이터에는 걸러낼 좌표가 없어서 필터를 넣어도 효과를 검증할 수 없었기 때문입니다.

### V-03. 에러 없이 실패하는 탈퇴 처리

세션을 먼저 지우면 RLS에 막힌 UPDATE가 에러 없이 "0건 수정"으로 끝나 try/catch로도 잡히지 않습니다.
그래서 **"소프트 삭제 → 세션 삭제" 순서로 고정**했습니다.

### V-04. 오프라인 러닝 후 자동 동기화

인터넷 없이 시작부터 종료까지 달린 기록이, Wi-Fi에 다시 연결되자 '동기화 대기' 표시 없이 자동으로
업로드됐습니다. local-first 설계가 실제 환경에서 의도대로 동작함을 확인했습니다.

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
