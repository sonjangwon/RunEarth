import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Run Earth 앱 테마 (다크 전용).
///
/// 정본: `docs/Run Earth_기능정의서.md` 7장.
/// - 한글 전체: Noto Sans KR
/// - 운동 수치(거리·페이스·타임): Barlow Condensed → [AppTextStyles.display]
/// - 고정폭 데이터(D-day·포인트·버전): DM Mono → [AppTextStyles.mono]
abstract final class AppTheme {
  static ThemeData get dark {
    const scheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: Colors.black,
      secondary: AppColors.accent,
      onSecondary: Colors.black,
      surface: AppColors.card,
      onSurface: AppColors.foreground,
      outline: AppColors.border,
      error: Color(0xFFEF4444),
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: GoogleFonts.notoSansKrTextTheme(base.textTheme).apply(
        bodyColor: AppColors.foreground,
        displayColor: AppColors.foreground,
      ),
      cardTheme: const CardThemeData(
        color: AppColors.card,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: AppColors.border),
        ),
      ),
      dividerColor: AppColors.border,
    );
  }
}

/// docs 7-2 타이포그래피 역할별 헬퍼.
abstract final class AppTextStyles {
  /// 운동 수치·큰 숫자 (Barlow Condensed, 기본 w900).
  static TextStyle display({
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w900,
    Color color = AppColors.foreground,
    double? letterSpacing,
  }) =>
      GoogleFonts.barlowCondensed(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: 1.0,
      );

  /// 영문 본문·UI (DM Sans).
  static TextStyle sans({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.foreground,
  }) =>
      GoogleFonts.dmSans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  /// 고정폭 데이터 (DM Mono) — D-day, 포인트, 버전 등.
  static TextStyle mono({
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.foreground,
    double? letterSpacing,
  }) =>
      GoogleFonts.dmMono(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
      );
}
