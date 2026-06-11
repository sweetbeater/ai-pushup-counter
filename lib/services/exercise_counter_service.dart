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

  final PoseSmoothing _smoothing = PoseSmoothing();
  int _missingFrames = 0;
  int _downConfirm = 0;
  int _upConfirm = 0;

  void Function(int count)? onCount;

  ExerciseCounterService(this.config);

  void processPose(PoseLandmarks pose) {
    final angle = _measureAngle(pose);

    if (angle == null) {
      _missingFrames++;
      if (_missingFrames >= AppConstants.maxMissingFrames) {
        // 자세 추적이 끊기면 진행 중이던 반복을 무효화 (오카운트 방지)
        _smoothing.reset();
        _downConfirm = 0;
        _upConfirm = 0;
        if (state == PushupState.down) state = PushupState.ready;
      }
      return;
    }
    _missingFrames = 0;

    _updateState(_smoothing.smooth(angle));
  }

  /// 좌우 중 신뢰도(visibility)가 충분한 쪽만 사용해 각도를 측정.
  /// 측면 자세에서 반대쪽 팔이 가려져도 보이는 쪽만으로 정확히 인식된다.
  double? _measureAngle(PoseLandmarks pose) {
    final leftAngle = _sideAngle(config.leftJoints(pose));
    final rightAngle = _sideAngle(config.rightJoints(pose));

    if (leftAngle != null && rightAngle != null) {
      return (leftAngle + rightAngle) / 2;
    }
    return leftAngle ?? rightAngle;
  }

  double? _sideAngle(JointSet joints) {
    final s = joints.s;
    final e = joints.e;
    final w = joints.w;
    if (s == null || e == null || w == null) return null;

    final minVisibility = [s.visibility, e.visibility, w.visibility]
        .reduce((a, b) => a < b ? a : b);
    if (minVisibility < AppConstants.visibilityThreshold) return null;

    return calculateAngle(s.position, e.position, w.position);
  }

  void _updateState(double angle) {
    switch (state) {
      case PushupState.ready:
      case PushupState.up:
        if (angle <= config.downThreshold) {
          _downConfirm++;
          if (_downConfirm >= AppConstants.stateConfirmFrames) {
            state = PushupState.down;
            _downConfirm = 0;
          }
        } else {
          _downConfirm = 0;
        }
      case PushupState.down:
        if (angle >= config.upThreshold) {
          _upConfirm++;
          if (_upConfirm >= AppConstants.stateConfirmFrames) {
            _upConfirm = 0;
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
        } else {
          _upConfirm = 0;
        }
    }
  }

  void reset() {
    state = PushupState.ready;
    count = 0;
    lastRepTime = null;
    _smoothing.reset();
    _missingFrames = 0;
    _downConfirm = 0;
    _upConfirm = 0;
  }
}
