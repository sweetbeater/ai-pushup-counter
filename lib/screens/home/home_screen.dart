import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/exercise_record.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/fade_slide_in.dart';
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
  static const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

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

  @override
  Widget build(BuildContext context) {
    final workout = ref.watch(workoutProvider);
    final now = DateTime.now();
    final dateStr = '${now.month}월 ${now.day}일 ${_weekdays[now.weekday - 1]}요일';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.screenH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              FadeSlideIn(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(dateStr.toUpperCase(),
                              style: AppTheme.overline),
                          const SizedBox(height: 8),
                          const Text('오늘도\n한 번 더.', style: AppTheme.h1),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HistoryScreen()),
                      ),
                      icon: const Icon(
                        Icons.bar_chart_rounded,
                        color: AppColors.textSecondary,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: const BorderSide(color: AppColors.hairline),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              FutureBuilder<List<ExerciseRecord>>(
                future: _recordsFuture,
                builder: (context, snapshot) {
                  final records = snapshot.data ?? [];
                  return Column(
                    children: [
                      FadeSlideIn(
                        delayMs: 60,
                        child: _WeeklyHeroCard(records: records),
                      ),
                      const SizedBox(height: 12),
                      FadeSlideIn(
                        delayMs: 120,
                        child: _StatTileRow(records: records),
                      ),
                    ],
                  );
                },
              ),
              const Spacer(),
              FadeSlideIn(
                delayMs: 180,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('목표', style: AppTheme.overline),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        for (final goal in _goalOptions) ...[
                          _GoalChip(
                            label: '$goal',
                            selected: workout.goalCount == goal,
                            onTap: () => ref
                                .read(workoutProvider.notifier)
                                .setGoal(goal),
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
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: AppTheme.accentGlow,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _openWorkout,
                          child: const Text('운동 시작'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

/// 이번 주 횟수 + 요일별 미니 바 차트
class _WeeklyHeroCard extends StatelessWidget {
  final List<ExerciseRecord> records;

  const _WeeklyHeroCard({required this.records});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));

    final dailyCounts = List<int>.filled(7, 0);
    for (final r in records) {
      if (!r.date.isBefore(weekStart)) {
        final dayIndex = r.date.difference(weekStart).inDays;
        if (dayIndex >= 0 && dayIndex < 7) dailyCounts[dayIndex] += r.count;
      }
    }
    final weekTotal = dailyCounts.fold(0, (a, b) => a + b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('이번 주', style: AppTheme.overline),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$weekTotal',
                      style: AppTheme.stat.copyWith(fontSize: 40),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text('회', style: AppTheme.caption),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(
            width: 132,
            height: 64,
            child: CustomPaint(
              painter: _WeekBarsPainter(
                dailyCounts,
                todayIndex: now.weekday - 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekBarsPainter extends CustomPainter {
  final List<int> counts;
  final int todayIndex;

  _WeekBarsPainter(this.counts, {required this.todayIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final maxCount = counts.fold(1, (m, c) => c > m ? c : m);
    const barWidth = 9.0;
    final gap = (size.width - barWidth * 7) / 6;

    for (var i = 0; i < 7; i++) {
      final h = counts[i] == 0
          ? 5.0
          : 5 + (size.height - 5) * (counts[i] / maxCount);
      final paint = Paint()
        ..color = i == todayIndex
            ? AppColors.accent
            : counts[i] == 0
                ? AppColors.surfaceRaised
                : AppColors.textTertiary;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            i * (barWidth + gap),
            size.height - h,
            barWidth,
            h,
          ),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WeekBarsPainter old) =>
      old.counts != counts || old.todayIndex != todayIndex;
}

class _StatTileRow extends StatelessWidget {
  final List<ExerciseRecord> records;

  const _StatTileRow({required this.records});

  @override
  Widget build(BuildContext context) {
    final totalReps = records.fold(0, (sum, r) => sum + r.count);
    final best = records.fold(0, (b, r) => r.count > b ? r.count : b);

    return Row(
      children: [
        Expanded(child: _StatTile(label: '누적', value: '$totalReps')),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(label: '최고 기록', value: '$best', accent: true),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final bool accent;

  const _StatTile({
    required this.label,
    required this.value,
    this.accent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTheme.overline),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTheme.stat.copyWith(
              color: accent ? AppColors.accent : AppColors.textPrimary,
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
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.hairline,
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
