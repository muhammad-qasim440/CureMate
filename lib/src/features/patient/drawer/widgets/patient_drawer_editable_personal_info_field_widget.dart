import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/src/shared/widgets/custom_text_form_field_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/font_sizes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';

class EditablePersonalInfoField extends ConsumerWidget {
  final String title;
  final StateProvider<String> subtitleProvider;
  final StateProvider<bool> isEditingProvider;
  final void Function(String) onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final bool isEnabled;
  final VoidCallback? onChangeDetected;

  const EditablePersonalInfoField({
    super.key,
    required this.title,
    required this.subtitleProvider,
    required this.isEditingProvider,
    required this.onChanged,
    this.validator,
    this.keyboardType,
    this.suffixIcon,
    required this.isEnabled,
    this.onChangeDetected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = ref.watch(isEditingProvider);
    final subtitle = ref.watch(subtitleProvider) ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: ScreenUtil.scaleWidth(context, 320),
      height: ScreenUtil.scaleHeight(context, 60),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        shape: BoxShape.rectangle,
        color: AppColors.gradientWhite,
      ),
      child: isEditing
          ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: CustomTextFormFieldWidget(
          initialValue: subtitle,
          onChanged: (value) {
            onChanged(value);
            if (onChangeDetected != null) {
              onChangeDetected!();
            }
          },
          onFieldSubmitted: (value) {
            ref.read(isEditingProvider.notifier).state = false;
          },
          validator: validator,
          keyboardType: keyboardType??TextInputType.text,
          suffixIcon: suffixIcon,
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size16,
            color: AppColors.subtextcolor,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
        ),
      )
          : Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: ScreenUtil.scaleWidth(context, 20)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextWidget(
                    text: title,
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: FontSizes(context).size12,
                      color: AppColors.gradientGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CustomTextWidget(
                    text: subtitle,
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: FontSizes(context).size16,
                      color: AppColors.subtextcolor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.subtextcolor, size: 20),
            onPressed: isEnabled
                ? () => ref.read(isEditingProvider.notifier).state = true
                : null,
          ),
        ],
      ),
    );
  }
}