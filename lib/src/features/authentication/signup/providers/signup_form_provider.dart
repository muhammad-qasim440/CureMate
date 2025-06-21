
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';


final userProfileProvider = StateProvider<XFile?>((ref) => null);
final profileImageURLProvider = StateProvider<String>((ref) => '');
final emailProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final fullNameProvider = StateProvider<String>((ref) => '');
final phoneNumberProvider = StateProvider<String>((ref) => '');
final dateOfBirthProvider = StateProvider<String>((ref) => '');
final cityProvider = StateProvider<String>((ref) => '');
final ageProvider = StateProvider<int>((ref) => 0);
final locationLatitudeProvider = StateProvider<double>((ref) => 0.0);
final locationLongitudeProvider = StateProvider<double>((ref) => 0.0);
final docConsultancyFeeProvider = StateProvider<int>((ref) => 0);
final docQualificationProvider = StateProvider<String>((ref) => '');
final docHospitalProvider = StateProvider<String>((ref) => '');
final docYearsOfExperienceProvider = StateProvider<String>((ref) => '');
final hidePasswordProvider = StateProvider<bool>((ref) => true);
final isSigningUpProvider = StateProvider<bool>((ref) => false);

// New provider for day-slot configurations
final daySlotConfigsProvider = StateProvider<List<Map<String, dynamic>>>((ref) => []);

// Temporary providers for building a single day-slot configuration
final tempDayProvider = StateProvider<String>((ref) => '');
final tempMorningAvailabilityProvider = StateProvider<bool>((ref) => false);
final tempMorningStartTimeProvider = StateProvider<String>((ref) => '');
final tempMorningEndTimeProvider = StateProvider<String>((ref) => '');
final tempAfternoonAvailabilityProvider = StateProvider<bool>((ref) => false);
final tempAfternoonStartTimeProvider = StateProvider<String>((ref) => '');
final tempAfternoonEndTimeProvider = StateProvider<String>((ref) => '');
final tempEveningAvailabilityProvider = StateProvider<bool>((ref) => false);
final tempEveningStartTimeProvider = StateProvider<String>((ref) => '');
final tempEveningEndTimeProvider = StateProvider<String>((ref) => '');
final tempFullDayProvider = StateProvider<bool>((ref) => false);
final tempFullDayStartTimeProvider = StateProvider<String>((ref) => '');
final tempFullDayEndTimeProvider = StateProvider<String>((ref) => '');