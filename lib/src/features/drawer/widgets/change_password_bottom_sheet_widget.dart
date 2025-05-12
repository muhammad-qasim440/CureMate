import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_form_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../const/app_fonts.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../providers/change_password_providers.dart';

class ChangePasswordBottomSheet {
  static void show(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.zero,
        child: CustomChangePasswordSheet(ref: ref),
      ),
    ).then((_) {
      ref.read(passwordUpdateProvider).resetProviders();
    });
  }
}

class CustomChangePasswordSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const CustomChangePasswordSheet({super.key, required this.ref});

  @override
  ConsumerState<CustomChangePasswordSheet> createState() => _CustomChangePasswordSheetState();
}

class _CustomChangePasswordSheetState extends ConsumerState<CustomChangePasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordFocus = FocusNode();
  final _newPasswordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  @override
  void dispose() {
    _currentPasswordFocus.dispose();
    _newPasswordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isUpdating = ref.watch(isUpdatingPasswordProvider);
    final allFieldsFilled = ref.watch(allFieldsFilledProvider);
    final errorMessage = ref.watch(errorMessageProvider);

    return ScaffoldMessenger(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7, // Limit to 70% of screen height
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Change Password',
                          style: TextStyle(
                            fontFamily: AppFonts.rubik,
                            fontWeight: FontWeight.bold,
                            fontSize: FontSizes(context).size20,
                            color: Colors.black87,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black54),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    16.height,
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          CustomTextFormFieldWidget(
                            label: 'Current Password',
                            hintText: 'Enter current password',
                            obscureText: ref.watch(hideCurrentPasswordProvider),
                            keyboardType: TextInputType.text,
                            focusNode: _currentPasswordFocus,
                            textStyle: TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontWeight: FontWeight.w400,
                              fontSize: FontSizes(context).size14,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your current password';
                              }
                              final error = ref.read(currentPasswordErrorProvider);
                              if (error != null) {
                                return error;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              ref.read(currentPasswordProvider.notifier).state = value;
                              ref.read(currentPasswordErrorProvider.notifier).state = null; // Clear error
                              ref.read(errorMessageProvider.notifier).state = null; // Clear general error
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_newPasswordFocus);
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                ref.watch(hideCurrentPasswordProvider) ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                              ),
                              onPressed: () {
                                ref.read(hideCurrentPasswordProvider.notifier).state =
                                !ref.read(hideCurrentPasswordProvider);
                                print('Current Password Visibility Toggled: ${ref.read(hideCurrentPasswordProvider)}');
                              },
                            ),
                          ),
                          12.height,
                          CustomTextFormFieldWidget(
                            label: 'New Password',
                            hintText: 'Enter new password',
                            obscureText: ref.watch(hideNewPasswordProvider),
                            keyboardType: TextInputType.text,
                            focusNode: _newPasswordFocus,
                            textStyle: TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontWeight: FontWeight.w400,
                              fontSize: FontSizes(context).size14,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a new password';
                              } else if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              ref.read(newPasswordProvider.notifier).state = value;
                              ref.read(errorMessageProvider.notifier).state = null; // Clear general error
                            },
                            onFieldSubmitted: (_) {
                              FocusScope.of(context).requestFocus(_confirmPasswordFocus);
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                ref.watch(hideNewPasswordProvider) ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                              ),
                              onPressed: () {
                                ref.read(hideNewPasswordProvider.notifier).state =
                                !ref.read(hideNewPasswordProvider);
                                print('New Password Visibility Toggled: ${ref.read(hideNewPasswordProvider)}');
                              },
                            ),
                          ),
                          12.height,
                          CustomTextFormFieldWidget(
                            label: 'Confirm New Password',
                            hintText: 'Confirm new password',
                            obscureText: ref.watch(hideConfirmPasswordProvider),
                            keyboardType: TextInputType.text,
                            focusNode: _confirmPasswordFocus,
                            textStyle: TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontWeight: FontWeight.w400,
                              fontSize: FontSizes(context).size14,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey.shade300),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your new password';
                              }
                              final error = ref.read(confirmPasswordErrorProvider);
                              if (error != null) {
                                return error;
                              }
                              return null;
                            },
                            onChanged: (value) {
                              ref.read(confirmNewPasswordProvider.notifier).state = value;
                              ref.read(confirmPasswordErrorProvider.notifier).state = null; // Clear error
                              ref.read(errorMessageProvider.notifier).state = null; // Clear general error
                            },
                            onFieldSubmitted: (_) {
                              if (_formKey.currentState!.validate()) {
                                ref.read(passwordUpdateProvider).updatePassword(context, _formKey);
                              }
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                ref.watch(hideConfirmPasswordProvider) ? Icons.visibility_off : Icons.visibility,
                                size: 20,
                              ),
                              onPressed: () {
                                ref.read(hideConfirmPasswordProvider.notifier).state =
                                !ref.read(hideConfirmPasswordProvider);
                              },
                            ),
                          ),
                          12.height,
                          if (errorMessage != null) ...[
                            CustomTextWidget(
                              text: errorMessage,
                              textStyle: TextStyle(
                                fontFamily: AppFonts.rubik,
                                fontSize: FontSizes(context).size14,
                                color: Colors.red,
                              ),
                            ),
                            8.height,
                          ],
                          CustomButtonWidget(
                            text: 'Update Password',
                            isEnabled: allFieldsFilled && !isUpdating,
                            isLoading: isUpdating,
                            backgroundColor: AppColors.gradientGreen,
                            textColor: Colors.white,
                            fontSize: FontSizes(context).size16,
                            fontFamily: AppFonts.rubik,
                            fontWeight: FontWeight.w500,
                            borderRadius: 12,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ref.read(passwordUpdateProvider).updatePassword(context, _formKey);
                              }
                            },
                          ),
                          16.height,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}