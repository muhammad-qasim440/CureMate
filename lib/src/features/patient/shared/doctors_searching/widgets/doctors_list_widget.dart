import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/patient_providers.dart';

class DoctorsListWidget extends ConsumerWidget {
  final List<Doctor> listOfDoctor;
  final Widget Function(Doctor doctor, bool isFavorite) doctorCardBuilder;

  const DoctorsListWidget({
    super.key,
    required this.listOfDoctor,
    required this.doctorCardBuilder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteUids = ref.watch(favoriteDoctorUidsProvider).value ?? [];

    if (listOfDoctor.isEmpty) {
      return const Center(child: Text('No doctors found'));
    }

    return Expanded(
      child: ListView.builder(
        itemCount: listOfDoctor.length,
        itemBuilder: (context, index) {
          final doctor = listOfDoctor[index];
          final isFavorite = favoriteUids.contains(doctor.uid);
          return doctorCardBuilder(doctor, isFavorite);
        },
      ),
    );
  }
}
