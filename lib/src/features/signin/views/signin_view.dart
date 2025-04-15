import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/extentions/widget_extension.dart';
import 'package:curemate/src/features/home/views/home_view.dart';
import 'package:curemate/src/features/reset_password/views/reset_password_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_form_field_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/shared/widgets/uper_background_effects_widget.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../const/app_strings.dart';
import '../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../shared/soft_corner_glow_container_widget.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_cloudy_color_effect_widget.dart';
import '../../../theme/app_colors.dart';
import '../../doctor/home/views/doctor_home_view.dart';
import '../../patient/home/views/patient_home_view.dart';
import '../../signup/signup_view.dart';
import '../providers/auth-provider.dart';
import '../providers/signin_form_providers.dart';
import '../widgets/signing_in_dialog_widget.dart';

final hidePasswordProvider = StateProvider<bool>((ref) => true);

class SignInView extends ConsumerStatefulWidget {
  SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSigningIn = ref.watch(isSigningInProvider);
    if (isSigningIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) =>
                  SigningInDialogWidget(email: emailController.text.trim()),
        );
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      });
    }
    final isPasswordHidden = ref.watch(hidePasswordProvider);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      child: Scaffold(
        // resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.gradientWhite,
        body: Form(
          key: _formKey,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const LowerBackgroundEffectsWidgets(),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                top:
                    keyboardHeight > 0
                        ? ScreenUtil.scaleHeight(context, 100)
                        : ScreenUtil.scaleHeight(context, 127),
                left: ScreenUtil.scaleWidth(context, 108),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: keyboardHeight > 0 ? 0.0 : 1.0,
                  child: CustomTextWidget(
                    text: AppStrings.welcomeBack,
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: FontSizes(context).size26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                top:
                    keyboardHeight > 0
                        ? ScreenUtil.scaleHeight(context, 100)
                        : ScreenUtil.scaleHeight(context, 163),
                left: ScreenUtil.scaleWidth(context, 50),
                right: ScreenUtil.scaleWidth(context, 45),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: keyboardHeight > 0 ? 0.0 : 1.0,
                  child: CustomTextWidget(
                    text: AppStrings.subtextOfWelcomeBack,
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: FontSizes(context).size14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.detailsTextColor,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return ListView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: EdgeInsets.only(
                        top: keyboardHeight > 0 ? 200 : 300,
                        bottom: keyboardHeight > 0 ? keyboardHeight + 20 : 20,
                      ),
                      children: [
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
                          suffixIcon:
                              isPasswordHidden
                                  ? InkWell(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    onTap: () {
                                      ref
                                          .read(hidePasswordProvider.notifier)
                                          .state = false;
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
                                      ref
                                          .read(hidePasswordProvider.notifier)
                                          .state = true;
                                    },
                                    child: const Icon(
                                      Icons.visibility,
                                      size: 20,
                                    ),
                                  ),
                        ),
                        50.height,
                        CustomButtonWidget(
                          text: AppStrings.signIn,
                          height: ScreenUtil.scaleHeight(context, 54),
                          backgroundColor: AppColors.btnBgColor,
                          fontFamily: AppFonts.rubik,
                          fontSize: FontSizes(context).size18,
                          fontWeight: FontWeight.w900,
                          textColor: AppColors.gradientWhite,
                          onPressed: _signIn,
                        ),
                        20.height,
                        TextButton(
                          onPressed: () {
                            AppNavigation.pushReplacement(
                              const ResetPasswordView(),
                            );
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
                        143.height,
                        TextButton(
                          onPressed: () {
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
                  },
                ),
              ),
              const UpperBackgroundEffectsWidgets(),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      final isNetworkAvailable = ref.read(checkInternetConnectionProvider);
      final isConnected =
          await isNetworkAvailable.whenData((value) => value).value ?? false;

      if (!isConnected) {
        CustomSnackBarWidget.show(
          context: context,
          backgroundColor: AppColors.gradientGreen,
          text: "No Internet Connection",
        );
        return;
      }

      try {
        ref.read(isSigningInProvider.notifier).state = true;

        final authService = ref.read(authProvider);

        User? user = await authService.signIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        if (!mounted) return;

        if (user == null) {
          CustomSnackBarWidget.show(
            context: context,
            backgroundColor: AppColors.gradientGreen,
            text: 'Failed to sign in. Please try again.',
          );
          return;
        }

        // Get user type directly here
        final dbRef = ref.read(firebaseDatabaseProvider);
        String uid = user.uid;

        final doctorSnapshot = await dbRef.child('Doctors').child(uid).get();
        final patientSnapshot = await dbRef.child('Patients').child(uid).get();

        if (!mounted) return;

        // Use direct Navigator instead of AppNavigation
        if (doctorSnapshot.exists) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const DoctorHomeView())
          );
        } else if (patientSnapshot.exists) {
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const PatientHomeView())
          );
        } else {
          CustomSnackBarWidget.show(
            context: context,
            backgroundColor: AppColors.gradientGreen,
            text: 'User not found',
          );
        }

      } catch (e) {
        if (mounted) {
          CustomSnackBarWidget.show(
              context: context,
              text: "${e.toString().replaceAll('Exception: ', '')}"
          );
        }
      } finally {
        if (mounted) {
          ref.read(isSigningInProvider.notifier).state = false;
        }
      }
    }
  }
}
