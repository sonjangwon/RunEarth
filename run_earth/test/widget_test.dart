import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:run_earth/main.dart';

void main() {
  testWidgets('앱 실행 시 홈 탭과 5개 탭바가 렌더된다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RunEarthApp()));
    // `pumpAndSettle` 을 쓰지 않는다 — 로딩 뼈대(`SkeletonBox`)의 펄스가
    // `repeat(reverse: true)` 라 영원히 끝나지 않고, 기다리면 타임아웃한다.
    // 테스트 환경에서는 로컬 DB 스트림이 첫 값을 주지 않아 홈이 뼈대에
    // 머문 채로 계속 뛴다.
    //
    // 대신 스플래시 최소 노출(800ms, `splash_screen.dart` `_minSplash`)을
    // 넘기고 라우팅이 끝날 만큼만 손으로 돌린다.
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 100));

    // 홈 탭 화면
    expect(find.text('홈'), findsWidgets);
    // 하단 탭바 라벨
    expect(find.text('기록'), findsOneWidget);
    expect(find.text('프로필'), findsOneWidget);
  });
}
