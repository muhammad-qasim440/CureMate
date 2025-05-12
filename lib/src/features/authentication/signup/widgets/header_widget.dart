import 'package:flutter/material.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/app_strings.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';

class HeaderWidget extends StatelessWidget {
  final double keyboardHeight;
  const HeaderWidget({super.key, required this.keyboardHeight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      // height: keyboardHeight > 0 ? 80 : 200,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: keyboardHeight > 0
                ? ScreenUtil.scaleHeight(context, 20)
                : ScreenUtil.scaleHeight(context, 85),
            left: ScreenUtil.scaleWidth(context, 20),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: keyboardHeight > 0 ? 0.0 : 1.0,
              child: CustomTextWidget(
                text: AppStrings.joinUsToDiscoverCareThatCares,
                textStyle: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: keyboardHeight > 0
                ? ScreenUtil.scaleHeight(context, 30)
                : ScreenUtil.scaleHeight(context, 120),
            left: ScreenUtil.scaleWidth(context, 50),
            right: ScreenUtil.scaleWidth(context, 45),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: keyboardHeight > 0 ? 0.0 : 1.0,
              child: CustomTextWidget(
                text: AppStrings.subtextOfJoinUS,
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
      ),
    );
  }
}