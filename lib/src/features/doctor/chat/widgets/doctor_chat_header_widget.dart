import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/app_strings.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';

class DoctorChatHeaderWidget extends ConsumerWidget {
  const DoctorChatHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Container(
      height: ScreenUtil.scaleHeight(context, 120),
      width: ScreenUtil.scaleWidth(context, 375),
      padding: EdgeInsets.zero,
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundLinearGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Center(
                  child: CustomTextWidget(
                    text: AppStrings.appName,
                    applySkew: true,
                    textStyle: TextStyle(
                      fontSize: FontSizes(context).size40,
                      color: AppColors.gradientWhite,
                      fontFamily: AppFonts.rubik,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Center(
                  child: CustomTextWidget(
                    text: AppStrings.chatsWithPatients,
                    textStyle: TextStyle(
                      fontSize: FontSizes(context).size15,
                      fontFamily: AppFonts.bangers,
                      color: AppColors.black,
                      fontWeight: FontWeight.w200,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
