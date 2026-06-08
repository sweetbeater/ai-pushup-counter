import 'package:flutter/painting.dart';

class PoseLandmarkData {
  final Offset position;
  final double visibility;

  const PoseLandmarkData({required this.position, required this.visibility});
}

class PoseLandmarks {
  final PoseLandmarkData? leftShoulder;
  final PoseLandmarkData? leftElbow;
  final PoseLandmarkData? leftWrist;
  final PoseLandmarkData? rightShoulder;
  final PoseLandmarkData? rightElbow;
  final PoseLandmarkData? rightWrist;

  const PoseLandmarks({
    this.leftShoulder,
    this.leftElbow,
    this.leftWrist,
    this.rightShoulder,
    this.rightElbow,
    this.rightWrist,
  });

  bool get isValid {
    final landmarks = [
      leftShoulder, leftElbow, leftWrist,
      rightShoulder, rightElbow, rightWrist,
    ];
    return landmarks.every(
      (l) => l != null && l.visibility > 0.5,
    );
  }
}
