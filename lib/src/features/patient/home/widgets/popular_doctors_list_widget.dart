import 'package:curemate/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';
import '../cards/popular_doctors_card.dart';

class PopularDoctorsListWidget extends ConsumerWidget {
  const PopularDoctorsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Doctors',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size18,
                ),
              ),
              const Text('See all', style: TextStyle(color: Colors.teal)),
            ],
          ),
          16.height,
          SizedBox(
            height: ScreenUtil.scaleHeight(context, 220),
            child: doctorsAsync.when(
              data: (doctors) {
                final sortedDoctors =
                doctors
                    .where((doctor) => doctor.averageRatings > 0)
                    .toList()
                  ..sort(
                        (a, b) => b.averageRatings.compareTo(a.averageRatings),
                  );
                return sortedDoctors.isEmpty
                    ? const Center(child: Text('No popular doctors available'))
                    : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                  sortedDoctors.length > 2
                      ? 2
                      : sortedDoctors
                      .length, // Limit to 2 as per screenshot
                  itemBuilder: (context, index) {
                    return PopularDoctorCard(doctor: sortedDoctors[index]);
                  },
                );
              },
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
}
