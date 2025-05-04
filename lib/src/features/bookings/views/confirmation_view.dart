// confirmation_view.dart
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../router/nav.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../patient/providers/patient_providers.dart';
import '../../patient/views/patient_main_view.dart';

class ConfirmationView extends ConsumerWidget {
  final Doctor doctor;
  final String date;
  final String timeSlot;
  final bool? isEditing;

  const ConfirmationView({
    super.key,
    required this.doctor,
    required this.date,
    required this.timeSlot,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gradientWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.thumb_up,
                    color: AppColors.gradientGreen,
                    size: 48,
                  ),
                  16.height,
                  const CustomTextWidget(
                    text: 'THANK YOU!',
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  8.height,
                   CustomTextWidget(
                    text:isEditing!?'Your appointment update successful': 'Your appointment successful',
                    textStyle: const TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: AppColors.subtextcolor,
                    ),
                  ),
                  16.height,
                  CustomTextWidget(
                    text: 'You booked an appointment with ${doctor.fullName} on $date at $timeSlot.',
                    textStyle: const TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: AppColors.subtextcolor,
                    ),
                    textAlignment: TextAlign.center,
                  ),
                  24.height,
                  CustomButtonWidget(
                    text: 'Done',
                    height: ScreenUtil.scaleHeight(context, 50),
                    width: double.infinity,
                    backgroundColor: AppColors.gradientGreen,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size16,
                    fontWeight: FontWeight.w500,
                    textColor: Colors.white,
                    onPressed: () {
                      AppNavigation.pushReplacement(const PatientMainView());
                    },
                  ),
                  16.height,
                  CustomButtonWidget(
                    text: 'Edit your appointment',
                    height: ScreenUtil.scaleHeight(context, 50),
                    width: double.infinity,
                    backgroundColor: Colors.transparent,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size16,
                    fontWeight: FontWeight.w500,
                    textColor: AppColors.gradientGreen,
                    border: const BorderSide(color: AppColors.gradientGreen),
                    onPressed: () {
                      AppNavigation.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}