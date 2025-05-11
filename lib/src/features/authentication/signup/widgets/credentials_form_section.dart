import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/app_strings.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_drop_down_menu_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_form_field_widget.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/signup_form_provider.dart';

class CredentialsFormSection extends ConsumerWidget {
  final GlobalKey<FormState> formKey;

  const CredentialsFormSection({super.key, required this.formKey});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPasswordHidden = ref.watch(hidePasswordProvider);

    return Column(
      children: [
        const CustomDropdown(
          items: AppStrings.userTypes,
          label: 'Type',
          validatorText: 'please select user type',
        ),
        23.height,
        CustomTextFormFieldWidget(
          label: AppStrings.email,
          hintText: AppStrings.enterEmail,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.enterEmail;
            }
            const pattern =
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';

            final regex = RegExp(pattern);
            if (!regex.hasMatch(value)) {
              return AppStrings.enterValidEmail;
            }
            return null;
          },
          onChanged: (value) => ref.read(emailProvider.notifier).state = value,
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
            color: AppColors.subTextColor,
          ),
        ),
        const SizedBox(height: 20),
        CustomTextFormFieldWidget(
          label: AppStrings.password,
          hintText: AppStrings.passwordHint,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return AppStrings.enterValidPassword;
            } else if (value.length < 6) {
              return AppStrings.passwordLengthMessage;
            }
            return null;
          },
          onChanged:
              (value) => ref.read(passwordProvider.notifier).state = value,
          keyboardType: TextInputType.text,
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w400,
            fontSize: FontSizes(context).size14,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          labelStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w400,
            fontSize: FontSizes(context).size14,
            color: AppColors.subTextColor,
          ),
          obscureText: isPasswordHidden,
          suffixIcon:
              isPasswordHidden
                  ? InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () {
                      ref.read(hidePasswordProvider.notifier).state = false;
                    },
                    child: const Icon(Icons.visibility_off, size: 20),
                  )
                  : InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () {
                      ref.read(hidePasswordProvider.notifier).state = true;
                    },
                    child: const Icon(Icons.visibility, size: 20),
                  ),
        ),
      ],
    );
  }
}
