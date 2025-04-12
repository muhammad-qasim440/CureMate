import 'package:curemate/extentions/widget_extension.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../assets/app_icons.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/app_strings.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_svg_picture_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../providers/splash_provider.dart';
import '../widgets/loading_progress_bar.dart';

class SplashView extends ConsumerWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final splashState = ref.watch(splashProvider);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          width: ScreenUtil.baseWidth,
          height: ScreenUtil.baseHeight,
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundLinearGradient,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.only(
                  top: ScreenUtil.scaleHeight(context, 120),
                ),
                child: CustomTextWidget(
                  text: AppStrings.appName,
                  applyShadow: true,
                  textStyle: TextStyle(
                    fontSize: FontSizes(context).size60,
                    fontFamily: AppFonts.rubik,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gradientWhite.withOpacity(0.9),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  top: ScreenUtil.scaleHeight(context, 5),
                ),
                child: CustomTextWidget(
                  text: AppStrings.aSmartHealthSolution,
                  textStyle: TextStyle(
                    fontSize: FontSizes(context).size18,
                    fontFamily: AppFonts.bangers,
                    fontWeight: FontWeight.w400,
                    color: AppColors.black,
                  ),
                ),
              ),
              SizedBox(height: ScreenUtil.scaleHeight(context, 120)),
              CustomSvgPictureWidget(
                icon: AppIcons.appSplashIc,
                width: ScreenUtil.scaleWidth(context, 100),
                height: ScreenUtil.scaleHeight(context, 150),
              ),
              200.height,
              Padding(
                padding: EdgeInsets.only(
                  right: ScreenUtil.scaleWidth(context, 220),
                  bottom: ScreenUtil.scaleHeight(context, 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CupertinoActivityIndicator(
                      color: AppColors.black,
                    ),
                    3.width,
                    CustomTextWidget(
                      text: AppStrings.loading,
                      textStyle: TextStyle(
                        fontSize: FontSizes(context).size20,
                        fontFamily: AppFonts.bangers,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: LoadingProgressBar(progress: splashState.progress),
              ),
              10.height,
              // Image.asset(AppAssets.dnaImage),
            ],
          ),
        ),
      ),
    );
  }
}
