import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../theme/app_colors.dart';

class LoadingProgressBar extends StatelessWidget {
  final double progress;

  const LoadingProgressBar({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            minHeight: ScreenUtil.scaleHeight(context, 35),
            value: progress,
            backgroundColor: AppColors.gradientWhite.withOpacity(0.7),
            borderRadius: BorderRadius.circular(15),
            valueColor: AlwaysStoppedAnimation<Color>(
              AppColors.gradientWhite.withOpacity(0.9),
            ),
          ),
        ),
        CustomTextWidget(
          text:'${(progress * 100).toStringAsFixed(0)}%',
          textStyle: TextStyle(
            color:AppColors.black,
            fontFamily: AppFonts.bangers,
            fontWeight: FontWeight.bold,
            fontSize: FontSizes(context).size22,
          ),
        ),
      ],
    );
  }

}
