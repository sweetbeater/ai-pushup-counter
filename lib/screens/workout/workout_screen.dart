import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCamera());
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

        final landmarks = await poseService.processImage(
          image,
          camera,
          MediaQuery.of(context).size,
        );

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

  @override
  Widget build(BuildContext context) {
    final cameraInit = ref.watch(cameraInitProvider);
    final workout = ref.watch(workoutProvider);
    final landmarks = ref.watch(poseLandmarksProvider);
    final cameraController =
        ref.watch(cameraServiceProvider).controller;

    if (workout.status == WorkoutStatus.finished) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              count: workout.count,
              durationSeconds: workout.durationSeconds,
              date: DateTime.now(),
            ),
          ),
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            cameraInit.when(
              data: (_) => cameraController != null
                  ? CameraPreviewWidget(
                      controller: cameraController,
                      landmarks: landmarks,
                    )
                  : const Center(child: Text('카메라 없음')),
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  Center(child: Text('카메라 오류: $e')),
            ),
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: WorkoutStatusWidget(
                  status: workout.status,
                  countdownValue: workout.countdownValue,
                ),
              ),
            ),
            if (workout.status == WorkoutStatus.exercising)
              Positioned(
                top: 80,
                left: 0,
                right: 0,
                child: Center(child: CountDisplay(count: workout.count)),
              ),
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (workout.status == WorkoutStatus.idle)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(140, 52),
                      ),
                      onPressed: () =>
                          ref.read(workoutProvider.notifier).startWorkout(),
                      child: const Text('시작',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                  if (workout.status == WorkoutStatus.exercising ||
                      workout.status == WorkoutStatus.countdown)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(140, 52),
                      ),
                      onPressed: () =>
                          ref.read(workoutProvider.notifier).stopWorkout(),
                      child: const Text('종료',
                          style: TextStyle(fontSize: 18, color: Colors.white)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
