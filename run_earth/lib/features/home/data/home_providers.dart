import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/run.dart';
import '../../../core/models/streak_day.dart';
import '../../records/data/records_providers.dart';
import 'journey_master.dart';

// ── 통계 (총 거리·시간·횟수) ────────────────────────────────────────

/// 홈 상단 통계 카드 값.
class HomeStats {
  const HomeStats({
    required this.totalKm,
    required this.totalSeconds,
    required this.count,
  });

  final double totalKm;
  final int totalSeconds;
  final int count;

  static const empty = HomeStats(totalKm: 0, totalSeconds: 0, count: 0);

  int get totalHours => totalSeconds ~/ 3600;
  int get totalMinutes => (totalSeconds % 3600) ~/ 60;

  /// "98h 48m" 형태.
  String get durationLabel => '${totalHours}h ${totalMinutes}m';
}

/// 로컬 DB 전체 기록에서 통계 집계.
///
/// 미완료 러닝(`isIncomplete`)은 세지 않는다 — 0km 기록 정책(2026-09-23).
/// 기록 자체는 DB 에 그대로 남아 있고, 집계에서만 빠진다.
final homeStatsProvider = Provider<HomeStats>((ref) {
  final all = ref.watch(runsStreamProvider).valueOrNull;
  if (all == null) return HomeStats.empty;
  final runs = all.where((r) => !r.isIncomplete).toList();
  if (runs.isEmpty) return HomeStats.empty;
  var km = 0.0;
  var sec = 0;
  for (final r in runs) {
    km += r.km;
    sec += r.durSeconds;
  }
  return HomeStats(totalKm: km, totalSeconds: sec, count: runs.length);
});

// ── 여정 (마스터 경로 진행률) ──────────────────────────────────────

/// 여정 카드에 표시할 진행 상태.
class JourneyProgress {
  const JourneyProgress({
    required this.absolutePositionKm,
    required this.fromCity,
    required this.toCity,
    required this.milestones,
  });

  /// 마스터 경로상 절대 위치 = 시작도시 누적km + 총 달린 거리.
  final double absolutePositionKm;
  final JourneyCity fromCity;
  final JourneyCity toCity;

  /// 마일스톤 점 표시용 윈도우(최대 5개).
  final List<JourneyMilestone> milestones;

  /// 현재 구간 진행률 0.0~1.0.
  double get segmentPct {
    final span = toCity.cumulativeKm - fromCity.cumulativeKm;
    if (span <= 0) return 1.0;
    return ((absolutePositionKm - fromCity.cumulativeKm) / span)
        .clamp(0.0, 1.0);
  }

  /// 다음 도시까지 남은 거리(km).
  double get remainingKm =>
      math.max(0, toCity.cumulativeKm - absolutePositionKm);
}

/// 마일스톤 점 1개 (도착=done, 현재 목적지=current).
class JourneyMilestone {
  const JourneyMilestone({
    required this.name,
    required this.done,
    required this.current,
  });
  final String name;
  final bool done;
  final bool current;
}

/// 총 달린 거리 기반 여정 진행 계산.
final journeyProgressProvider = Provider<JourneyProgress>((ref) {
  final stats = ref.watch(homeStatsProvider);
  final start = journeyRoute[kDefaultStartCityIndex];
  final absolute = start.cumulativeKm + stats.totalKm;

  // 마지막으로 지난(도달한) 도시 = cumulativeKm <= 절대위치 중 가장 뒤.
  var fromIndex = 0;
  for (var i = 0; i < journeyRoute.length; i++) {
    if (journeyRoute[i].cumulativeKm <= absolute) {
      fromIndex = i;
    } else {
      break;
    }
  }
  // 마지막 도시 도달 시(엣지케이스, journey.md 미확정) — 한 칸 뒤를 from 으로 잡아
  // 진행률 100% 로 표시.
  final lastIndex = journeyRoute.length - 1;
  if (fromIndex >= lastIndex) fromIndex = lastIndex - 1;
  final targetIndex = fromIndex + 1;

  // 마일스톤 윈도우: 현재 목적지가 보이도록 최대 5개.
  const windowSize = 5;
  final start0 = (targetIndex - 3)
      .clamp(0, math.max(0, journeyRoute.length - windowSize))
      .toInt();
  final end0 = math.min(journeyRoute.length, start0 + windowSize);
  final milestones = <JourneyMilestone>[
    for (var i = start0; i < end0; i++)
      JourneyMilestone(
        name: journeyRoute[i].name,
        done: journeyRoute[i].cumulativeKm <= absolute && i != targetIndex,
        current: i == targetIndex,
      ),
  ];

  return JourneyProgress(
    absolutePositionKm: absolute,
    fromCity: journeyRoute[fromIndex],
    toCity: journeyRoute[targetIndex],
    milestones: milestones,
  );
});

