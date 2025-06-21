import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/date_time_format_extension.dart';
import 'package:curemate/src/features/patient/providers/patient_providers.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../theme/app_colors.dart';
import '../../appointments/models/appointment_model.dart';
import '../../appointments/providers/appointments_providers.dart';

class PatientDrawerRatingsViewsWidget extends ConsumerWidget {
  const PatientDrawerRatingsViewsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final currentUser = ref.watch(currentSignInPatientDataProvider).value;
    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 15.0,
                  ),
                  child: CustomAppBarHeaderWidget(
                    title: 'My Ratings & Reviews',
                  ),
                ),
                appointmentsAsync.when(
                  data: (appointments) {
                    final myRatedAppointments =
                        appointments
                            .where(
                              (apt) =>
                                  apt.patientUid == currentUser!.uid &&
                                  apt.isRated &&
                                  apt.rating != null &&
                                  apt.review != null,
                            )
                            .toList()
                          ..sort(
                            (a, b) =>
                                (b.ratedAt ?? '').compareTo(a.ratedAt ?? ''),
                          );

                    if (myRatedAppointments.isEmpty) {
                      return _buildEmptyRatings(context);
                    }

                    return Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: myRatedAppointments.length,
                        itemBuilder:
                            (context, index) => _buildRatingCard(
                              context,
                              myRatedAppointments[index],
                            ),
                      ),
                    );
                  },
                  loading:
                      () => const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.gradientGreen,
                          ),
                        ),
                      ),
                  error:
                      (error, stack) => Center(
                        child: Text(
                          'Error loading ratings',
                          style: TextStyle(
                            color: Colors.red[400],
                            fontSize: FontSizes(context).size14,
                            fontFamily: AppFonts.rubik,
                          ),
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRatings(BuildContext context) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.gradientGreen,
              child: Icon(
                Icons.rate_review_outlined,
                size: 64,
                color: AppColors.gradientWhite,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You haven\'t given any ratings yet',
              style: TextStyle(
                color: AppColors.black,
                fontSize: FontSizes(context).size12,
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rate to your completed appointments',
              style: TextStyle(
                color: AppColors.gradientGreen,
                fontSize: FontSizes(context).size16,
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w500,

              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingCard(BuildContext context, AppointmentModel appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.gradientGreen.withOpacity(0.1),
                      child: Text(
                        appointment.doctorName[0].toUpperCase(),
                        style: TextStyle(
                          color: AppColors.gradientGreen,
                          fontSize: FontSizes(context).size16,
                          fontFamily: AppFonts.rubik,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.doctorName,
                            style: TextStyle(
                              fontSize: FontSizes(context).size14,
                              fontFamily: AppFonts.rubik,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            appointment.doctorCategory,
                            style: TextStyle(
                              fontSize: FontSizes(context).size12,
                              fontFamily: AppFonts.rubik,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gradientGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      appointment.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: FontSizes(context).size14,
                        fontFamily: AppFonts.rubik,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (appointment.review != '') ...[
            Text(
              appointment.review!,
              style: TextStyle(
                fontSize: FontSizes(context).size14,
                fontFamily: AppFonts.rubik,
                color: Colors.grey[700],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            appointment.patientType == 'My Self'
                ? 'Booked for: ${appointment.bookerName}'
                : 'Booked for: ${appointment.patientName}',
            style: TextStyle(
              fontSize: FontSizes(context).size12,
              fontFamily: AppFonts.rubik,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Appointment Date: ${appointment.date.formattedDate}',
                style: TextStyle(
                  fontSize: FontSizes(context).size12,
                  fontFamily: AppFonts.rubik,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Rated: ${DateFormat('MMM d, y').format(DateTime.parse(appointment.ratedAt!))}',
                style: TextStyle(
                  fontSize: FontSizes(context).size12,
                  fontFamily: AppFonts.rubik,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
