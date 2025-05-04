import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/debug_print.dart';
import '../../authentication/signin/providers/auth-provider.dart';
import '../../patient/providers/patient_providers.dart';
import '../models/appointment_model.dart';

final appointmentsProvider = StreamProvider<List<AppointmentModel>>((ref) async* {
  await for (final user in FirebaseAuth.instance.authStateChanges()) {
    if (user == null) {
      yield [];
      continue;
    }

    final database = ref.read(firebaseDatabaseProvider);
    final authService = ref.read(authProvider);
    final appointmentsRef = database.child('Appointments');

    final streamController = StreamController<List<AppointmentModel>>();
    final List<AppointmentModel> appointments = [];
    final Set<String> appointmentIds = {};

    void updateAppointment(String key, Map<dynamic, dynamic> value) {
      final appointment = AppointmentModel.fromMap(value, key);
      final index = appointments.indexWhere((app) => app.id == key);
      if (index == -1) {
        appointments.add(appointment);
        appointmentIds.add(key);
      } else {
        appointments[index] = appointment;
      }

      appointments.sort((a, b) {
        try {
          final aDateTime = DateTime.parse(a.createdAt);
          final bDateTime = DateTime.parse(b.createdAt);
          return bDateTime.compareTo(aDateTime); // Descending
        } catch (e) {
          print('Error parsing createdAt for sorting: $e');
          return 0;
        }
      });

      streamController.add(List.from(appointments));
    }

    void removeAppointment(String key) {
      appointments.removeWhere((app) => app.id == key);
      appointmentIds.remove(key);
      streamController.add(List.from(appointments));
    }

    final patientQuery = appointmentsRef.orderByChild('patientUid').equalTo(user.uid);
    final doctorQuery = appointmentsRef.orderByChild('doctorUid').equalTo(user.uid);

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
    final patientRemoveSubscription = patientQuery.onChildRemoved.listen((event) {
      final key = event.snapshot.key!;
      removeAppointment(key);
    });

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
    final doctorRemoveSubscription = doctorQuery.onChildRemoved.listen((event) {
      final key = event.snapshot.key!;
      removeAppointment(key);
    });

    authService.addRealtimeDbListener(patientSubscription);
    authService.addRealtimeDbListener(patientUpdateSubscription);
    authService.addRealtimeDbListener(patientRemoveSubscription);
    authService.addRealtimeDbListener(doctorSubscription);
    authService.addRealtimeDbListener(doctorUpdateSubscription);
    authService.addRealtimeDbListener(doctorRemoveSubscription);

    yield* streamController.stream;

    ref.onDispose(() {
      patientSubscription.cancel();
      patientUpdateSubscription.cancel();
      patientRemoveSubscription.cancel();
      doctorSubscription.cancel();
      doctorUpdateSubscription.cancel();
      doctorRemoveSubscription.cancel();
      streamController.close();
    });
  }
});


final patientDataByUidProvider = FutureProvider.family<Patient?, String>((ref, patientUid) async {
  final database = ref.read(firebaseDatabaseProvider);
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
      profileImagePublicId: data['profileImagePublicId'] ?? '',
      userType: data['userType'] ?? 'Patient',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: data['createdAt'] ?? '',
      favorites: data['favorites']??[],
      medicalRecords: data['MedicalRecords']??[],
    );
  }
  return null;
});
final appointmentsFilterOptionProvider = StateProvider<String>((ref) => 'All');

final bookingViewSelectedPatientLabelProvider = StateProvider<String>((ref) => 'My Self');
final bookingViewPatientNameProvider = StateProvider<String>((ref) => '');
final bookingViewPatientNumberProvider = StateProvider<String>((ref) => '');
final bookingViewPatientNoteProvider = StateProvider<String>((ref) => '');

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});
class BookingRepository {
  Future<void> updateBooking(AppointmentModel newAppointment) async {
    final database = FirebaseDatabase.instance.ref();
    final appointmentRef = database.child('Appointments').child(newAppointment.id);

    try {
      final updates = <String, dynamic>{};

      void addIfChanged(String key, dynamic oldVal, dynamic newVal) {
        if (oldVal != newVal) updates[key] = newVal;
      }

      final snapshot = await appointmentRef.get();
      if (!snapshot.exists) throw Exception('Appointment does not exist');
      final data = snapshot.value as Map;

      addIfChanged('date', data['date'], newAppointment.date);
      addIfChanged('timeSlot', data['timeSlot'], newAppointment.timeSlot);
      addIfChanged('slotType', data['slotType'], newAppointment.slotType);
      addIfChanged('patientNotes', data['patientNotes'], newAppointment.patientNotes);
      addIfChanged('patientName', data['patientName'], newAppointment.patientName);
      addIfChanged('patientNumber', data['patientNumber'], newAppointment.patientNumber);
      addIfChanged('patientType', data['patientType'], newAppointment.patientType);
      addIfChanged('status', data['status'], newAppointment.status);

      if (updates.isEmpty) {
        throw Exception('No changes to update');
      }

      updates['updatedAt'] = DateTime.now().toIso8601String();

      await appointmentRef.update(updates);
      logDebug('Updated appointment with: $updates');
    } catch (e, stack) {
      logDebug('Error during updateBooking: $e');
      logDebug('Stack: $stack');
      rethrow;
    }
  }
  Future<void> createBooking(AppointmentModel appointment) async {
    final database = FirebaseDatabase.instance.ref();
    logDebug('Creating appointment: ${appointment.toMap()}');
    await database.child('Appointments').child(appointment.id).set(appointment.toMap());
  }
  Future<void> cancelBooking(String appointmentId, String updatedAt) async {
    final database = FirebaseDatabase.instance.ref();
    logDebug('Cancelling appointment: $appointmentId');
    await database.child('Appointments').child(appointmentId).update({
      'status': 'cancelled',
      'updatedAt': updatedAt,
    });
  }
}