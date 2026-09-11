# 개발 노트 — 러닝 중 화면 GoogleMap 실지도 전환

**날짜**: 2026-08-28
**범위**: 달리기 탭. 러닝 중 "캔버스 폴리라인"으로 그리던 경로를 **실제 Google Map
(다크 스타일)** 위에 그리도록 전환. 지난 노트(2026-08-23)에서 "내일 이어서"로
남겨둔 작업.
**정본 문서**: `docs/features/run-flow.md`, `CLAUDE.md`(지도=google_maps_flutter 확정)

---

## 1. 오늘 완성한 것

러닝 중 화면을 실제 구글 지도로 교체 → 다크 스타일 적용 → 그 위에 네온그린 경로
Polyline + 현재위치 파란점 + 실시간 카메라 추적. **에뮬레이터(Pixel 9 API35)로
직접 실행해 키 작동·지도·다크 스타일·경로·위치점·라이브 스탯 모두 정상 확인.**

커버 이미지(결과 화면)는 기존 `RoutePainter` 캔버스를 **그대로 유지**(지도 안 들어감).

### 커밋 (main 브랜치)
- `f4792d9` feat(run): 러닝 중 화면 GoogleMap 실지도 전환
- `449d353` fix(run): 러닝 지도 다크 스타일 적용 (LATEST 렌더러 + setMapStyle)

### 변경 파일
**신규 (gitignore — 커밋에 키 노출 안 됨)**
- `android/secrets.properties` — `MAPS_API_KEY=...`
- `ios/Runner/Secrets.xcconfig` — `MAPS_API_KEY = ...`

**수정 — 지도 교체**
- `lib/features/run/presentation/run_screen.dart` — 러닝 중 `_RouteView`(캔버스) →
  `_RunMap`(GoogleMap, 다크 스타일 `_darkMapStyle`, Polyline, myLocation 파란점,
  카메라 추적)로 교체. 카운트다운 배경은 단색으로.

**수정 — 키 주입 배선**
- `.gitignore` — secrets 두 파일 등록
- `android/app/build.gradle.kts` — `secrets.properties` 읽어 `manifestPlaceholders`
  로 주입
- `android/app/src/main/AndroidManifest.xml` — `com.google.android.geo.API_KEY`
  meta-data(`${MAPS_API_KEY}`)
- `ios/Flutter/Debug.xcconfig`·`Release.xcconfig` — `#include? "../Runner/Secrets.xcconfig"`
- `ios/Runner/Info.plist` — `MAPS_API_KEY = $(MAPS_API_KEY)`
- `ios/Runner/AppDelegate.swift` — `import GoogleMaps` + `GMSServices.provideAPIKey`

**수정 — 다크 스타일 fix**
- `lib/main.dart` — `initializeWithRenderer(AndroidMapRenderer.latest)` 로 Android
  최신 렌더러 요청.
- `lib/features/run/presentation/run_screen.dart` — GoogleMap `style:` 파라미터 →
  `onMapCreated` 의 `setMapStyle` 로 변경(양쪽 렌더러 호환).
- `pubspec.yaml` — `google_maps_flutter_android`, `google_maps_flutter_platform_interface`
  명시적 추가(최신 렌더러 API 사용 + analyze 경고 방지).

**검증**: `flutter analyze` No issues. **에뮬레이터 실행 검증 완료**(아래 3-2 참고).

---

## 2. 오늘 내린 결정 (승인받음)

