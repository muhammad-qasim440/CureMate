
// ConfirmButtonWidgetimport 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../../core/utils/debug_print.dart';
import '../../../router/nav.dart';
import '../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../patient/providers/patient_providers.dart';
import '../models/appointment_model.dart';
import '../providers/booking_providers.dart';
import '../views/confirmation_view.dart';
import '../views/select_time_view.dart';

class ConfirmButtonWidget extends ConsumerWidget {
  final Doctor doctor;
  final AppointmentModel? appointment;

  const ConfirmButtonWidget({
    super.key,
    required this.doctor,
    this.appointment,
  });

  Future<void> _scheduleNotification(
      BuildContext context,
      AppointmentModel appointment,
      String reminderTime,
      ) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'appointment_channel',
      'Appointment Reminders',
      channelDescription: 'Notifications for appointment reminders',
      importance: Importance.max,
      priority: Priority.high,
    );
    const platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    try {
      final dateFormat = DateFormat('yyyy-MM-dd');
      final timeFormat = DateFormat('hh:mm a');
      final appointmentDate = dateFormat.parse(appointment.date);
      final appointmentTime = timeFormat.parse(appointment.timeSlot);
      final appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        appointmentTime.hour,
        appointmentTime.minute,
      );

      final reminderMinutes = int.parse(reminderTime.replaceAll(' min', ''));
      final notificationTime = appointmentDateTime.subtract(Duration(minutes: reminderMinutes));

      if (notificationTime.isBefore(DateTime.now())) {
        logDebug('Notification time is in the past: $notificationTime');
        return;
      }

      final tzNotificationTime = tz.TZDateTime.from(notificationTime, tz.local);

      String statusMessage;
      if (appointment.status == 'pending') {
        statusMessage = 'Still not accepted by doctor';
      } else if (appointment.status == 'rejected') {
        statusMessage = 'Rejected by doctor';
      } else if (appointment.status == 'accepted') {
        statusMessage = 'Accepted by doctor';
      } else {
        statusMessage = 'Status: ${appointment.status}';
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        appointment.id.hashCode,
        'Appointment Reminder',
        'Your appointment with ${appointment.doctorName} is in $reminderTime at ${appointment.timeSlot} on ${appointment.date}.\n$statusMessage',
        tzNotificationTime,
        platformChannelSpecifics,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'open_tab_2',
      );
      logDebug('Scheduled notification for appointment ${appointment.id} at $tzNotificationTime');
    } catch (e) {
      logDebug('Error scheduling notification: $e');
      CustomSnackBarWidget.show(
        context: context,
        text: 'Failed to schedule reminder: $e',
      );
    }
  }

  Future<void> _cancelNotification(String appointmentId) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(appointmentId.hashCode);
    logDebug('Canceled notification for appointment $appointmentId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = appointment != null;
    final selectedDay = ref.watch(selectedDayProvider);

    return Center(
      child: CustomButtonWidget(
        text: isEditing ? 'Save Changes' : 'Confirm',
        height: ScreenUtil.scaleHeight(context, 50),
        width: double.infinity,
        backgroundColor: AppColors.gradientGreen,
        fontFamily: AppFonts.rubik,
        fontSize: FontSizes(context).size16,
        fontWeight: FontWeight.w500,
        textColor: Colors.white,
        onPressed: () async {
          logDebug('Starting onPressed for appointment editing');
          logDebug('isEditing: $isEditing');
          final selectedTimeSlot = ref.read(selectedTimeSlotProvider)?.trim();
          final selectedSlotType = ref.read(selectedSlotTypeProvider)?.trim();
          final patientName = ref.read(bookingViewPatientNameProvider).trim();
          final patientNumber = ref.read(bookingViewPatientNumberProvider).trim();
          final patientType = ref.read(bookingViewSelectedPatientLabelProvider).trim();
          final patientNotes = ref.read(bookingViewPatientNoteProvider).trim();
          final reminderTime = ref.read(reminderProvider).trim();

          logDebug('Input values:');
          logDebug('  patientName: "$patientName" (length: ${patientName.length})');
          logDebug('  patientNumber: "$patientNumber" (length: ${patientNumber.length})');
          logDebug('  patientType: "$patientType" (length: ${patientType.length})');
          logDebug('  slotType: "$selectedSlotType"');
          logDebug('  timeSlot: "$selectedTimeSlot"');
          logDebug('  patientNotes: "$patientNotes"');
          logDebug('  reminderTime: "$reminderTime"');
          logDebug('  selectedDay: ${selectedDay?.toIso8601String() ?? "null"}');

          if (selectedDay == null) {
            logDebug('Validation failed: selectedDay is null');
            CustomSnackBarWidget.show(
              context: context,
              text: 'Please select a valid date',
            );
            return;
          }
          logDebug('Validated: selectedDay is not null');

          if (selectedDay.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
            logDebug('Validation failed: selectedDay is in the past');
            CustomSnackBarWidget.show(
              context: context,
              text: 'Cannot edit or book appointments in the past',
            );
            return;
          }
          logDebug('Validated: selectedDay is not in the past');

          if (selectedTimeSlot == null || selectedTimeSlot.isEmpty) {
            logDebug('Validation failed: selectedTimeSlot is null or empty');
            CustomSnackBarWidget.show(
              context: context,
              text: 'Please select a valid time slot',
            );
            return;
          }
          logDebug('Validated: selectedTimeSlot is "$selectedTimeSlot"');

          if (selectedSlotType == null ||
              !['Morning', 'Afternoon', 'Evening', 'FullDay'].contains(selectedSlotType)) {
            logDebug('Validation failed: invalid slotType "$selectedSlotType"');
            CustomSnackBarWidget.show(
              context: context,
              text: 'Invalid slot type: ${selectedSlotType ?? "null"}',
            );
            return;
          }
          logDebug('Validated: slotType is "$selectedSlotType"');

          if (patientName.isEmpty) {
            logDebug('Validation failed: patientName is empty');
            CustomSnackBarWidget.show(
              context: context,
              text: 'Please enter a valid patient name',
            );
            return;
          }
          logDebug('Validated: patientName is "$patientName"');

          if (patientNumber.isEmpty) {
            logDebug('Validation failed: patientNumber is empty');
            CustomSnackBarWidget.show(
              context: context,
              text: 'Please enter a valid patient phone number',
            );
            return;
          }
          logDebug('Validated: patientNumber is "$patientNumber"');

          if (patientType.isEmpty) {
            logDebug('Validation failed: patientType is empty');
            CustomSnackBarWidget.show(
              context: context,
              text: 'Please select a valid patient type',
            );
            return;
          }
          logDebug('Validated: patientType is "$patientType"');

          logDebug('Checking internet connection');
          final isConnected = await ref.read(checkInternetConnectionProvider.future);
          if (!isConnected) {
            logDebug('Validation failed: no internet connection');
            CustomSnackBarWidget.show(
              context: context,
              text: 'No Internet Connection',
            );
            return;
          }
          logDebug('Validated: internet connection is available');

          logDebug('Checking authentication');
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            logDebug('Validation failed: user is not authenticated');
            CustomSnackBarWidget.show(
              context: context,
              text: 'Please sign in to book an appointment',
            );
            return;
          }
          logDebug('Authenticated user UID: ${user.uid}');

          try {
            if (isEditing) {
              logDebug('Processing edit for appointment ID: ${appointment!.id}');
              logDebug('Fetching appointment from Firebase');
              final database = FirebaseDatabase.instance.ref();
              final snapshot = await database
                  .child('Appointments')
                  .child(appointment!.id)
                  .get();
              if (!snapshot.exists) {
                logDebug('Appointment not found: ${appointment!.id}');
                CustomSnackBarWidget.show(
                  context: context,
                  text: 'Appointment not found',
                );
                AppNavigation.pop();
                return;
              }
              logDebug('Appointment fetched successfully');

              final data = snapshot.value as Map<dynamic, dynamic>;
              logDebug('Appointment data: $data');

              if (data['patientUid'] != user.uid) {
                logDebug(
                  'Authorization failed: patientUid ${data['patientUid']} does not match user UID ${user.uid}',
                );
                CustomSnackBarWidget.show(
                  context: context,
                  text: 'You are not authorized to edit this appointment',
                );
                AppNavigation.pop();
                return;
              }
              logDebug('Validated: user is authorized to edit appointment');

              if (data['status'] != 'pending') {
                logDebug(
                  'Validation failed: appointment status is "${data['status']}", expected "pending"',
                );
                CustomSnackBarWidget.show(
                  context: context,
                  text: 'Only pending appointments can be edited',
                );
                AppNavigation.pop();
                return;
              }
              logDebug('Validated: appointment status is "pending"');

              logDebug('Canceling previous notification');
              await _cancelNotification(appointment!.id);

              logDebug('Creating updated appointment model');
              final updatedAppointment = appointment!.copyWith(
                date: DateFormat('yyyy-MM-dd').format(selectedDay),
                timeSlot: selectedTimeSlot,
                slotType: selectedSlotType,
                patientNotes: patientNotes.isEmpty ? null : patientNotes,
                patientName: patientName,
                patientNumber: patientNumber,
                patientType: patientType,
                updatedAt: DateTime.now().toIso8601String(),
                reminderTime: reminderTime,
              );
              logDebug('Updated appointment data: ${updatedAppointment.toMap()}');

              logDebug('Calling updateBooking');
              await ref.read(bookingRepositoryProvider).updateBooking(updatedAppointment);
              logDebug('updateBooking completed successfully');

              logDebug('Scheduling new notification');
              await _scheduleNotification(context, updatedAppointment, reminderTime);

              CustomSnackBarWidget.show(
                context: context,
                text: 'Appointment updated successfully',
              );
              logDebug('Clearing input providers');
              ref.read(bookingViewPatientNameProvider.notifier).state = '';
              ref.read(bookingViewPatientNumberProvider.notifier).state = '';
              ref.read(bookingViewPatientNoteProvider.notifier).state = '';
              ref.read(bookingViewSelectedPatientLabelProvider.notifier).state = 'My Self';

              logDebug('Navigating to ConfirmationView');
              ConfirmationDialog.show(
                context: context,
                doctor: doctor,
                date: DateFormat('yyyy-MM-dd').format(selectedDay),
                timeSlot: selectedTimeSlot,
                isEditing: isEditing,
                appointment: updatedAppointment,
              );
            } else {
              logDebug('Processing new appointment creation');
              logDebug('Fetching patient data for UID: ${user.uid}');
              final patientData = await ref.read(patientDataByUidProvider(user.uid).future);
              if (patientData == null) {
                logDebug('Failed to load patient data');
                CustomSnackBarWidget.show(
                  context: context,
                  text: 'Failed to load patient data',
                );
                return;
              }
              logDebug('Patient data loaded: fullName=${patientData.fullName}');

              final bookerName = patientData.fullName;
              logDebug('Creating new AppointmentModel');
              final appointment = AppointmentModel(
                id: FirebaseDatabase.instance.ref().child('Appointments').push().key!,
                patientUid: user.uid,
                doctorUid: doctor.uid,
                doctorName: doctor.fullName,
                doctorCategory: doctor.category,
                hospital: doctor.hospital,
                date: DateFormat('yyyy-MM-dd').format(selectedDay),
                timeSlot: selectedTimeSlot,
                slotType: selectedSlotType,
                status: 'pending',
                consultationFee: doctor.consultationFee,
                createdAt: DateTime.now().toIso8601String(),
                patientNotes: patientNotes.isEmpty ? null : patientNotes,
                bookerName: bookerName,
                patientName: patientName,
                patientNumber: patientNumber,
                patientType: patientType,
                reminderTime: reminderTime,
              );
              logDebug('New appointment data: ${appointment.toMap()}');

              logDebug('Calling createBooking');
              await ref.read(bookingRepositoryProvider).createBooking(appointment);
              logDebug('createBooking completed successfully');

              logDebug('Scheduling notification');
              await _scheduleNotification(context, appointment, reminderTime);

              CustomSnackBarWidget.show(
                context: context,
                text: 'Booking created successfully',
              );
              logDebug('Clearing input providers');
              ref.read(bookingViewPatientNameProvider.notifier).state = '';
              ref.read(bookingViewPatientNumberProvider.notifier).state = '';
              ref.read(bookingViewPatientNoteProvider.notifier).state = '';
              ref.read(bookingViewSelectedPatientLabelProvider.notifier).state = 'My Self';

              logDebug('Navigating to ConfirmationView');
              ConfirmationDialog.show(
                context: context,
                doctor: doctor,
                date: DateFormat('yyyy-MM-dd').format(selectedDay),
                timeSlot: selectedTimeSlot,
                isEditing: isEditing,
                appointment: appointment,
              );
            }
          } catch (e) {
            logDebug('Error processing appointment: $e');
            if (e.toString().contains('No changes to update')) {
              logDebug('No changes to update');
              CustomSnackBarWidget.show(
                context: context,
                text: 'No changes to save',
              );
            } else if (e.toString().contains('permission-denied')) {
              logDebug('Failed to Update appointment: ${e.toString()}');
              CustomSnackBarWidget.show(
                context: context,
                text: 'Failed to update appointment. Ensure name, phone number, patient type, and slot type are valid and the appointment is still pending.',
              );
            } else {
              logDebug(
                'Failed to ${isEditing ? "update" : "create"} appointment: ${e.toString()}',
              );
              CustomSnackBarWidget.show(
                context: context,
                text: isEditing
                    ? 'Failed to update appointment: $e'
                    : 'Failed to create booking: $e',
              );
            }
          }
        },
      ),
    );
  }
}