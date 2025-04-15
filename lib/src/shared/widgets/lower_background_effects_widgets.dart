import 'package:flutter/material.dart';
import 'custom_cloudy_color_effect_widget.dart';
import '../../theme/app_colors.dart';


class LowerBackgroundEffectsWidgets extends StatelessWidget {
  const LowerBackgroundEffectsWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomCloudyColorEffectWidget.bottomRight(
          color: AppColors.gradientGreen,
          size: 100,
          intensity: 1,
          spreadRadius: 1,
        ),
        CustomCloudyColorEffectWidget.topLeft(
          color: AppColors.gradientGreen,
          size: 100,
          intensity: 1,
          spreadRadius: 1,
        ),

      ],
    );
  }
}
