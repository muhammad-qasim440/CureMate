import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models_for_patient_and_doctors_for_chatting.dart';

final currentUserProvider = StreamProvider<AppUser?>((ref) {
  final auth = FirebaseAuth.instance;
  final database = FirebaseDatabase.instance.ref();

  return auth.authStateChanges().asyncMap((user) async {
    if (user == null) return null;

    final uid = user.uid;

    final pathsToCheck = [
      'Users/$uid',
      'Patients/$uid',
      'Doctors/$uid',
    ];

    for (final path in pathsToCheck) {
      final snapshot = await database.child(path).get();
      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        if (path.startsWith('Users/')) {
          return AppUser.fromUserMap(data, uid);
        } else if (path.startsWith('Patients/')) {
          return AppUser.fromPatientMap(data, uid);
        } else if (path.startsWith('Doctors/')) {
          return AppUser.fromDoctorMap(data, uid);
        }
      }
    }

    return null;
  });
});
