import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/shared/helpers/add_or_remove_doctor_into_favorite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../const/app_fonts.dart';
import '../../../../../../const/font_sizes.dart';
import '../../../../../assets/app_assets.dart';
import '../../../../../const/app_strings.dart';
import '../../../../../core/utils/calculate_distance_between_two_latitude_and_logitude_points.dart';
import '../../../../router/nav.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../../appointments/views/appointment_booking_view.dart';
import '../../providers/patient_providers.dart';
import '../../shared/views/doctor_details_view.dart';

class AllNearByDoctorsViewCard extends ConsumerWidget {
  final Doctor doctor;
  final bool isFavorite;
  final bool? isFromPopular;
  final bool? isFromFeatured;
  final bool? isFromRecommendations;
  const AllNearByDoctorsViewCard({
    super.key,
    required this.doctor,
    required this.isFavorite,
    this.isFromPopular,
    this.isFromFeatured,
    this.isFromRecommendations,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPatientData =
        ref.watch(currentSignInPatientDataProvider).value;

    final availableDays =
        doctor.availability.map((avail) => avail['day'] as String).toList();
    final now = DateTime.now();
    DateTime? nextAvailableDay;
    for (int i = 0; i < 7; i++) {
      final day = now.add(Duration(days: i));
      final dayName = AppStrings.daysOfWeek[day.weekday - 1];
      if (availableDays.contains(dayName)) {
        nextAvailableDay = day;
        break;
      }
    }

    final showPopular = isFromPopular == true;
    final showFeatured = isFromFeatured == true;
    final showRecommendations = isFromRecommendations == true;

    return GestureDetector(
      onTap: () {
        AppNavigation.push(DoctorProfileView(doctor: doctor));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.gradientWhite,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: ScreenUtil.scaleWidth(context, 92),
                      height: ScreenUtil.scaleHeight(context, 92),
                      child:
                          doctor.profileImageUrl.isNotEmpty
                              ? Image.network(
                                doctor.profileImageUrl,
                                fit: BoxFit.cover,
                              )
                              : Image.asset(
                                AppAssets.defaultDoctorImg,
                                fit: BoxFit.cover,
                              ),
                    ),
                  ),
                  12.width,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: CustomTextWidget(
                                text: doctor.fullName,
                                textStyle: TextStyle(
                                  fontFamily: AppFonts.rubik,
                                  fontSize: FontSizes(context).size18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                            ),
                            4.width,
                            InkWell(
                              onTap: () {
                                AddORRemoveDoctorIntoFavorite.toggleFavorite(
                                  context,
                                  ref,
                                  doctor.uid,
                                );
                              },
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                    isFavorite ? Colors.red : Colors.grey[400],
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                        4.width,
                        CustomTextWidget(
                          text: doctor.category,
                          textAlignment: TextAlign.center,
                          textStyle: TextStyle(
                            fontFamily: AppFonts.rubik,
                            fontSize: FontSizes(context).size14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gradientGreen,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            CustomTextWidget(
                              text:
                                  '${doctor.yearsOfExperience} Years experience',
                              textAlignment: TextAlign.left,
                              textStyle: TextStyle(
                                fontFamily: AppFonts.rubik,
                                fontSize: FontSizes(context).size12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (!showPopular && !showFeatured) ...[
                              55.width,
                              CustomTextWidget(
                                text:
                                    '${calculateDistance(doctor.latitude, doctor.longitude, currentPatientData!.latitude, currentPatientData.longitude).toStringAsFixed(0)} KM',
                                textAlignment: TextAlign.left,
                                textStyle: TextStyle(
                                  fontFamily: AppFonts.rubik,
                                  fontSize: FontSizes(context).size14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.gradientGreen,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.local_hospital,
                              color: Colors.green,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: CustomTextWidget(
                                text:
                                    showPopular
                                        ? 'Consultation Fee: ${doctor.consultationFee} PKR'
                                        : doctor.hospital,
                                textAlignment: TextAlign.left,
                                textStyle: TextStyle(
                                  fontFamily: AppFonts.rubik,
                                  fontSize: FontSizes(context).size12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            ...List.generate(
                              5,
                              (index) => Icon(
                                Icons.star,
                                size: 18,
                                color:
                                    index < ((doctor.averageRatings)).round()
                                        ? Colors.amber
                                        : Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.visibility,
                              color: Colors.blueGrey,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            CustomTextWidget(
                              text: '${doctor.profileViews} Profile Views',
                              textStyle: TextStyle(
                                fontFamily: AppFonts.rubik,
                                fontSize: FontSizes(context).size12,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        if (!showFeatured ||
                            (showRecommendations && showFeatured)) ...[
                          Row(
                            children: [
                              const Icon(
                                Icons.people,
                                color: Colors.green,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: CustomTextWidget(
                                  text:
                                      '${doctor.totalPatientConsulted} Patients Consulted',
                                  textAlignment: TextAlign.left,
                                  textStyle: TextStyle(
                                    fontFamily: AppFonts.rubik,
                                    fontSize: FontSizes(context).size12,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomTextWidget(
                        text: 'Next Available',
                        textAlignment: TextAlign.left,
                        textStyle: TextStyle(
                          fontFamily: AppFonts.rubik,
                          fontSize: FontSizes(context).size14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.gradientGreen,
                        ),
                      ),
                      CustomTextWidget(
                        text:
                            nextAvailableDay != null
                                ? '${AppStrings.daysOfWeek[nextAvailableDay.weekday - 1]}, ${nextAvailableDay.day} ${AppStrings.months[nextAvailableDay.month - 1]}'
                                : 'Not Available',
                        textAlignment: TextAlign.left,
                        textStyle: TextStyle(
                          fontFamily: AppFonts.rubik,
                          fontSize: FontSizes(context).size12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  CustomButtonWidget(
                    text: 'Book Now',
                    height: ScreenUtil.scaleHeight(context, 36),
                    width: ScreenUtil.scaleWidth(context, 112),
                    backgroundColor: AppColors.gradientGreen,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size13,
                    fontWeight: FontWeight.w500,
                    textColor: Colors.white,
                    shadowColor: Colors.transparent,
                    borderRadius: 6,
                    onPressed: () {
                      AppNavigation.push(
                        AppointmentBookingView(doctor: doctor),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
