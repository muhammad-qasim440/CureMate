import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../authentication/signin/providers/auth_provider.dart';


///  patient medical records view provider
final medicalRecordsProvider = StreamProvider.autoDispose<List<Map<String, dynamic>>>((ref) async* {
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield [];
      continue;
    }
    final database = ref.watch(firebaseDatabaseProvider);
    final recordsRef = database
        .child('Patients')
        .child(user.uid)
        .child('MedicalRecords');
    await for (final snapshot in recordsRef.onValue) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};
      yield data.entries
          .map(
            (entry) {
          final record = {
            'id': entry.key,
            ...Map<String, dynamic>.from(entry.value as Map<dynamic, dynamic>),
          };
          // Normalize images field: ensure it's a list of maps with string keys and values
          if (record['images'] != null && record['images'] is List) {
            record['images'] = (record['images'] as List).map((item) {
              if (item is Map) {
                return Map<String, String>.fromEntries(
                  (item).entries.map((e) => MapEntry(e.key.toString(), e.value.toString())),
                );
              }
              return {'url': '', 'public_id': ''}; // Default fallback
            }).toList();
          } else {
            record['images'] = [];
          }
          return record;
        },
      )
          .toList();
    }
  }
});




/// add patient record view providers
final selectedImagesProvider = StateProvider<List<File>>((ref) => []);
final recordTypeProvider = StateProvider.autoDispose<String>((ref) => 'Prescription');
final recordDateProvider = StateProvider.autoDispose<String>(
      (ref) => DateTime.now().toIso8601String(),
);
final patientNameProvider = StateProvider.autoDispose<String>((ref) => '');
final isEditingNameProvider = StateProvider<bool>((ref) => false);
final isEditingDateProvider = StateProvider.autoDispose<bool>((ref) => false);
final isUploadingProvider = StateProvider.autoDispose<bool>((ref) => false);
final isDeletingProvider = StateProvider.autoDispose<bool>((ref) => false);
/// medical records details view Providers
final selectedIndicesProvider = StateProvider<Set<int>>((ref) => {});
final selectionModeProvider = StateProvider<bool>((ref) => false);
final newImagesProvider = StateProvider<List<File>>((ref) => []);
/// Full image Screen Providers
final currentOpenedImageIndexProvider=StateProvider<int>((ref)=>0);

/// user profile providers

final userUpdatedNameProvider = StateProvider<String>((ref) => '');
final userUpdatedPhoneNumberProvider = StateProvider<String>((ref) => '');
final userUpdatedCityProvider = StateProvider<String>((ref) => '');
final userUpdatedLatitudeProvider = StateProvider<String>((ref) => '');
final userUpdatedLongitudeProvider = StateProvider<String>((ref) => '');
final userUpdatedDOBProvider = StateProvider<String>((ref) => '');
final isEditingPhoneNumberProvider = StateProvider<bool>((ref) => false);
final isEditingDOBProvider = StateProvider<bool>((ref) => false);
final isEditingCityProvider = StateProvider<bool>((ref) => false);
final isEditingLocationProvider = StateProvider<bool>((ref) => false);


/// more for doctor profile
final userUpdatedQualificationProvider = StateProvider<String>((ref) => '');
final userUpdatedYearsOfExperienceProvider = StateProvider<String>((ref) => '');
final userUpdatedCategoryProvider = StateProvider<String>((ref) => '');
final userUpdatedHospitalProvider = StateProvider<String>((ref) => '');
final userUpdatedConsultationFeeProvider = StateProvider<int>((ref) => 0);
final isEditingQualificationProvider = StateProvider<bool>((ref) => false);
final isEditingYearsOfExperienceProvider = StateProvider<bool>((ref) => false);
final isEditingCategoryProvider = StateProvider<bool>((ref) => false);
final isEditingHospitalProvider = StateProvider<bool>((ref) => false);
final isEditingConsultationFeeProvider = StateProvider<bool>((ref) => false);
