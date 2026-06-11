import 'dart:math';

/// One Euro Filter (스칼라).
/// 정지 상태의 떨림은 강하게 누르고, 빠른 동작은 즉시 따라간다.
/// 이동평균 대비 빠른 푸시업 페이스에서 지연이 거의 없다.
class PoseSmoothing {
  // 낮을수록 정지 시 더 부드럽고, 높을수록 반응이 빠름
  static const double _minCutoff = 1.5;
  // 속도에 비례해 컷오프를 올리는 계수 (빠른 동작 추종성)
  static const double _beta = 0.02;
  static const double _dCutoff = 1.0;
  // 카메라 스트림 공칭 프레임 간격 (결정적 동작을 위해 고정)
  static const double _dt = 1 / 30;

  double? _prev;
  double _prevDeriv = 0;

  double smooth(double value) {
    final prev = _prev;
    if (prev == null) {
      _prev = value;
      _prevDeriv = 0;
      return value;
    }

    final dValue = (value - prev) / _dt;
    final aD = _alpha(_dCutoff);
    final deriv = aD * dValue + (1 - aD) * _prevDeriv;
    _prevDeriv = deriv;

    final cutoff = _minCutoff + _beta * deriv.abs();
    final a = _alpha(cutoff);
    final smoothed = a * value + (1 - a) * prev;
    _prev = smoothed;
    return smoothed;
  }

  double _alpha(double cutoff) {
    final tau = 1 / (2 * pi * cutoff);
    return 1 / (1 + tau / _dt);
  }

  void reset() {
    _prev = null;
    _prevDeriv = 0;
  }
}
