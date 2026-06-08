import 'package:flutter/painting.dart';
import 'pose_landmark.dart';

enum JointGroup { arms, legs }

class ExerciseConfig {
  final String id;
  final String name;
  final double downThreshold;
  final double upThreshold;
  final JointGroup jointGroup;

  const ExerciseConfig({
    required this.id,
    required this.name,
    required this.downThreshold,
    required this.upThreshold,
    required this.jointGroup,
  });

  // 설정에 맞는 좌우 관절 추출
  ({Offset? s, Offset? e, Offset? w})? leftJoints(PoseLandmarks p) {
    return switch (jointGroup) {
      JointGroup.arms => (
          s: p.leftShoulder?.position,
          e: p.leftElbow?.position,
          w: p.leftWrist?.position,
        ),
      JointGroup.legs => (
          s: p.leftHip?.position,
          e: p.leftKnee?.position,
          w: p.leftAnkle?.position,
        ),
    };
  }

  ({Offset? s, Offset? e, Offset? w})? rightJoints(PoseLandmarks p) {
    return switch (jointGroup) {
      JointGroup.arms => (
          s: p.rightShoulder?.position,
          e: p.rightElbow?.position,
          w: p.rightWrist?.position,
        ),
      JointGroup.legs => (
          s: p.rightHip?.position,
          e: p.rightKnee?.position,
          w: p.rightAnkle?.position,
        ),
    };
  }
}
