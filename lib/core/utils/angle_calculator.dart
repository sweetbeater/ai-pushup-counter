import 'dart:math';
import 'package:flutter/painting.dart';

double calculateAngle(Offset shoulder, Offset elbow, Offset wrist) {
  final a = Offset(shoulder.dx - elbow.dx, shoulder.dy - elbow.dy);
  final b = Offset(wrist.dx - elbow.dx, wrist.dy - elbow.dy);

  final dot = a.dx * b.dx + a.dy * b.dy;
  final magA = sqrt(a.dx * a.dx + a.dy * a.dy);
  final magB = sqrt(b.dx * b.dx + b.dy * b.dy);

  if (magA == 0 || magB == 0) return 0;

  final cosAngle = (dot / (magA * magB)).clamp(-1.0, 1.0);
  return acos(cosAngle) * 180 / pi;
}