// ── 스트릭 (이번 주 + 주 연속) ─────────────────────────────────────

const _weekdayNames = ['월', '화', '수', '목', '금', '토', '일'];

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Run 의 날짜를 DateTime(날짜만) 으로 복원. date "MM.DD" + year 사용.
DateTime? _runDate(Run r) {
  final parts = r.date.split('.');
  if (parts.length != 2) return null;
  final mm = int.tryParse(parts[0]);
  final dd = int.tryParse(parts[1]);
  if (mm == null || dd == null) return null;
  return DateTime(r.year, mm, dd);
}

/// 스트릭 카드 전체 상태.
class StreakInfo {
  const StreakInfo({required this.week, required this.weekStreakCount});

  /// 이번 주 7일(월~일).
  final List<StreakDay> week;

  /// "N주 연속" 뱃지 값 — 주당 1회 이상 달린 연속 주 수(A안).
  final int weekStreakCount;

  /// 이번 주 안에서 가장 길었던 연속 일수. 카드의 불꽃 크기와 글로우 색이
  /// 이 값을 따른다(Figma).
  ///
  /// 새 필드가 아니라 [week] 에서 파생한다 — [StreakDay.consec] 이 이미
  /// 날짜별 연속 일수를 들고 있어서, 따로 들고 있으면 둘이 어긋날 수 있다.
  int get maxConsec {
    var m = 0;
    for (final d in week) {
      final c = d.consec ?? 0;
      if (c > m) m = c;
    }
    return m;
  }

  static const empty = StreakInfo(week: [], weekStreakCount: 0);
}

/// 로컬 DB 기록으로 이번 주 스트릭 + 주 연속 계산.
final streakProvider = Provider<StreakInfo>((ref) {
  final runs = ref.watch(runsStreamProvider).valueOrNull ?? const <Run>[];
  final today = _dateOnly(DateTime.now());

  // 러닝한 날짜 집합.
  // 미완료 러닝(`isIncomplete`)은 제외한다 — START 만 눌렀다 만 기록이 스트릭을
  // 채우면 "매일 뛰었다"가 "매일 버튼을 눌렀다"가 된다. 0km 기록 정책(2026-09-20).
  final ranDates = <DateTime>{};
  for (final r in runs) {
    if (r.isIncomplete) continue;
    final d = _runDate(r);
    if (d != null) ranDates.add(d);
  }

  bool ranOn(DateTime d) => ranDates.contains(_dateOnly(d));

  /// d 까지 연속으로 달린 일수(하루라도 빠지면 끊김). streak.md §2.
  int consecOn(DateTime d) {
    var n = 0;
    var cur = _dateOnly(d);
    while (ranDates.contains(cur)) {
      n++;
      cur = cur.subtract(const Duration(days: 1));
    }
    return n;
  }

  // 이번 주 월요일.
  final monday = today.subtract(Duration(days: today.weekday - 1));
  final week = <StreakDay>[
    for (var i = 0; i < 7; i++)
      () {
        final d = monday.add(Duration(days: i));
        final isFuture = d.isAfter(today);
        final ran = !isFuture && ranOn(d);
        return StreakDay(
          name: _weekdayNames[i],
          date: '${d.month}/${d.day}',
          ran: ran,
          consec: ran ? consecOn(d) : null,
          today: d == today,
          future: isFuture,
        );
      }(),
  ];

  // 주 연속(A안): 그 주에 러닝 1건 이상인 주가 연속 몇 주인지.
  // 진행 중인 이번 주는 이미 달렸으면 포함, 아직이면 빼되 연속을 끊지 않음.
  bool weekHasRun(DateTime weekMonday) {
    for (var i = 0; i < 7; i++) {
      if (ranDates.contains(weekMonday.add(Duration(days: i)))) return true;
    }
    return false;
  }

  var weekStreak = 0;
  if (weekHasRun(monday)) weekStreak++;
  var prev = monday.subtract(const Duration(days: 7));
  while (weekHasRun(prev)) {
    weekStreak++;
    prev = prev.subtract(const Duration(days: 7));
  }

  return StreakInfo(week: week, weekStreakCount: weekStreak);
});
