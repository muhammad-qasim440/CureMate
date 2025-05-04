import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/bookings/models/appointment_model.dart';
import 'package:curemate/src/features/patient/shared/views/doctor_details_view.dart';
import 'package:curemate/src/shared/widgets/custom_centered_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../router/nav.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../shared/widgets/custom_drop_down_menu_widget.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../../bookings/providers/booking_providers.dart';
import '../../../bookings/views/appointment_booking_view.dart';
import '../../../bookings/views/edit_booking_view.dart';
import '../../providers/patient_providers.dart';
import '../../../../../const/app_strings.dart';

class PatientAppointmentsView extends ConsumerWidget {
  const PatientAppointmentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentsProvider).value ?? [];
    final filterOption = ref.watch(appointmentsFilterOptionProvider);
    List<AppointmentModel>? filteredAppointments = appointments.where((app) {
      if (app.status == 'cancelled') return false;
      if (filterOption == 'All') return true;
      return app.status.toLowerCase() == filterOption.toLowerCase();
    }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.gradientGreen,
        titleSpacing: 10,
        title: CustomTextWidget(
          text: 'My Appointments',
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w500,
            fontSize: FontSizes(context).size24,
            color: AppColors.gradientWhite,
          ),
        ),
        actions: [
            Padding(
              padding: EdgeInsets.only(right: ScreenUtil.scaleWidth(context, 5.0)),
              child: SizedBox(
                width: ScreenUtil.scaleWidth(context, 110),
                height: ScreenUtil.scaleHeight(context, 35),
                child: CustomDropdown(
                  items: AppStrings.appointmentFilterOptions,
                  label: '',
                  onChanged: (value) {
                    ref.read(appointmentsFilterOptionProvider.notifier).state = value;
                  },
                  backgroundColor: AppColors.gradientWhite,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  24.height,
                  if (filteredAppointments.isEmpty)
                    const Expanded(
                      child: CustomCenteredTextWidget(
                        text: 'No bookings Found',
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: ()async{
                          filteredAppointments= ref.refresh(appointmentsProvider).value;
                        },
                        color: AppColors.gradientGreen,
                        child: ListView.builder(
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = filteredAppointments![index];
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
                        
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isCancelled ? Colors.grey[200] : AppColors.gradientWhite,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.black.withOpacity(0.05),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GestureDetector(
                                    onTap:(){
                                      AppNavigation.push(DoctorProfileView(doctor: doctor));
                                    },
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: SizedBox(
                                            width: ScreenUtil.scaleWidth(context, 60),
                                            height: ScreenUtil.scaleHeight(context, 60),
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
                                        12.width,
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CustomTextWidget(
                                                text: doctor.fullName,
                                                textStyle: TextStyle(
                                                  fontFamily: AppFonts.rubik,
                                                  fontSize: FontSizes(context).size18,
                                                  fontWeight: FontWeight.w600,
                                                  color: isCancelled ? Colors.grey : AppColors.black,
                                                ),
                                              ),
                                              4.height,
                                              CustomTextWidget(
                                                text: doctor.category,
                                                textStyle: TextStyle(
                                                  fontFamily: AppFonts.rubik,
                                                  fontSize: FontSizes(context).size14,
                                                  fontWeight: FontWeight.w400,
                                                  color: isCancelled
                                                      ? Colors.grey
                                                      : AppColors.subtextcolor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  12.height,
                                  CustomTextWidget(
                                    text: 'Patient: ${appointment.patientName} (${appointment.patientType})',
                                    textStyle: TextStyle(
                                      fontFamily: AppFonts.rubik,
                                      fontSize: FontSizes(context).size14,
                                      fontWeight: FontWeight.w400,
                                      color: isCancelled ? Colors.grey : AppColors.subtextcolor,
                                    ),
                                  ),
                                  4.height,
                                  CustomTextWidget(
                                    text: 'Booked by: ${appointment.bookerName}',
                                    textStyle: TextStyle(
                                      fontFamily: AppFonts.rubik,
                                      fontSize: FontSizes(context).size14,
                                      fontWeight: FontWeight.w400,
                                      color: isCancelled ? Colors.grey : AppColors.subtextcolor,
                                    ),
                                  ),
                                  4.height,
                                  CustomTextWidget(
                                    text: 'Created At: ${appointment.createdAt.formattedDate}',
                                    textStyle: TextStyle(
                                      fontFamily: AppFonts.rubik,
                                      fontSize: FontSizes(context).size14,
                                      fontWeight: FontWeight.w400,
                                      color: AppColors.subtextcolor,
                                    ),
                                  ),
                                  4.height,
                                  CustomTextWidget(
                                    text: 'Appointment Date: ${appointment.date}',
                                    textStyle: TextStyle(
                                      fontFamily: AppFonts.rubik,
                                      fontSize: FontSizes(context).size14,
                                      fontWeight: FontWeight.w400,
                                      color: isCancelled ? Colors.grey : AppColors.subtextcolor,
                                    ),
                                  ),
                                  4.height,
                                  CustomTextWidget(
                                    text: 'Time: ${appointment.timeSlot}',
                                    textStyle: TextStyle(
                                      fontFamily: AppFonts.rubik,
                                      fontSize: FontSizes(context).size14,
                                      fontWeight: FontWeight.w400,
                                      color: isCancelled ? Colors.grey : AppColors.subtextcolor,
                                    ),
                                  ),
                                  4.height,
                                  CustomTextWidget(
                                    text: 'Status: ${appointment.status.capitalize()}',
                                    textStyle: TextStyle(
                                      fontFamily: AppFonts.rubik,
                                      fontSize: FontSizes(context).size14,
                                      fontWeight: FontWeight.w500,
                                      color: _getStatusColor(appointment.status),
                                    ),
                                  ),
                                  if (appointment.patientNotes != null) ...[
                                    4.height,
                                    CustomTextWidget(
                                      text: 'Notes: ${appointment.patientNotes}',
                                      textStyle: TextStyle(
                                        fontFamily: AppFonts.rubik,
                                        fontSize: FontSizes(context).size14,
                                        fontWeight: FontWeight.w400,
                                        color: isCancelled
                                            ? Colors.grey
                                            : AppColors.subtextcolor,
                                      ),
                                    ),
                                  ],
                                  16.height,
                                  if (isPending)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomButtonWidget(
                                          text: 'Edit',
                                          height: ScreenUtil.scaleHeight(context, 40),
                                          width: ScreenUtil.scaleWidth(context, 100),
                                          backgroundColor: AppColors.gradientGreen,
                                          fontFamily: AppFonts.rubik,
                                          fontSize: FontSizes(context).size14,
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.white,
                                          onPressed: () {
                                            // ref.read(bookingViewSelectedPatientLabelProvider.notifier).state = appointment.patientType;
                                            // ref.read(bookingViewPatientNameProvider.notifier).state = appointment.patientName;
                                            // ref.read(bookingViewPatientNumberProvider.notifier).state = appointment.patientNumber;
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
                                          height: ScreenUtil.scaleHeight(context, 40),
                                          width: ScreenUtil.scaleWidth(context, 100),
                                          backgroundColor: Colors.transparent,
                                          fontFamily: AppFonts.rubik,
                                          fontSize: FontSizes(context).size14,
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
                        
                                              CustomSnackBarWidget.show(
                                                context: context,
                                                text: 'Booking cancelled successfully',
                                              );
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
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
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
        return AppColors.subtextcolor;
    }
  }
}

