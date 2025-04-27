import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../const/app_strings.dart';
import '../../../../core/utils/calculate_distance_between_two_latitude_and_logitude_points.dart';
import '../../../shared/providers/check_internet_connectivity_provider.dart';
import '../home/widgets/near_by_doctors_searching_radius_provider_widget.dart';
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
  final String hospital;
  final double averageRatings;
  final int numberOfReviews;
  final int totalReviews;
  final int totalPatientConsulted;
  final int consultationFee;
  final Map<String, dynamic> availability; // New field

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
    required this.hospital,
    required this.averageRatings,
    required this.numberOfReviews,
    required this.totalReviews,
    required this.totalPatientConsulted,
    required this.consultationFee,
    required this.availability,
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
      hospital: map['hospital'] ?? '',
      averageRatings: (map['averageRatings'] as num?)?.toDouble() ?? 0.0,
      numberOfReviews: map['numberOfReviews'] ?? 0,
      totalReviews: map['totalReviews'] ?? 0,
      totalPatientConsulted: map['totalPatientConsulted'] ?? 0,
      consultationFee: map['consultationFee'] ?? 0,
      availability: (map['availability'] as Map<dynamic, dynamic>?)?.map((key, value) {
        return MapEntry(key as String, value);
      }) ?? {},
    );
  }
}
final doctorsProvider = StreamProvider<List<Doctor>>((ref) async* {
  final isNetworkConnected=ref.read(checkInternetConnectionProvider.future);
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
final currentSignInPatientDataProvider = StreamProvider<Patient?>((ref) async* {
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield null;
      continue;
    }
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
final nearByDoctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final patientAsync = ref.watch(currentSignInPatientDataProvider);
  final searchingRadius = ref.watch(radiusProvider);
  var doctors = ref.watch(doctorsProvider).value ?? [];

  if (patientAsync.value == null) {
    return [];
  }

  final patient = patientAsync.value!;
  if (searchingRadius == 0) {
    return doctors;
  }

  // If not 'All', filter doctors by distance within the selected radius
  final nearbyDoctors = doctors
      .map((doctor) {
    final distance = calculateDistance(
      patient.latitude,
      patient.longitude,
      doctor.latitude,
      doctor.longitude,
    );
    return MapEntry(doctor, distance);
  })
      .where((entry) => entry.value <= searchingRadius) // Only doctors within the radius
      .toList()
    ..sort((a, b) => a.value.compareTo(b.value)); // Sort by distance

  return nearbyDoctors.map((entry) => entry.key).toList();
});
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
final favoriteDoctorsProvider = StreamProvider<List<Doctor>>((ref) async* {
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield [];
      continue;
    }

    final database = FirebaseDatabase.instance.ref();
    final favoritesRef = database.child('Patients').child(user.uid).child('favorites');

    await for (final event in favoritesRef.onValue) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data == null) {
        yield [];
        continue;
      }

      final doctorUids = data.keys.cast<String>();
      final favoriteDoctors = <Doctor>[];

      for (final uid in doctorUids) {
        final snapshot = await database.child('Doctors').child(uid).get();
        if (snapshot.exists) {
          final doctor = Doctor.fromMap(snapshot.value as Map, uid);
          favoriteDoctors.add(doctor);
        }
      }

      yield favoriteDoctors;
    }
  }
});
