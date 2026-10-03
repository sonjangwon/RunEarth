import 'package:flutter_test/flutter_test.dart';
import 'package:run_earth/core/models/enums.dart';
import 'package:run_earth/core/models/run.dart';

Run _run({required double km, int kcal = 0}) => Run(
      id: 'run_test',
      date: '10.03',
      day: '토',
      km: km,
      pace: "9'28\"",
      dur: '24:12',
      kcal: kcal,
      type: RecordType.normal,
      year: 2026,
      month: 10,
    );

void main() {
  test('체중 80kg 가정으로 거리에 비례해 추정한다', () {
    expect(estimateKcal(2.56), 205);
    expect(estimateKcal(10), 800);
  });

  test('저장값이 없으면 추정값을 보인다', () {
    expect(_run(km: 2.56).displayKcal, 205);
  });

  test('저장값(워치 등)이 있으면 그것을 우선한다', () {
    expect(_run(km: 2.56, kcal: 180).displayKcal, 180);
  });

  test('0km 미완료 기록은 0 — 화면에서 -- 로 비워진다', () {
    expect(_run(km: 0).displayKcal, 0);
  });
}
