
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/authentication/signin/widgets/signin_footer_widget.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_form_field_widget.dart';
import 'package:curemate/src/utils/delay_utils.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_strings.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../doctor/home/views/doctor_home_view.dart';
import '../../../patient/providers/patient_providers.dart';
import '../../../patient/views/patient_main_view.dart';
import '../providers/auth-provider.dart';
import '../providers/signin_form_providers.dart';
import '../views/signin_view.dart';

class SignInFormWidget extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode emailFocus;
  final FocusNode passwordFocus;
  final double keyboardHeight;

  const SignInFormWidget({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.emailFocus,
    required this.passwordFocus,
    required this.keyboardHeight,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPasswordHidden = ref.watch(hidePasswordProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.only(
              top: keyboardHeight > 0 ? 200 : 300,
              bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 20,
            ),
            children: [
              // Email field
              CustomTextFormFieldWidget(
                controller: emailController,
                label: AppStrings.email,
                hintText: AppStrings.enterEmail,
                focusNode: emailFocus,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterEmail;
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                textStyle: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontWeight: FontWeight.w400,
                  fontSize: FontSizes(context).size14,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  fontFamily: AppFonts.rubik,
                  color: AppColors.subtextcolor,
                ),
              ),
              const SizedBox(height: 20),
              CustomTextFormFieldWidget(
                controller: passwordController,
                label: AppStrings.password,
                hintText: AppStrings.passwordHint,
                focusNode: passwordFocus,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppStrings.enterValidPassword;
                  } else if (value.length < 6) {
                    return AppStrings.passwordLengthMessage;
                  }
                  return null;
                },
                keyboardType: TextInputType.text,
                textStyle: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontWeight: FontWeight.w400,
                  fontSize: FontSizes(context).size14,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppColors.grey),
                ),
                labelStyle: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontWeight: FontWeight.w400,
                  fontSize: FontSizes(context).size14,
                  color: AppColors.subtextcolor,
                ),
                obscureText: isPasswordHidden,
                suffixIcon: isPasswordHidden
                    ? InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () {
                    ref.read(hidePasswordProvider.notifier).state = false;
                  },
                  child: const Icon(
                    Icons.visibility_off,
                    size: 20,
                  ),
                )
                    : InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  onTap: () {
                    ref.read(hidePasswordProvider.notifier).state = true;
                  },
                  child: const Icon(
                    Icons.visibility,
                    size: 20,
                  ),
                ),
              ),
              50.height,

              // Sign In button
              Padding(
                padding: const EdgeInsets.only(left: 20.0,right: 20),
                child: CustomButtonWidget(
                  text: AppStrings.signIn,
                  height: ScreenUtil.scaleHeight(context, 54),
                  backgroundColor: AppColors.btnBgColor,
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size18,
                  fontWeight: FontWeight.w900,
                  textColor: AppColors.gradientWhite,
                  onPressed: () async {
                    await _signIn(context, ref);
                  },
                ),
              ),
              20.height,

           const SignInFooterWidget(),
            ],
          );
        },
      ),
    );
  }

  Future<void> _signIn(BuildContext context, WidgetRef ref) async {
    await wait(const Duration(milliseconds: 100));
    FocusScope.of(context).unfocus();
    if (!formKey.currentState!.validate()) return;

    final isConnected = await ref.read(checkInternetConnectionProvider.future);
    if (!isConnected) {
      if (context.mounted) {
        CustomSnackBarWidget.show(
          context: context,
          text: "No Internet Connection",
        );
      }
      return;
    }

    try {
      ref.read(isSigningInProvider.notifier).state = true;
      final authService = ref.read(authProvider);
      final result = await authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      if (!context.mounted) return;
      await wait(const Duration(seconds: 3));
      ref.read(isSigningInProvider.notifier).state = false;
      if (result['success']) {
        CustomSnackBarWidget.show(
          context: context,
          text: result['message'],
        );
        if (result['userType'] == 'Doctor') {
          AppNavigation.pushReplacement(const DoctorHomeView());
        } else if (result['userType'] == 'Patient') {
          ref.refresh(currentSignInPatientDataProvider);
          ref.refresh(doctorsProvider);
          ref.refresh(favoriteDoctorUidsProvider);
          AppNavigation.pushReplacement( PatientMainView());
        } else {
          CustomSnackBarWidget.show(
            context: context,
            text: 'User type not identified',
          );
        }
      } else {
        CustomSnackBarWidget.show(
          context: context,
          text: result['message'],
        );
      }
    } catch (e) {
      if (context.mounted) {
        ref.read(isSigningInProvider.notifier).state = false;
        CustomSnackBarWidget.show(
          context: context,
          text: e.toString().replaceAll('Exception: ', ''),
        );
      }
    }
  }

}