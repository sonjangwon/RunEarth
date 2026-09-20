import 'package:flutter/material.dart';

/// Run Earth 디자인 토큰 — 색상.
///
/// 정본: `docs/Run Earth_기능정의서.md` 7-1 (색상 토큰),
/// 7-3 (러닝 타입 뱃지), 7-4 (스트릭 인디케이터).
/// 코드에서는 반드시 이 클래스의 상수를 사용하고, 화면에 hex 를 직접 쓰지 않는다.
abstract final class AppColors {
  // ── 기본 토큰 ──────────────────────────────────────────────
  /// 앱 전체 배경
  static const background = Color(0xFF070911);

  /// 카드 배경
  static const card = Color(0xFF0D1018);

  /// 기본 텍스트
  static const foreground = Color(0xFFEDF0F7);

  /// 네온 그린 — 주요 액션·강조
  static const primary = Color(0xFF00E87A);

  /// 오렌지 — 보조 강조
  static const accent = Color(0xFFFF5F1F);

  /// 카드·구분선 테두리 (white @ 7%)
  static const border = Color(0x12FFFFFF);

  /// 비활성 배경
  static const muted = Color(0xFF151923);

  /// 보조 텍스트
  static const mutedForeground = Color(0xFF6B7280);

  // ── 러닝 타입 뱃지 (7-3) ───────────────────────────────────
  /// 일반 러닝
  static const typeNormal = Color(0xFF00E87A);

  /// 테마 러닝
  static const typeTheme = Color(0xFF3B82F6);

  /// 온라인 마라톤
  static const typeOnline = Color(0xFFFACC15);

  /// 뱃지 배경용 옅은 알파(0x18) 처리.
  static Color badgeBackground(Color base) => base.withAlpha(0x18);

  // ── 미세먼지 4단계 (4-2 섹션 B) ────────────────────────────
  // 에어코리아 표준 색계를 따른다(2026-09-20 확정) — 기상·대기 앱 어디서나
  // 같은 의미로 쓰여 사용자가 새로 배울 게 없다. 네 색 모두 기존 토큰과
  // 같은 값이라 팔레트가 늘어나지도 않는다.
  /// 좋음 — 파랑(러닝 타입 '테마' 와 같은 값)
  static const dustGood = typeTheme;

  /// 보통 — 네온 그린
  static const dustModerate = primary;

  /// 나쁨 — 오렌지
  static const dustBad = accent;

  /// 매우나쁨 — 빨강(스트릭 7일과 같은 값)
  static const dustVeryBad = Color(0xFFEF4444);

  // ── 스트릭 인디케이터 (7-4) ────────────────────────────────
  /// 연속 러닝일 수(1~7)에 대응하는 채움 색.
  /// 1~3일 초록 · 4~6일 주황 · 7일 빨강. 미달성/미래는 null.
  static Color? streakFill(int? consecutiveDays) {
    if (consecutiveDays == null || consecutiveDays < 1) return null;
    if (consecutiveDays <= 3) return const Color(0xFF00E87A);
    if (consecutiveDays <= 6) return const Color(0xFFFF5F1F);
    return const Color(0xFFEF4444);
  }
}
