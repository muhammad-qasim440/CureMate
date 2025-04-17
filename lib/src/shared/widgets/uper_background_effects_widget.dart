import 'package:flutter/material.dart';
import '../custom_linear_gradient_container_widget.dart';
import '../../theme/app_colors.dart';
import '../../utils/screen_utils.dart';


class UpperBackgroundEffectsWidgets extends StatelessWidget {
  const UpperBackgroundEffectsWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Gradient containers for background effects
        CustomLinearGradientContainerWidget(
          width: ScreenUtil.scaleWidth(context, 200),
          height: ScreenUtil.scaleHeight(context, 200),
          left: ScreenUtil.scaleHeight(context, -100),
          top: ScreenUtil.scaleHeight(context, -150),
          colors: const [
            AppColors.gradientGreen,
            AppColors.gradientTurquoiseGreen,
          ],
        ),
        CustomLinearGradientContainerWidget(
          width: ScreenUtil.scaleWidth(context, 200),
          height: ScreenUtil.scaleHeight(context, 200),
          right: ScreenUtil.scaleHeight(context, -100),
          bottom: ScreenUtil.scaleHeight(context, -150),
          colors: const [
            AppColors.gradientGreen,
            AppColors.gradientTurquoiseGreen,
          ],
        ),
      ],
    );
  }
}
