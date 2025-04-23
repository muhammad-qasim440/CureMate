import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models_for_patient_and_doctors_for_chatting.dart';

final currentUserProvider = StreamProvider<AppUser?>((ref) async* {
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      print('currentUserProvider: No user authenticated at ${DateTime.now()}');
      yield null;
      continue;
    }

    final database = FirebaseDatabase.instance.ref();
    final userRef = database.child('Users').child(user.uid);
    final patientRef = database.child('Patients').child(user.uid);
    final doctorRef = database.child('Doctors').child(user.uid);

    // Check Users node
    final userSnapshot = await userRef.once();
    if (userSnapshot.snapshot.value != null) {
      final data = Map<String, dynamic>.from(userSnapshot.snapshot.value as Map);
      print('currentUserProvider: Found user data in Users/${user.uid}: $data at ${DateTime.now()}');
      yield AppUser.fromUserMap(data, user.uid);
      continue;
    }

    // Check if user is a patient
    final patientSnapshot = await patientRef.once();
    if (patientSnapshot.snapshot.value != null) {
      final data = Map<String, dynamic>.from(patientSnapshot.snapshot.value as Map);
      print('currentUserProvider: Found patient data in Patients/${user.uid}: $data at ${DateTime.now()}');
      yield AppUser.fromPatientMap(data, user.uid);
      continue;
    }

    // Check if user is a doctor
    final doctorSnapshot = await doctorRef.once();
    if (doctorSnapshot.snapshot.value != null) {
      final data = Map<String, dynamic>.from(doctorSnapshot.snapshot.value as Map);
      print('currentUserProvider: Found doctor data in Doctors/${user.uid}: $data at ${DateTime.now()}');
      yield AppUser.fromDoctorMap(data, user.uid);
      continue;
    }

    print('currentUserProvider: No user data found for ${user.uid} in Users, Patients, or Doctors at ${DateTime.now()}');
    yield null;
  }
});