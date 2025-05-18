import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/shared/views/doctor_details_view.dart';
import 'package:curemate/src/shared/widgets/back_view_icon_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../assets/app_assets.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../router/nav.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../../appointments/models/appointment_model.dart';
import '../../../appointments/providers/appointments_providers.dart';
import '../../../appointments/views/appointment_booking_view.dart';
import '../../../appointments/widgets/rate_doctor_dialog_widget.dart';
import '../../../appointments/widgets/custom_star_rating_widget.dart';
import '../../providers/patient_providers.dart';

class PatientAppointmentDetailsView extends ConsumerStatefulWidget {
  final AppointmentModel appointment;

  const PatientAppointmentDetailsView({super.key, required this.appointment});

  @override
  ConsumerState<PatientAppointmentDetailsView> createState() => _PatientAppointmentDetailsViewState();
}

class _PatientAppointmentDetailsViewState extends ConsumerState<PatientAppointmentDetailsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowRatingDialog();
    });
  }

  Future<void> _checkAndShowRatingDialog() async {
    if (widget.appointment.status == 'completed' && !widget.appointment.isRated) {
      final result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => RateDoctorDialog(appointment: widget.appointment),
      );

      if (result == true) {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Thank you for rating your experience!',
        );
      }
    }
  }

  Future<void> _cancelNotification(String appointmentId) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(appointmentId.hashCode);
  }

  Widget _buildRatingSection() {
    if (widget.appointment.status != 'completed') {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            text: 'Your Rating',
            textStyle: TextStyle(
              fontSize: FontSizes(context).size18,
              fontWeight: FontWeight.w600,
              fontFamily: AppFonts.rubik,
            ),
          ),
          const SizedBox(height: 16),
          if (!widget.appointment.isRated) ...[
            CustomTextWidget(
              text: 'You haven\'t rated this appointment yet',
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size14,
                color: AppColors.subTextColor,
              ),
            ),
            const SizedBox(height: 8),
            CustomButtonWidget(
              onPressed: _checkAndShowRatingDialog,
              text: 'Rate Now',
              backgroundColor: AppColors.gradientGreen,
            ),
          ] else ...[
            Row(
              children: [
                CustomTextWidget(
                  text: 'Rating: ',
                  textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size14,
                    color: AppColors.subTextColor,
                  ),
                ),
                CustomStarRating(
                  rating: widget.appointment.rating ?? 0,
                  size: 20,
                  isInteractive: false,
                ),
                CustomTextWidget(
                  text: ' (${widget.appointment.rating})',
                  textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size14,
                    color: AppColors.subTextColor,
                  ),
                ),
              ],
            ),
            if (widget.appointment.review != null && widget.appointment.review!.isNotEmpty) ...[
              const SizedBox(height: 8),
              CustomTextWidget(
                text: 'Your Review:',
                textStyle: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subTextColor,
                ),
              ),
              const SizedBox(height: 4),
              CustomTextWidget(
                text: widget.appointment.review!,
                textStyle: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size14,
                  color: AppColors.subTextColor,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctor = ref
        .watch(doctorsProvider)
        .value
        ?.firstWhere(
          (doc) => doc.uid == widget.appointment.doctorUid,
          orElse:
              () => Doctor(
                uid: widget.appointment.doctorUid,
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
                totalReviews: 0,
                totalPatientConsulted: 0,
                consultationFee: 0,
                profileViews: 0,
                viewedBy: {},
                availability: [],
              ),
        );

    final isPending = widget.appointment.status == 'pending';
    final isCancelled = widget.appointment.status == 'cancelled';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        leading: const BackViewIconWidget(),
        titleSpacing: 0,
        elevation: 0,
        backgroundColor: AppColors.gradientGreen,
        title: Text(
          'Appointment Details',
          style: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.gradientGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          AppNavigation.push(
                            DoctorProfileView(doctor: doctor),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Hero(
                                tag: 'doctor-${doctor!.uid}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: SizedBox(
                                    width: ScreenUtil.scaleWidth(context, 90),
                                    height: ScreenUtil.scaleHeight(
                                      context,
                                      90,
                                    ),
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
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    CustomTextWidget(
                                      text: doctor.fullName,
                                      textStyle: TextStyle(
                                        fontFamily: AppFonts.rubik,
                                        fontSize: FontSizes(context).size20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
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
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.getStatusColor(
                                          widget.appointment.status,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          20,
                                        ),
                                      ),
                                      child: Text(
                                        widget.appointment.status.capitalize(),
                                        style: TextStyle(
                                          color: AppColors.getStatusColor(
                                            widget.appointment.status,
                                          ),
                                          fontWeight: FontWeight.w500,
                                          fontSize: FontSizes(context).size14,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'Appointment Information',
                                style: TextStyle(
                                  fontFamily: AppFonts.rubik,
                                  fontSize: FontSizes(context).size18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const Divider(height: 1),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  _buildDetailItem(
                                    context,
                                    'Appointment ID',
                                    widget.appointment.id,
                                  ),
                                  _buildDetailItem(
                                    context,
                                    'Patient Name',
                                    widget.appointment.patientName,
                                  ),
                                  _buildDetailItem(
                                    context,
                                    'Patient Type',
                                    widget.appointment.patientType,
                                  ),
                                  _buildDetailItem(
                                    context,
                                    'Patient Number',
                                    widget.appointment.patientNumber,
                                  ),
                                  _buildDetailItem(
                                    context,
                                    'Booked By',
                                    widget.appointment.bookerName,
                                  ),
                                  _buildDetailItem(
                                    context,
                                    'Created At',
                                    widget.appointment.createdAt.formattedDateTime,
                                  ),
                                  if (widget.appointment.updatedAt != null)
                                    _buildDetailItem(
                                      context,
                                      'Updated At',
                                      widget.appointment.updatedAt!.formattedDateTime,
                                    ),
                                  _buildDetailItem(
                                    context,
                                    'Hospital',
                                    widget.appointment.hospital,
                                  ),
                                  _buildDetailItem(
                                    context,
                                    'Consultation Fee',
                                    '${widget.appointment.consultationFee.toString()} PKR',
                                  ),
                                  _buildDetailItem(
                                    context,
                                    'Appointment Date',
                                    widget.appointment.date,
                                  ),
                                  _buildDetailItem(
                                    context,
                                    'Time Slot',
                                    widget.appointment.timeSlot,
                                  ),
                                  if (widget.appointment.patientNotes != null)
                                    _buildDetailItem(
                                      context,
                                      'Notes',
                                      widget.appointment.patientNotes!,
                                    ),
                                  if (widget.appointment.reminderTime != null)
                                    _buildDetailItem(
                                      context,
                                      'Reminder',
                                      '${widget.appointment.reminderTime} before',
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isPending)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: CustomButtonWidget(
                                  text: 'Edit',
                                  height: ScreenUtil.scaleHeight(context, 50),
                                  backgroundColor: AppColors.gradientGreen,
                                  fontFamily: AppFonts.rubik,
                                  fontSize: FontSizes(context).size16,
                                  fontWeight: FontWeight.w500,
                                  textColor: Colors.white,
                                  onPressed: () {
                                    ref
                                        .read(
                                      bookingViewSelectedPatientLabelProvider
                                          .notifier,
                                    )
                                        .state = widget.appointment.patientType;
                                    ref
                                        .read(bookingViewPatientNameProvider.notifier)
                                        .state = widget.appointment.patientName;
                                    ref
                                        .read(
                                      bookingViewPatientNumberProvider.notifier,
                                    )
                                        .state = widget.appointment.patientNumber;
                                    AppNavigation.push(
                                      AppointmentBookingView(
                                        doctor: doctor,
                                        appointment: widget.appointment,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CustomButtonWidget(
                                  text: 'Cancel',
                                  height: ScreenUtil.scaleHeight(context, 50),
                                  backgroundColor: Colors.white,
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
                                      await ref
                                          .read(bookingRepositoryProvider)
                                          .cancelBooking(
                                        widget.appointment.id,
                                        DateTime.now().toIso8601String(),
                                      );
                                      await _cancelNotification(widget.appointment.id);
                  
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
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 24),
                      if (widget.appointment.status == 'completed')
                        _buildRatingSection(),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: CustomTextWidget(
              text: label,
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size14,
                color: AppColors.subTextColor,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: CustomTextWidget(
              text: value,
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