| 항목 | 결정 | 이유 |
|---|---|---|
| 키 저장 | gitignore된 `secrets.properties`/`Secrets.xcconfig` | 커밋에 키 노출 방지. 플랫폼별로 파일이 갈려 있어 키도 플랫폼별 분리 가능 |
| 키 앱 제한 | **Android 키만** 제한(패키지+SHA-1), iOS는 나중 | 키 1개엔 애플리케이션 제한을 **한 종류만**(Android/iOS 중 택1) 걸 수 있음 |
| 다크 스타일 | LATEST 렌더러 요청 + `setMapStyle` 폴백 | `style:` 파라미터는 최신 렌더러에서만 먹어서, 구형 LEGACY(일부 에뮬)에선 무시됨 |
| 커버 이미지 | 지도 안 넣고 캔버스 유지 | 문서 확정(2026-08-23 결정사항 #2) |

### Android 키 제한 값 (참고)
- 패키지: `com.runearth.run_earth`
- debug SHA-1: `56:AE:87:2B:D9:33:C1:B2:32:FF:4E:95:02:20:09:A4:CC:EE:F9:E4`
  (이 PC의 debug 키스토어. **다른 PC·release 빌드 땐 해당 SHA-1도 추가**해야 함)

---

## 3. ⚠️ 임시로 처리한 것 / 향후 염두에 둘 것

### 3-1. iOS 키 미발급 · iOS 빌드 검증 미완
- 키 1개엔 한 제한만 걸리므로 iOS는 **별도 키**가 필요. 아직 미발급.
- 개발 환경이 Windows라 **iOS 빌드 자체가 불가** → iOS 배선(Info.plist/AppDelegate/
  xcconfig)은 코드만 넣어뒀고 검증은 못 함. **Mac에서 iOS 빌드 시**: iOS용 키 발급 →
  `Secrets.xcconfig` 에 넣고 → Google Cloud에서 iOS 앱 제한(번들ID) 걸기.

### 3-2. 검증은 에뮬레이터(LEGACY 렌더러)에서만
- Pixel 9 API35 에뮬은 Play 스토어·최신 GMS가 있는데도 `maps_core feature
  installation failed` 로 **최신 렌더러를 못 불러오고 LEGACY로 고정**됨.
- 그래서 `style:` 파라미터만으론 다크가 안 떴고, `setMapStyle`(LEGACY도 지원)로
  다크 확인. **실기기(최신 렌더러)에선 `style:`·`setMapStyle` 둘 다 동작 예상**이나
  실기기 최종 확인은 남음.

### 3-3. setMapStyle = deprecated (ignore 처리)
- `GoogleMapController.setMapStyle` 은 deprecated(최신 API는 `style:` 파라미터)지만,
  LEGACY 렌더러 호환을 위해 사용하고 `// ignore: deprecated_member_use` 로 처리.
- 향후 최신 렌더러만 타겟한다고 확정되면 `style:` 파라미터로 되돌리고 이 코드 제거 가능.

### 3-4. 라이브 스탯 거리 튐(에뮬 아티팩트)
- 에뮬 테스트 중 거리가 9,000km대로 튀는 현상 → 에뮬 기본위치(미국)→서울로 GPS를
  점프시킬 때 생긴 한 번의 큰 세그먼트. **실사용/실기기와 무관**. 저장은 안 함.

### 3-5. (2026-08-23에서 이어짐) 여전히 미해결
- 백그라운드 추적 없음, 칼로리 미표시(몸무게 필요), 경로 일시정지 세그먼트 미분리,
  날씨/미세먼지 하드코딩, RunType 고정(테마/온라인 진입 주입 없음), gpsVerified=false.
  (상세는 `2026-08-23-run-gps.md` 3장 참고)

---

## 4. 다음 후보 (MVP 남은 기능)

오늘 대화로 MVP 남은 "진짜 기능"을 정리함:

1. **홈 실데이터 연결** (순수 코드, Supabase 불필요) — 홈의 여정·스트릭·통계가 현재
   하드코딩(`home_screen.dart` `_totalKm = 247.3` 등). 실제 Runs 데이터로 계산 연결.
2. **인증 (구글 로그인)** — 스플래시→세션체크→로그인(구글)→위치권한→홈, 세션 가드.
   **Supabase 프로젝트 미생성** + Google OAuth 셋업 필요. (카카오·네이버는 MVP 이후)
3. **Supabase 동기화** — 서버 테이블(users·runs)+RLS, 로컬→서버 업로드 큐, 커버
   이미지 Storage 업로드(로컬경로→URL 치환). `lib/services/` 신설.

- MVP 경계(확인 필요): **백그라운드 추적**(run-flow 완료조건이나 실기기 필요 → 별도 단위).
- 추천 순서: **1(홈 실데이터) → 2(인증) → 3(동기화)**. 1은 콘솔 작업 없이 진행 가능.
