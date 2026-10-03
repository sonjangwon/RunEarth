import 'package:freezed_annotation/freezed_annotation.dart';

import 'enums.dart';
import 'geo.dart';

part 'run.freezed.dart';
part 'run.g.dart';

/// 러닝 기록 1건.
///
/// 4개 문서에 분산 정의된 필드를 병합:
/// - 기본: `Run Earth_기능정의서.md` 6-3 (date, day, km, pace, dur, kcal, type, year, month)
///   · `photoUrl` 은 run-flow.md 의 coverImage 로 대체됨
/// - run-flow.md 6: coverImageType, coverImageUrl
/// - records.md 5: marathonChallengeId?, marathonCourseId?, gpsVerified?
/// - wearable-sync.md 6: source
///
/// [id] 는 문서에 없는 기술 필드 — 로컬 DB/서버 동기화용 고유 식별자.
/// [route] 는 실제 추적된 GPS 좌표 배열 — 대표 이미지(경로 렌더) 생성/재생성·
///   상세 경로 표시용. run-flow.md 6 의 polyline 을 코드 정본으로 반영(2026-08-23 확정).
@freezed
abstract class Run with _$Run {
  const factory Run({
    required String id,
    required String date, // "06.30"
    required String day, // "화"
    required double km, // 8.4
    required String pace, // "5'12\""
    required String dur, // "43:41"
    required int kcal, // 498
    required RecordType type,
    required int year, // 2026
    required int month, // 6
    @Default(CoverImageType.route) CoverImageType coverImageType,
    String? coverImageUrl,
    String? marathonChallengeId,
    String? marathonCourseId,
    bool? gpsVerified,
    @Default(RunSource.app) RunSource source,
    @Default(<LatLngPoint>[]) List<LatLngPoint> route,
  }) = _Run;

  factory Run.fromJson(Map<String, dynamic> json) => _$RunFromJson(json);
}

/// 미완료 러닝 판정 — 0km 기록 정책(2026-09-23 개정, 최초 2026-09-20).
///
/// START 를 눌렀다 만 기록이 스트릭·총 횟수를 오염시키는 문제를 막는다.
/// **저장은 막지 않는다** — `records.md` 4 의 "삭제 불가·영구 보존"은 데이터를
/// 지키자는 것이지 표시를 강제하는 게 아니다. 그래서 **세는 것과 보여주는
/// 것만** 조정한다.
extension RunCompleteness on Run {
  /// `dur`("mm:ss" 또는 "hh:mm:ss")을 초로 변환. 형식이 깨졌으면 0.
  int get durSeconds {
    final parts = dur.split(':').map(int.tryParse).toList();
    if (parts.contains(null)) return 0;
    if (parts.length == 3) {
      return parts[0]! * 3600 + parts[1]! * 60 + parts[2]!;
    }
    if (parts.length == 2) {
      return parts[0]! * 60 + parts[1]!;
    }
    return 0;
  }

  /// 미완료 러닝 — 거리가 사실상 0 인 기록. **시간은 보지 않는다.**
  ///
  /// 2026-09-20 에는 `durSeconds < 60` 도 같이 봤다. 1분 넘게 뛰었는데 GPS 를
  /// 못 잡은 기록(2026-09-13 노트 §3-2 `run_1789297203613307`: 1분 37초에 좌표
  /// 1개)을 살리려던 것이다. 2026-09-23 사용자 결정으로 **거리만** 본다 —
  /// 거리가 0 인 기록은 목록에서도 안 보이고 스트릭에도 안 들어간다.
  ///
  /// 잃는 것: GPS 를 못 잡은 날은 실제로 뛰었어도 연속이 끊긴다.
  /// 얻는 것: 보이는 것과 세는 것의 기준이 하나라 목록과 총 횟수가 어긋나지
  /// 않는다. 근거는 `records.md` §4-1.
  bool get isIncomplete => km < 0.01;
}

/// 칼로리 추정에 쓰는 가정 체중(kg). 체중 입력 수단이 없어 고정값을 쓴다
/// (2026-10-03 사용자 결정). 입력이 생기면 이 자리만 바꾼다. 근거는 `records.md` 3.
const double kAssumedWeightKg = 80;

/// 달리기 칼로리 추정 — 체중(kg) × 거리(km). 달리기는 속도와 거의 무관하게
/// 1kg·1km 당 약 1kcal 이 든다.
int estimateKcal(double km) => (kAssumedWeightKg * km).round();

extension RunCalories on Run {
  /// 화면에 보일 칼로리. 저장값이 있으면(워치 연동 등) 그것을, 없으면 추정한다.
  ///
  /// 추정값은 **저장하지 않는다.** 저장하면 이미 올라간 기록을 다시 올려야
  /// 하고, 내려받기가 로컬 값을 유지하므로(`offline-handling.md` §4-1) 기기마다
  /// 숫자가 어긋난다. 화면에서 계산하면 체중이 바뀌어도 한 곳만 고치면 된다.
  int get displayKcal => kcal > 0 ? kcal : estimateKcal(km);
}
