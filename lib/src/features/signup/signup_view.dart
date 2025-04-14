import 'package:curemate/extentions/widget_extension.dart';
import 'package:curemate/src/features/signup/providers/signup_form_provider.dart';
import 'package:curemate/src/features/signup/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/features/signup/widgets/credentials_form_section.dart';
import 'package:curemate/src/features/signup/widgets/header_widget.dart';
import 'package:curemate/src/features/signup/widgets/personal_info_section.dart';
import 'package:curemate/src/features/signup/widgets/profile_image_section.dart';
import 'package:curemate/src/features/signup/widgets/signin_link_section.dart';
import 'package:curemate/src/features/signup/widgets/signup_button_section.dart';
import 'package:curemate/src/features/signup/widgets/uper_background_effects_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewScreenState();
}

class _SignUpViewScreenState extends ConsumerState<SignUpView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isSigningUp = ref.watch(isSigningUpProvider);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: AppColors.gradientWhite,
        body: Form(
          key: _formKey,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const LowerBackgroundEffectsWidgets(),
              if (!isSigningUp) ...[
              SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  children: [
                    SizedBox(
                      height: keyboardHeight > 0 ? 10 : 100,
                      width: double.infinity,
                      child: HeaderWidget(keyboardHeight: keyboardHeight),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const ProfileImageSection(),
                          CredentialsFormSection(formKey: _formKey),
                          const SizedBox(height: 23),
                          const PersonalInfoSection(),
                          50.height,
                          SignupButtonSection(formKey: _formKey),
                          30.height,
                          const SignInLinkSection(),
                          SizedBox(
                            height: keyboardHeight > 0 ? keyboardHeight : 20,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              ],
              if (isSigningUp) ...[
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        CustomTextWidget(text: 'Signing Up please wait'),
                      ],
                    ),
                  )
              ],

              const UpperBackgroundEffectsWidgets(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    ref.read(signUpFormProvider.notifier).dispose();
    super.dispose();
  }
}
