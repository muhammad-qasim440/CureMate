import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/patient_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => 'Dentist');

// Filtered doctors provider
final filteredDoctorsProvider = Provider<List<Doctor>>((ref) {
  final doctors = ref.watch(doctorsProvider).value ?? [];
  final query = ref.watch(searchQueryProvider).toLowerCase();

  if (query.isEmpty) return doctors;

  return doctors.where((doctor) {
    final nameMatch = doctor.fullName.toLowerCase().contains(query);
    final categoryMatch = doctor.category.toLowerCase().contains(query);
    final experienceMatch = doctor.yearsOfExperience.toLowerCase().contains(query);
    return nameMatch || categoryMatch || experienceMatch;
  }).toList();
});
