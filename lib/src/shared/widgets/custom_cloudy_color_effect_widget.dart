import 'package:flutter/material.dart';

class CustomCloudyColorEffectWidget extends StatelessWidget {
  final Color color;
  final double size;
  final EdgeInsets? position;
  final AlignmentGeometry alignment;
  final double intensity;
  final double spreadRadius;

  /// Creates a cloudy color effect that can be positioned anywhere on screen
  ///
  /// - [color]: The main color of the effect
  /// - [size]: Size of the effect container (width and height)
  /// - [position]: Position using EdgeInsets (top, left, right, bottom)
  /// - [alignment]: Alignment of the gradient relative to its container
  /// - [intensity]: Opacity intensity of the effect (0.0 to 1.0)
  /// - [spreadRadius]: How far the effect spreads (smaller values = more concentrated)
  const CustomCloudyColorEffectWidget({
    super.key,
    required this.color,
    this.size = 300,
    this.position,
    this.alignment = Alignment.center,
    this.intensity = 0.3,
    this.spreadRadius = 1.5,
  });

  /// Convenience constructor for top-left positioned effect
  factory CustomCloudyColorEffectWidget.topLeft({
    required Color color,
    double size = 300,
    double intensity = 0.3,
    double spreadRadius = 1.5,
  }) {
    return CustomCloudyColorEffectWidget(
      color: color,
      size: size,
      position: const EdgeInsets.only(top: -100, left: -100),
      alignment: Alignment.topLeft,
      intensity: intensity,
      spreadRadius: spreadRadius,
    );
  }

  /// Convenience constructor for bottom-right positioned effect
  factory CustomCloudyColorEffectWidget.bottomRight({
    required Color color,
    double size = 300,
    double intensity = 0.3,
    double spreadRadius = 1.5,
  }) {
    return CustomCloudyColorEffectWidget(
      color: color,
      size: size,
      position: const EdgeInsets.only(bottom: -100, right: -100),
      alignment: Alignment.bottomRight,
      intensity: intensity,
      spreadRadius: spreadRadius,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: position?.top,
      left: position?.left,
      right: position?.right,
      bottom: position?.bottom,
      child: IgnorePointer(
        child: SizedBox(
          width: size,
          height: size,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: alignment,
                radius: spreadRadius,
                colors: _generateGradientColors(),
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Color> _generateGradientColors() {
    return [
      color.withOpacity(intensity),        // Center of the effect
      color.withOpacity(intensity * 0.5),  // Mid spread
      color.withOpacity(intensity * 0.2),  // Far spread
      Colors.transparent,                  // Fade to transparent
    ];
  }
}