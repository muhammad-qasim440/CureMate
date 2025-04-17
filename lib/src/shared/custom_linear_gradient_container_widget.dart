import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class CustomLinearGradientContainerWidget extends StatelessWidget {
  final List<Color> colors;
  final double radius;
  final double width;
  final double height;

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;

  const CustomLinearGradientContainerWidget({
    super.key,
    required this.colors,
    this.radius = 0.6,
    this.width = 300,
    this.height = 300,
    this.top,
    this.left,
    this.right,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {

    return Positioned(
      top: top,
      right: right,
      left: left,
      bottom: bottom ,
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.backgroundLinearGradient,
          // gradient: RadialGradient(
          //   colors: colors,
          //   radius: radius,
          // ),
        ),
      ),
    );
  }

}
