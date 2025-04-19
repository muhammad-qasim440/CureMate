// Doctor Card Widget (Reusable for all doctor lists)
import 'package:curemate/extentions/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';

class NearByDoctorsCard extends StatelessWidget {
  final Doctor doctor;

  const NearByDoctorsCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Tapped on ${doctor.fullName}',
        );
      },
      child: Container(
        width: ScreenUtil.scaleWidth(context, 190),
        height: ScreenUtil.scaleHeight(context, 264),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.gradientWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: ScreenUtil.scaleWidth(context, 190),
              height: ScreenUtil.scaleHeight(context, 180),
              decoration: BoxDecoration(
                image:
                doctor.profileImageUrl.isNotEmpty
                    ? DecorationImage(
                  image: NetworkImage(doctor.profileImageUrl),
                  fit: BoxFit.cover,
                )
                    : null,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child:
              doctor.profileImageUrl.isEmpty
                  ? Center(
                child: Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.grey.shade600,
                ),
              )
                  : null,
            ),
            5.height,
            CustomTextWidget(
              text: doctor.fullName,
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size15,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextWidget(
                  text:
                  doctor.category.isNotEmpty ? doctor.category : 'General',
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size12,
                    color: AppColors.subtextcolor,
                  ),
                ),
                15.width,
                CustomTextWidget(
                  text:
                  '${doctor.latitude != 0 ? (doctor.latitude - 30.2246769).abs().toStringAsFixed(1) : 'N/A'} km',
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size14,
                    color: AppColors.gradientGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}