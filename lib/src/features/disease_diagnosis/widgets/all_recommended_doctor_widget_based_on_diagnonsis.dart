import 'package:curemate/src/features/patient/home/cards/all_near_by_doctors_view_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../router/nav.dart';
import '../../../shared/widgets/back_view_icon_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../patient/providers/patient_providers.dart';

class AllDoctorsScreen extends ConsumerWidget {
  final String doctorType;
  const AllDoctorsScreen({super.key, required this.doctorType});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.gradientGreen,
        leading: const BackViewIconWidget(),
        titleSpacing: 0,
        leadingWidth: 60,
        title: CustomTextWidget(
          text: '${doctorType}s',
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size18,
            fontWeight: FontWeight.w700,
            color: AppColors.gradientWhite,
          ),
        ),
      ),
      body: doctorsAsync.when(
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.gradientGreen),
            ),
        error:
            (error, _) => Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: $error',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
        data: (doctors) {
          final matchingDoctors =
              doctors.where((doctor) => doctor.category == doctorType).toList()
                ..sort((a, b) => b.averageRatings.compareTo(a.averageRatings));
          final favoriteIds = ref.watch(favoriteDoctorUidsProvider);
          return favoriteIds.when(
            data: (data) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: matchingDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = matchingDoctors[index];
                  final isFavorite = data.contains(doctor.uid);
                  return AllNearByDoctorsViewCard(
                    doctor: doctor,
                    isFavorite: isFavorite,
                    isFromRecommendations: true,
                  );
                },
              );
            },
            loading:
                () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.gradientGreen,
                  ),
                ),
            error:
                (error, stack) => Center(
                  child: Text(
                    'Error loading favorites: $error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
          );
        },
      ),
    );
  }
}
