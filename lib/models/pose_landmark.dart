import 'package:flutter/painting.dart';

class PoseLandmarkData {
  /// 원본 이미지 좌표계 기준 위치 (각도 계산이 왜곡되지 않도록 균등 좌표계 유지)
  final Offset position;

  /// 깊이(z). 카메라와 몸이 기울어진 상황에서도 3D 각도가 안정적이도록 사용
  final double z;
  final double visibility;

  const PoseLandmarkData({
    required this.position,
    this.z = 0,
    required this.visibility,
  });
}

class PoseLandmarks {
  /// 랜드마크 좌표의 기준이 되는 카메라 이미지 크기
  final Size imageSize;

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
    required this.imageSize,
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
}
