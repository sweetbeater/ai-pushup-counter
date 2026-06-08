import 'package:flutter/painting.dart';

class PoseLandmarkData {
  final Offset position;
  final double visibility;

  const PoseLandmarkData({required this.position, required this.visibility});
}

class PoseLandmarks {
  // 팔
  final PoseLandmarkData? leftShoulder;
  final PoseLandmarkData? leftElbow;
  final PoseLandmarkData? leftWrist;
  final PoseLandmarkData? rightShoulder;
  final PoseLandmarkData? rightElbow;
  final PoseLandmarkData? rightWrist;
  // 다리
  final PoseLandmarkData? leftHip;
  final PoseLandmarkData? leftKnee;
  final PoseLandmarkData? leftAnkle;
  final PoseLandmarkData? rightHip;
  final PoseLandmarkData? rightKnee;
  final PoseLandmarkData? rightAnkle;

  const PoseLandmarks({
    this.leftShoulder,
    this.leftElbow,
    this.leftWrist,
    this.rightShoulder,
    this.rightElbow,
    this.rightWrist,
    this.leftHip,
    this.leftKnee,
    this.leftAnkle,
    this.rightHip,
    this.rightKnee,
    this.rightAnkle,
  });

  bool isValidFor(List<PoseLandmarkData?> joints) =>
      joints.every((l) => l != null && l.visibility > 0.5);
}
