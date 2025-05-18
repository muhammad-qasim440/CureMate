// confirmation_dialog.dart
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
import '../../patient/views/patient_main_view.dart';
import '../models/appointment_model.dart';
import 'appointment_booking_view.dart';

class ConfirmationDialog extends ConsumerWidget {
  final dynamic doctor;
  final String date;
  final String timeSlot;
  final bool isEditing;
  final AppointmentModel? appointment;

  const ConfirmationDialog({
    super.key,
    required this.doctor,
    required this.date,
    required this.timeSlot,
    this.isEditing = false,
    this.appointment,
  });

  static Future<void> show({
    required BuildContext context,
    required dynamic doctor,
    required String date,
    required String timeSlot,
    bool isEditing = false,
    dynamic appointment,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ConfirmationDialog(
          doctor: doctor,
          date: date,
          timeSlot: timeSlot,
          isEditing: isEditing,
          appointment: appointment,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: ScreenUtil.scaleWidth(context, 335),
      height: ScreenUtil.scaleHeight(context, 530),
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
          const CircleAvatar(
              radius: 80,
            backgroundColor: AppColors.lightGreen,
            child: Icon(
              Icons.thumb_up_off_alt_sharp,
              color: AppColors.gradientGreen,
              size: 60,
            ),
          ),
          const SizedBox(height: 16),
           CustomTextWidget(
            text: 'THANK YOU!',
            textStyle: TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size30,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 5),
          CustomTextWidget(
            textAlignment: TextAlign.center,
            text: isEditing ? 'Your appointment update successful' : 'Your appointment successful',
            textStyle: TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size20,
              fontWeight: FontWeight.w400,
              color: AppColors.subTextColor,
            ),
          ),

          const SizedBox(height: 16),
          CustomTextWidget(
            textAlignment: TextAlign.center,
            text: 'Appointment ID ${appointment!.id}',
            textStyle: TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size14,
              fontWeight: FontWeight.w400,
              color: AppColors.black,
            ),
          ),
          CustomTextWidget(
            textAlignment:TextAlign.center,
            text: 'You booked an appointment with ${doctor.fullName} ${doctor.category} on ${date.dayMonthDisplay} at $timeSlot.',
            textStyle:  TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size14,
              fontWeight: FontWeight.w400,
              color: AppColors.subTextColor,
            ),
          ),
          const SizedBox(height: 24),
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
              Navigator.of(context).pop();
              ref.read(patientBottomNavIndexProvider.notifier).state=2;
              AppNavigation.pushReplacement(const PatientMainView());
            },
          ),
          5.height,
          CustomButtonWidget(
            text: 'Edit your appointment',
            height: ScreenUtil.scaleHeight(context, 50),
            width: double.infinity,
            backgroundColor: Colors.transparent,
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size14,
            fontWeight: FontWeight.w500,
            textColor: AppColors.subTextColor,
            onPressed: () {
              Navigator.of(context).pop();
              AppNavigation.push(
                AppointmentBookingView(
                  doctor: doctor,
                  appointment: appointment,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}