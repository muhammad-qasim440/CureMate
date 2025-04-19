import 'package:curemate/extentions/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../../../../const/app_fonts.dart';
import '../../../../../../const/font_sizes.dart';
import '../../../../../shared/widgets/custom_button_widget.dart';
import '../../../../../shared/widgets/custom_text_widget.dart';
import '../../../../../theme/app_colors.dart';
import '../../../../../utils/screen_utils.dart';
import '../../../providers/patient_providers.dart';

class DoctorSearchingViewDoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool isFavorite;

  const DoctorSearchingViewDoctorCard({
    super.key,
    required this.doctor,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                              'assets/default_doctor.png',
                              fit: BoxFit.cover,
                            ),
                  ),
                ),
                12.width, // Doctor information
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
                          Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey[400],
                            size: 20,
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
                      // Years of experience
                      CustomTextWidget(
                        text: '${doctor.yearsOfExperience} Years experience',
                        textAlignment: TextAlign.left,
                        textStyle: TextStyle(
                          fontFamily: AppFonts.rubik,
                          fontSize: FontSizes(context).size12,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 4),
                          CustomTextWidget(
                            text: '${doctor.averageRatings.toInt()}%',
                            textAlignment: TextAlign.left,
                            textStyle: TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: FontSizes(context).size12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: CustomTextWidget(
                              text: '${doctor.numberOfReviews} Patient Stories',
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
                        color:AppColors.gradientGreen,
                      ),
                    ),
                    CustomTextWidget(
                      text: '10:00 AM tomorrow',
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
                // Book now button
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
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
