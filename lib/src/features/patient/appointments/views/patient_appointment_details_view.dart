import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/bookings/models/appointment_model.dart';
import 'package:curemate/src/features/patient/shared/views/doctor_details_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../router/nav.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../../bookings/providers/booking_providers.dart';
import '../../../bookings/views/appointment_booking_view.dart';
import '../../providers/patient_providers.dart';

class PatientAppointmentDetailsView extends ConsumerWidget {
  final AppointmentModel appointment;

  const PatientAppointmentDetailsView({
    super.key,
    required this.appointment,
  });

  Future<void> _cancelNotification(String appointmentId) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(appointmentId.hashCode);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctor = ref.watch(doctorsProvider).value?.firstWhere(
          (doc) => doc.uid == appointment.doctorUid,
          orElse: () => Doctor(
            uid: appointment.doctorUid,
            fullName: 'Unknown Doctor',
            email: '',
            city: '',
            dob: '',
            phoneNumber: '',
            profileImageUrl: '',
            profileImagePublicId: '',
            userType: 'Doctor',
            latitude: 0.0,
            longitude: 0.0,
            createdAt: '',
            qualification: '',
            yearsOfExperience: '',
            category: '',
            hospital: '',
            averageRatings: 0.0,
            numberOfReviews: 0,
            totalReviews: 0,
            totalPatientConsulted: 0,
            consultationFee: 0,
            profileViews: 0,
            viewedBy: {},
            availability: [],
          ),
        );

    final isPending = appointment.status == 'pending';
    final isCancelled = appointment.status == 'cancelled';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.gradientGreen,
        title: const Text('Appointment Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                AppNavigation.push(DoctorProfileView(doctor: doctor));
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.gradientWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: SizedBox(
                        width: ScreenUtil.scaleWidth(context, 80),
                        height: ScreenUtil.scaleHeight(context, 80),
                        child: doctor!.profileImageUrl.isNotEmpty
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
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            text: doctor.fullName,
                            textStyle: TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: FontSizes(context).size20,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          CustomTextWidget(
                            text: doctor.category,
                            textStyle: TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: FontSizes(context).size16,
                              color: AppColors.subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailItem(context, 'Appointment ID', appointment.id),
            _buildDetailItem(context, 'Patient Name', appointment.patientName),
            _buildDetailItem(context, 'Patient Type', appointment.patientType),
            _buildDetailItem(context, 'Patient Number', appointment.patientNumber),
            _buildDetailItem(context, 'Booked By', appointment.bookerName),
            _buildDetailItem(context, 'Created At', appointment.createdAt.formattedDate),
            if (appointment.updatedAt != null)
              _buildDetailItem(context, 'Updated At', appointment.updatedAt!.formattedDate),
            _buildDetailItem(context, 'Appointment Date', appointment.date),
            _buildDetailItem(context, 'Time Slot', appointment.timeSlot),
            _buildDetailItem(
              context,
              'Status',
              appointment.status.capitalize(),
              color: _getStatusColor(appointment.status),
            ),
            if (appointment.patientNotes != null)
              _buildDetailItem(context, 'Notes', appointment.patientNotes!),
            if (appointment.reminderTime != null)
              _buildDetailItem(context, 'Reminder', '${appointment.reminderTime} before'),
            const SizedBox(height: 32),
            if (isPending)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButtonWidget(
                    text: 'Edit',
                    height: ScreenUtil.scaleHeight(context, 45),
                    width: ScreenUtil.scaleWidth(context, 140),
                    backgroundColor: AppColors.gradientGreen,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size16,
                    fontWeight: FontWeight.w500,
                    textColor: Colors.white,
                    onPressed: () {
                      ref.read(bookingViewSelectedPatientLabelProvider.notifier).state =
                          appointment.patientType;
                      ref.read(bookingViewPatientNameProvider.notifier).state =
                          appointment.patientName;
                      ref.read(bookingViewPatientNumberProvider.notifier).state =
                          appointment.patientNumber;
                      AppNavigation.push(
                        AppointmentBookingView(
                          doctor: doctor,
                          appointment: appointment,
                        ),
                      );
                    },
                  ),
                  CustomButtonWidget(
                    text: 'Cancel',
                    height: ScreenUtil.scaleHeight(context, 45),
                    width: ScreenUtil.scaleWidth(context, 140),
                    backgroundColor: Colors.transparent,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size16,
                    fontWeight: FontWeight.w500,
                    textColor: Colors.red,
                    border: const BorderSide(color: Colors.red),
                    onPressed: () async {
                      final isConnected = await ref.read(
                        checkInternetConnectionProvider.future,
                      );
                      if (!isConnected) {
                        CustomSnackBarWidget.show(
                          context: context,
                          text: 'No Internet Connection',
                        );
                        return;
                      }

                      try {
                        await ref.read(bookingRepositoryProvider).cancelBooking(
                              appointment.id,
                              DateTime.now().toIso8601String(),
                            );
                        await _cancelNotification(appointment.id);

                        CustomSnackBarWidget.show(
                          context: context,
                          text: 'Booking cancelled successfully',
                        );
                        AppNavigation.pop();
                      } catch (e) {
                        CustomSnackBarWidget.show(
                          context: context,
                          text: 'Failed to cancel booking: $e',
                        );
                      }
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            text: label,
            textStyle: TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size14,
              color: AppColors.subTextColor,
            ),
          ),
          const SizedBox(height: 4),
          CustomTextWidget(
            text: value,
            textStyle: TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size16,
              fontWeight: FontWeight.w500,
              color: color ?? AppColors.black,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return AppColors.gradientGreen;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      default:
        return AppColors.subTextColor;
    }
  }
} 