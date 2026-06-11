import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/exercises.dart';
import '../models/exercise_config.dart';
import '../models/exercise_record.dart';
import '../services/exercise_counter_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

enum WorkoutStatus { idle, countdown, exercising, finished }

class WorkoutState {
  final WorkoutStatus status;
  final int count;
  final int countdownValue;
  final int durationSeconds;
  final ExerciseConfig exercise;

  /// 목표 횟수 (null = 무제한)
  final int? goalCount;
  final bool isNewRecord;

  const WorkoutState({
    this.status = WorkoutStatus.idle,
    this.count = 0,
    this.countdownValue = AppConstants.countdownSeconds,
    this.durationSeconds = 0,
    this.exercise = Exercises.pushup,
    this.goalCount,
    this.isNewRecord = false,
  });

  static const _unset = Object();

  WorkoutState copyWith({
    WorkoutStatus? status,
    int? count,
    int? countdownValue,
    int? durationSeconds,
    ExerciseConfig? exercise,
    Object? goalCount = _unset,
    bool? isNewRecord,
  }) =>
      WorkoutState(
        status: status ?? this.status,
        count: count ?? this.count,
        countdownValue: countdownValue ?? this.countdownValue,
        durationSeconds: durationSeconds ?? this.durationSeconds,
        exercise: exercise ?? this.exercise,
        goalCount:
            identical(goalCount, _unset) ? this.goalCount : goalCount as int?,
        isNewRecord: isNewRecord ?? this.isNewRecord,
      );
}

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  late ExerciseCounterService _counter;
  final TtsService _tts = TtsService();
  final StorageService _storage = StorageService();

  Timer? _countdownTimer;
  Timer? _durationTimer;
  DateTime? _startTime;
  bool _goalAnnounced = false;

  WorkoutNotifier() : super(const WorkoutState()) {
    _counter = ExerciseCounterService(state.exercise);
    _tts.initialize();
    _counter.onCount = _onCount;
  }

  ExerciseCounterService get counterService => _counter;

  void selectExercise(ExerciseConfig exercise) {
    if (state.status != WorkoutStatus.idle) return;
    _counter = ExerciseCounterService(exercise);
    _counter.onCount = _onCount;
    state = state.copyWith(exercise: exercise);
  }

  void setGoal(int? goal) {
    if (state.status != WorkoutStatus.idle) return;
    state = state.copyWith(goalCount: goal);
  }

  void startWorkout() {
    if (state.status != WorkoutStatus.idle) return;
    state = state.copyWith(
      status: WorkoutStatus.countdown,
      countdownValue: AppConstants.countdownSeconds,
    );
    _runCountdown();
  }

  void _runCountdown() {
    int remaining = AppConstants.countdownSeconds;
    _tts.speakCountdown(remaining);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      remaining--;
      state = state.copyWith(countdownValue: remaining);

      if (remaining > 0) {
        _tts.speakCountdown(remaining);
      } else {
        timer.cancel();
        _tts.speakStart();
        _beginExercise();
      }
    });
  }

  void _beginExercise() {
    _counter.reset();
    _startTime = DateTime.now();
    _goalAnnounced = false;
    state = state.copyWith(
      status: WorkoutStatus.exercising,
      count: 0,
      durationSeconds: 0,
    );
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final elapsed = DateTime.now().difference(_startTime!).inSeconds;
      state = state.copyWith(durationSeconds: elapsed);
    });
  }

  void _onCount(int count) {
    state = state.copyWith(count: count);

    final goal = state.goalCount;
    if (goal != null && count >= goal) {
      _goalAnnounced = true;
      _tts.speakGoalReached(goal);
      stopWorkout();
    } else {
      _tts.speakCount(count, goal: goal);
    }
  }

  Future<void> stopWorkout() async {
    _countdownTimer?.cancel();
    _durationTimer?.cancel();

    // 카운트다운 중 종료 → 기록 없이 대기 상태로 복귀
    if (state.status == WorkoutStatus.countdown) {
      _tts.dispose();
      state = state.copyWith(
        status: WorkoutStatus.idle,
        countdownValue: AppConstants.countdownSeconds,
      );
      return;
    }

    if (state.status != WorkoutStatus.exercising) return;

    final best = await _storage.getBestCount(state.exercise.id);
    final isNewRecord = state.count > 0 && state.count > best;

    final record = ExerciseRecord(
      date: _startTime ?? DateTime.now(),
      count: state.count,
      durationSeconds: state.durationSeconds,
      exerciseId: state.exercise.id,
      exerciseName: state.exercise.name,
    );
    await _storage.saveRecord(record);

    // 목표 달성 멘트가 이미 나간 경우 마무리 멘트는 생략
    if (!_goalAnnounced) {
      _tts.speakFinish(state.count, isNewRecord: isNewRecord);
    }

    state = state.copyWith(
      status: WorkoutStatus.finished,
      isNewRecord: isNewRecord,
    );
  }

  void resetWorkout() {
    _countdownTimer?.cancel();
    _durationTimer?.cancel();
    _counter.reset();
    state = WorkoutState(
      exercise: state.exercise,
      goalCount: state.goalCount,
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _durationTimer?.cancel();
    _tts.dispose();
    super.dispose();
  }
}

final workoutProvider =
    StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier();
});

final storageProvider = Provider<StorageService>((ref) => StorageService());
