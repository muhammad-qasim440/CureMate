import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/shared/views/doctor_details_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';

class DoctorWithAppointmentCard extends ConsumerWidget {
  final Doctor doctor;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const DoctorWithAppointmentCard({
    super.key,
    required this.doctor,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // _showRatingDialog(context, ref);
        CustomSnackBarWidget.show(
          context: context,
          text: 'Tapped on ${doctor.fullName}',
        );
        AppNavigation.push(DoctorProfileView(doctor: doctor));

      },
      child: Stack(
        children: [
          Container(
            width: ScreenUtil.scaleWidth(context, 140),
            height: ScreenUtil.scaleHeight(context, 150),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: ScreenUtil.scaleWidth(context, 80),
                  height: ScreenUtil.scaleHeight(context, 80),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image:
                    doctor.profileImageUrl.isNotEmpty
                        ? DecorationImage(
                      image: NetworkImage(doctor.profileImageUrl),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child:
                  doctor.profileImageUrl.isEmpty
                      ? Center(
                    child: Icon(
                      Icons.person,
                      size: 40,
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
                    fontSize: FontSizes(context).size14,
                  ),
                ),
                4.height,
                CustomTextWidget(
                  text:
                  doctor.category,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size12,
                    color: AppColors.gradientGreen,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: ScreenUtil.scaleWidth(context, 4),
            left: ScreenUtil.scaleWidth(context, 4),
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : const Color(0xFF6B46C1), // Purple for not favorited
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            top: ScreenUtil.scaleWidth(context, 8),
            right: ScreenUtil.scaleWidth(context, 20),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                4.width,
                CustomTextWidget(
                  text: (doctor.averageRatings / 5).toStringAsFixed(1),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size12,
                    color: AppColors.subTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
