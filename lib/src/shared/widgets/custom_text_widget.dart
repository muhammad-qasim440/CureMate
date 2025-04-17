import 'package:flutter/material.dart';

class CustomTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;
  final List<Color>? strokeColors;
  final double? strokeWidth;
  final Color? borderColor;
  final Color? shadowColor;
  final List<Color>? gradientColors;
  final bool applyGradient;
  final bool applyShadow;
  final bool applySkew;
  final List<Shadow>? shadows;
  final int? maxLines;
  final TextAlign? textAlignment;
  final bool? softWrap;

  const CustomTextWidget({
    super.key,
    required this.text,
    this.textStyle,
    this.strokeColors,
    this.strokeWidth,
    this.borderColor,
    this.shadowColor,
    this.gradientColors,
    this.applyGradient = false,
    this.applyShadow = false,
    this.applySkew = false,
    this.shadows,
    this.maxLines,
    this.textAlignment,
    this.softWrap,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle baseStyle =
        textStyle ?? const TextStyle(fontSize: 20, color: Colors.black);

    Widget textWidget = Text(
      text,
      maxLines: maxLines,
      textAlign: textAlignment,
      softWrap: softWrap,
      overflow:
          maxLines != null
              ? TextOverflow.ellipsis
              : null, // Optional: to ellipsize long text
      style: baseStyle.copyWith(
        foreground:
            (applyGradient && gradientColors != null)
                ? (Paint()
                  ..shader = LinearGradient(
                    colors: gradientColors!,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(const Rect.fromLTWH(0, 0, 200, 50)))
                : null,
        color:
            (applyGradient && gradientColors != null) ? null : baseStyle.color,
        shadows:
            applyShadow
                ? (shadows ??
                    [
                      Shadow(
                        offset: const Offset(2, 2),
                        blurRadius: 4,
                        color: shadowColor ?? Colors.black,
                      ),
                    ])
                : null,
      ),
    );

    if (strokeColors != null && strokeColors!.isNotEmpty) {
      return Stack(
        children: [
          Text(
            text,
            textAlign: textAlignment,
            softWrap: softWrap,
            maxLines: maxLines,
            overflow: maxLines != null ? TextOverflow.ellipsis : null,
            style: baseStyle.copyWith(
              foreground:
                  Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = strokeWidth ?? 3.0
                    ..color = borderColor ?? Colors.deepPurple,
            ),
          ),
          applySkew
              ? Transform(transform: Matrix4.skewX(-0.1), child: textWidget)
              : textWidget,
        ],
      );
    } else {
      return applySkew
          ? Transform(transform: Matrix4.skewX(-0.1), child: textWidget)
          : textWidget;
    }
  }
}
