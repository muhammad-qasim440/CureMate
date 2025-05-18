import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/date_time_format_extension.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/back_view_icon_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../theme/app_colors.dart';
import '../../../appointments/models/appointment_model.dart';
import '../../../appointments/providers/appointments_providers.dart';

class DoctorAllReviewsView extends ConsumerWidget {
  const DoctorAllReviewsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackViewIconWidget(),
        title: Text(
          'All Reviews',
          style: TextStyle(
            fontSize: FontSizes(context).size18,
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.gradientGreen,
        foregroundColor: Colors.white,
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          final ratedAppointments = appointments
              .where((apt) => apt.isRated && apt.rating != null && apt.review != null)
              .toList()
            ..sort((a, b) => (b.ratedAt ?? '').compareTo(a.ratedAt ?? ''));

          if (ratedAppointments.isEmpty) {
            return _buildEmptyReviews();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ratedAppointments.length,
            itemBuilder: (context, index) => _buildReviewCard(
              context,
              ratedAppointments[index],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.gradientGreen),
          ),
        ),
        error: (error, stack) => Center(
          child: Text(
            'Error loading reviews',
            style: TextStyle(
              color: Colors.red[400],
              fontSize: FontSizes(context).size14,
              fontFamily: AppFonts.rubik,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyReviews() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontFamily: AppFonts.rubik,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, AppointmentModel appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gradientWhite,
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
                        appointment.bookerName[0].toUpperCase(),
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
                            appointment.bookerName,
                            style: TextStyle(
                              fontSize: FontSizes(context).size14,
                              fontFamily: AppFonts.rubik,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                           appointment.ratedAt!.formattedDateTime,
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
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      appointment.rating!.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: FontSizes(context).size14,
                        fontFamily: AppFonts.rubik,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if(appointment.review!='')...[
          Text(
           'Review: ${appointment.review!}',
            style: TextStyle(
              fontSize: FontSizes(context).size14,
              fontFamily: AppFonts.rubik,
              color: AppColors.subTextColor,
            ),
          ),
          ],
          const SizedBox(height: 8),
          Text(
            appointment.patientType=='My Self'?'Booked for: ${appointment.bookerName }'
            :'Booked for: ${appointment.patientName}',
            style: TextStyle(
              fontSize: FontSizes(context).size12,
              fontFamily: AppFonts.rubik,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Appointment Date: ${appointment.date.formattedDate}',
            style: TextStyle(
              fontSize: FontSizes(context).size12,
              fontFamily: AppFonts.rubik,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
} 