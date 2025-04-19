import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';
import '../cards/featured_doctor_card.dart';

class FeaturedDoctorsListWidget extends ConsumerWidget {
  const FeaturedDoctorsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final favoriteUidsAsync = ref.watch(favoriteDoctorUidsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Doctors',
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
                  doctors.toList()..shuffle(); // Shuffle all doctors
                  return shuffledDoctors.isEmpty
                      ? const Center(child: Text('No doctors available'))
                      : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount:
                    shuffledDoctors.length > 3
                        ? 3
                        : shuffledDoctors
                        .length, // Limit to 3 as per screenshot
                    itemBuilder: (context, index) {
                      final doctor = shuffledDoctors[index];
                      final isFavorite = favoriteUids.contains(
                        doctor.uid,
                      );
                      return FeaturedDoctorCard(
                        doctor: doctor,
                        isFavorite: isFavorite,
                        onFavoriteToggle:
                            () => _toggleFavorite(
                          context,
                          ref,
                          doctor.uid,
                        ),
                      );
                    },
                  );
                },
                loading:
                    () => const Center(child: CircularProgressIndicator()),
                error:
                    (error, stack) => Center(
                  child: Text(
                    'Error loading favorites: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
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

  void _toggleFavorite(
      BuildContext context,
      WidgetRef ref,
      String doctorUid,
      ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final database = FirebaseDatabase.instance.ref();
    final favoritesRef = database
        .child('Patients')
        .child(user.uid)
        .child('favorites')
        .child(doctorUid);

    try {
      final snapshot = await favoritesRef.get();
      if (snapshot.exists) {
        await favoritesRef.remove();
      } else {
        await favoritesRef.set(true);
      }
    } catch (e) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'Error toggling favorite: $e',
      );
    }
  }
}
