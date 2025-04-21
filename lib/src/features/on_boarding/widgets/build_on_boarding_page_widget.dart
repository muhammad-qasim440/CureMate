import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/custom_linear_gradient_container_widget.dart';
import '../../../shared/widgets/custom_asset_image_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../views/on_boarding_carousel_view.dart';

class BuildOnBoardingPageWidget extends StatelessWidget {
  final  OnBoardingPageData data;
  const BuildOnBoardingPageWidget({super.key,required this.data});

  @override
  Widget build(BuildContext context,) {
    return ClipRect(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: AppColors.gradientWhite,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomLinearGradientContainerWidget(
              width: ScreenUtil.scaleWidth(context, 342),
              height: ScreenUtil.scaleHeight(context, 342),
              left: data.isGradientLeft ? ScreenUtil.scaleHeight(context, -140) : null,
              right: data.isGradientLeft ? null : ScreenUtil.scaleHeight(context, -140),
              top: ScreenUtil.scaleHeight(context, -10),
              colors: const [
                AppColors.gradientGreen,
                AppColors.gradientTurquoiseGreen,
              ],
            ),
            Positioned(
              top: ScreenUtil.scaleHeight(context, 120),
              left: 0,
              right: 0,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image
                    CustomAssetImageWidget(
                      img: data.image,
                      width: ScreenUtil.scaleWidth(context, 320),
                      height: ScreenUtil.scaleHeight(context, 320),
                    ),
                    50.height,
                    CustomTextWidget(
                      text: data.title,
                      textStyle: TextStyle(
                        fontFamily: AppFonts.rubik,
                        fontSize: FontSizes(context).size26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    12.height,

                    // Description text
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil.scaleWidth(context, 20),
                      ),
                      child: CustomTextWidget(
                        text: data.description,
                        textAlignment: TextAlign.center,
                        textStyle: TextStyle(
                          fontFamily: AppFonts.rubik,
                          fontSize: FontSizes(context).size14,
                          color: AppColors.detailsTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
