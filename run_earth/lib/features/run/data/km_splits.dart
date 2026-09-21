import 'dart:math' as math;

import 'package:geolocator/geolocator.dart';

import '../../../core/models/geo.dart';

/// 구간 하나 — 1km 단위로 자른 페이스.
/// 정본: run-flow.md 6-2.
class KmSplit {
  const KmSplit({
    required this.endKm,
    required this.seconds,
    required this.partial,
  });

  /// 구간이 끝나는 지점의 누적 거리. 온전한 구간은 1.0·2.0…,
  /// 마지막 자투리는 실제 총거리(예: 2.89).
  final double endKm;

  /// **1km 환산** 소요 초. 자투리 구간도 같은 기준이라 나란히 비교된다.
  final int seconds;

  /// 1km 를 못 채운 마지막 구간인가.
  final bool partial;

  /// "6'28\"" 형식.
  String get paceLabel {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return "$m'${s.toString().padLeft(2, '0')}\"";
  }

  /// "1" · "2.89" 형식 — 온전한 구간은 소수점을 떼고 보인다.
  String get kmLabel =>
      partial ? endKm.toStringAsFixed(2) : endKm.toStringAsFixed(0);
}

/// 경로 좌표에서 1km 구간별 페이스를 뽑는다.
///
/// **[LatLngPoint.e](달린 시간)를 쓴다.** 벽시계([LatLngPoint.t])로 재면
/// 일시정지 시간이 그 구간에 통째로 얹혀 페이스가 튄다.
///
/// 1km 경계는 좌표 사이에 걸리므로 **선형 보간**한다 — 경계를 넘은 좌표의
/// 시간을 그대로 쓰면 구간이 실제보다 길어지고, 그 오차가 뒤로 계속 밀린다.
///
/// 시간 정보가 없는 예전 기록(`e == null`)은 빈 목록을 돌려준다.
List<KmSplit> computeKmSplits(List<LatLngPoint> route) {
  if (route.length < 2) return const [];

  final firstMs = route.first.e;
  if (firstMs == null) return const [];

  final splits = <KmSplit>[];
  var cumulativeKm = 0.0;
  // 직전 구간이 끝난 지점 — 거리·시간 둘 다 경계에 맞춰 보간된 값이다.
  var segmentStartKm = 0.0;
  var segmentStartMs = firstMs;

  for (var i = 1; i < route.length; i++) {
    final prev = route[i - 1];
    final cur = route[i];
    final prevMs = prev.e;
    final curMs = cur.e;
    if (prevMs == null || curMs == null) return const [];

    final legKm = Geolocator.distanceBetween(
          prev.lat,
          prev.lng,
          cur.lat,
          cur.lng,
        ) /
        1000;
    if (legKm <= 0) continue;

    final legMs = curMs - prevMs;
    var legStartKm = cumulativeKm;
    cumulativeKm += legKm;

    // 한 번에 여러 km 경계를 넘을 수도 있다(신호가 끊겼다 돌아온 경우).
    while (cumulativeKm >= segmentStartKm + 1) {
      final boundaryKm = segmentStartKm + 1;
      // 이 좌표 구간 안에서 경계가 걸리는 비율.
      final ratio = (boundaryKm - legStartKm) / legKm;
      final boundaryMs = prevMs + (legMs * ratio).round();

      splits.add(KmSplit(
        endKm: boundaryKm,
        seconds: ((boundaryMs - segmentStartMs) / 1000).round(),
        partial: false,
      ));

      segmentStartKm = boundaryKm;
      segmentStartMs = boundaryMs;
      legStartKm = boundaryKm;
    }
  }

  // 마지막 자투리 — 1km 환산해야 온전한 구간과 나란히 비교된다.
  final leftoverKm = cumulativeKm - segmentStartKm;
  final leftoverMs = (route.last.e ?? segmentStartMs) - segmentStartMs;
  if (leftoverKm >= 0.01 && leftoverMs > 0) {
    splits.add(KmSplit(
      endKm: cumulativeKm,
      seconds: (leftoverMs / 1000 / leftoverKm).round(),
      partial: true,
    ));
  }

  return splits;
}

/// 막대 길이 비율(0~1) — **빠를수록 길다**(Figma).
///
/// 구간이 하나뿐이거나 전부 같은 페이스면 비교 대상이 없어 꽉 채운다.
double splitBarRatio(KmSplit split, List<KmSplit> all) {
  if (all.length < 2) return 1;
  final fastest = all.map((s) => s.seconds).reduce(math.min);
  final slowest = all.map((s) => s.seconds).reduce(math.max);
  if (slowest == fastest) return 1;
  final ratio = 1 - (split.seconds - fastest) / (slowest - fastest);
  // 가장 느린 구간도 막대가 보이긴 해야 한다.
  return ratio.clamp(0.1, 1.0);
}
