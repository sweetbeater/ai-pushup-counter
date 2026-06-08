import '../core/constants/app_constants.dart';
import '../core/utils/angle_calculator.dart';
import '../core/utils/pose_smoothing.dart';
import '../models/pose_landmark.dart';

enum PushupState { ready, down, up }

class PushupCounterService {
  PushupState state = PushupState.ready;
  int count = 0;
  DateTime? lastRepTime;

  final PoseSmoothing _leftSmoothing = PoseSmoothing();
  final PoseSmoothing _rightSmoothing = PoseSmoothing();
  int _missingFrames = 0;

  void Function(int count)? onCount;

  void processPose(PoseLandmarks pose) {
    if (!pose.isValid) {
      _missingFrames++;
      if (_missingFrames >= AppConstants.maxMissingFrames) {
        _leftSmoothing.reset();
        _rightSmoothing.reset();
      }
      return;
    }
    _missingFrames = 0;

    final leftAngle = calculateAngle(
      pose.leftShoulder!.position,
      pose.leftElbow!.position,
      pose.leftWrist!.position,
    );
    final rightAngle = calculateAngle(
      pose.rightShoulder!.position,
      pose.rightElbow!.position,
      pose.rightWrist!.position,
    );

    final smoothedLeft = _leftSmoothing.smooth(leftAngle);
    final smoothedRight = _rightSmoothing.smooth(rightAngle);
    final avgAngle = (smoothedLeft + smoothedRight) / 2;

    _updateState(avgAngle);
  }

  void _updateState(double angle) {
    switch (state) {
      case PushupState.ready:
      case PushupState.up:
        if (angle <= AppConstants.downAngleThreshold) {
          state = PushupState.down;
        }
      case PushupState.down:
        if (angle >= AppConstants.upAngleThreshold) {
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
