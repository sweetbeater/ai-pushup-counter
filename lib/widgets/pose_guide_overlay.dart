import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';
import '../models/pose_landmark.dart';

/// 운동 시작 전 카메라 가이드 오버레이.
/// 코너 브래킷 프레임 + 전신 인식 상태 피드백으로 카메라 조건을 표준화해
/// 시작 시점의 인식 정확도를 끌어올린다.
class PoseGuideOverlay extends StatelessWidget {
  final PoseLandmarks? landmarks;

  const PoseGuideOverlay({super.key, this.landmarks});

  /// 한쪽이라도 어깨~발목 핵심 관절이 모두 신뢰도 있게 보이면 준비 완료
  bool get _bodyDetected {
    final p = landmarks;
    if (p == null) return false;

    bool ok(PoseLandmarkData? lm) =>
        lm != null && lm.visibility >= AppConstants.visibilityThreshold;

    final left =
        ok(p.leftShoulder) &&
        ok(p.leftElbow) &&
        ok(p.leftWrist) &&
        ok(p.leftHip) &&
        ok(p.leftAnkle);
    final right =
        ok(p.rightShoulder) &&
        ok(p.rightElbow) &&
        ok(p.rightWrist) &&
        ok(p.rightHip) &&
        ok(p.rightAnkle);
    return left || right;
  }

  @override
  Widget build(BuildContext context) {
    final detected = _bodyDetected;

    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomPaint(painter: _GuideFramePainter(active: detected)),
          Align(
            alignment: const Alignment(0, -0.5),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: detected
                      ? AppColors.success.withValues(alpha: 0.4)
                      : AppColors.hairline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: detected
                          ? AppColors.success
                          : AppColors.textTertiary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    detected ? '전신 인식 완료' : '전신이 보이게 기기를 두세요',
                    style: AppTheme.caption.copyWith(
                      color: detected
                          ? AppColors.success
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 화면 가장자리 코너 브래킷 — 몸을 맞춰야 할 영역을 암시
class _GuideFramePainter extends CustomPainter {
  final bool active;

  _GuideFramePainter({required this.active});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTRB(
      32,
      size.height * 0.18,
      size.width - 32,
      size.height * 0.78,
    );
    const len = 26.0;

    final paint = Paint()
      ..color = active
          ? AppColors.success.withValues(alpha: 0.6)
          : const Color(0x40FFFFFF)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 좌상
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(len, 0), paint);
    canvas.drawLine(rect.topLeft, rect.topLeft + const Offset(0, len), paint);
    // 우상
    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(-len, 0),
      paint,
    );
    canvas.drawLine(rect.topRight, rect.topRight + const Offset(0, len), paint);
    // 좌하
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(len, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(0, -len),
      paint,
    );
    // 우하
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(-len, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(0, -len),
      paint,
    );
  }

  @override
  bool shouldRepaint(_GuideFramePainter old) => old.active != active;
}
