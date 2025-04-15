import 'package:curemate/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../theme/app_colors.dart';
import '../providers/signup_form_provider.dart';

class DoctorDetailsWidget extends ConsumerStatefulWidget {
  const DoctorDetailsWidget({super.key});

  @override
  ConsumerState<DoctorDetailsWidget> createState() => _DoctorDetailsWidgetState();
}

class _DoctorDetailsWidgetState extends ConsumerState<DoctorDetailsWidget> {
  final FocusNode qualificationFocus = FocusNode();
  final FocusNode categoryFocus = FocusNode();
  final FocusNode yearsOfExperienceFocus = FocusNode();

  @override
  void dispose() {
    qualificationFocus.dispose();
    categoryFocus.dispose();
    yearsOfExperienceFocus.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormFieldWidget(
          label: 'Category',
          hintText: 'Enter your category',
          focusNode: categoryFocus,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your category';
            }
            return null;
          },
          onChanged:
              (value) =>
          ref.read(docQualificationProvider.notifier).state = value,
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
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: AppFonts.rubik,
            color: AppColors.subtextcolor,
          ),
          maxLines: 3,
        ),
        23.height,
        CustomTextFormFieldWidget(
          label: 'Qualification',
          hintText: 'Enter your qualification',
          focusNode: qualificationFocus,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your qualification';
            }
            return null;
          },
          onChanged:
              (value) =>
          ref.read(docQualificationProvider.notifier).state = value,
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
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: AppFonts.rubik,
            color: AppColors.subtextcolor,
          ),
          maxLines: 3,
        ),
        23.height,
        CustomTextFormFieldWidget(
          label: 'Experience',
          hintText: 'Enter years of experience',
          focusNode: yearsOfExperienceFocus,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter years of experience';
            }
            return null;
          },
          onChanged:
              (value) =>
          ref.read(docYearsOfExperienceProvider.notifier).state = value,
          keyboardType: TextInputType.number,
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
          maxLines: 3,
        ),
      ],
    );
  }
}
