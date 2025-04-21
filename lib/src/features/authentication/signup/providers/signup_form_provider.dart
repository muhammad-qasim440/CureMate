import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class SignUpFormState {
  final String? userType;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController phoneNumberController;
  final TextEditingController categoryController;
  final TextEditingController qualificationController;
  final TextEditingController yearsOfExperienceController;
  final TextEditingController fullNameController;
  final TextEditingController dobController;
  final TextEditingController cityController;
  final XFile? profileImage;

  SignUpFormState({
     this.userType,
    required this.emailController,
    required this.passwordController,
    required this.phoneNumberController,
    required this.categoryController,
    required this.qualificationController,
    required this.yearsOfExperienceController,
    required this.fullNameController,
    required this.dobController,
    required this.cityController,
    this.profileImage,
  });

  SignUpFormState copyWith({
    XFile? profileImage,
  }) {
    return SignUpFormState(
      userType: userType,
      emailController: emailController,
      passwordController: passwordController,
      phoneNumberController: phoneNumberController,
      categoryController: categoryController,
      qualificationController: qualificationController,
      yearsOfExperienceController: yearsOfExperienceController,
      fullNameController: fullNameController,
      dobController: dobController,
      cityController: cityController,
      profileImage: profileImage ?? this.profileImage,
    );
  }

  void clearForm() {
    emailController.clear();
    passwordController.clear();
    phoneNumberController.clear();
    categoryController.clear();
    qualificationController.clear();
    yearsOfExperienceController.clear();
    fullNameController.clear();
    dobController.clear();
    cityController.clear();
  }

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    phoneNumberController.dispose();
    categoryController.dispose();
    qualificationController.dispose();
    yearsOfExperienceController.dispose();
    fullNameController.dispose();
    dobController.dispose();
    cityController.dispose();
  }
}

class SignUpFormController extends StateNotifier<SignUpFormState> {
  SignUpFormController()
      : super(
    SignUpFormState(
      emailController: TextEditingController(),
      passwordController: TextEditingController(),
      phoneNumberController: TextEditingController(),
      categoryController: TextEditingController(),
      qualificationController: TextEditingController(),
      yearsOfExperienceController: TextEditingController(),
      fullNameController: TextEditingController(),
      dobController: TextEditingController(),
      cityController: TextEditingController(),
    ),
  );

  void setProfileImage(XFile image) {
    state = state.copyWith(profileImage: image);
  }

  @override
  void dispose() {
    state.dispose();
    super.dispose();
  }
}

final signUpFormProvider =
StateNotifierProvider<SignUpFormController, SignUpFormState>((ref) {
  return SignUpFormController();
});

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

