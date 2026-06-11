import 'pose_landmark.dart';

enum JointGroup { arms, legs }

/// 한쪽(좌 또는 우)의 관절 3점 세트
typedef JointSet = ({
  PoseLandmarkData? s,
  PoseLandmarkData? e,
  PoseLandmarkData? w,
});

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
  JointSet leftJoints(PoseLandmarks p) {
    return switch (jointGroup) {
      JointGroup.arms => (
          s: p.leftShoulder,
          e: p.leftElbow,
          w: p.leftWrist,
        ),
      JointGroup.legs => (
          s: p.leftHip,
          e: p.leftKnee,
          w: p.leftAnkle,
        ),
    };
  }

  JointSet rightJoints(PoseLandmarks p) {
    return switch (jointGroup) {
      JointGroup.arms => (
          s: p.rightShoulder,
          e: p.rightElbow,
          w: p.rightWrist,
        ),
      JointGroup.legs => (
          s: p.rightHip,
          e: p.rightKnee,
          w: p.rightAnkle,
        ),
    };
  }
}
