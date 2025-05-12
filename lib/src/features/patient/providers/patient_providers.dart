import 'package:curemate/src/features/authentication/signin/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/calculate_distance_between_two_latitude_and_logitude_points.dart';
import '../../../../core/utils/debug_print.dart';
import '../../bookings/providers/booking_providers.dart';
import '../home/widgets/near_by_doctors_searching_radius_provider_widget.dart';

class Patient {
  final String uid;
  final String fullName;
  final String email;
  final String city;
  final String dob;
  final String phoneNumber;
  final String profileImageUrl;
  final String profileImagePublicId;
  final String userType;
  final double latitude;
  final double longitude;
  final String createdAt;
  final Map<String, bool> favorites;
  final Map<String, Map<String, dynamic>> medicalRecords;

  Patient({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.city,
    required this.dob,
    required this.phoneNumber,
    required this.profileImageUrl,
    required this.profileImagePublicId,
    required this.userType,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.favorites,
    required this.medicalRecords,
  });

  factory Patient.fromMap(Map<dynamic, dynamic> map, String uid) {
    // Helper function to safely convert favorites to Map<String, bool>
    Map<String, bool> parseFavorites(dynamic favorites) {
      if (favorites == null) return {};
      if (favorites is! Map) {
        logDebug('Warning: favorites is not a Map, received: $favorites');
        return {};
      }
      return favorites.map((key, value) {
        return MapEntry(
          key.toString(),
          value is bool ? value : false,
        );
      });
    }

    return Patient(
      uid: uid,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      city: map['city'] ?? '',
      dob: map['dob'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      profileImagePublicId: map['profileImagePublicId'] ?? '',
      userType: map['userType'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: map['createdAt'] ?? '',
      favorites: parseFavorites(map['favorites']),
      medicalRecords: Map<String, Map<String, dynamic>>.from(
        (map['MedicalRecords'] as Map<dynamic, dynamic>?)?.map((key, value) => MapEntry(key.toString(), Map<String, dynamic>.from(value))) ?? {},
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'city': city,
      'dob': dob,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'profileImagePublicId': profileImagePublicId,
      'userType': userType,
      'latitude': latitude,
      'longitude': longitude,
      'createdAt': createdAt,
      'favorites': favorites,
      'MedicalRecords': medicalRecords,
    };
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
  final int profileViews;
  final Map<String, bool> viewedBy;
  final List<Map<String, dynamic>> availability;

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
    required this.profileViews,
    required this.viewedBy,
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
      profileViews: map['profileViews'] ?? 0,
      viewedBy: Map<String, bool>.from(
        map['viewedBy'] as Map<dynamic, dynamic>? ?? {},
      ),
      availability: (map['availability'] as List<dynamic>?)?.map((item) {
        return Map<String, dynamic>.from(item as Map<dynamic, dynamic>);
      }).toList() ??
          [],
    );
  }
}
final doctorsProvider = StreamProvider<List<Doctor>>((ref) async* {
  final authService = ref.read(authProvider);
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield [];
      continue;
    }

    final database = ref.read(firebaseDatabaseProvider);
    final userTypeRef = database.child('Patients').child(user.uid).child('userType');
    final userTypeSnapshot = await userTypeRef.get();
    if (userTypeSnapshot.value != 'Patient') {
      yield [];
      continue;
    }

    final doctorsRef = database.child('Doctors');
    final subscription = doctorsRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final List<Doctor> doctors = [];
      if (data != null) {
        data.forEach((key, value) {
          doctors.add(Doctor.fromMap(value, key));
        });
      }
      ref.state = AsyncValue.data(doctors);
      ref.state.whenData((value) => value);
    });
    authService.addRealtimeDbListener(subscription);
    yield ref.state.value ?? [];
  }
});
final currentSignInPatientDataProvider = StreamProvider<Patient?>((ref) async* {
  final authService = ref.read(authProvider);
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield null;
      continue;
    }
    final database = ref.read(firebaseDatabaseProvider);
    final patientRef = database.child('Patients').child(user.uid);

    final subscription = patientRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final patient = data != null ? Patient.fromMap(data, user.uid) : null;
      ref.state = AsyncValue.data(patient);
      ref.state.whenData((value) => value);
    });
    authService.addRealtimeDbListener(subscription);
    yield ref.state.value;
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
      .where((entry) => entry.value <= searchingRadius)
      .toList()
    ..sort((a, b) => a.value.compareTo(b.value));

  return nearbyDoctors.map((entry) => entry.key).toList();
});
final favoriteDoctorUidsProvider = StreamProvider<List<String>>((ref) async* {
  final authService = ref.read(authProvider);
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield [];
      continue;
    }

    final database = ref.read(firebaseDatabaseProvider);
    final favoritesRef = database.child('Patients').child(user.uid).child('favorites');

    final subscription = favoritesRef.onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final favoriteDoctorUids = data?.keys.cast<String>().toList() ?? [];
      ref.state = AsyncValue.data(favoriteDoctorUids);
      ref.state.whenData((value) => value);
    });
    authService.addRealtimeDbListener(subscription);
    yield ref.state.value ?? [];
  }
});
final favoriteDoctorsProvider = StreamProvider<List<Doctor>>((ref) async* {
  final authService = ref.read(authProvider);
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield [];
      continue;
    }

    final database = ref.read(firebaseDatabaseProvider);
    final favoritesRef = database.child('Patients').child(user.uid).child('favorites');

    final subscription = favoritesRef.onValue.listen((event) async {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      final favoriteDoctors = <Doctor>[];
      if (data != null) {
        final doctorUids = data.keys.cast<String>();
        for (final uid in doctorUids) {
          final snapshot = await database.child('Doctors').child(uid).get();
          if (snapshot.exists) {
            final doctor = Doctor.fromMap(snapshot.value as Map, uid);
            favoriteDoctors.add(doctor);
          }
        }
      }
      ref.state = AsyncValue.data(favoriteDoctors);
      ref.state.whenData((value) => value);
    });
    authService.addRealtimeDbListener(subscription);
    yield ref.state.value ?? [];
  }
});
final patientDoctorsWithBookingsProvider = StreamProvider<List<Doctor>>((ref) async* {
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield [];
      continue;
    }
    try {
      await for (final appointments in ref.watch(appointmentsProvider.stream)) {
        final doctorUids = appointments
            .where((appointment) => appointment.patientUid == user.uid)
            .map((appointment) => appointment.doctorUid)
            .toSet()
            .toList();
        final doctorsAsyncValue = ref.watch(doctorsProvider);
        if (doctorsAsyncValue is AsyncError) {
          yield [];
          continue;
        }

        final doctors = doctorsAsyncValue.value ?? [];
        final doctorsWithBookings =
        doctors.where((doctor) => doctorUids.contains(doctor.uid)).toList();
        yield doctorsWithBookings;
      }
    } catch (e, stack) {
      logDebug('patientDoctorsWithBookingsProvider: Error processing stream: $e, Stack: $stack');
      yield [];
    }
  }
});
final popularDoctorsProvider = StreamProvider<List<Doctor>>((ref) async* {
  final authService = ref.read(authProvider);
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield [];
      continue;
    }
    final doctorsAsyncValue = ref.watch(doctorsProvider);
    if (doctorsAsyncValue.hasValue) {
      final doctors = doctorsAsyncValue.value ?? [];
      /// popular doctors: based on average ratings and profile views
      final popularDoctors = List<Doctor>.from(doctors)
        ..sort((a, b) {
          final ratingComparison = b.averageRatings.compareTo(a.averageRatings);
          if (ratingComparison != 0) {
            return ratingComparison;
          }
          return (b.profileViews).compareTo(a.profileViews);
        });

      yield popularDoctors;
    } else {
      yield [];
    }
    final database = ref.read(firebaseDatabaseProvider);
    final doctorsRef = database.child('Doctors');

    final subscription = doctorsRef.onValue.listen((event) {
      ref.state = AsyncValue.data(ref.state.value ?? []);
    });

    authService.addRealtimeDbListener(subscription);
  }
});
final featuredDoctorsProvider = StreamProvider<List<Doctor>>((ref) async* {
  final authService = ref.read(authProvider);
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield [];
      continue;
    }

    final doctorsAsyncValue = ref.watch(doctorsProvider);

    if (doctorsAsyncValue.hasValue) {
      final doctors = doctorsAsyncValue.value ?? [];

      /// Apply logic for featured doctors
      // Criteria:
      // 1. Experience over 3 years
      // 2. Average Rating above 4.0
      // 3. Has at least 10 patients consulted
      final featuredDoctors = List<Doctor>.from(doctors.where((doctor) {
        return int.parse(doctor.yearsOfExperience) >= 3  &&
            doctor.averageRatings >= 4.0;
            // &&
            // (doctor.totalPatientConsulted) >= 10;
      }))
        ..sort((a, b) {
          final patientsComparison = (b.totalPatientConsulted).compareTo(a.totalPatientConsulted);
          if (patientsComparison != 0) {
            return patientsComparison;
          }
          return b.yearsOfExperience.compareTo(a.yearsOfExperience);
        });

      yield featuredDoctors;
    } else {
      yield [];
    }

    final database = ref.read(firebaseDatabaseProvider);
    final doctorsRef = database.child('Doctors');
    final subscription = doctorsRef.onValue.listen((event) {
      ref.state = AsyncValue.data(ref.state.value ?? []);
    });

    authService.addRealtimeDbListener(subscription);
  }
});
final isPhoneCallsAllowedByUserProvider = FutureProvider.family<bool, String>((ref, userId) async {
  if (userId.isEmpty) {
    return false;
  }

  try {
    final database = ref.read(firebaseDatabaseProvider);
    final dbRef = database.child('Users/$userId/settings/allowCall');
    final snapshot = await dbRef.get();
    if (snapshot.exists) {
      return snapshot.value as bool;
    }
    return false;
  } catch (e) {
    return false;
  }
});