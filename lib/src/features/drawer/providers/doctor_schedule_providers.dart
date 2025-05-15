import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../helpers/doctor_schedule_services.dart';

final scheduleConfigsProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);
final tempDayProvider = StateProvider<String>((ref) => '');
final tempFullDayProvider = StateProvider<bool>((ref) => false);
final tempFullDayStartTimeProvider = StateProvider<String>((ref) => '');
final tempFullDayEndTimeProvider = StateProvider<String>((ref) => '');
final tempMorningAvailabilityProvider = StateProvider<bool>((ref) => false);
final tempMorningStartTimeProvider = StateProvider<String>((ref) => '');
final tempMorningEndTimeProvider = StateProvider<String>((ref) => '');
final tempAfternoonAvailabilityProvider = StateProvider<bool>((ref) => false);
final tempAfternoonStartTimeProvider = StateProvider<String>((ref) => '');
final tempAfternoonEndTimeProvider = StateProvider<String>((ref) => '');
final tempEveningAvailabilityProvider = StateProvider<bool>((ref) => false);
final tempEveningStartTimeProvider = StateProvider<String>((ref) => '');
final tempEveningEndTimeProvider = StateProvider<String>((ref) => '');
final isUpdatingScheduleProvider = StateProvider<bool>((ref) => false);
final hasChangesProvider = StateProvider<bool>((ref) => false);
final showInputUIProvider = StateProvider<bool>((ref) => false);
final editingDayProvider = StateProvider<String?>((ref) => null);

final doctorAvailabilityProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final service = DoctorScheduleService(ref);
  return await service.fetchAvailability();
});