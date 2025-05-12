import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/custom_linear_gradient_container_widget.dart';
import 'package:curemate/src/shared/widgets/custom_cloudy_color_effect_widget.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';

class NoInternetView extends StatelessWidget {
  final VoidCallback? onTryAgain;
  final String title;
  final String subtitle;

  const NoInternetView({
    super.key,
    this.onTryAgain,
    this.title = "No Internet Connection",
    this.subtitle = "Please check your connection and try again",
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gradientWhite,
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorations
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

          // Main content
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: ScreenUtil.scaleWidth(context, 120),
                    height: ScreenUtil.scaleWidth(context, 120),
                    decoration: BoxDecoration(
                      color: AppColors.gradientWhite,
                      borderRadius: BorderRadius.circular(60),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.gradientGreen.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: ScreenUtil.scaleWidth(context, 60),
                      color: AppColors.gradientGreen,
                    ),
                  ),
                  30.height,

                  CustomTextWidget(
                    text: title,
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: FontSizes(context).size22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.subTextColor,
                    ),
                  ),
                  15.height,
                  CustomTextWidget(
                    text: subtitle,
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: FontSizes(context).size14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.detailsTextColor,
                    ),
                  ),
                  if (onTryAgain != null) ...[
                    60.height,
                    CustomButtonWidget(
                      text: "Try Again",
                      height: ScreenUtil.scaleHeight(context, 54),
                      backgroundColor: AppColors.btnBgColor,
                      fontFamily: AppFonts.rubik,
                      fontSize: FontSizes(context).size18,
                      fontWeight: FontWeight.w900,
                      textColor: AppColors.gradientWhite,
                      onPressed: onTryAgain!,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

