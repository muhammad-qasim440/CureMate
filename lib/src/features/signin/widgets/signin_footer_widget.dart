
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/extentions/widget_extension.dart';
import 'package:curemate/src/features/signup/signup_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../const/app_strings.dart';
import '../../../theme/app_colors.dart';
import '../../reset_password/providers/password_reset_providers.dart';
import '../../reset_password/views/forget_password_bottom_sheet_view.dart';

class SignInFooterWidget extends ConsumerWidget {
  const SignInFooterWidget({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            ref.read(forgotPasswordEmailProvider.notifier).state='';
            ref.read(isEmailSentProvider.notifier).state=false;
            ForgetPasswordBottomSheet.show(context, FocusNode());
          },
          child: CustomTextWidget(
            text: AppStrings.forgetPassword,
            textStyle: TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size14,
              color: AppColors.gradientGreen,
            ),
          ),
        ),
        150.height,
        TextButton(
          onPressed: () {
            FocusScope.of(context).unfocus();
            AppNavigation.pushReplacement(const SignUpView());
          },
          child: CustomTextWidget(
            text: AppStrings.doNotHaveAccount,
            textStyle: TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size14,
              color: AppColors.gradientGreen,
            ),
          ),
        ),
      ],
    );
  }
}