import 'dart:math' as math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
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
    final previewSize = controller.value.previewSize;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 화면 비율에 맞춰 늘리지 않고 cover로 채워 왜곡 제거
        if (previewSize != null)
          ClipRect(
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                // previewSize는 가로 기준이므로 세로 화면에 맞게 스왑
                width: previewSize.height,
                height: previewSize.width,
                child: CameraPreview(controller),
              ),
            ),
          )
        else
          CameraPreview(controller),
        if (landmarks != null)
          CustomPaint(painter: _LandmarkPainter(landmarks!)),
        // 상/하단 가독성을 위한 스크림
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.25, 0.7, 1.0],
              colors: [
                Color(0xCC0A0B0D),
                Color(0x000A0B0D),
                Color(0x000A0B0D),
                Color(0xCC0A0B0D),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LandmarkPainter extends CustomPainter {
  final PoseLandmarks landmarks;

  _LandmarkPainter(this.landmarks);

  @override
  void paint(Canvas canvas, Size size) {
    final img = landmarks.imageSize;
    if (img.width == 0 || img.height == 0) return;

    // 프리뷰와 동일한 cover 변환으로 매핑
    final scale = math.max(size.width / img.width, size.height / img.height);
    final dx = (size.width - img.width * scale) / 2;
    final dy = (size.height - img.height * scale) / 2;

    Offset? map(PoseLandmarkData? lm) {
      if (lm == null || lm.visibility < 0.5) return null;
      return Offset(lm.position.dx * scale + dx, lm.position.dy * scale + dy);
    }

    final linePaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.7)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final dotPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    void drawSegment(PoseLandmarkData? a, PoseLandmarkData? b) {
      final pa = map(a);
      final pb = map(b);
      if (pa != null && pb != null) canvas.drawLine(pa, pb, linePaint);
    }

    // 팔
    drawSegment(landmarks.leftShoulder, landmarks.leftElbow);
    drawSegment(landmarks.leftElbow, landmarks.leftWrist);
    drawSegment(landmarks.rightShoulder, landmarks.rightElbow);
    drawSegment(landmarks.rightElbow, landmarks.rightWrist);
    // 다리
    drawSegment(landmarks.leftHip, landmarks.leftKnee);
    drawSegment(landmarks.leftKnee, landmarks.leftAnkle);
    drawSegment(landmarks.rightHip, landmarks.rightKnee);
    drawSegment(landmarks.rightKnee, landmarks.rightAnkle);

    final points = [
      landmarks.leftShoulder,
      landmarks.leftElbow,
      landmarks.leftWrist,
      landmarks.rightShoulder,
      landmarks.rightElbow,
      landmarks.rightWrist,
      landmarks.leftHip,
      landmarks.leftKnee,
      landmarks.leftAnkle,
      landmarks.rightHip,
      landmarks.rightKnee,
      landmarks.rightAnkle,
    ];

    for (final lm in points) {
      final p = map(lm);
      if (p != null) canvas.drawCircle(p, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(_LandmarkPainter old) => true;
}
