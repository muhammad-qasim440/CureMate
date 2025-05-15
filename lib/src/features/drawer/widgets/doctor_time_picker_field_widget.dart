import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../theme/app_colors.dart';

class DoctorTimePickerFieldWidget extends ConsumerWidget {
  final String label;
  final StateProvider<String> provider;
  final String hintText;

  const DoctorTimePickerFieldWidget({
    super.key,
    required this.label,
    required this.provider,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeString = ref.watch(provider);
    TimeOfDay initialTime = TimeOfDay.now();

    if (timeString.isNotEmpty) {
      try {
        final format = DateFormat('h:mm a');
        final dateTime = format.parse(timeString);
        initialTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      } catch (e) {}
    }

    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.btnBgColor,
                  onPrimary: AppColors.gradientWhite,
                  onSurface: AppColors.subTextColor,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gradientGreen,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          final formattedTime = picked.format(context);
          ref.read(provider.notifier).state = formattedTime;
        }
      },
      child: CustomTextFormFieldWidget(
        label: label,
        hintText: hintText,
        enabled: false,
        controller: TextEditingController(text: timeString),
        validator: (value) {
          if (timeString.isEmpty) {
            return 'Please select a time';
          }
          return null;
        },
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
          fontWeight: FontWeight.w400,
          fontSize: FontSizes(context).size14,
          fontFamily: AppFonts.rubik,
          color: AppColors.subTextColor,
        ),
      ),
    );
  }
}
