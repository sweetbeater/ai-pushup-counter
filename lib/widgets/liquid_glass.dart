import 'dart:ui';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// 액체 유리(Liquid Glass) 카드.
/// 배경을 블러로 굴절시키고, 빛이 위에서 비치는 듯한
/// 그라데이션 엣지 + 스펙큘러 하이라이트로 유리의 물성을 표현한다.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double blur;

  const LiquidGlass({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.blur = 24,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: CustomPaint(
          foregroundPainter: _GlassEdgePainter(radius: radius),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              // 유리를 통과한 빛 — 좌상단이 밝고 우하단으로 잦아든다
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.09),
                  Colors.white.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// 유리 가장자리 — 광원 방향(좌상단)이 밝은 그라데이션 스트로크
class _GlassEdgePainter extends CustomPainter {
  final double radius;

  _GlassEdgePainter({required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(radius),
    ).deflate(0.5);

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.38),
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0.16),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(rect);

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(_GlassEdgePainter old) => old.radius != radius;
}

/// 유리 뒤에서 굴절될 빛 — 화면 배경의 앰비언트 컬러 블롭.
/// 블롭이 있어야 블러를 통과하는 색이 생겨 유리 질감이 산다.
class AmbientBackground extends StatelessWidget {
  final Widget child;

  const AmbientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -140,
          right: -100,
          child: _blob(320, AppColors.accent.withValues(alpha: 0.16)),
        ),
        Positioned(
          top: 260,
          left: -160,
          child: _blob(340, const Color(0xFF3D5AFE).withValues(alpha: 0.09)),
        ),
        Positioned(
          bottom: -120,
          right: -80,
          child: _blob(300, AppColors.accent.withValues(alpha: 0.07)),
        ),
        child,
      ],
    );
  }

  Widget _blob(double size, Color color) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
