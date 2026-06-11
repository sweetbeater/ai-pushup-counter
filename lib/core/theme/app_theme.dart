import 'package:flutter/material.dart';

/// 미니멀 다크 + 단일 악센트 디자인 시스템.
/// 프리미엄 피트니스 톤: 거의 검정 배경, 오프화이트 텍스트, 볼트 라임 포인트.
class AppColors {
  static const background = Color(0xFF0B0C0E);
  static const surface = Color(0xFF16181C);
  static const surfaceLight = Color(0xFF1F2228);
  static const border = Color(0xFF2A2D34);

  static const accent = Color(0xFFD2FF52);
  static const onAccent = Color(0xFF101205);

  static const textPrimary = Color(0xFFF4F5F7);
  static const textSecondary = Color(0xFF9AA0AB);
  static const textTertiary = Color(0xFF5C6270);

  static const danger = Color(0xFFFF5A5A);
  static const success = Color(0xFF5ADB8C);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accent,
          onPrimary: AppColors.onAccent,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.accent,
            foregroundColor: AppColors.onAccent,
            elevation: 0,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        dividerColor: AppColors.border,
        useMaterial3: true,
      );

  /// 큰 숫자 표시용 (카운트, 통계)
  static const numberStyle = TextStyle(
    color: AppColors.textPrimary,
    fontWeight: FontWeight.w700,
    letterSpacing: -2,
    height: 1.0,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}
