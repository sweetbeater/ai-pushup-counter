import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants/app_constants.dart';
import '../models/exercise_record.dart';
import '../services/pushup_counter_service.dart';
import '../services/storage_service.dart';
import '../services/tts_service.dart';

enum WorkoutStatus { idle, countdown, exercising, finished }

class WorkoutState {
  final WorkoutStatus status;
  final int count;
  final int countdownValue;
  final int durationSeconds;

  const WorkoutState({
    this.status = WorkoutStatus.idle,
    this.count = 0,
    this.countdownValue = AppConstants.countdownSeconds,
    this.durationSeconds = 0,
  });

  WorkoutState copyWith({
    WorkoutStatus? status,
    int? count,
    int? countdownValue,
    int? durationSeconds,
  }) =>
      WorkoutState(
        status: status ?? this.status,
        count: count ?? this.count,
        countdownValue: countdownValue ?? this.countdownValue,
        durationSeconds: durationSeconds ?? this.durationSeconds,
      );
}

class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final PushupCounterService _counter = PushupCounterService();
  final TtsService _tts = TtsService();
  final StorageService _storage = StorageService();

  Timer? _countdownTimer;
  Timer? _durationTimer;
  DateTime? _startTime;

  WorkoutNotifier() : super(const WorkoutState()) {
    _tts.initialize();
    _counter.onCount = _onCount;
  }

  PushupCounterService get counterService => _counter;

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
    state = state.copyWith(status: WorkoutStatus.exercising, count: 0);
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final elapsed = DateTime.now().difference(_startTime!).inSeconds;
      state = state.copyWith(durationSeconds: elapsed);
    });
  }

  void _onCount(int count) {
    state = state.copyWith(count: count);
    _tts.speakCount(count);
  }

  Future<void> stopWorkout() async {
    _countdownTimer?.cancel();
    _durationTimer?.cancel();

    if (state.status == WorkoutStatus.exercising) {
      final record = ExerciseRecord(
        date: _startTime ?? DateTime.now(),
        count: state.count,
        durationSeconds: state.durationSeconds,
      );
      await _storage.saveRecord(record);
    }

    state = state.copyWith(status: WorkoutStatus.finished);
  }

  void resetWorkout() {
    _countdownTimer?.cancel();
    _durationTimer?.cancel();
    _counter.reset();
    state = const WorkoutState();
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
