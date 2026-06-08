import '../../core/constants/app_constants.dart';

class PoseSmoothing {
  final List<double> _history = [];

  double smooth(double value) {
    _history.add(value);
    if (_history.length > AppConstants.smoothingFrames) {
      _history.removeAt(0);
    }
    return _history.reduce((a, b) => a + b) / _history.length;
  }

  void reset() => _history.clear();
}
