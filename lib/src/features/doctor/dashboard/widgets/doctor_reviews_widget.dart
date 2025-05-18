import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../appointments/models/appointment_model.dart';
import '../../../appointments/providers/appointments_providers.dart';
import '../views/doctor_all_reviews_view.dart';

class DoctorReviewsWidget extends ConsumerWidget {
  const DoctorReviewsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            CustomTextWidget(
              text: 'Recent Reviews & Ratings',
              textStyle: TextStyle(
                fontSize: FontSizes(context).size16,
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DoctorAllReviewsView(),
                  ),
                );
              },
              child: Row(
                children: [
                  Text(
                    'See All',
                    style: TextStyle(
                      color: AppColors.gradientGreen,
                      fontSize: FontSizes(context).size14,
                      fontFamily: AppFonts.rubik,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: AppColors.gradientGreen,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        appointmentsAsync.when(
          data: (appointments) {
            final ratedAppointments = appointments
                .where((apt) => apt.isRated && apt.rating != null && apt.review != null)
                .toList()
              ..sort((a, b) => (b.ratedAt ?? '').compareTo(a.ratedAt ?? ''));

            if (ratedAppointments.isEmpty) {
              return _buildEmptyReviews();
            }

            return Column(
              children: [
                ...ratedAppointments.take(3).map((apt) => _buildReviewCard(context, apt)),
              ],
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
      ],
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No reviews yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontFamily: AppFonts.rubik,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(BuildContext context, AppointmentModel appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
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
              Row(
                children: [
                  Text(
                    appointment.bookerName,
                    style: TextStyle(
                      fontSize: FontSizes(context).size14,
                      fontFamily: AppFonts.rubik,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
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
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          appointment.rating!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: FontSizes(context).size12,
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
          const SizedBox(height: 8),
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
        ],
      ),
    );
  }
} 