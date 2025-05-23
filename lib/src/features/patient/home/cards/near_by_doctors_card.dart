import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../../core/utils/calculate_distance_between_two_latitude_and_logitude_points.dart';
import '../../../../router/nav.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';
import '../../shared/views/doctor_details_view.dart';

class NearByDoctorsCard extends StatelessWidget {
  final Doctor doctor;
  final Patient patient;
  const NearByDoctorsCard({super.key, required this.doctor,required this.patient});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        AppNavigation.push(DoctorProfileView(doctor: doctor));
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
                    color: AppColors.subTextColor,
                  ),
                ),
                15.width,
                CustomTextWidget(
                  text:
                  '${calculateDistance(patient.latitude,patient.longitude,doctor.latitude,doctor.longitude).toStringAsFixed(0)} km',
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