import 'package:flutter_test/flutter_test.dart';
import 'package:run_earth/core/models/geo.dart';
import 'package:run_earth/features/run/data/km_splits.dart';

/// 서울 시청 근처에서 정북으로 [km] 만큼 떨어진 좌표.
/// 위도 1도 ≈ 111.32km 라 경도를 안 건드리면 거리 계산이 단순해진다.
LatLngPoint _north(double km, int elapsedMs) => LatLngPoint(
      lat: 37.5665 + km / 111.32,
      lng: 126.9780,
      e: elapsedMs,
    );

void main() {
  group('computeKmSplits', () {
    test('좌표가 없거나 하나뿐이면 빈 목록', () {
      expect(computeKmSplits(const []), isEmpty);
      expect(computeKmSplits([_north(0, 0)]), isEmpty);
    });

    test('시간이 없는 예전 기록은 빈 목록', () {
      final route = [
        const LatLngPoint(lat: 37.5665, lng: 126.9780),
        const LatLngPoint(lat: 37.5765, lng: 126.9780),
      ];
      expect(computeKmSplits(route), isEmpty);
    });

    test('2km 를 일정한 속도로 — 두 구간이 같은 페이스', () {
      // 6분/km 로 2km. 0.5km 마다 좌표를 찍는다.
      final route = [
        for (var i = 0; i <= 4; i++) _north(i * 0.5, (i * 180 * 1000)),
      ];
      final splits = computeKmSplits(route);

      expect(splits.length, 2);
      expect(splits[0].endKm, closeTo(1, 0.01));
      expect(splits[0].seconds, closeTo(360, 2));
      expect(splits[0].partial, isFalse);
      expect(splits[1].seconds, closeTo(360, 2));
      expect(splits[0].paceLabel, '6\'00"');
    });

    test('자투리 구간은 1km 로 환산되고 partial 로 표시된다', () {
      // 1km 를 6분에, 이어서 0.5km 를 3분 30초에(= 7분/km).
      final route = [
        _north(0, 0),
        _north(1, 360 * 1000),
        _north(1.5, (360 + 210) * 1000),
      ];
      final splits = computeKmSplits(route);

      expect(splits.length, 2);
      expect(splits[0].partial, isFalse);
      expect(splits[1].partial, isTrue);
      expect(splits[1].endKm, closeTo(1.5, 0.02));
      // 0.5km 를 210초 → 1km 환산 420초 = 7'00"
      expect(splits[1].seconds, closeTo(420, 5));
      expect(splits[1].kmLabel, '1.50');
    });

    test('1km 경계가 좌표 사이에 걸리면 보간한다', () {
      // 0 → 1.5km 를 한 번에 이동(9분). 1km 경계는 그 중간에 걸린다.
      final route = [
        _north(0, 0),
        _north(1.5, 540 * 1000),
      ];
      final splits = computeKmSplits(route);

      expect(splits.length, 2);
      // 1km 지점은 9분의 2/3 = 360초. 좌표 시간(540초)을 그대로 쓰면 틀린다.
      expect(splits[0].seconds, closeTo(360, 3));
      expect(splits[1].seconds, closeTo(360, 5));
    });

    test('일시정지는 구간 시간에 들어가지 않는다', () {
      // 1km 를 6분에 뛰고, 5분 쉬고(경과시간은 안 흐른다), 다시 1km 를 6분에.
      final route = [
        _north(0, 0),
        _north(1, 360 * 1000),
        // 쉬는 동안 e 는 멈춰 있다 — 다음 좌표도 360초에서 이어진다.
        _north(2, 720 * 1000),
      ];
      final splits = computeKmSplits(route);

      expect(splits.length, 2);
      expect(splits[1].seconds, closeTo(360, 2));
    });
  });

  group('splitBarRatio', () {
    test('구간이 하나면 꽉 채운다', () {
      const only = KmSplit(endKm: 1, seconds: 360, partial: false);
      expect(splitBarRatio(only, const [only]), 1);
    });

    test('빠른 구간이 더 길다', () {
      const fast = KmSplit(endKm: 1, seconds: 300, partial: false);
      const slow = KmSplit(endKm: 2, seconds: 420, partial: false);
      final all = [fast, slow];
      expect(splitBarRatio(fast, all), 1);
      expect(splitBarRatio(slow, all), closeTo(0.1, 0.001));
      expect(splitBarRatio(fast, all), greaterThan(splitBarRatio(slow, all)));
    });

    test('전부 같은 페이스면 다 꽉 채운다', () {
      const a = KmSplit(endKm: 1, seconds: 360, partial: false);
      const b = KmSplit(endKm: 2, seconds: 360, partial: false);
      expect(splitBarRatio(a, const [a, b]), 1);
    });
  });
}
