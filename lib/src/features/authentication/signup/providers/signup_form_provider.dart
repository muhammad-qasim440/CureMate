
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
final locationLatitudeProvider = StateProvider<double>((ref) => 0.0);
final locationLongitudeProvider = StateProvider<double>((ref) => 0.0);
final docConsultancyFeeProvider = StateProvider<int>((ref) => 0);
final docQualificationProvider = StateProvider<String>((ref) => '');
final docHospitalProvider = StateProvider<String>((ref) => '');
final docYearsOfExperienceProvider = StateProvider<String>((ref) => '');
final hidePasswordProvider = StateProvider<bool>((ref) => true);
final isSigningUpProvider = StateProvider<bool>((ref) => false);

final availableDaysProvider = StateProvider<List<String>>((ref) => []);
final morningAvailabilityProvider = StateProvider<bool>((ref) => false);
final afternoonAvailabilityProvider = StateProvider<bool>((ref) => false);
final eveningAvailabilityProvider = StateProvider<bool>((ref) => false);