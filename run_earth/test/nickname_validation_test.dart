import 'package:flutter_test/flutter_test.dart';
import 'package:run_earth/features/profile/presentation/nickname_edit_screen.dart';

/// 닉네임 규칙(profile-settings.md 3, 2026-09-26 확정)을 문서 문장 그대로 건다.
/// 규칙이 코드에만 있으면 다음에 누가 바꿔도 어긋난 걸 알 방법이 없다.
void main() {
  group('validateNickname', () {
    test('2~12자는 통과한다', () {
      expect(validateNickname('가나'), isNull);
      expect(validateNickname('열두자리닉네임입니다'), isNull);
      expect(validateNickname('runner01'), isNull);
    });

    test('앞뒤 공백은 떼고 센다', () {
      expect(validateNickname('  가나  '), isNull);
      expect(validateNickname('  가  '), isNotNull);
    });

    test('중간 공백은 막는다', () {
      expect(validateNickname('홍 길동'), isNotNull);
    });

    test('빈 값과 1자는 막는다', () {
      expect(validateNickname(''), isNotNull);
      expect(validateNickname('   '), isNotNull);
      expect(validateNickname('가'), isNotNull);
    });

    test('13자는 막는다', () {
      expect(validateNickname('가' * 13), isNotNull);
      expect(validateNickname('가' * 12), isNull);
    });

    test('이모지는 runes 로 세서 1자다 — length 로 세면 2자로 잡힌다', () {
      // '🏃' 는 UTF-16 으로 2칸이라 String.length 가 2 를 준다.
      expect('🏃'.length, 2);
      expect(validateNickname('🏃'), isNotNull, reason: '1자라 길이 미달');
      expect(validateNickname('🏃🏃'), isNull, reason: '2자라 통과');
      expect(validateNickname('🏃' * 12), isNull, reason: '12자라 통과');
      expect(validateNickname('🏃' * 13), isNotNull, reason: '13자라 초과');
    });
  });
}
