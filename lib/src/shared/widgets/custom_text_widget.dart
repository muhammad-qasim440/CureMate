import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final List<Color>? strokeColors;
  final double? strokeWidth;
  final Color? borderColor;
  final List<Color>? gradientColors;
  final bool applyGradient;
  final bool applyShadow;
  final bool applySkew;
  final List<Shadow>? shadows;

  const CustomTextWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.strokeColors,
    this.strokeWidth,
    this.borderColor,
    this.gradientColors,
    this.applyGradient = false,
    this.applyShadow = false,
    this.applySkew = false,
    this.shadows,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle baseStyle = textStyle ?? const TextStyle(fontSize: 20, color: Colors.black);

    Widget textWidget = Text(
      text,
      style: baseStyle.copyWith(
        foreground: (applyGradient && gradientColors != null)
            ? (Paint()
          ..shader = LinearGradient(
            colors: gradientColors!,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(const Rect.fromLTWH(0, 0, 200, 50)))
            : null,
        color: (applyGradient && gradientColors != null) ? null : baseStyle.color,
        shadows: applyShadow ? (shadows ?? [const Shadow(offset: Offset(2, 2), blurRadius: 4, color: Colors.black)]) : null,
      ),
    );

    if (strokeColors != null && strokeColors!.isNotEmpty) {
      return Stack(
        children: [
          Text(
            text,
            style: baseStyle.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = strokeWidth ?? 3.0
                ..color = borderColor ?? Colors.deepPurple,
            ),
          ),
          applySkew ? Transform(transform: Matrix4.skewX(-0.1), child: textWidget) : textWidget,
        ],
      );
    } else {
      return applySkew ? Transform(transform: Matrix4.skewX(-0.1), child: textWidget) : textWidget;
    }
  }
}
