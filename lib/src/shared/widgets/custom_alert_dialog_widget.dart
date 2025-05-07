import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CustomInfoDialogWidget extends StatelessWidget {
  final String title;
  final String message;
  final String buttonText;

  const CustomInfoDialogWidget({
    super.key,
    required this.title,
    required this.message,
    this.buttonText = 'OK',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: CustomTextWidget(
        text: title,
        textStyle: TextStyle(
          fontFamily: AppFonts.rubik,
          fontSize: FontSizes(context).size20,
          color: AppColors.gradientGreen,
        ),
      ),
      content: CustomTextWidget(
        textAlignment: TextAlign.center,
        text: message,
        textStyle: TextStyle(
          fontFamily: AppFonts.rubik,
          fontSize: FontSizes(context).size14,
          color: AppColors.subtextcolor,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: CustomTextWidget(
            text: buttonText,
            textStyle: TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size18,
              color: AppColors.gradientGreen,
            ),
          ),
        ),
      ],
    );
  }
}
