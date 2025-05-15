import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../authentication/signin/providers/auth_provider.dart';
import '../../patient/providers/patient_providers.dart';

final currentSignInDoctorDataProvider = StreamProvider<Doctor?>((ref) async* {
  final authService = ref.read(authProvider);
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield null;
      continue;
    }
    final database = ref.read(firebaseDatabaseProvider);
    final doctorRef = database.child('Doctors').child(user.uid);

    final subscription = doctorRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final doctor = data != null ? Doctor.fromMap(data, user.uid) : null;
      ref.state = AsyncValue.data(doctor);
      ref.state.whenData((value) => value);
    });
    authService.addRealtimeDbListener(subscription);
    yield ref.state.value;
  }
});