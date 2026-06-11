import 'dart:math';
import '../../models/pose_landmark.dart';

/// 세 관절(어깨-팔꿈치-손목)이 이루는 3D 각도.
/// z축을 포함해 몸이 카메라와 기울어진 상황에서도 각도가 안정적이다.
double calculateAngle(
  PoseLandmarkData shoulder,
  PoseLandmarkData elbow,
  PoseLandmarkData wrist,
) {
  final ax = shoulder.position.dx - elbow.position.dx;
  final ay = shoulder.position.dy - elbow.position.dy;
  final az = shoulder.z - elbow.z;
  final bx = wrist.position.dx - elbow.position.dx;
  final by = wrist.position.dy - elbow.position.dy;
  final bz = wrist.z - elbow.z;

  final dot = ax * bx + ay * by + az * bz;
  final magA = sqrt(ax * ax + ay * ay + az * az);
  final magB = sqrt(bx * bx + by * by + bz * bz);

  if (magA == 0 || magB == 0) return 0;

  final cosAngle = (dot / (magA * magB)).clamp(-1.0, 1.0);
  return acos(cosAngle) * 180 / pi;
}
