import 'package:curemate/extentions/widget_extension.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:flutter/material.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../shared/doctors_searching/views/search_doctors_view.dart';

class DoctorSearchBarWidget extends StatelessWidget {
  const DoctorSearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppNavigation.push(const DoctorsSearchingView());
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: ScreenUtil.scaleWidth(context, 335),
          height: ScreenUtil.scaleHeight(context, 54),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search, color: AppColors.subtextcolor, size: 20),
              5.width,
              CustomTextWidget(
                text: 'Search...',
                textStyle: TextStyle(
                  fontSize: FontSizes(context).size15,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFonts.rubik,
                  color: AppColors.subtextcolor,
                ),
              ),
              const Spacer(),
              const Icon(Icons.close, color: AppColors.subtextcolor, size: 20),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}
