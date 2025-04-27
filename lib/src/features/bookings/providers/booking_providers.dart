import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../patient/providers/patient_providers.dart';

class Appointment {
  final String id;
  final String patientUid;
  final String doctorUid;
  final String date;
  final String timeSlot;
  final String status;
  final String createdAt;
  final String? patientNotes;

  Appointment({
    required this.id,
    required this.patientUid,
    required this.doctorUid,
    required this.date,
    required this.timeSlot,
    required this.status,
    required this.createdAt,
    this.patientNotes,
  });

  factory Appointment.fromMap(Map<dynamic, dynamic> map, String id) {
    return Appointment(
      id: id,
      patientUid: map['patientUid'] ?? '',
      doctorUid: map['doctorUid'] ?? '',
      date: map['date'] ?? '',
      timeSlot: map['timeSlot'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: map['createdAt'] ?? '',
      patientNotes: map['patientNotes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patientUid': patientUid,
      'doctorUid': doctorUid,
      'date': date,
      'timeSlot': timeSlot,
      'status': status,
      'createdAt': createdAt,
      'patientNotes': patientNotes,
    };
  }
}
final appointmentsProvider = StreamProvider<List<Appointment>>((ref) async* {
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield [];
      continue;
    }

    final database = FirebaseDatabase.instance.ref();
    final appointmentsRef = database.child('Appointments');

    final streamController = StreamController<List<Appointment>>();
    final List<Appointment> appointments = [];
    final Set<String> appointmentIds = {};

    void updateAppointment(String key, Map<dynamic, dynamic> value) {
      final appointment = Appointment.fromMap(value, key);
      final index = appointments.indexWhere((app) => app.id == key);
      if (index == -1) {
        appointments.add(appointment);
        appointmentIds.add(key);
        print('Added appointment: $key');
      } else {
        appointments[index] = appointment;
        print('Updated appointment: $key, Status: ${appointment.status}');
      }
      streamController.add(List.from(appointments));
    }

    // Listen to patient appointments
    final patientQuery = appointmentsRef.orderByChild('patientUid').equalTo(user.uid);
    final patientSubscription = patientQuery.onChildAdded.listen((event) {
      final key = event.snapshot.key!;
      final value = event.snapshot.value as Map<dynamic, dynamic>;
      updateAppointment(key, value);
    });

    final patientUpdateSubscription = patientQuery.onChildChanged.listen((event) {
      final key = event.snapshot.key!;
      final value = event.snapshot.value as Map<dynamic, dynamic>;
      updateAppointment(key, value);
    });

    // Listen to doctor appointments
    final doctorQuery = appointmentsRef.orderByChild('doctorUid').equalTo(user.uid);
    final doctorSubscription = doctorQuery.onChildAdded.listen((event) {
      final key = event.snapshot.key!;
      final value = event.snapshot.value as Map<dynamic, dynamic>;
      updateAppointment(key, value);
    });

    final doctorUpdateSubscription = doctorQuery.onChildChanged.listen((event) {
      final key = event.snapshot.key!;
      final value = event.snapshot.value as Map<dynamic, dynamic>;
      updateAppointment(key, value);
    });

    yield* streamController.stream;

    ref.onDispose(() {
      patientSubscription.cancel();
      patientUpdateSubscription.cancel();
      doctorSubscription.cancel();
      doctorUpdateSubscription.cancel();
      streamController.close();
    });
  }
});
final patientDataByUidProvider = FutureProvider.family<Patient?, String>((ref, patientUid) async {
  final database = FirebaseDatabase.instance.ref();
  final patientRef = database.child('Patients').child(patientUid);

  final snapshot = await patientRef.get();
  if (snapshot.exists) {
    final data = snapshot.value as Map<dynamic, dynamic>;
    return Patient(
      uid: patientUid,
      fullName: data['fullName'] ?? 'Unknown Patient',
      email: data['email'] ?? '',
      city: data['city'] ?? '',
      dob: data['dob'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      profileImageUrl: data['profileImageUrl'] ?? '',
      userType: data['userType'] ?? 'Patient',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: data['createdAt'] ?? '',
    );
  }
  return null;
});