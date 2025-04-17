import 'package:curemate/extentions/widget_extension.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_asset_image_widget.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../assets/app_assets.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/app_strings.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/custom_linear_gradient_container_widget.dart';
import '../../../shared/widgets/custom_cloudy_color_effect_widget.dart';
import '../../../utils/screen_utils.dart';
import '../../splash/providers/splash_provider.dart';
import '../providers/on_boarding_views_provider.dart';
import 'on_boarding_third_view.dart';

class OnBoardingSecondView extends ConsumerWidget {
  const OnBoardingSecondView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingViewsProvider=ref.read(onBoardingViewsProvider.notifier);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.gradientWhite,
        body: Stack(
          clipBehavior: Clip.none,
          children: [
            CustomLinearGradientContainerWidget(
              width: ScreenUtil.scaleWidth(context, 342),
              height: ScreenUtil.scaleHeight(context, 342),
              right: ScreenUtil.scaleHeight(context, -140),
              top: ScreenUtil.scaleHeight(context, -10),
              colors: const [
                AppColors.gradientGreen,
                AppColors.gradientTurquoiseGreen,
              ],
            ),
            CustomCloudyColorEffectWidget.bottomRight(
              color: AppColors.gradientGreen,
              size: 200,
              intensity: 1,
              spreadRadius: 1,
            ),
            Positioned(
              top: ScreenUtil.scaleHeight(context, 120),
              left: ScreenUtil.scaleHeight(context, 0),
              right: ScreenUtil.scaleHeight(context, 0),
              child: Column(
                children: [
                  CustomAssetImageWidget(
                    img: AppAssets.doctorImg2,
                    width: ScreenUtil.scaleWidth(context, 320),
                    height: ScreenUtil.scaleHeight(context, 320),
                  ),
                  50.height,
                  CustomTextWidget(
                    text: AppStrings.chooseBestDoctors,
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: FontSizes(context).size28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  12.height,
                  CustomTextWidget(
                    text: AppStrings.lorem2000,
                    textStyle: TextStyle(
                        fontFamily: AppFonts.rubik,
                        fontSize: FontSizes(context).size14,
                        color: AppColors.detailsTextColor
                    ),
                  ),
                  65.height,
                  CustomButtonWidget(
                    text: AppStrings.getStartedBtnText,
                    height: ScreenUtil.scaleHeight(context, 54),
                    width: ScreenUtil.scaleWidth(context, 295),
                    backgroundColor: AppColors.btnBgColor,
                    fontFamily: AppFonts.rubik,
                    fontSize:FontSizes(context).size18,
                    fontWeight: FontWeight.w900,
                    textColor: AppColors.gradientWhite,
                    onPressed: (){
                      AppNavigation.push(const OnBoardingThirdView());
                    },
                  ),
                  14.height,
                  CustomButtonWidget(
                    text: AppStrings.skipBtnText,
                    height: ScreenUtil.scaleHeight(context, 25),
                    width: ScreenUtil.scaleWidth(context, 30),
                    backgroundColor: Colors.transparent,
                    fontFamily: AppFonts.rubik,
                    fontSize:FontSizes(context).size14,
                    fontWeight: FontWeight.w400,
                    textColor: AppColors.detailsTextColor,
                    shadowColor: Colors.transparent,
                    onPressed:(){
                      onboardingViewsProvider.onBoardingViewShownORSkipped();
                      ref.read(splashProvider.notifier).checkAuthUser();

                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
