import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DoctorRepository {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  User? _currentUser;
  late final Stream<User?> _authStateChanges;

  DoctorRepository() {
    _authStateChanges = FirebaseAuth.instance.authStateChanges();
    _authStateChanges.listen((user) {
      _currentUser = user;
    });

    // Initialize with the current user (in case user is already logged in)
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  Future<void> incrementProfileView(String doctorUid) async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }

    final doctorRef = _database.child('Doctors').child(doctorUid);
    final viewedByRef = doctorRef.child('viewedBy').child(_currentUser!.uid);

    final snapshot = await viewedByRef.get();
    if (snapshot.exists) {
      // Already viewed, don't increment again
      return;
    }

    await doctorRef.update({
      'viewedBy/${_currentUser!.uid}': true,
      'profileViews': ServerValue.increment(1),
    });
  }
}
