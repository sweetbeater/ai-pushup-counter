import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exercise_record.dart';
import '../../providers/workout_provider.dart';
import '../workout/workout_screen.dart';
import '../history/history_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late Future<List<ExerciseRecord>> _recordsFuture;

  static const _goalOptions = [10, 20, 30, 50];

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  void _loadRecords() {
    _recordsFuture = ref.read(storageProvider).getRecords();
  }

  Future<void> _openWorkout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutScreen()),
    );
    // 운동 후 돌아오면 통계 갱신
    setState(_loadRecords);
  }

  Future<void> _openHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PUSH UP',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                  ),
                  IconButton(
                    onPressed: _openHistory,
                    icon: const Icon(
                      Icons.history,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text(
                'AI가 자세를 보고 카운트합니다',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),
              FutureBuilder<List<ExerciseRecord>>(
                future: _recordsFuture,
                builder: (context, snapshot) {
                  final records = snapshot.data ?? [];
                  return _StatsCard(records: records);
                },
              ),
              const Spacer(),
              const Text(
                '목표 횟수',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (final goal in _goalOptions) ...[
                    _GoalChip(
                      label: '$goal',
                      selected: workout.goalCount == goal,
                      onTap: () =>
                          ref.read(workoutProvider.notifier).setGoal(goal),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _GoalChip(
                    label: '무제한',
                    selected: workout.goalCount == null,
                    onTap: () =>
                        ref.read(workoutProvider.notifier).setGoal(null),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _openWorkout,
                child: const Text('운동 시작'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsCard extends StatelessWidget {
  final List<ExerciseRecord> records;

  const _StatsCard({required this.records});

  @override
  Widget build(BuildContext context) {
    final totalReps = records.fold(0, (sum, r) => sum + r.count);
    final best = records.fold(0, (b, r) => r.count > b ? r.count : b);

    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final weekReps = records
        .where((r) => !r.date.isBefore(weekStart))
        .fold(0, (sum, r) => sum + r.count);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _StatItem(label: '누적', value: '$totalReps'),
          _divider(),
          _StatItem(label: '이번 주', value: '$weekReps'),
          _divider(),
          _StatItem(label: '최고 기록', value: '$best', accent: true),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 36,
        color: AppColors.border,
      );
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _StatItem({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.numberStyle.copyWith(
              fontSize: 28,
              letterSpacing: -1,
              color: accent ? AppColors.accent : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GoalChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.onAccent : AppColors.textSecondary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
