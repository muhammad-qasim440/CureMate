import 'package:flutter/material.dart';

import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';

class DoctorScheduleHeaderWidget extends StatelessWidget {
  const DoctorScheduleHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTextWidget(
      text: 'Your Availability',
      textStyle: TextStyle(
        fontFamily: AppFonts.rubik,
        fontWeight: FontWeight.w500,
        fontSize: FontSizes(context).size16,
        color: AppColors.black,
      ),
    );
  }
}
