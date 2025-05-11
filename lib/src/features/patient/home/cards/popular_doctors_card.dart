import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:flutter/material.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';
import '../../shared/views/doctor_details_view.dart';

class PopularDoctorCard extends StatelessWidget {
  final Doctor doctor;

  const PopularDoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Tapped on ${doctor.fullName}',
        );
        AppNavigation.push(DoctorProfileView(doctor: doctor));
      },
      child: Container(
        width: ScreenUtil.scaleWidth(context, 190),
        height: ScreenUtil.scaleHeight(context, 270),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.gradientWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            5.height,
            Container(
              width: ScreenUtil.scaleWidth(context, 160),
              height: ScreenUtil.scaleHeight(context, 140),
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
                      index < (doctor.averageRatings / 5).round()
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
