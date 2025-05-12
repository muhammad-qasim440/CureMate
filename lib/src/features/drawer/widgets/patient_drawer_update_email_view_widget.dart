import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_form_field_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curemate/src/theme/app_colors.dart';
import '../../../../../const/app_strings.dart';
import '../../../../../const/font_sizes.dart';
import '../../../utils/screen_utils.dart';

final updateEmailProvider =
StateNotifierProvider<UpdateEmailNotifier, UpdateEmailState>((ref) {
  return UpdateEmailNotifier();
});

class UpdateEmailState {
  final String newEmail;
  final String currentPassword;
  final String newPassword;
  final String confirmNewPassword;
  final bool isLoading;
  final String? errorMessage;

  UpdateEmailState({
    this.newEmail = '',
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmNewPassword = '',
    this.isLoading = false,
    this.errorMessage,
  });

  UpdateEmailState copyWith({
    String? newEmail,
    String? currentPassword,
    String? newPassword,
    String? confirmNewPassword,
    bool? isLoading,
    String? errorMessage,
  }) {
    return UpdateEmailState(
      newEmail: newEmail ?? this.newEmail,
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmNewPassword: confirmNewPassword ?? this.confirmNewPassword,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class UpdateEmailNotifier extends StateNotifier<UpdateEmailState> {
  UpdateEmailNotifier() : super(UpdateEmailState());

  void updateNewEmail(String value) {
    state = state.copyWith(newEmail: value);
  }

  void updateCurrentPassword(String value) {
    state = state.copyWith(currentPassword: value);
  }

  void updateNewPassword(String value) {
    state = state.copyWith(newPassword: value);
  }

  void updateConfirmNewPassword(String value) {
    state = state.copyWith(confirmNewPassword: value);
  }

  Future<void> submitUpdate(
      String currentEmail,
      Function(String, String, String) onUpdate,
      BuildContext context,
      ) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await onUpdate(state.newEmail, state.currentPassword, state.newPassword);
      Navigator.pop(context);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update email: $e',
      );
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }
}

class UpdateEmailScreen extends ConsumerStatefulWidget {
  final String currentEmail;
  final Future<void> Function(
      String newEmail,
      String currentPassword,
      String newPassword,
      ) onUpdate;

  const UpdateEmailScreen({
    super.key,
    required this.currentEmail,
    required this.onUpdate,
  });

  @override
  ConsumerState<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends ConsumerState<UpdateEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController newEmailController;
  late final TextEditingController currentPasswordController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmNewPasswordController;


  @override
  void initState() {
    super.initState();
    newEmailController = TextEditingController(text: '');
    currentPasswordController = TextEditingController(text: '');
    newPasswordController = TextEditingController(text: '');
    confirmNewPasswordController = TextEditingController(text: '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(updateEmailProvider);
      newEmailController.text = state.newEmail;
      currentPasswordController.text = state.currentPassword;
      newPasswordController.text = state.newPassword;
      confirmNewPasswordController.text = state.confirmNewPassword;
    });
  }

  @override
  void dispose() {
    newEmailController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateEmailProvider);
    final notifier = ref.read(updateEmailProvider.notifier);

    newEmailController.text = state.newEmail;
    currentPasswordController.text = state.currentPassword;
    newPasswordController.text = state.newPassword;
    confirmNewPasswordController.text = state.confirmNewPassword;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.gradientGreen,
        elevation: 0,
        title: CustomTextWidget(
          text: 'Update Email & Password',
          textStyle: TextStyle(
            color: AppColors.gradientWhite,
            fontSize: FontSizes(context).size20,
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientGreen.withOpacity(0.15), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: ScreenUtil.scaleWidth(context, 24),
              vertical: ScreenUtil.scaleHeight(context, 20),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Current Email Display
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.email,
                            color: AppColors.gradientGreen,
                          ),
                          12.width,
                          Expanded(
                            child: CustomTextWidget(
                              text: 'Current Email: ${widget.currentEmail}',
                              textStyle: TextStyle(
                                fontFamily: AppFonts.rubik,
                                fontSize: FontSizes(context).size16,
                                color: AppColors.subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  24.height,

                  // New Email Field
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: CustomTextFormFieldWidget(
                      label: 'New Email',
                      hintText: 'Enter new email address',
                      controller: newEmailController
                        ..addListener(() {
                          notifier.updateNewEmail(newEmailController.text);
                        }),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return AppStrings.enterValidEmail;
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(
                        Icons.email_outlined,
                        color: AppColors.gradientGreen,
                      ),
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  16.height,

                  // Current Password Field
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: CustomTextFormFieldWidget(
                      label: 'Current Password',
                      hintText: 'Enter your current password',
                      controller: currentPasswordController
                        ..addListener(() {
                          notifier.updateCurrentPassword(currentPasswordController.text);
                        }),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your current password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.gradientGreen,
                      ),
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  16.height,

                  // New Password Field
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: CustomTextFormFieldWidget(
                      label: 'New Password',
                      hintText: 'Enter new password',
                      controller: newPasswordController
                        ..addListener(() {
                          notifier.updateNewPassword(newPasswordController.text);
                        }),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a new password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.gradientGreen,
                      ),
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  16.height,

                  // Confirm New Password Field
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: CustomTextFormFieldWidget(
                      label: 'Confirm New Password',
                      hintText: 'Confirm your new password',
                      controller: confirmNewPasswordController
                        ..addListener(() {
                          notifier.updateConfirmNewPassword(confirmNewPasswordController.text);
                        }),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your new password';
                        }
                        if (value != state.newPassword) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      obscureText: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: AppColors.gradientGreen,
                      ),
                      fillColor: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  24.height,

                  // Error Message
                  if (state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: CustomTextWidget(
                        text: state.errorMessage!,
                        textStyle: TextStyle(
                          color: Colors.redAccent,
                          fontSize: FontSizes(context).size14,
                          fontFamily: AppFonts.rubik,
                        ),
                      ),
                    ),

                  // Update Button
                  CustomButtonWidget(
                    text: 'Update Email & Password',
                    onPressed: state.isLoading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        await notifier.submitUpdate(
                          widget.currentEmail,
                          widget.onUpdate,
                          context,
                        );
                      }
                    },
                    backgroundColor: AppColors.gradientGreen,
                    textColor: Colors.white,
                    borderRadius: 12,
                    isLoading: state.isLoading,
                    height: 56,
                      fontSize: FontSizes(context).size16,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppFonts.rubik,
                    elevation: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}