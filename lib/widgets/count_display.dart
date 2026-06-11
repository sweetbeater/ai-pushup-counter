import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CountDisplay extends StatelessWidget {
  final int count;
  final int? goal;

  const CountDisplay({super.key, required this.count, this.goal});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$count',
          style: AppTheme.numberStyle.copyWith(fontSize: 112),
        ),
        const SizedBox(height: 4),
        Text(
          goal != null ? '/ $goal회 목표' : 'REPS',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
