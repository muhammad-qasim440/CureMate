import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/debug_print.dart';
import '../../authentication/signin/providers/auth_provider.dart';
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

    void updateAppointment(String key, Map<dynamic, dynamic> value) {
      final appointment = AppointmentModel.fromMap(value, key);
      final index = appointments.indexWhere((app) => app.id == key);
      if (index == -1) {
        appointments.add(appointment);
      } else {
        appointments[index] = appointment;
      }

      // Sort appointments by updatedAt or createdAt
      appointments.sort((a, b) {
        final aDate = DateTime.tryParse((a.updatedAt?.isNotEmpty ?? false) ? a.updatedAt! : a.createdAt);
        final bDate = DateTime.tryParse((b.updatedAt?.isNotEmpty ?? false) ? b.updatedAt! : b.createdAt);
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate); // latest first
      });

      streamController.add(List.from(appointments));
    }

    void removeAppointment(String key) {
      appointments.removeWhere((app) => app.id == key);
      streamController.add(List.from(appointments));
    }

    final doctorsNode = database.child('Doctors/${user.uid}');
    final patientsNode = database.child('Patients/${user.uid}');

    final isDoctorSnap = await doctorsNode.get();
    final isPatientSnap = await patientsNode.get();

    Query? query;

    if (isDoctorSnap.exists) {
      query = appointmentsRef.orderByChild('doctorUid').equalTo(user.uid);
    } else if (isPatientSnap.exists) {
      query = appointmentsRef.orderByChild('patientUid').equalTo(user.uid);
    } else {
      yield [];
      continue;
    }

    // Initial fetch to emit empty list if no appointments exist
    final snapshot = await query.get();
    if (!snapshot.exists) {
      yield [];
    } else {
      // Pre-fill from existing data
      final data = snapshot.value as Map<dynamic, dynamic>;
      data.forEach((key, value) {
        if (value is Map<dynamic, dynamic>) {
          updateAppointment(key, value);
        }
      });
    }

    // Setup real-time listeners
    final addedSub = query.onChildAdded.listen((event) {
      final key = event.snapshot.key!;
      final value = event.snapshot.value as Map<dynamic, dynamic>;
      updateAppointment(key, value);
    });

    final changedSub = query.onChildChanged.listen((event) {
      final key = event.snapshot.key!;
      final value = event.snapshot.value as Map<dynamic, dynamic>;
      updateAppointment(key, value);
    });

    final removedSub = query.onChildRemoved.listen((event) {
      final key = event.snapshot.key!;
      removeAppointment(key);
    });

    // Attach listeners to auth service for cleanup
    authService.addRealtimeDbListener(addedSub);
    authService.addRealtimeDbListener(changedSub);
    authService.addRealtimeDbListener(removedSub);

    // Yield the stream
    yield* streamController.stream;

    // Handle provider disposal
    ref.onDispose(() {
      addedSub.cancel();
      changedSub.cancel();
      removedSub.cancel();
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
    try {
      return Patient.fromMap(data, patientUid);
    } catch (e) {
      logDebug('Error parsing patient data for UID $patientUid: $e');
      rethrow;
    }
  }
  return null;
});

final appointmentsFilterOptionProvider = StateProvider<String>((ref) => 'All');
final bookingViewSelectedPatientLabelProvider = StateProvider<String>((ref) => 'My Self');
final bookingViewPatientNameProvider = StateProvider<String>((ref) => '');
final bookingViewPatientNumberProvider = StateProvider<String>((ref) => '');
final bookingViewPatientAgeProvider = StateProvider<int>((ref) => 0);
final bookingViewPatientNoteProvider = StateProvider<String>((ref) => '');
final isUploadingAppointmentProvider = StateProvider<bool>((ref) => false);

final appointmentsDateFilterProvider = StateProvider<String>((ref) => 'All');
final appointmentsPatientFilterProvider = StateProvider<String>((ref) => 'All');
final appointmentsGroupByPatientProvider = StateProvider<bool>((ref) => false);
final appointmentsGroupByDoctorProvider = StateProvider<bool>((ref) => false);

final bookingRepositoryProvider = Provider<BookingRepository>((ref) {
  return BookingRepository();
});

class BookingRepository {
  Future<void> updateBooking(AppointmentModel newAppointment) async {
    final database = FirebaseDatabase.instance.ref();
    final appointmentRef = database.child('Appointments').child(newAppointment.id);

    try {
      logDebug('Updating appointmentxsxsxsdsdsdsdsdsd: ${newAppointment.id}');

      final updates = {
        'patientUid': newAppointment.patientUid,
        'doctorUid': newAppointment.doctorUid,
        'doctorName': newAppointment.doctorName,
        'doctorCategory': newAppointment.doctorCategory,
        'hospital': newAppointment.hospital,
        'date': newAppointment.date,
        'timeSlot': newAppointment.timeSlot,
        'slotType': newAppointment.slotType,
        'status': newAppointment.status,
        'consultationFee': newAppointment.consultationFee,
        'createdAt': newAppointment.createdAt,
        'bookerName': newAppointment.bookerName,
        'patientName': newAppointment.patientName,
        'patientNumber': newAppointment.patientNumber,
        'patientGender': newAppointment.patientGender,
        'patientAge': newAppointment.patientAge,
        'patientType': newAppointment.patientType,
        'reminderTime': newAppointment.reminderTime,
        'updatedAt': DateTime.now().toIso8601String(),
      };
      if (newAppointment.patientNotes != null) {
        updates['patientNotes'] = newAppointment.patientNotes!;
      }
      logDebug('new updates: $updates');
      await appointmentRef.update(updates);
      logDebug('Successfully updated appointment: ${newAppointment.id}');
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