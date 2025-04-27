import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/app_strings.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_drop_down_menu_widget.dart';
import '../../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../../theme/app_colors.dart';
import '../providers/signup_form_provider.dart';

class DoctorDetailsWidget extends ConsumerStatefulWidget {
  const DoctorDetailsWidget({super.key});

  @override
  ConsumerState<DoctorDetailsWidget> createState() => _DoctorDetailsWidgetState();
}

class _DoctorDetailsWidgetState extends ConsumerState<DoctorDetailsWidget> {
  final FocusNode qualificationFocus = FocusNode();
  final FocusNode categoryFocus = FocusNode();
  final FocusNode hospitalFocus = FocusNode();
  final FocusNode yearsOfExperienceFocus = FocusNode();
// Days of the week for selection
  final List<String> daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  @override
  void dispose() {
    qualificationFocus.dispose();
    categoryFocus.dispose();
    hospitalFocus.dispose();
    yearsOfExperienceFocus.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormFieldWidget(
          label: 'Fee',
          hintText: 'Consultation Fee (PKR)',
          focusNode: categoryFocus,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your consultation fee';
            }
            return null;
          },
          onChanged:
              (value) =>
          ref.read(docConsultancyFeeProvider.notifier).state =int.parse(value),
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
        23.height,

        const CustomDropdown(
          items: AppStrings.docCategories,
          label: 'Category',
          validatorText: 'please select your category',
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
          label: 'Hospital/Clinic',
          hintText: 'Hospital/Clinic name (CMH Multan)',
          focusNode: hospitalFocus,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please your hospital or clinic name';
            }
            return null;
          },
          onChanged:
              (value) =>
          ref.read(docHospitalProvider.notifier).state = value,
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
        23.height,
// New Fields for Availability
        const Text(
          'Select Available Days',
          style: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
        10.height,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: daysOfWeek.map((day) {
            final selectedDays = ref.watch(availableDaysProvider);
            final isSelected = selectedDays.contains(day);
            return ChoiceChip(
              label: Text(day),
              selected: isSelected,
              onSelected: (selected) {
                final updatedDays = List<String>.from(selectedDays);
                if (selected) {
                  updatedDays.add(day);
                } else {
                  updatedDays.remove(day);
                }
                ref.read(availableDaysProvider.notifier).state = updatedDays;
              },
              selectedColor: AppColors.gradientGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.subtextcolor,
                fontFamily: AppFonts.rubik,
              ),
            );
          }).toList(),
        ),
        23.height,

        const Text(
          'Select Available Times',
          style: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.black,
          ),
        ),
        10.height,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTimeSlotCheckbox('Morning', morningAvailabilityProvider),
            _buildTimeSlotCheckbox('Afternoon', afternoonAvailabilityProvider),
            _buildTimeSlotCheckbox('Evening', eveningAvailabilityProvider),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeSlotCheckbox(String label, StateProvider<bool> provider) {
    return Row(
      children: [
        Checkbox(
          value: ref.watch(provider),
          onChanged: (value) {
            ref.read(provider.notifier).state = value ?? false;
          },
          activeColor: AppColors.gradientGreen,
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: 14,
            color: AppColors.subtextcolor,
          ),
        ),
      ],
    );
  }
}

