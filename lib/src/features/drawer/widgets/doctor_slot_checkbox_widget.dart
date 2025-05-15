import 'package:flutter/material.dart';

import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';

class DoctorSlotCheckboxWidget extends StatelessWidget {
  final String label;
  final bool isChecked;
  final bool isDisabled;
  final ValueChanged<bool?> onChanged;

  const DoctorSlotCheckboxWidget({
    super.key,
    required this.label,
    required this.isChecked,
    this.isDisabled = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: isDisabled ? null : onChanged,
          activeColor: AppColors.gradientGreen,
        ),
        CustomTextWidget(
          text: label,
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size14,
            color: AppColors.subTextColor,
          ),
        ),
      ],
    );
  }
}
