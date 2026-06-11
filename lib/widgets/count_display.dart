import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'progress_ring.dart';

/// 운동 중 카운트.
/// 숫자가 바뀔 때 살짝 튀어오르는 pop 모션, 목표가 있으면 진행 링으로 감싼다.
class CountDisplay extends StatelessWidget {
  final int count;
  final int? goal;

  const CountDisplay({super.key, required this.count, this.goal});

  @override
  Widget build(BuildContext context) {
    final number = TweenAnimationBuilder<double>(
      key: ValueKey(count),
      tween: Tween(begin: 1.12, end: 1.0),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: Text('$count', style: AppTheme.display),
    );

    final label = Text(
      goal != null ? '/ $goal REPS' : 'REPS',
      style: AppTheme.overline.copyWith(color: AppColors.textSecondary),
    );

    if (goal == null) {
      return Column(
        children: [number, const SizedBox(height: 8), label],
      );
    }

    return ProgressRing(
      progress: count / goal!,
      size: 248,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [number, const SizedBox(height: 8), label],
      ),
    );
  }
}
