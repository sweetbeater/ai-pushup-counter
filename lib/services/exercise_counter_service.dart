import '../core/constants/app_constants.dart';
import '../core/utils/angle_calculator.dart';
import '../core/utils/pose_smoothing.dart';
import '../models/exercise_config.dart';
import '../models/pose_landmark.dart';

enum PushupState { ready, down, up }

class ExerciseCounterService {
  final ExerciseConfig config;

  PushupState state = PushupState.ready;
  int count = 0;
  DateTime? lastRepTime;

  final PoseSmoothing _leftSmoothing = PoseSmoothing();
  final PoseSmoothing _rightSmoothing = PoseSmoothing();
  int _missingFrames = 0;

  void Function(int count)? onCount;

  ExerciseCounterService(this.config);

  void processPose(PoseLandmarks pose) {
    final left = config.leftJoints(pose);
    final right = config.rightJoints(pose);

    if (left == null || right == null ||
        left.s == null || left.e == null || left.w == null ||
        right.s == null || right.e == null || right.w == null) {
      _missingFrames++;
      if (_missingFrames >= AppConstants.maxMissingFrames) {
        _leftSmoothing.reset();
        _rightSmoothing.reset();
      }
      return;
    }
    _missingFrames = 0;

    final leftAngle = calculateAngle(left.s!, left.e!, left.w!);
    final rightAngle = calculateAngle(right.s!, right.e!, right.w!);

    final smoothedLeft = _leftSmoothing.smooth(leftAngle);
    final smoothedRight = _rightSmoothing.smooth(rightAngle);
    final avgAngle = (smoothedLeft + smoothedRight) / 2;

    _updateState(avgAngle);
  }

  void _updateState(double angle) {
    switch (state) {
      case PushupState.ready:
      case PushupState.up:
        if (angle <= config.downThreshold) {
          state = PushupState.down;
        }
      case PushupState.down:
        if (angle >= config.upThreshold) {
          final now = DateTime.now();
          final elapsed = lastRepTime == null
              ? AppConstants.minRepIntervalMs + 1
              : now.difference(lastRepTime!).inMilliseconds;

          if (elapsed > AppConstants.minRepIntervalMs) {
            count++;
            lastRepTime = now;
            state = PushupState.up;
            onCount?.call(count);
          }
        }
    }
  }

  void reset() {
    state = PushupState.ready;
    count = 0;
    lastRepTime = null;
    _leftSmoothing.reset();
    _rightSmoothing.reset();
    _missingFrames = 0;
  }
}
