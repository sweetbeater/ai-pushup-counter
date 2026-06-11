import 'package:flutter/material.dart';

/// 디자인 시스템 v2 "FORGE"
/// 컨셉: 어두운 체육관, 한 줄기 조명 — 깊은 다크 베이스 + 시그널 오렌지 단일 악센트.
/// 악센트는 화면당 1곳(핵심 숫자 1개 + 버튼 1개)에만 사용한다.
class AppColors {
  // 레이어
  static const background = Color(0xFF0A0B0D);
  static const surface = Color(0xFF13151A);
  static const surfaceRaised = Color(0xFF1A1D24);
  static const hairline = Color(0x14FFFFFF); // white 8%

  // 악센트: 시그널 오렌지
  static const accent = Color(0xFFFF5C38);
  static const onAccent = Color(0xFFFFFFFF);

  // 텍스트
  static const textPrimary = Color(0xFFF5F6F8);
  static const textSecondary = Color(0xFF9BA1AC);
  static const textTertiary = Color(0xFF5E6470);

  static const danger = Color(0xFFFF5A5A);
  static const success = Color(0xFF3EE08F);
}

/// 4pt 그리드 스페이싱
class AppSpacing {
  static const double screenH = 24; // 화면 좌우 여백
  static const double section = 32; // 섹션 간격
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
              borderRadius: BorderRadius.circular(18),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        dividerColor: AppColors.hairline,
        useMaterial3: true,
      );

  // ── 타이포그래피 스케일 ──────────────────────────────
  static const _tabular = [FontFeature.tabularFigures()];

  /// 운동 중 카운트
  static const display = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 104,
    fontWeight: FontWeight.w800,
    letterSpacing: -3,
    height: 1.0,
    fontFeatures: _tabular,
  );

  /// 결과 횟수
  static const hero = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 64,
    fontWeight: FontWeight.w800,
    letterSpacing: -2,
    height: 1.0,
    fontFeatures: _tabular,
  );

  /// 홈 인사말
  static const h1 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.5,
    height: 1.15,
  );

  static const h2 = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
  );

  /// 통계 숫자
  static const stat = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -1,
    height: 1.0,
    fontFeatures: _tabular,
  );

  static const body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 15,
    fontWeight: FontWeight.w500,
    height: 1.4,
  );

  static const caption = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  /// 라벨 (REPS, 누적 등)
  static const overline = TextStyle(
    color: AppColors.textTertiary,
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.2,
  );

  // ── 형태 & 깊이 ─────────────────────────────────────
  static final cardDecoration = BoxDecoration(
    color: AppColors.surface,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: AppColors.hairline),
  );

  /// 악센트 버튼 글로우 — "조명" 컨셉의 깊이감
  static final accentGlow = [
    BoxShadow(
      color: AppColors.accent.withValues(alpha: 0.25),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}
