import 'package:curemate/src/features/appointments/models/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../const/app_strings.dart';
import '../../../shared/providers/drop_down_provider/custom_drop_down_provider.dart';
import '../../patient/providers/patient_providers.dart';
import '../providers/appointments_providers.dart';

List<AppointmentModel> filterAndSortAppointments({
  required List<AppointmentModel> appointments,
  required String filterOption,
  required String dateFilter,
  String? groupByField,
  String? userUid,
}) {
  List<AppointmentModel> filteredAppointments = appointments.where((app) {
    if (app.status == 'cancelled') return false;

    /// Doctor-specific filter (for DoctorAppointmentsView)
    if (userUid != null && app.doctorUid != userUid) return false;

    /// Status Filter
    if (filterOption != 'All' && app.status.toLowerCase() != filterOption.toLowerCase()) {
      return false;
    }

    /// Date Filter
    final appointmentDate = DateFormat('yyyy-MM-dd').parse(app.date);
    final now = DateTime.now();
    switch (dateFilter) {
      case 'Today':
        if (!_isSameDay(appointmentDate, now)) return false;
        break;
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        if (appointmentDate.isBefore(weekStart) || appointmentDate.isAfter(weekEnd)) {
          return false;
        }
        break;
      case 'This Month':
        if (appointmentDate.month != now.month || appointmentDate.year != now.year) {
          return false;
        }
        break;
    }

    return true;
  }).toList();

  if (groupByField != null) {
    /// Group by the specified field (doctorUid or patientUid) and sort by updatedAt/createdAt
    filteredAppointments.sort((a, b) {
      /// Compare by groupByField (doctorUid or patientUid)
      final groupCompare = groupByField == 'doctorUid'
          ? a.doctorUid.compareTo(b.doctorUid)
          : a.patientUid.compareTo(b.patientUid);
      if (groupCompare != 0) return groupCompare;

      /// Sort by updatedAt or createdAt within the group
      final aDate = DateTime.tryParse(
        (a.updatedAt?.isNotEmpty ?? false) ? a.updatedAt! : a.createdAt,
      );
      final bDate = DateTime.tryParse(
        (b.updatedAt?.isNotEmpty ?? false) ? b.updatedAt! : b.createdAt,
      );

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return bDate.compareTo(aDate); /// Recent to oldest
    });
  } else {
    /// Sort by updatedAt or createdAt only
    filteredAppointments.sort((a, b) {
      final aDate = DateTime.tryParse(
        (a.updatedAt?.isNotEmpty ?? false) ? a.updatedAt! : a.createdAt,
      );
      final bDate = DateTime.tryParse(
        (b.updatedAt?.isNotEmpty ?? false) ? b.updatedAt! : b.createdAt,
      );

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return bDate.compareTo(aDate); /// Recent to oldest
    });
  }

  return filteredAppointments;
}

bool _isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

void prefillPatientDataIfMySelf({
  required WidgetRef ref,
  required Patient currentUser,
  required bool hasPrefilled,
  required ValueChanged<bool> onPrefillChanged,
}) {
  final selectedLabel =
  ref.watch(bookingViewSelectedPatientLabelProvider).toString();

  if (selectedLabel == 'My Self' && !hasPrefilled) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingViewPatientNameProvider.notifier).state =
          currentUser.fullName ?? '';
      ref.read(bookingViewPatientAgeProvider.notifier).state =
          currentUser.age ?? 0;
      ref.read(bookingViewPatientNumberProvider.notifier).state =
          currentUser.phoneNumber ?? '';
      ref.read(customDropDownProvider(AppStrings.genders).notifier).setSelected(
          currentUser.gender ?? '');
      onPrefillChanged(true); // Update hasPrefilled to true
    });
  } else if (selectedLabel != 'My Self' && hasPrefilled) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingViewPatientNameProvider.notifier).state = '';
      ref.read(bookingViewPatientAgeProvider.notifier).state = 0;
      ref.read(bookingViewPatientNumberProvider.notifier).state = '';
      ref.invalidate(customDropDownProvider(AppStrings.genders));
      onPrefillChanged(false); // Update hasPrefilled to false
    });
  }
}