import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

class CustomConfirmationDialogWidget extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;

  const CustomConfirmationDialogWidget({
    super.key,
    required this.title,
    required this.content,
     this.onConfirm,
    this.onCancel,
    this.confirmText = 'Delete',
    this.cancelText = 'Cancel',
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: CustomTextWidget(
      text: title,
      textStyle: TextStyle(
        color: AppColors.gradientGreen,
        fontSize: FontSizes(context).size20,
        fontFamily: AppFonts.rubik,
      ),
    ),
      content: CustomTextWidget(
        text: content,
        textAlignment: TextAlign.center,
        textStyle: TextStyle(
          color: AppColors.subTextColor,
          fontSize: FontSizes(context).size14,
          fontFamily: AppFonts.rubik,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
            onCancel?.call();
          },
          child: CustomTextWidget(
            text: cancelText,
            textStyle: TextStyle(
              color: AppColors.black,
              fontSize: FontSizes(context).size14,
              fontFamily: AppFonts.rubik,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true);
            onConfirm?.call();
          },
          child: CustomTextWidget(
            text: confirmText,
            textStyle: TextStyle(
              color: AppColors.gradientGreen,
              fontSize: FontSizes(context).size14,
              fontFamily: AppFonts.rubik,
            ),
          ),
        ),
      ],
    );
  }
}
