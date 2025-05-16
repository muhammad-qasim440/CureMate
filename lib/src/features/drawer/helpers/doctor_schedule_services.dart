import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/debug_print.dart';
import '../providers/doctor_schedule_providers.dart';
import '../../../shared/providers/check_internet_connectivity_provider.dart';

class DoctorScheduleService {
  final dynamic ref;

  DoctorScheduleService(this.ref);

  /// Fetches doctor's availability from Firebase for the FutureProvider.
  Future<List<Map<String, dynamic>>> fetchAvailability() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('User not authenticated');
    }

    final refDb = FirebaseDatabase.instance
        .ref()
        .child('Doctors')
        .child(user.uid)
        .child('availability');

    try {
      final snapshot = await refDb.get();
      if (!snapshot.exists || snapshot.value == null) {
        logDebug('No availability data found for user ${user.uid}');
        return [];
      }
      logDebug('Raw Firebase data: ${snapshot.value}');
      final rawData = snapshot.value;
      if (rawData is List<dynamic>) {
        final result = rawData.asMap().entries.map((entry) {
          final index = entry.key;
          final value = entry.value;
          if (value is Map) {
            try {
              final map = Map<String, dynamic>.from(
                value.map((k, v) => MapEntry(k.toString(), v)),
              );
              if (!map.containsKey('day') || map['day'] is! String) {
                logDebug('Invalid data at index $index: Missing or invalid day');
                return null;
              }
              if (map['isFullDay'] == true) {
                if (!map.containsKey('startTime') ||
                    !map.containsKey('endTime') ||
                    map['startTime'] is! String ||
                    map['endTime'] is! String) {
                  logDebug(
                      'Invalid full-day data at index $index: Missing or invalid times');
                  return null;
                }
              } else if (map['isFullDay'] == false) {
                if (!map.containsKey('morning') ||
                    !map.containsKey('afternoon') ||
                    !map.containsKey('evening')) {
                  logDebug(
                      'Invalid partial-day data at index $index: Missing time slots');
                  return null;
                }
                for (var slot in ['morning', 'afternoon', 'evening']) {
                  if (map[slot] is! Map) {
                    logDebug('Invalid $slot data at index $index: Not a map');
                    return null;
                  }
                  final slotMap = map[slot] as Map;
                  if (!slotMap.containsKey('isAvailable') ||
                      !slotMap.containsKey('startTime') ||
                      !slotMap.containsKey('endTime')) {
                    logDebug('Invalid $slot data at index $index: Missing fields');
                    return null;
                  }
                }
              } else {
                logDebug('Invalid isFullDay at index $index: ${map['isFullDay']}');
                return null;
              }

              logDebug('Validated data at index $index: $map');
              return map;
            } catch (e) {
              logDebug('Error parsing data at index $index: $e');
              return null;
            }
          } else {
            logDebug('Invalid data at index $index: Expected Map, got $value');
            return null;
          }
        }).whereType<Map<String, dynamic>>().toList();

        logDebug('Final fetched availability: $result');
        return result;
      } else {
        throw Exception('Expected a List, but got ${rawData.runtimeType}');
      }
    } catch (e) {
      logDebug('Error fetching availability: $e');
      rethrow;
    }
  }

  /// Loads doctor's availability and updates scheduleConfigsProvider.
  Future<void> loadAvailability() async {
    final data = await fetchAvailability();
    logDebug('Setting scheduleConfigsProvider: $data');
    ref.read(scheduleConfigsProvider.notifier).state = data;
  }

  /// Validates input for adding or updating a slot.
  bool isInputValid() {
    final day = ref.read(tempDayProvider);
    final isFullDay = ref.read(tempFullDayProvider);
    final fullDayStart = ref.read(tempFullDayStartTimeProvider);
    final fullDayEnd = ref.read(tempFullDayEndTimeProvider);
    final morningAvailable = ref.read(tempMorningAvailabilityProvider);
    final morningStart = ref.read(tempMorningStartTimeProvider);
    final morningEnd = ref.read(tempMorningEndTimeProvider);
    final afternoonAvailable = ref.read(tempAfternoonAvailabilityProvider);
    final afternoonStart = ref.read(tempAfternoonStartTimeProvider);
    final afternoonEnd = ref.read(tempAfternoonEndTimeProvider);
    final eveningAvailable = ref.read(tempEveningAvailabilityProvider);
    final eveningStart = ref.read(tempEveningStartTimeProvider);
    final eveningEnd = ref.read(tempEveningEndTimeProvider);

    if (day.isEmpty) return false;
    if (isFullDay) {
      return _isValidTimeRange(fullDayStart, fullDayEnd);
    } else {
      if (!morningAvailable && !afternoonAvailable && !eveningAvailable) {
        return false;
      }
      if (morningAvailable && !_isValidTimeRange(morningStart, morningEnd)) {
        return false;
      }
      if (afternoonAvailable && !_isValidTimeRange(afternoonStart, afternoonEnd)) {
        return false;
      }
      if (eveningAvailable && !_isValidTimeRange(eveningStart, eveningEnd)) {
        return false;
      }
      return true;
    }
  }

  /// Validates a time range to ensure end time is after start time.
  bool _isValidTimeRange(String startTime, String endTime) {
    if (startTime.isEmpty || endTime.isEmpty) return false;
    try {
      final format = DateFormat('h:mm a');
      final start = format.parse(startTime);
      final end = format.parse(endTime);
      return end.isAfter(start) && end.difference(start).inMinutes > 0;
    } catch (e) {
      return false;
    }
  }

  /// Checks if a time range qualifies as a full-day slot.
  bool _isFullDaySlot(String startTime, String endTime) {
    try {
      final format = DateFormat('h:mm a');
      final start = format.parse(startTime);
      final end = format.parse(endTime);
      final duration = end.difference(start).inHours;
      final startHour = start.hour;
      final endHour = end.hour;
      return duration >= 8 || (startHour < 12 && endHour >= 16);
    } catch (e) {
      return false;
    }
  }

  /// Merges multiple slots into a single config, combining overlapping slots if possible.
  Map<String, dynamic>? mergeSlots({
    required bool morningAvailable,
    required String morningStart,
    required String morningEnd,
    required bool afternoonAvailable,
    required String afternoonStart,
    required String afternoonEnd,
    required bool eveningAvailable,
    required String eveningStart,
    required String eveningEnd,
  }) {
    final format = DateFormat('h:mm a');
    List<Map<String, dynamic>> slots = [];

    if (morningAvailable && morningStart.isNotEmpty && morningEnd.isNotEmpty) {
      slots.add({
        'start': format.parse(morningStart),
        'end': format.parse(morningEnd),
      });
    }
    if (afternoonAvailable &&
        afternoonStart.isNotEmpty &&
        afternoonEnd.isNotEmpty) {
      slots.add({
        'start': format.parse(afternoonStart),
        'end': format.parse(afternoonEnd),
      });
    }
    if (eveningAvailable && eveningStart.isNotEmpty && eveningEnd.isNotEmpty) {
      slots.add({
        'start': format.parse(eveningStart),
        'end': format.parse(eveningEnd),
      });
    }

    if (slots.isEmpty) return null;

    slots.sort((a, b) => a['start'].compareTo(b['start']));
    List<Map<String, dynamic>> merged = [];
    var current = slots[0];
    for (var i = 1; i < slots.length; i++) {
      if (slots[i]['start'].isBefore(current['end']) ||
          slots[i]['start'] == current['end']) {
        current['end'] = slots[i]['end'].isAfter(current['end'])
            ? slots[i]['end']
            : current['end'];
      } else {
        merged.add(current);
        current = slots[i];
      }
    }
    merged.add(current);

    if (merged.length == 1 &&
        _isFullDaySlot(
            format.format(merged[0]['start']), format.format(merged[0]['end']))) {
      return {
        'isFullDay': true,
        'startTime': format.format(merged[0]['start']),
        'endTime': format.format(merged[0]['end']),
      };
    }

    return {
      'isFullDay': false,
      'morning': {
        'isAvailable': morningAvailable,
        'startTime': morningStart,
        'endTime': morningEnd,
      },
      'afternoon': {
        'isAvailable': afternoonAvailable,
        'startTime': afternoonStart,
        'endTime': afternoonEnd,
      },
      'evening': {
        'isAvailable': eveningAvailable,
        'startTime': eveningStart,
        'endTime': eveningEnd,
      },
    };
  }

  /// Adds or updates a slot configuration and saves to Firebase.
  Future<String?> addOrUpdateConfig({required String? editingDay}) async {
    if (!isInputValid()) return 'Invalid input';
    final day = ref.read(tempDayProvider);
    final isFullDay = ref.read(tempFullDayProvider);
    final fullDayStart = ref.read(tempFullDayStartTimeProvider);
    final fullDayEnd = ref.read(tempFullDayEndTimeProvider);
    final morningAvailable = ref.read(tempMorningAvailabilityProvider);
    final morningStart = ref.read(tempMorningStartTimeProvider);
    final morningEnd = ref.read(tempMorningEndTimeProvider);
    final afternoonAvailable = ref.read(tempAfternoonAvailabilityProvider);
    final afternoonStart = ref.read(tempAfternoonStartTimeProvider);
    final afternoonEnd = ref.read(tempAfternoonEndTimeProvider);
    final eveningAvailable = ref.read(tempEveningAvailabilityProvider);
    final eveningStart = ref.read(tempEveningStartTimeProvider);
    final eveningEnd = ref.read(tempEveningEndTimeProvider);

    Map<String, dynamic> config;

    if (isFullDay) {
      config = {
        'day': day,
        'isFullDay': true,
        'startTime': fullDayStart,
        'endTime': fullDayEnd,
      };
    } else {
      final configData = mergeSlots(
        morningAvailable: morningAvailable,
        morningStart: morningStart,
        morningEnd: morningEnd,
        afternoonAvailable: afternoonAvailable,
        afternoonStart: afternoonStart,
        afternoonEnd: afternoonEnd,
        eveningAvailable: eveningAvailable,
        eveningStart: eveningStart,
        eveningEnd: eveningEnd,
      );

      if (configData == null) return 'Invalid configuration';
      config = {'day': day, ...configData};
    }

    final currentConfigs = ref.read(scheduleConfigsProvider) as List<Map<String, dynamic>>;
    if (editingDay == null && currentConfigs.any((c) => c['day'] == day)) {
      return '$day is already added. Please edit the existing configuration.';
    }

    final updatedConfigs = editingDay != null
        ? [
      ...currentConfigs.where((c) => c['day'] != editingDay),
      config,
    ]
        : [
      ...currentConfigs,
      config,
    ];

    /// Save to Firebase and update local state only on success
    final error = await updateSchedule(updatedConfigs);
    if (error != null) {
      return error;
    }

    ref.read(scheduleConfigsProvider.notifier).state = updatedConfigs;
    resetTempProviders();
    return null;
  }

  /// Updates the schedule in Firebase.
  Future<String?> updateSchedule(List<Map<String, dynamic>> updatedConfigs) async {
    logDebug('updateSchedule: isUpdatingSchedule = ${ref.read(isUpdatingScheduleProvider)}');
    if (ref.read(isUpdatingScheduleProvider)) return 'Update in progress';
    ref.read(isUpdatingScheduleProvider.notifier).state = true;
    logDebug('updateSchedule: Set isUpdatingSchedule to true');
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final hasInternet = await ref.read(checkInternetConnectionProvider.future);
      if (!hasInternet) {
        ref.read(isUpdatingScheduleProvider.notifier).state = false;
        logDebug('updateSchedule: No internet, reset isUpdatingSchedule to false');
        return 'No internet connection. Please check your network.';
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ref.read(isUpdatingScheduleProvider.notifier).state = false;
        logDebug('updateSchedule: No user, reset isUpdatingSchedule to false');
        return 'User not authenticated.';
      }

      await FirebaseDatabase.instance
          .ref()
          .child('Doctors')
          .child(user.uid)
          .child('availability')
          .set(updatedConfigs);

      logDebug('updateSchedule: Success');
      return null;
    } catch (e) {
      ref.read(isUpdatingScheduleProvider.notifier).state = false;
      logDebug('updateSchedule: Error $e, reset isUpdatingSchedule to false');
      return 'Failed to update schedule: $e';
    } finally {
      ref.read(isUpdatingScheduleProvider.notifier).state = false;
      logDebug('updateSchedule: Finally, reset isUpdatingSchedule to false');
    }
  }

  /// Deletes a day's availability.
  Future<String?> deleteConfig(String day, {String? editingDay}) async {
    if (ref.read(isUpdatingScheduleProvider)) return 'Update in progress';
    try {
      final scheduleConfigs = ref.read(scheduleConfigsProvider);
      final updatedConfigs = scheduleConfigs.where((c) => c['day'] != day).toList();

      final error = await updateSchedule(updatedConfigs);
      if (error != null) {
        return error;
      }

      ref.read(scheduleConfigsProvider.notifier).state = updatedConfigs;
      if (editingDay == day) {
        resetTempProviders();
      }
      return null;
    } catch (e) {
      return 'Failed to delete $day: $e';
    }
  }

  /// Loads a configuration for editing.
  void loadConfigForEdit(Map<String, dynamic> config) {
    ref.read(tempDayProvider.notifier).state = config['day']?.toString() ?? '';
    if (config['isFullDay'] == true) {
      ref.read(tempFullDayProvider.notifier).state = true;
      ref.read(tempFullDayStartTimeProvider.notifier).state =
          config['startTime']?.toString() ?? '';
      ref.read(tempFullDayEndTimeProvider.notifier).state =
          config['endTime']?.toString() ?? '';
      ref.read(tempMorningAvailabilityProvider.notifier).state = false;
      ref.read(tempMorningStartTimeProvider.notifier).state = '';
      ref.read(tempMorningEndTimeProvider.notifier).state = '';
      ref.read(tempAfternoonAvailabilityProvider.notifier).state = false;
      ref.read(tempAfternoonStartTimeProvider.notifier).state = '';
      ref.read(tempAfternoonEndTimeProvider.notifier).state = '';
      ref.read(tempEveningAvailabilityProvider.notifier).state = false;
      ref.read(tempEveningStartTimeProvider.notifier).state = '';
      ref.read(tempEveningEndTimeProvider.notifier).state = '';
    } else {
      ref.read(tempFullDayProvider.notifier).state = false;
      ref.read(tempFullDayStartTimeProvider.notifier).state = '';
      ref.read(tempFullDayEndTimeProvider.notifier).state = '';
      ref.read(tempMorningAvailabilityProvider.notifier).state =
          config['morning']?['isAvailable'] == true;
      ref.read(tempMorningStartTimeProvider.notifier).state =
          config['morning']?['startTime']?.toString() ?? '';
      ref.read(tempMorningEndTimeProvider.notifier).state =
          config['morning']?['endTime']?.toString() ?? '';
      ref.read(tempAfternoonAvailabilityProvider.notifier).state =
          config['afternoon']?['isAvailable'] == true;
      ref.read(tempAfternoonStartTimeProvider.notifier).state =
          config['afternoon']?['startTime']?.toString() ?? '';
      ref.read(tempAfternoonEndTimeProvider.notifier).state =
          config['afternoon']?['endTime']?.toString() ?? '';
      ref.read(tempEveningAvailabilityProvider.notifier).state =
          config['evening']?['isAvailable'] == true;
      ref.read(tempEveningStartTimeProvider.notifier).state =
          config['evening']?['startTime']?.toString() ?? '';
      ref.read(tempEveningEndTimeProvider.notifier).state =
          config['evening']?['endTime']?.toString() ?? '';
    }
  }

  /// Resets temporary providers to their initial state.
  void resetTempProviders() {
    ref.read(tempDayProvider.notifier).state = '';
    ref.read(tempFullDayProvider.notifier).state = false;
    ref.read(tempFullDayStartTimeProvider.notifier).state = '';
    ref.read(tempFullDayEndTimeProvider.notifier).state = '';
    ref.read(tempMorningAvailabilityProvider.notifier).state = false;
    ref.read(tempMorningStartTimeProvider.notifier).state = '';
    ref.read(tempMorningEndTimeProvider.notifier).state = '';
    ref.read(tempAfternoonAvailabilityProvider.notifier).state = false;
    ref.read(tempAfternoonStartTimeProvider.notifier).state = '';
    ref.read(tempAfternoonEndTimeProvider.notifier).state = '';
    ref.read(tempEveningAvailabilityProvider.notifier).state = false;
    ref.read(tempEveningStartTimeProvider.notifier).state = '';
    ref.read(tempEveningEndTimeProvider.notifier).state = '';
  }
}