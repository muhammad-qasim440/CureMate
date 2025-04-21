import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/models_for_patient_and_doctors_for_chatting.dart';

// Unified auth provider
final currentUserProvider = StreamProvider<AppUser?>((ref) async* {
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield null; // User logged out
      continue;
    }

    final database = FirebaseDatabase.instance.ref();
    final patientRef = database.child('Patients').child(user.uid);
    final doctorRef = database.child('Doctors').child(user.uid);

    // Check if user is a patient
    final patientSnapshot = await patientRef.once();
    if (patientSnapshot.snapshot.value != null) {
      final data = patientSnapshot.snapshot.value as Map<dynamic, dynamic>;
      yield AppUser.fromPatientMap(data, user.uid);
      continue;
    }

    // Check if user is a doctor
    final doctorSnapshot = await doctorRef.once();
    if (doctorSnapshot.snapshot.value != null) {
      final data = doctorSnapshot.snapshot.value as Map<dynamic, dynamic>;
      yield AppUser.fromDoctorMap(data, user.uid);
      continue;
    }

    // No user data found
    yield null;
  }
});