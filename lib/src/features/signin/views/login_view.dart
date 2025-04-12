import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/extentions/widget_extension.dart';
import 'package:curemate/src/features/home/views/home_view.dart';
import 'package:curemate/src/features/reset_password/views/reset_password_view.dart';
import 'package:curemate/src/features/signup/signup-view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_text_form_field_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../const/app_strings.dart';
import '../../../shared/soft_corner_glow_container_widget.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_cloudy_color_effect_widget.dart';
import '../../../theme/app_colors.dart';
import '../providers/auth-provider.dart';

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
    final isPasswordHidden = ref.watch(hidePasswordProvider);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return WillPopScope(
      onWillPop: ()async=>false,
      child: Scaffold(
        // resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.gradientWhite,
        body: Form(
          key: _formKey,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomLinearGradientContainerWidget(
                width: ScreenUtil.scaleWidth(context, 200),
                height: ScreenUtil.scaleHeight(context, 200),
                left: ScreenUtil.scaleHeight(context, -100),
                top: ScreenUtil.scaleHeight(context, -150),
                colors: const [
                  AppColors.gradientGreen,
                  AppColors.gradientTurquoiseGreen,
                ],
              ),
              CustomLinearGradientContainerWidget(
                width: ScreenUtil.scaleWidth(context, 200),
                height: ScreenUtil.scaleHeight(context, 200),
                right: ScreenUtil.scaleHeight(context, -100),
                bottom: ScreenUtil.scaleHeight(context, -150),
                colors: const [
                  AppColors.gradientGreen,
                  AppColors.gradientTurquoiseGreen,
                ],
              ),
      
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
      
              // Background effects
              CustomCloudyColorEffectWidget.bottomRight(
                color: AppColors.gradientGreen,
                size: 100,
                intensity: 1,
                spreadRadius: 1,
              ),
              CustomCloudyColorEffectWidget.topLeft(
                color: AppColors.gradientGreen,
                size: 100,
                intensity: 1,
                spreadRadius: 1,
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
                            }
                            return null;
                          },
                          keyboardType: TextInputType.visiblePassword,
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
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              try {
                                User? user = await ref
                                    .read(authProvider)
                                    .signIn(
                                      email: emailController.text.trim(),
                                      password: passwordController.text.trim(),
                                    );
                                if (user != null && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Sign In Successful!'),
                                    ),
                                  );
                                  AppNavigation.push(const HomeView());
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            }
                          },
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
                              color: AppColors.gradientGreen
                            ),
                          ),
                        ),
                        143.height,
                        TextButton(
                          onPressed: () {
                            AppNavigation.pushReplacement(SignUpScreen());
                          },
                          child:  CustomTextWidget(
                            text: AppStrings.doNotHaveAccount,
                            textStyle: TextStyle(
                                fontFamily: AppFonts.rubik,
                                fontSize: FontSizes(context).size14,
                                color: AppColors.gradientGreen
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
