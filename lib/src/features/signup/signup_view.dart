import 'package:curemate/extentions/widget_extension.dart';
import 'package:curemate/src/features/signup/providers/signup_form_provider.dart';
import 'package:curemate/src/features/signup/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/features/signup/widgets/credentials_form_section.dart';
import 'package:curemate/src/features/signup/widgets/header_widget.dart';
import 'package:curemate/src/features/signup/widgets/personal_info_section.dart';
import 'package:curemate/src/features/signup/widgets/profile_image_section.dart';
import 'package:curemate/src/features/signup/widgets/signin_link_section.dart';
import 'package:curemate/src/features/signup/widgets/signing_up_dialog_widget.dart';
import 'package:curemate/src/features/signup/widgets/signup_button_section.dart';
import 'package:curemate/src/features/signup/widgets/uper_background_effects_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../const/app_fonts.dart';
import '../../../const/app_strings.dart';
import '../../../const/font_sizes.dart';
import '../../router/nav.dart';
import '../../shared/providers/check_internet_connectivity_provider.dart';
import '../../shared/providers/drop_down_provider/custom_drop_down_provider.dart';
import '../../shared/widgets/custom_button_widget.dart';
import '../../theme/app_colors.dart';
import '../../utils/screen_utils.dart';
import '../doctor/home/views/doctor_home_view.dart';
import '../patient/home/views/patient_home_view.dart';
import '../signin/providers/auth-provider.dart';

class SignUpView extends ConsumerStatefulWidget {
  const SignUpView({super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewScreenState();
}

class _SignUpViewScreenState extends ConsumerState<SignUpView> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isSigningUpProvider, (previous, next) {
      if (next) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const SigningUpDialog(),
        );
      } else {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    });

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
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
                          // SignupButtonSection(formKey: _formKey),
                      CustomButtonWidget(
                        text: AppStrings.signUp,
                        height: ScreenUtil.scaleHeight(context, 54),
                        backgroundColor: AppColors.btnBgColor,
                        fontFamily: AppFonts.rubik,
                        fontSize: FontSizes(context).size18,
                        fontWeight: FontWeight.w900,
                        textColor: AppColors.gradientWhite,
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final profileImage = ref.read(userProfileProvider);
                              final isNetworkAvailable = ref.read(checkInternetConnectionProvider);
                              final userType = ref.read(customDropDownProvider(AppStrings.userTypes));
                              final user = userType.selected;

                              if (profileImage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Please upload a profile image')),
                                );
                                return;
                              }

                              final isConnected = await isNetworkAvailable.whenData((value) => value).value ?? false;

                              if (!isConnected) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('No internet connection')),
                                );
                                return;
                              }

                              ref.read(isSigningUpProvider.notifier).state = true;

                              String result = '';
                              try {
                                result = await ref.read(authProvider).signUp();
                              } catch (e) {
                                result = 'SignUp Error: ${e.toString()}';
                              } finally {
                                if (mounted) {
                                  ref.read(isSigningUpProvider.notifier).state = false;
                                }
                              }

                              if (!mounted) return;

                              if (result == 'Account created successfully!') {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Sign Up Successful!')),
                                );
                                AppNavigation.pushReplacement(
                                  user == 'Doctor' ? const DoctorHomeView() : const PatientHomeView(),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result)),
                                );
                              }
                            }
                          }

                      ),
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
              const UpperBackgroundEffectsWidgets(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

