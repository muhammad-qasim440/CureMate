import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../router/nav.dart';
import '../../patient/providers/patient_providers.dart';
import '../../patient/shared/views/doctor_details_view.dart';
import 'all_recommended_doctor_widget_based_on_diagnonsis.dart';

class RecommendedDoctorsWidget extends StatelessWidget {
  final String doctorType;
  final List<Doctor> doctors;

  const RecommendedDoctorsWidget({
    super.key,
    required this.doctorType,
    required this.doctors,
  });

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return Center(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.gradientGreen,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomTextWidget(
                text: '$doctorType Specialists',
                textStyle:TextStyle(
                    fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black
                ),
              ),
              const SizedBox(height: 16),
              CustomTextWidget(
                text: 'No specialists available at the moment.\nPlease try again later.',
                textAlignment: TextAlign.center,
                textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gradientWhite,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: CustomTextWidget(
            text: 'Recommended By US',
            textAlignment: TextAlign.center,
            textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size16,
                fontWeight: FontWeight.bold,
                color: AppColors.gradientGreen,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5),
          child: Row(
            children: [
              CustomTextWidget(
                text: 'Top $doctorType',
                textAlignment: TextAlign.center,
                textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black
                ),
              ),
              const Spacer(),
              CustomButtonWidget(
                onPressed: () {
                  AppNavigation.push(AllDoctorsScreen(doctorType: doctorType));
                },
                text: 'See All',
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size14,
                fontWeight: FontWeight.w600,
                  textColor: AppColors.gradientGreen,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return GestureDetector(
                onTap: () {
                  AppNavigation.push(DoctorProfileView(doctor: doctor));
                },
                child: Container(
                  width: ScreenUtil.scaleWidth(context, 180),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: doctor.profileImageUrl.isNotEmpty
                              ? NetworkImage(doctor.profileImageUrl)
                              : null,
                          child: doctor.profileImageUrl.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 30,
                                  color: AppColors.textColor,
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        CustomTextWidget(
                          text: doctor.fullName,
                          textAlignment: TextAlign.center,
                          textStyle: TextStyle(
                            fontFamily: AppFonts.rubik,
                              fontSize: FontSizes(context).size16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        CustomTextWidget(
                          text: doctor.category,
                          textAlignment: TextAlign.center,
                          textStyle: TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: FontSizes(context).size12,
                              color: AppColors.subTextColor
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        CustomTextWidget(
                          text: doctor.hospital,
                          textAlignment: TextAlign.center,
                          textStyle: TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: FontSizes(context).size12,
                              color: AppColors.subTextColor
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            5,
                                (index) => Icon(
                              Icons.star,
                              size: 16,
                              color:
                              index < (doctor.averageRatings).round()
                                  ? Colors.amber
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        CustomTextWidget(
                          text: 'Fee: ${doctor.consultationFee} PKR',
                          textStyle: TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: FontSizes(context).size12,
                              color: AppColors.subTextColor
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 