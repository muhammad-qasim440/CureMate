import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/app_strings.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../signin/views/signin_view.dart';

class SignInLinkSection extends StatelessWidget {
  const SignInLinkSection({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        AppNavigation.pushReplacement(const SignInView());
      },
      child: CustomTextWidget(
        text: AppStrings.haveAccount,
        textStyle: TextStyle(
          fontFamily: AppFonts.rubik,
          fontSize: FontSizes(context).size14,
          color: AppColors.gradientGreen,
        ),
      ),
    );
  }
}