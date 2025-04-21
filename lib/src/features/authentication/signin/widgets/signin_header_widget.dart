import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';

import '../../../../../const/app_strings.dart';
import '../../../../theme/app_colors.dart';
class SignInHeaderWidget extends StatelessWidget {
  final double keyboardHeight;

  const SignInHeaderWidget({
    required this.keyboardHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Welcome back text
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          top: keyboardHeight > 0
              ? ScreenUtil.scaleHeight(context, 100)
              : ScreenUtil.scaleHeight(context, 127),
          left: ScreenUtil.scaleWidth(context, 108),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: keyboardHeight > 0 ? 0.0 : 1.0,
            child: CustomTextWidget(
              text: AppStrings.welcomeBack,
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),

        // Subtext
        AnimatedPositioned(
          duration: const Duration(milliseconds: 200),
          top: keyboardHeight > 0
              ? ScreenUtil.scaleHeight(context, 100)
              : ScreenUtil.scaleHeight(context, 163),
          left: ScreenUtil.scaleWidth(context, 50),
          right: ScreenUtil.scaleWidth(context, 45),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: keyboardHeight > 0 ? 0.0 : 1.0,
            child: CustomTextWidget(
              text: AppStrings.subtextOfWelcomeBack,
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size14,
                fontWeight: FontWeight.w400,
                color: AppColors.detailsTextColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}