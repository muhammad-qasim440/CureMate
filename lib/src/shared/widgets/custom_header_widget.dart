import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/extentions/widget_extension.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';

import '../../../const/font_sizes.dart';
import '../../theme/app_colors.dart';
import '../../utils/screen_utils.dart';

class CustomHeaderWidget extends StatelessWidget {
  final String? title;
  const CustomHeaderWidget({super.key, this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap:  (){AppNavigation.pop(context);},
          child: Container(
            width: ScreenUtil.scaleWidth(context, 30),
            height: ScreenUtil.scaleHeight(context, 30),
            decoration: const BoxDecoration(
              color: AppColors.appBarBackBtnBgColor,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: const Center(
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
        ),
        if (title!.isNotEmpty) ...[
          19.width,
          CustomTextWidget(
            text: title!,
            textStyle: TextStyle(
              fontSize: FontSizes(context).size18,
              fontFamily: AppFonts.rubik,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ],
      ],
    );
  }
}
