import 'package:curemate/src/features/patient/providers/patient_providers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/diagnosis_model.dart';

final diagnosisProvider = StateProvider<AsyncValue<List<Diagnosis>>>((ref) => const AsyncValue.loading());

final apiUrlProvider = StateProvider<String>((ref) => 'https://f0f7-119-154-241-110.ngrok-free.app/diagnose');

final ngrokApiProvider = StreamProvider<String>((ref) {
  final currentPatient = ref.watch(currentSignInPatientDataProvider).value;

  if (currentPatient == null) {
    return const Stream.empty();
  }

  final refNode = FirebaseDatabase.instance.ref('config/ngrokApiKey');
  return refNode.onValue.map((event) {
    final value = event.snapshot.value;
    return value?.toString() ?? '';
  });
});
