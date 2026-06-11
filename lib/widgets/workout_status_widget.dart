import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../providers/workout_provider.dart';

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
      WorkoutStatus.countdown => ('$countdownValue', AppColors.accent),
      WorkoutStatus.exercising => ('운동 중', AppColors.accent),
      WorkoutStatus.finished => ('완료', AppColors.success),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
