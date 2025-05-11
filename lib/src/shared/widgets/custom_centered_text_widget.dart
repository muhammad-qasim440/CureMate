import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import 'custom_text_widget.dart';

class CustomCenteredTextWidget extends StatelessWidget {
  final String text;
  final TextStyle? textStyle;

  const CustomCenteredTextWidget({
    super.key,
    required this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomTextWidget(
        text: text,
        textAlignment: TextAlign.center,
        textStyle: textStyle ??
            const TextStyle(
              fontFamily: 'Rubik',
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.subTextColor,
            ),
      ),
    );
  }
}