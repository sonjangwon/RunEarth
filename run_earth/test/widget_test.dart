import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:run_earth/main.dart';

void main() {
  testWidgets('앱 실행 시 홈 탭과 5개 탭바가 렌더된다', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: RunEarthApp()));
    await tester.pumpAndSettle();

    // 홈 탭 화면
    expect(find.text('홈'), findsWidgets);
    // 하단 탭바 라벨
    expect(find.text('기록'), findsOneWidget);
    expect(find.text('프로필'), findsOneWidget);
  });
}
