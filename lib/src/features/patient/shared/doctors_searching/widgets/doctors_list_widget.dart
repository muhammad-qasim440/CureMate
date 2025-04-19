import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/patient_providers.dart';
import '../card/doctor_searching_view_doctor_card.dart';
import '../providers/doctors_searching_providers.dart';

class DoctorsListWidget extends ConsumerWidget {
  const DoctorsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredDoctors = ref.watch(filteredDoctorsProvider);
    final favoriteUids = ref.watch(favoriteDoctorUidsProvider).value ?? [];

    if (filteredDoctors.isEmpty) {
      return const Center(child: Text('No doctors found'));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: filteredDoctors.length,
        itemBuilder: (context, index) {
          final doctor = filteredDoctors[index];
          final isFavorite = favoriteUids.contains(doctor.uid);
          return DoctorSearchingViewDoctorCard(doctor: doctor, isFavorite: isFavorite);
        },
      ),
    );
  }
}
