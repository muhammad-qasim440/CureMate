
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
final docYearsOfExperienceProvider = StateProvider<String>((ref) => '');
final hidePasswordProvider = StateProvider<bool>((ref) => true);
final isSigningUpProvider = StateProvider<bool>((ref) => false);

