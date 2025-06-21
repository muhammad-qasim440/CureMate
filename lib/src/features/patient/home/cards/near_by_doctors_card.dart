import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../../core/utils/calculate_distance_between_two_latitude_and_logitude_points.dart';
import '../../../../router/nav.dart';
import '../../../../shared/chat/providers/chatting_providers.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';
import '../../shared/views/doctor_details_view.dart';

class NearByDoctorsCard extends ConsumerWidget {
  final Doctor doctor;
  final Patient patient;
  const NearByDoctorsCard({super.key, required this.doctor,required this.patient});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final isOnline = ref.watch(formattedStatusProvider(doctor.uid)).value=='Online';

    return GestureDetector(
      onTap: () {
        AppNavigation.push(DoctorProfileView(doctor: doctor));
      },
      child: Container(
        width: ScreenUtil.scaleWidth(context, 140),
        height: ScreenUtil.scaleHeight(context, 150),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.gradientWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children:[ Container(
                width: ScreenUtil.scaleWidth(context, 140),
                height: ScreenUtil.scaleHeight(context, 120),
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
                Positioned(
                  top: 4,
                  left: 5,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline ? AppColors.gradientGreen : AppColors.subTextColor,
                      border: Border.all(color: AppColors.black, width: 1),

                    ),
                  ),
                ),
               ],
            ),
            5.height,
            CustomTextWidget(
              text: doctor.fullName,
              textAlignment: TextAlign.center,
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size15,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextWidget(
                  textAlignment: TextAlign.center,
                  text:
                  doctor.category.isNotEmpty ? doctor.category : 'General',
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size12,
                    color: AppColors.subTextColor,
                  ),
                ),
                10.height,
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