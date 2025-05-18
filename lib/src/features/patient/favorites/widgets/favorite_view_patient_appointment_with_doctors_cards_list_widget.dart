import 'package:curemate/src/features/patient/favorites/cards/doctor_with_appointment_card.dart';
import 'package:curemate/src/features/patient/shared/helpers/add_or_remove_doctor_into_favorite.dart';
import 'package:curemate/src/shared/widgets/custom_centered_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';

class FavoriteViewPatientAppointmentWithDoctorsCardsListWidget extends ConsumerWidget {
  const FavoriteViewPatientAppointmentWithDoctorsCardsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(patientDoctorsWithBookingsProvider);
    final favoriteUidsAsync = ref.watch(favoriteDoctorUidsProvider);

    return Padding(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Appointments With',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size18,
                  color: AppColors.black,
                ),
              ),
              const Text('See all', style: TextStyle(color: Colors.teal)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: ScreenUtil.scaleHeight(context, 180),
            child: doctorsAsync.when(
              data:
                  (doctors) => favoriteUidsAsync.when(
                data: (favoriteUids) {
                  final shuffledDoctors =
                  doctors.toList()..shuffle();
                  return doctors.isEmpty
                      ? const CustomCenteredTextWidget(text: 'No doctors available')
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                    shuffledDoctors.length > 6
                        ? 6
                        : shuffledDoctors
                        .length,
                    itemBuilder: (context, index) {
                      final doctor = shuffledDoctors[index];
                      final isFavorite = favoriteUids.contains(
                        doctor.uid,
                      );
                      return DoctorWithAppointmentCard(
                        doctor: doctor,
                        isFavorite: isFavorite,
                        onFavoriteToggle: () {
                          AddORRemoveDoctorIntoFavorite.toggleFavorite(
                            context,
                            ref,
                            doctor.uid,
                          );
                        },
                      );
                    },
                  );
                },
                loading:
                    () => const Center(child: CircularProgressIndicator(color:AppColors.gradientGreen)),
                error:
                    (error, stack) => Center(
                  child: Text(
                    'Error loading favorites: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator(color:AppColors.gradientGreen)),
              error:
                  (error, stack) => Center(
                child: Text(
                  error.toString().contains('permission_denied')
                      ? 'Permission denied. Please sign in as a patient.'
                      : 'Error loading doctors: $error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
