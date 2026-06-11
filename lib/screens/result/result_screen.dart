import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/fade_slide_in.dart';
import '../../widgets/liquid_glass.dart';
import '../../widgets/progress_ring.dart';

class ResultScreen extends StatelessWidget {
  final int count;
  final int durationSeconds;
  final DateTime date;
  final String exerciseName;
  final bool isNewRecord;
  final int? goalCount;

  const ResultScreen({
    super.key,
    required this.count,
    required this.durationSeconds,
    required this.date,
    this.exerciseName = '팔굽혀펴기',
    this.isNewRecord = false,
    this.goalCount,
  });

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '$m분 $s초' : '$s초';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    // 목표가 있으면 달성률, 없으면 링 가득
    final progress = goalCount != null && goalCount! > 0
        ? count / goalCount!
        : 1.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AmbientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                FadeSlideIn(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$exerciseName 완료'.toUpperCase(),
                        style: AppTheme.overline.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      if (isNewRecord)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: const Text(
                            '🏆 신기록',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Center(
                    child: FadeSlideIn(
                      delayMs: 80,
                      child: ProgressRing(
                        progress: progress,
                        size: 280,
                        strokeWidth: 10,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 0부터 차오르는 count-up — 성취의 한 장면
                            TweenAnimationBuilder<int>(
                              tween: IntTween(begin: 0, end: count),
                              duration: const Duration(milliseconds: 800),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, _) => Text(
                                '$value',
                                style: AppTheme.hero.copyWith(
                                  fontSize: 88,
                                  color: isNewRecord
                                      ? AppColors.accent
                                      : AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'REPS',
                              style: AppTheme.overline.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                FadeSlideIn(
                  delayMs: 160,
                  child: LiquidGlass(
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoItem(
                            label: '운동 시간',
                            value: _formatDuration(durationSeconds),
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 36,
                          color: AppColors.hairline,
                        ),
                        Expanded(
                          child: _InfoItem(label: '날짜', value: dateStr),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                FadeSlideIn(
                  delayMs: 220,
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).popUntil((route) => route.isFirst),
                      child: const Text('홈으로'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppTheme.overline),
      ],
    );
  }
}
