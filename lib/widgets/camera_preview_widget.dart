import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../models/pose_landmark.dart';

class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;
  final PoseLandmarks? landmarks;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
    this.landmarks,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreview(controller),
        if (landmarks != null)
          CustomPaint(painter: _LandmarkPainter(landmarks!)),
      ],
    );
  }
}

class _LandmarkPainter extends CustomPainter {
  final PoseLandmarks landmarks;

  _LandmarkPainter(this.landmarks);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.fill;

    final points = [
      landmarks.leftShoulder?.position,
      landmarks.leftElbow?.position,
      landmarks.leftWrist?.position,
      landmarks.rightShoulder?.position,
      landmarks.rightElbow?.position,
      landmarks.rightWrist?.position,
    ];

    for (final p in points) {
      if (p != null) canvas.drawCircle(p, 6, paint);
    }

    final linePaint = Paint()
      ..color = Colors.greenAccent.withValues(alpha: 0.6)
      ..strokeWidth = 2;

    void drawLine(Offset? a, Offset? b) {
      if (a != null && b != null) canvas.drawLine(a, b, linePaint);
    }

    drawLine(landmarks.leftShoulder?.position, landmarks.leftElbow?.position);
    drawLine(landmarks.leftElbow?.position, landmarks.leftWrist?.position);
    drawLine(landmarks.rightShoulder?.position, landmarks.rightElbow?.position);
    drawLine(landmarks.rightElbow?.position, landmarks.rightWrist?.position);
  }

  @override
  bool shouldRepaint(_LandmarkPainter old) => true;
}
