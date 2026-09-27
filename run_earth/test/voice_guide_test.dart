import 'package:flutter_test/flutter_test.dart';
import 'package:run_earth/features/run/data/voice_guide.dart';

/// 음성 안내 **문구 조립** 검증.
///
/// 소리는 기기에서 들어봐야 하지만, 어떤 문장을 넘기는지는 여기서 잡는다.
/// 기호(`'`·`"`)나 `km` 가 섞여 들어가면 엔진이 이상하게 읽는데,
/// 그건 들어보기 전에는 모르므로 **문장 단계에서 막는다.**
void main() {
  group('spokenDuration', () {
    test('분과 초를 한글 단위로 읽는다', () {
      expect(spokenDuration(388), "6분 28초");
    });

    test('0초는 빼고 읽는다 — "6분 0초" 는 어색하다', () {
      expect(spokenDuration(360), '6분');
    });

    test('1분 미만은 초만 읽는다', () {
      expect(spokenDuration(45), '45초');
    });

    test('10분을 넘는 페이스도 그대로 읽는다 (걷기 속도)', () {
      // 2026-09-27 실측 기록이 실제로 12분 53초였다.
      expect(spokenDuration(773), '12분 53초');
    });
  });

  group('spokenDistance', () {
    test('정수면 소수점을 떼고 읽는다', () {
      expect(spokenDistance(3.0), '3킬로미터');
    });

    test('소수는 첫째 자리까지', () {
      expect(spokenDistance(3.24), '3.2킬로미터');
      expect(spokenDistance(142.63), '142.6킬로미터');
    });

    test("단위는 'km' 가 아니라 '킬로미터'", () {
      expect(spokenDistance(5).contains('km'), isFalse);
    });
  });

  group('kmMessage', () {
    test('첫 구간은 평균을 읽지 않는다 — 구간과 값이 같다', () {
      expect(
        kmMessage(km: 1, splitSeconds: 388, avgSeconds: 388),
        '1킬로미터, 6분 28초',
      );
    });

    test('2km 부터 구간과 평균을 함께 읽는다', () {
      expect(
        kmMessage(km: 2, splitSeconds: 388, avgSeconds: 401),
        '2킬로미터, 구간 6분 28초, 평균 6분 41초',
      );
    });

    test('거리에 못 더한 구간이면 페이스 없이 거리만 읽는다', () {
      expect(kmMessage(km: 2, splitSeconds: null), '2킬로미터');
    });

    test('문구에 따옴표 기호가 섞이지 않는다', () {
      final msg = kmMessage(km: 3, splitSeconds: 388, avgSeconds: 401);
      expect(msg.contains("'"), isFalse);
      expect(msg.contains('"'), isFalse);
    });
  });

  group('finishMessage', () {
    test('평소에는 여정 잔여 거리를 알려준다', () {
      expect(
        finishMessage(cityName: '전주', remainingKm: 142.63),
        '러닝을 종료합니다. 전주까지 142.6킬로미터 남았습니다',
      );
    });

    test('도시에 도착한 날은 멘트가 바뀐다', () {
      expect(
        finishMessage(cityName: '전주', remainingKm: 0, arrived: true),
        '러닝을 종료합니다. 전주에 도착했습니다',
      );
    });
  });

  test('출발 멘트', () {
    expect(startMessage(), '러닝을 시작합니다');
  });
}
