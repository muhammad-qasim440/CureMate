import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/chat/providers/chatting_providers.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';
import '../../shared/views/doctor_details_view.dart';

class PopularDoctorCard extends ConsumerWidget {
  final Doctor doctor;

  const PopularDoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline =
        ref.watch(formattedStatusProvider(doctor.uid)).value == 'Online';

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
          mainAxisSize: MainAxisSize.min,
          children: [
            5.height,
            Stack(
              children: [
                Container(
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
                  left: 8,
                  child: Container(
                    width: 13,
                    height: 13,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          isOnline
                              ? AppColors.gradientGreen
                              : AppColors.subTextColor,
                      border: Border.all(color: AppColors.black, width: 1),


                    ),
                  ),
                ),
              ],
            ),
            8.height,
            CustomTextWidget(
              text: doctor.fullName,
              textAlignment: TextAlign.center,
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size15,
              ),
            ),
            4.height,
            CustomTextWidget(
              text: doctor.category.isNotEmpty ? doctor.category : 'General',
              textAlignment: TextAlign.center,
              textStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size12,
                color: AppColors.subTextColor,
              ),
            ),
            4.height,
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
          ],
        ),
      ),
    );
  }
}
