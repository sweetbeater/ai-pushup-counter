import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/camera_provider.dart';
import '../../providers/pose_provider.dart';
import '../../providers/workout_provider.dart';
import '../../widgets/camera_preview_widget.dart';
import '../../widgets/count_display.dart';
import '../../widgets/workout_status_widget.dart';
import '../result/result_screen.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCamera();
      ref.listenManual(workoutProvider, (previous, next) {
        // 카운트마다 미디엄 햅틱 — 보지 않아도 몸으로 느끼는 피드백
        if (next.status == WorkoutStatus.exercising &&
            previous != null &&
            next.count > previous.count) {
          HapticFeedback.mediumImpact();
        }

        if (previous?.status != WorkoutStatus.finished &&
            next.status == WorkoutStatus.finished &&
            mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => ResultScreen(
                count: next.count,
                durationSeconds: next.durationSeconds,
                date: DateTime.now(),
                exerciseName: next.exercise.name,
                isNewRecord: next.isNewRecord,
                goalCount: next.goalCount,
              ),
            ),
          );
          // 다음 운동을 위해 상태 초기화 (finished로 남는 버그 방지)
          ref.read(workoutProvider.notifier).resetWorkout();
        }
      });
    });
  }

  Future<void> _initCamera() async {
    await ref.read(cameraInitProvider.future);
    final cameraService = ref.read(cameraServiceProvider);
    final poseService = ref.read(poseServiceProvider);
    final workoutNotifier = ref.read(workoutProvider.notifier);

    await cameraService.startStream((CameraImage image) async {
      if (_processing) return;
      _processing = true;

      try {
        final camera = cameraService.currentCamera;
        if (camera == null) return;

        final landmarks = await poseService.processImage(image, camera);

        if (!mounted) return;
        ref.read(poseLandmarksProvider.notifier).state = landmarks;

        final workout = ref.read(workoutProvider);
        if (workout.status == WorkoutStatus.exercising && landmarks != null) {
          workoutNotifier.counterService.processPose(landmarks);
        }
      } finally {
        _processing = false;
      }
    });
  }

  @override
  void dispose() {
    ref.read(cameraServiceProvider).stopStream();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cameraInit = ref.watch(cameraInitProvider);
    final workout = ref.watch(workoutProvider);
    final landmarks = ref.watch(poseLandmarksProvider);
    final cameraController = ref.watch(cameraServiceProvider).controller;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          cameraInit.when(
            data: (_) => cameraController != null
                ? CameraPreviewWidget(
                    controller: cameraController,
                    landmarks: landmarks,
                  )
                : const Center(
                    child: Text('카메라를 사용할 수 없습니다', style: AppTheme.body),
                  ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
            error: (e, _) => Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  '카메라 오류: $e',
                  style: AppTheme.body,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // 상단 바: 닫기 + 상태 필 + 경과 시간
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      WorkoutStatusWidget(
                        status: workout.status,
                        countdownValue: workout.countdownValue,
                      ),
                      const Spacer(),
                      SizedBox(
                        width: 52,
                        child: Text(
                          workout.status == WorkoutStatus.exercising
                              ? _formatTime(workout.durationSeconds)
                              : '',
                          textAlign: TextAlign.right,
                          style: AppTheme.caption.copyWith(
                            fontFeatures: const [
                              FontFeature.tabularFigures()
                            ],
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                if (workout.status == WorkoutStatus.exercising)
                  CountDisplay(count: workout.count, goal: workout.goalCount),
                if (workout.status == WorkoutStatus.countdown)
                  Expanded(
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 350),
                        switchInCurve: Curves.easeOutBack,
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(
                          scale: Tween(begin: 1.4, end: 1.0)
                              .animate(animation),
                          child:
                              FadeTransition(opacity: animation, child: child),
                        ),
                        child: Text(
                          '${workout.countdownValue}',
                          key: ValueKey(workout.countdownValue),
                          style: AppTheme.display.copyWith(
                            fontSize: 150,
                            color: AppColors.accent,
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  const Spacer(),
                // 하단 컨트롤
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  child: switch (workout.status) {
                    WorkoutStatus.idle => Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '카메라에 몸 전체가 나오도록 측면에 두세요',
                            style: AppTheme.caption
                                .copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 14),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: AppTheme.accentGlow,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => ref
                                    .read(workoutProvider.notifier)
                                    .startWorkout(),
                                child: const Text('시작'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    WorkoutStatus.countdown ||
                    WorkoutStatus.exercising =>
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          side: const BorderSide(color: AppColors.hairline),
                          backgroundColor:
                              AppColors.surface.withValues(alpha: 0.7),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () =>
                            ref.read(workoutProvider.notifier).stopWorkout(),
                        child: Text(
                          workout.status == WorkoutStatus.countdown
                              ? '취소'
                              : '종료',
                          style: const TextStyle(
                            color: AppColors.danger,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    WorkoutStatus.finished => const SizedBox.shrink(),
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
