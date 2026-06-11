import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../providers/workout_provider.dart';

/// 글래스(blur) 배경의 상태 필.
class WorkoutStatusWidget extends StatelessWidget {
  final WorkoutStatus status;
  final int countdownValue;

  const WorkoutStatusWidget({
    super.key,
    required this.status,
    required this.countdownValue,
  });

  @override
  Widget build(BuildContext context) {
    final (text, color) = switch (status) {
      WorkoutStatus.idle => ('준비', AppColors.textSecondary),
      WorkoutStatus.countdown => ('곧 시작', AppColors.accent),
      WorkoutStatus.exercising => ('운동 중', AppColors.accent),
      WorkoutStatus.finished => ('완료', AppColors.success),
    };

    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: AppColors.hairline),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
