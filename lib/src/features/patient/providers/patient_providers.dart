import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Model for Patient
class Patient {
  final String uid;
  final String fullName;
  final String email;
  final String city;
  final String dob;
  final String phoneNumber;
  final String profileImageUrl;
  final String userType;
  final double latitude;
  final double longitude;
  final String createdAt;

  Patient({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.city,
    required this.dob,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.userType,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  factory Patient.fromMap(Map<dynamic, dynamic> map, String uid) {
    return Patient(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      city: map['city'] ?? '',
      dob: map['dob'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      userType: map['userType'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] ?? '',
    );
  }
}

// Model for Doctor
class Doctor {
  final String uid;
  final String fullName;
  final String email;
  final String city;
  final String dob;
  final String phoneNumber;
  final String profileImageUrl;
  final String userType;
  final double latitude;
  final double longitude;
  final String createdAt;
  final String qualification;
  final String yearsOfExperience;
  final String category;
  final double averageRatings;
  final int numberOfReviews;
  final int totalReviews;

  Doctor({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.city,
    required this.dob,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.userType,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.qualification,
    required this.yearsOfExperience,
    required this.category,
    required this.averageRatings,
    required this.numberOfReviews,
    required this.totalReviews,
  });

  factory Doctor.fromMap(Map<dynamic, dynamic> map, String uid) {
    return Doctor(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      city: map['city'] ?? '',
      dob: map['dob'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      userType: map['userType'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] ?? '',
      qualification: map['qualification'] ?? '',
      yearsOfExperience: map['yearsOfExperience'] ?? '',
      category: map['category'] ?? '',
      averageRatings: (map['averageRatings'] as num?)?.toDouble() ?? 0.0,
      numberOfReviews: map['numberOfReviews'] ?? 0,
      totalReviews: map['totalReviews'] ?? 0,
    );
  }
}

// Provider for current user (Patient)
final currentPatientProvider = StreamProvider<Patient?>((ref) async* {
  // Listen to auth state changes
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield null; // User logged out, return null
      continue;
    }

    // User is logged in, fetch patient data
    final database = FirebaseDatabase.instance.ref();
    final patientRef = database.child('Patients').child(user.uid);

    await for (final event in patientRef.onValue) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        yield Patient.fromMap(data, user.uid);
      } else {
        yield null;
      }
    }
  }
});

// Provider for doctors list
final doctorsProvider = StreamProvider<List<Doctor>>((ref) async* {
  // Listen to auth state changes
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield []; // User logged out, return empty list
      continue;
    }

    // Check if user is a patient
    final database = FirebaseDatabase.instance.ref();
    final userTypeRef = database.child('Patients').child(user.uid).child('userType');
    final userTypeSnapshot = await userTypeRef.get();
    if (userTypeSnapshot.value != 'Patient') {
      yield []; // Not a patient, return empty list
      continue;
    }

    // Fetch doctors list
    final doctorsRef = database.child('Doctors');
    await for (final event in doctorsRef.onValue) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final List<Doctor> doctors = [];
      if (data != null) {
        data.forEach((key, value) {
          doctors.add(Doctor.fromMap(value, key));
        });
      }
      yield doctors;
    }
  }
});

// In providers/patient_providers.dart
final favoriteDoctorUidsProvider = StreamProvider<List<String>>((ref) async* {
  // Listen to auth state changes
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield []; // User logged out, return empty list
      continue;
    }

    // Fetch favorites for the logged-in user
    final database = FirebaseDatabase.instance.ref();
    final favoritesRef = database.child('Patients').child(user.uid).child('favorites');

    await for (final event in favoritesRef.onValue) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final favoriteDoctorUids = data?.keys.cast<String>().toList() ?? [];
      yield favoriteDoctorUids;
    }
  }
});