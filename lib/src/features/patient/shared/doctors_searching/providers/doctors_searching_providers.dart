import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/patient_providers.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final filteredDoctorsByProvider = Provider.family<List<Doctor>, ProviderListParam>((ref, param) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  final doctors = ref.watch(param.doctorListProvider).value ?? [];

  if (query.isEmpty) return doctors;

  return doctors.where((doctor) {
    return doctor.fullName.toLowerCase().contains(query) ||
        doctor.category.toLowerCase().contains(query) ||
        doctor.yearsOfExperience.toLowerCase().contains(query);
  }).toList();
});

class ProviderListParam {
  final AlwaysAliveProviderBase<AsyncValue<List<Doctor>>> doctorListProvider;

  ProviderListParam({required this.doctorListProvider});
}

