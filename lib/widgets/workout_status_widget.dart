import 'package:flutter/material.dart';
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
      WorkoutStatus.idle => ('준비', Colors.grey),
      WorkoutStatus.countdown => ('$countdownValue', Colors.orange),
      WorkoutStatus.exercising => ('운동 중', Colors.green),
      WorkoutStatus.finished => ('완료', Colors.blue),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
