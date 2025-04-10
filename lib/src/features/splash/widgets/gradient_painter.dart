
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';

class GradientPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;
    Paint whitePaint = Paint()..color = Colors.white;
    canvas.drawRect(rect, whitePaint);
    Paint bluePaint =
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.7, -0.7),
        radius: 0.8,
        colors: [
          AppColors.gradientBlue,
          AppColors.gradientWhite.withOpacity(0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, bluePaint);

    Paint greenPaint =
    Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.8, 0.8),
        radius: 0.8,
        colors: [
          AppColors.gradientGreen,
          AppColors.gradientWhite.withOpacity(0),
        ],
        stops: const [0.0, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, greenPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
