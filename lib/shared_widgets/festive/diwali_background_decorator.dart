import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A high-performance, vector-rendered background decorator for Diwali.
/// Renders ambient warm diya glows, subtle corner rangoli mandalas, and
/// delicate sparkle particles without any heavy bitmap images.
class DiwaliBackgroundDecorator extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const DiwaliBackgroundDecorator({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base Ambient Gradient Layer
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1E1035), // Deep festive royal purple
                        Color(0xFF140B24), // Midnight plum
                        Color(0xFF0F081D), // Deepest night
                      ],
                    )
                  : const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFFFDF8), // Warm champagne ivory
                        Color(0xFFFFF9ED), // Soft golden silk
                        Color(0xFFFBF4E6), // Warm ambient linen
                      ],
                    ),
            ),
          ),
        ),

        // Ambient Warm Glow Radial Highlights (Top header glow & bottom corner glow)
        Positioned(
          top: -120,
          left: 0,
          right: 0,
          height: 380,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.6),
                  radius: 0.9,
                  colors: [
                    isDark
                        ? const Color(0xFFF59E0B).withValues(alpha: 0.16)
                        : const Color(0xFFFBBF24).withValues(alpha: 0.22),
                    isDark
                        ? const Color(0xFFD97706).withValues(alpha: 0.06)
                        : const Color(0xFFF59E0B).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Vector Canvas Overlay: Rangoli mandalas, diyas, and sparkles
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _DiwaliVectorPainter(isDark: isDark),
            ),
          ),
        ),

        // Main User-Side Content
        Positioned.fill(child: child),
      ],
    );
  }
}

class _DiwaliVectorPainter extends CustomPainter {
  final bool isDark;

  _DiwaliVectorPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final goldColor = isDark
        ? const Color(0xFFFBBF24)
        : const Color(0xFFD97706);

    // 1. Draw Corner Rangoli Mandalas
    _drawCornerRangoli(canvas, Offset.zero, 0, goldColor, 0.08);
    _drawCornerRangoli(canvas, Offset(size.width, 0), math.pi / 2, goldColor, 0.08);
    _drawCornerRangoli(canvas, Offset(0, size.height), -math.pi / 2, goldColor, 0.06);
    _drawCornerRangoli(canvas, Offset(size.width, size.height), math.pi, goldColor, 0.06);

    // 2. Draw Decorative Floating Sparkles / Stars
    final sparklePaint = Paint()
      ..color = goldColor.withValues(alpha: isDark ? 0.28 : 0.22)
      ..style = PaintingStyle.fill;

    _drawSparkle(canvas, Offset(size.width * 0.15, 60), 8, sparklePaint);
    _drawSparkle(canvas, Offset(size.width * 0.85, 80), 10, sparklePaint);
    _drawSparkle(canvas, Offset(size.width * 0.52, 35), 6, sparklePaint);
    _drawSparkle(canvas, Offset(size.width * 0.28, size.height * 0.88), 7, sparklePaint);
    _drawSparkle(canvas, Offset(size.width * 0.74, size.height * 0.92), 9, sparklePaint);

    // 3. Draw Stylized Diyas at Bottom Left & Right Margins
    _drawStylizedDiya(canvas, Offset(60, size.height - 45), 32, isDark);
    _drawStylizedDiya(canvas, Offset(size.width - 60, size.height - 45), 32, isDark);
  }

  void _drawCornerRangoli(Canvas canvas, Offset origin, double rotation, Color color, double alpha) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.rotate(rotation);

    final strokePaint = Paint()
      ..color = color.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    // Concentric rings
    for (final r in [40.0, 75.0, 115.0, 155.0]) {
      canvas.drawCircle(Offset.zero, r, strokePaint);
    }

    // Radial Petal Curves
    const numPetals = 8;
    for (int i = 0; i <= numPetals; i++) {
      final angle = (math.pi / 2) * (i / numPetals);
      final x1 = math.cos(angle) * 40.0;
      final y1 = math.sin(angle) * 40.0;
      final x2 = math.cos(angle) * 155.0;
      final y2 = math.sin(angle) * 155.0;

      final path = Path()
        ..moveTo(x1, y1)
        ..quadraticBezierTo(
          x2 * 0.6 + 15 * math.sin(angle * 2),
          y2 * 0.6 - 15 * math.cos(angle * 2),
          x2,
          y2,
        );
      canvas.drawPath(path, strokePaint);
    }

    canvas.restore();
  }

  void _drawSparkle(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    path.moveTo(center.dx, center.dy - size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx + size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + size);
    path.quadraticBezierTo(center.dx, center.dy, center.dx - size, center.dy);
    path.quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - size);
    canvas.drawPath(path, paint);
  }

  void _drawStylizedDiya(Canvas canvas, Offset center, double width, bool isDark) {
    final height = width * 0.45;
    final gold = isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706);

    // Diya Clay/Brass Lamp Bowl
    final bowlPaint = Paint()
      ..color = gold.withValues(alpha: isDark ? 0.35 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final bowlFill = Paint()
      ..color = (isDark ? const Color(0xFF78350F) : const Color(0xFFFEF3C7))
          .withValues(alpha: isDark ? 0.30 : 0.45)
      ..style = PaintingStyle.fill;

    final bowlPath = Path()
      ..moveTo(center.dx - width / 2, center.dy)
      ..quadraticBezierTo(center.dx, center.dy + height * 1.3, center.dx + width / 2, center.dy)
      ..quadraticBezierTo(center.dx, center.dy + height * 0.2, center.dx - width / 2, center.dy);

    canvas.drawPath(bowlPath, bowlFill);
    canvas.drawPath(bowlPath, bowlPaint);

    // Diya Warm Glowing Flame
    final flameCenter = Offset(center.dx, center.dy - 6);
    final flameRadius = height * 0.95;

    // Outer Flame Glow
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFBBF24).withValues(alpha: isDark ? 0.55 : 0.45),
          const Color(0xFFEA580C).withValues(alpha: isDark ? 0.20 : 0.15),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: flameCenter, radius: flameRadius * 2.2));

    canvas.drawCircle(flameCenter, flameRadius * 1.8, glowPaint);

    // Inner Flame Teardrop
    final flamePath = Path()
      ..moveTo(flameCenter.dx, flameCenter.dy - flameRadius * 1.4)
      ..quadraticBezierTo(
        flameCenter.dx + flameRadius * 0.65,
        flameCenter.dy - flameRadius * 0.2,
        flameCenter.dx,
        flameCenter.dy + flameRadius * 0.4,
      )
      ..quadraticBezierTo(
        flameCenter.dx - flameRadius * 0.65,
        flameCenter.dy - flameRadius * 0.2,
        flameCenter.dx,
        flameCenter.dy - flameRadius * 1.4,
      );

    final flameFill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFEF08A), // bright warm yellow
          Color(0xFFF59E0B), // amber gold
          Color(0xFFDC2626), // saffron red base
        ],
      ).createShader(Rect.fromLTWH(
        flameCenter.dx - flameRadius,
        flameCenter.dy - flameRadius * 1.4,
        flameRadius * 2,
        flameRadius * 1.8,
      ));

    canvas.drawPath(flamePath, flameFill);
  }

  @override
  bool shouldRepaint(covariant _DiwaliVectorPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
