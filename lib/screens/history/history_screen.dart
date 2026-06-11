import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exercise_record.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/fade_slide_in.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return m > 0 ? '$m분 $s초' : '$s초';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storage = ref.watch(storageProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('운동 기록')),
      body: FutureBuilder<List<ExerciseRecord>>(
        future: storage.getRecords(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.hairline),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.textTertiary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '아직 기록이 없습니다',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '첫 운동을 시작해보세요',
                    style: AppTheme.caption
                        .copyWith(color: AppColors.textTertiary),
                  ),
                ],
              ),
            );
          }

          final groups = _groupByWeek(records);
          final totalReps = records.fold(0, (sum, r) => sum + r.count);

          return ListView(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenH, 8, AppSpacing.screenH, 32),
            children: [
              FadeSlideIn(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: AppTheme.cardDecoration,
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('총 운동', style: AppTheme.overline),
                            const SizedBox(height: 8),
                            Text('${records.length}회',
                                style: AppTheme.stat),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 36,
                        color: AppColors.hairline,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('누적 횟수', style: AppTheme.overline),
                            const SizedBox(height: 8),
                            Text(
                              '$totalReps',
                              style: AppTheme.stat
                                  .copyWith(color: AppColors.accent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              for (final group in groups) ...[
                const SizedBox(height: 28),
                Text(group.title, style: AppTheme.overline),
                const SizedBox(height: 12),
                for (final r in group.records) ...[
                  _RecordCard(
                    record: r,
                    duration: _formatDuration(r.durationSeconds),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  List<({String title, List<ExerciseRecord> records})> _groupByWeek(
    List<ExerciseRecord> records,
  ) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
    final lastWeekStart = weekStart.subtract(const Duration(days: 7));

    final thisWeek = <ExerciseRecord>[];
    final lastWeek = <ExerciseRecord>[];
    final earlier = <ExerciseRecord>[];

    for (final r in records) {
      if (!r.date.isBefore(weekStart)) {
        thisWeek.add(r);
      } else if (!r.date.isBefore(lastWeekStart)) {
        lastWeek.add(r);
      } else {
        earlier.add(r);
      }
    }

    return [
      if (thisWeek.isNotEmpty) (title: '이번 주', records: thisWeek),
      if (lastWeek.isNotEmpty) (title: '지난 주', records: lastWeek),
      if (earlier.isNotEmpty) (title: '이전', records: earlier),
    ];
  }
}

class _RecordCard extends StatelessWidget {
  final ExerciseRecord record;
  final String duration;

  const _RecordCard({required this.record, required this.duration});

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${record.date.month}.${record.date.day.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.hairline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.exerciseName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$dateStr · $duration',
                  style: AppTheme.caption
                      .copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${record.count}',
                  style: AppTheme.stat.copyWith(fontSize: 24),
                ),
                TextSpan(
                  text: ' 회',
                  style: AppTheme.caption
                      .copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
