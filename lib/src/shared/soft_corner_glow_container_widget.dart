import 'package:flutter/material.dart';

class SoftCornerGlowContainerWidget extends StatelessWidget {
  final Alignment alignment;
  final List<Color> colors;
  final double radius;
  final double size;

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  const SoftCornerGlowContainerWidget({
    super.key,
    required this.alignment,
    required this.colors,
    this.radius = 0.6,
    this.size = 300,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final defaultPosition = _alignmentToPosition(alignment);

    return Positioned(
      top: top ?? defaultPosition['top'],
      left: left ?? defaultPosition['left'],
      right: right ?? defaultPosition['right'],
      bottom: bottom ?? defaultPosition['bottom'],
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: colors,
            radius: radius,
          ),
        ),
      ),
    );
  }

  Map<String, double?> _alignmentToPosition(Alignment alignment) {
    return {
      'top': alignment.y < 0 ? -size / 3 : null,
      'bottom': alignment.y > 0 ? -size / 3 : null,
      'left': alignment.x < 0 ? -size / 3 : null,
      'right': alignment.x > 0 ? -size / 3 : null,
    };
  }
}
