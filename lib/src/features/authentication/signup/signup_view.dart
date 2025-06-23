import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/authentication/signup/providers/signup_form_provider.dart';
import 'package:curemate/src/features/authentication/signup/widgets/credentials_form_section.dart';
import 'package:curemate/src/features/authentication/signup/widgets/header_widget.dart';
import 'package:curemate/src/features/authentication/signup/widgets/personal_info_section.dart';
import 'package:curemate/src/features/authentication/signup/widgets/profile_image_section.dart';
import 'package:curemate/src/features/authentication/signup/widgets/signin_link_section.dart';
import 'package:curemate/src/features/authentication/signup/widgets/signing_up_dialog_widget.dart';
import 'package:curemate/src/features/patient/views/patient_main_view.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/shared/widgets/uper_background_effects_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/app_strings.dart';
import '../../../../const/font_sizes.dart';
import '../../../router/nav.dart';
import '../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../shared/providers/drop_down_provider/custom_drop_down_provider.dart';
import '../../../shared/providers/profile_image_picker_provider/profile_image_picker_provider.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../doctor/doctor_main_view.dart';
import '../signin/providers/auth_provider.dart';

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
          barrierDismissible: true,
          builder: (context) => const SigningUpDialog(),
        );
      } else {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    });

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    return PopScope(
      canPop: false,
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
                      Padding(
                        padding: const EdgeInsets.only(left:20.0,right: 20),
                        child: CustomButtonWidget(
                          text: AppStrings.signUp,
                          height: ScreenUtil.scaleHeight(context, 54),
                          backgroundColor: AppColors.btnBgColor,
                          fontFamily: AppFonts.rubik,
                          fontSize: FontSizes(context).size18,
                          fontWeight: FontWeight.w900,
                          textColor: AppColors.gradientWhite,
                            onPressed:_signUp,
                        ),
                      ),
                          10.height,
                          Padding(
                            padding: const EdgeInsets.only(left:20.0,right: 20),
                            child: CustomButtonWidget(
                              text: 'Logout',
                              height: ScreenUtil.scaleHeight(context, 54),
                              backgroundColor: AppColors.btnBgColor,
                              fontFamily: AppFonts.rubik,
                              fontSize: FontSizes(context).size18,
                              fontWeight: FontWeight.w900,
                              textColor: AppColors.gradientWhite,
                              onPressed:()async{await ref.read(authProvider).logout(context);},
                            ),
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


  Future<void> _signUp() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    final daySlotConfigs = ref.read(daySlotConfigsProvider);
    final profileImage = ref.read(userProfileProvider);
    final isConnected = await ref.read(checkInternetConnectionProvider.future);
    final userType = ref.read(customDropDownProvider(AppStrings.userTypes));
    final user = userType.selected;
    if (profileImage == null) {
        CustomSnackBarWidget.show(
          context: context,
          text: "Please upload a profile image",
        );
      return;
    }
    if (daySlotConfigs.isEmpty) {
      CustomSnackBarWidget.show(
        context: context,
        text: "Please add available time slot in list",
      );
      return;
    }
    if (!isConnected) {
      CustomSnackBarWidget.show(
        context: context,
        text: "No Internet Connection",
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
      ref.read(profileImagePickerProvider.notifier).reset(ref);
      ref.read(daySlotConfigsProvider.notifier).state=[];
      CustomSnackBarWidget.show(
        context: context,
        text: "Sign Up Successful!",
      );
      AppNavigation.pushReplacement(
        user == 'Doctor' ? const DoctorMainView() :const PatientMainView(),
      );
    } else {
      CustomSnackBarWidget.show(
        context: context,
        text: result,
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }


}

