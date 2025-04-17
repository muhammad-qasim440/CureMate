import 'package:flutter/material.dart';
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';

import '../../theme/app_colors.dart';

class CustomSnackBarWidget {
  static void show({
    required BuildContext context,
    required String text,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: CustomTextWidget(
          text: text,
          maxLines: 3,
          softWrap: true,
          textAlignment: TextAlign.center,
          textStyle:const TextStyle(
            fontSize: 12,
            fontFamily: AppFonts.rubik,
            color: Colors.black,

          ),
        ),
        backgroundColor: backgroundColor ?? AppColors.gradientGreen,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        action: action,
      ),
    );
  }
}

