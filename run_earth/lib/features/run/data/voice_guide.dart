import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 러닝 음성 안내.
///
/// 정본: `docs/features/run-flow.md` 9 '음성 안내'.
///
/// **목소리를 앱이 싣지 않는다** — 기기에 설치된 TTS 엔진과 사용자의 시스템
/// 설정(엔진·속도·톤)을 그대로 따른다. 삼성헬스도 같은 방식이고, 사용자가
/// 안드로이드 설정에서 목소리를 바꾸면 우리 안내도 함께 바뀐다.
/// (2026-09-27 노트8 확인: 삼성 TTS 엔진 · 한국어 '기본 음성 1' 하나만 설치돼
///  있어 **성별 선택지가 없다.** 기기마다 다를 수 있다.)
///
/// 문구 조립은 아래 순수 함수들이 맡는다 — 소리를 못 듣는 테스트에서도
/// 검증할 수 있어야 한다(`test/voice_guide_test.dart`).

/// 초 단위 시간을 읽을 수 있는 한국어로 바꾼다.
///
/// **기호를 쓰지 않는다.** 화면 표기인 `6'28"` 를 그대로 넘기면 따옴표를
/// 단위로 못 읽는다. 단위는 한글로 적어야 엔진이 안 헷갈린다.
///
/// - `388` → `6분 28초`
/// - `360` → `6분` (**0초는 빼고 읽는다** — "6분 0초" 는 어색하다)
/// - `45`  → `45초`
String spokenDuration(int seconds) {
  if (seconds < 0) seconds = 0;
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (m == 0) return '$s초';
  if (s == 0) return '$m분';
  return '$m분 $s초';
}

/// 거리를 읽을 수 있는 한국어로 바꾼다. 단위는 **'킬로미터'** 로 적는다 —
/// `km` 는 엔진마다 다르게 읽는다.
///
/// 정수면 소수점을 떼고(`3` → `3킬로미터`), 아니면 소수 첫째 자리까지
/// (`3.24` → `3.2킬로미터`).
String spokenDistance(double km) {
  final rounded = (km * 10).round() / 10;
  if (rounded == rounded.roundToDouble()) {
    return '${rounded.toStringAsFixed(0)}킬로미터';
  }
  return '${rounded.toStringAsFixed(1)}킬로미터';
}

/// 출발 안내.
///
/// 카운트다운이 끝나고 **자동으로** 시작되는 시점이라, 이때 폰은 이미 주머니에
/// 있을 수 있다. 그래서 '시작됐다'는 신호로서 값이 있다.
String startMessage() => '러닝을 시작합니다';

/// 1km 구간 안내.
///
/// - 첫 구간은 **평균을 읽지 않는다** — 구간 페이스와 값이 같아서 같은 숫자를
///   두 번 듣게 된다.
/// - [splitSeconds] 가 null 이면 거리만 읽는다. 신호가 끊겼다 돌아와 **거리에
///   더하지 못한 구간**이라 페이스가 의미가 없다.
String kmMessage({
  required int km,
  int? splitSeconds,
  int? avgSeconds,
}) {
  final distance = '$km킬로미터';
  if (splitSeconds == null) return distance;
  if (km <= 1 || avgSeconds == null) {
    return '$distance, ${spokenDuration(splitSeconds)}';
  }
  return '$distance, 구간 ${spokenDuration(splitSeconds)}, '
      '평균 ${spokenDuration(avgSeconds)}';
}

/// 종료 안내.
///
/// **거리·시간을 읽지 않는다** — 종료 직후 요약 화면에 크게 떠 있다. 눈앞에
/// 있는 숫자를 다시 읽어주는 건 안내가 아니다. 반대로 **여정 잔여 거리는 그
/// 화면에 없어서**, 음성이 그걸 알려주는 유일한 자리다.
///
/// [arrived] 면 도시 도착 멘트로 바뀐다 — 22개 도시에서 딱 한 번씩만 들린다.
String finishMessage({
  required String cityName,
  required double remainingKm,
  bool arrived = false,
}) {
  if (arrived) return '러닝을 종료합니다. $cityName에 도착했습니다';
  return '러닝을 종료합니다. $cityName까지 '
      '${spokenDistance(remainingKm)} 남았습니다';
}

/// TTS 래퍼. 말할 수 없는 상황(엔진 없음·한국어 미설치·iOS 미검증)에서는
/// **조용히 아무것도 하지 않는다.** 알림 권한·절전 모드와 같은 원칙으로,
/// 음성이 안 되는 것이 러닝을 막아서는 안 된다.
class VoiceGuide {
  VoiceGuide(this._tts);

  final FlutterTts _tts;

  bool _ready = false;
  bool _unavailable = false;

  /// 사용자가 이번 세션에서 음소거했는가.
  ///
  /// 🟡 **아직 저장하지 않는다** — 설정 저장소를 어디에 둘지 미정이라
  /// (drift 설정 테이블 vs `shared_preferences`) 앱을 끄면 풀린다.
  /// `docs/features/run-flow.md` 9 참조.
  bool muted = false;

  Future<void> _ensureReady() async {
    if (_ready || _unavailable) return;
    try {
      // 한국어 음성 데이터가 **엔진과 별개로** 안 깔려 있을 수 있다.
      // 그때 speak 를 부르면 아무 소리도 안 나거나 영어로 읽는다.
      final available = await _tts.isLanguageAvailable('ko-KR');
      if (available != true) {
        debugPrint('[voice] 한국어 음성 없음 — 안내를 끈다');
        _unavailable = true;
        return;
      }
      await _tts.setLanguage('ko-KR');
      // 속도·톤은 **건드리지 않는다.** 사용자가 시스템 설정에서 정해둔 값을
      // 덮어쓰면, 다른 앱과 우리 앱만 다르게 들린다.
      await _tts.awaitSpeakCompletion(true);
      _ready = true;
    } catch (e) {
      debugPrint('[voice] 초기화 실패: $e');
      _unavailable = true;
    }
  }

  /// 한 문장 읽는다. 앞 문장이 남아 있으면 **끊고 새 문장을 읽는다** —
  /// 구간 안내는 늦게 들으면 값이 틀린 정보가 된다.
  Future<void> speak(String text) async {
    if (muted) return;
    // iOS 는 Mac 이 없어 검증하지 못했다. 안드로이드만 켠다
    // (`run-flow.md` 9 '남은 것').
    if (!Platform.isAndroid) return;
    await _ensureReady();
    if (!_ready) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('[voice] 재생 실패: $e');
    }
  }

  Future<void> stop() async {
    if (!_ready) return;
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('[voice] 정지 실패: $e');
    }
  }
}

final voiceGuideProvider = Provider<VoiceGuide>((ref) {
  final guide = VoiceGuide(FlutterTts());
  ref.onDispose(guide.stop);
  return guide;
});
