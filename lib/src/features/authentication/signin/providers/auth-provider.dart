import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curemate/const/app_strings.dart';
import 'package:curemate/src/shared/providers/drop_down_provider/custom_drop_down_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../patient/providers/patient_providers.dart';
import '../../../patient/views/patient_main_view.dart';
import '../../../splash/providers/splash_provider.dart';
import '../../reset_password/providers/password_reset_providers.dart';
import '../../signup/helpers/upload_profile_image_to_cloudinary.dart';
import '../../signup/providers/signup_form_provider.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
  (ref) => FirebaseAuth.instance,
);
final firebaseDatabaseProvider = Provider<DatabaseReference>(
  (ref) => FirebaseDatabase.instance.ref(),
);
final fireStoreProvider = Provider<FirebaseFirestore>(
  (ref) => FirebaseFirestore.instance,
);

final authProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  Future<String> signUp() async {
    try {
      final auth = _ref.read(firebaseAuthProvider);
      final database = _ref.read(firebaseDatabaseProvider);
      final userType = _ref.read(customDropDownProvider(AppStrings.userTypes));
      final profileImage = _ref.read(userProfileProvider);
      final email = _ref.read(emailProvider);
      final password = _ref.read(passwordProvider);
      final fullName = _ref.read(fullNameProvider);
      final phoneNumber = _ref.read(phoneNumberProvider);
      final dateOfBirth = _ref.read(dateOfBirthProvider);
      final city = _ref.read(customDropDownProvider(AppStrings.cities));
      final latitude = _ref.read(locationLatitudeProvider);
      final longitude = _ref.read(locationLongitudeProvider);
      final docConsultationFee=_ref.read(docConsultancyFeeProvider);
      final docCategory = _ref.read(customDropDownProvider(AppStrings.docCategories));
      final docQualification = _ref.read(docQualificationProvider);
      final docExperience = _ref.read(docYearsOfExperienceProvider);

      // Create user
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      String uid = user!.uid;
      String profileImageUrl = '';

        String userTypePath =
        userType.selected == 'Doctor' ? 'Doctors' : 'Patients';

        Map<String, dynamic> userData = {
          'uid': uid,
          'email': email,
          'fullName': fullName,
          'phoneNumber': phoneNumber,
          'profileImageUrl': profileImageUrl,
          'dob': dateOfBirth,
          'city': city.selected,
          'latitude': latitude,
          'longitude': longitude,
          'userType': userType.selected,
          'createdAt': DateTime.now().toIso8601String(),
        };

        if (userType.selected == 'Doctor') {
          userData.addAll({
            'qualification': docQualification,
            'category': docCategory.selected,
            'yearsOfExperience': docExperience,
            'consultationFee':docConsultationFee,
            'totalReviews': 0,
            'averageRatings': 0.0,
            'totalPatientConsulted': 0,
          });
        }

        await database.child(userTypePath).child(uid).set(userData);

        if (profileImage != null) {
          String? cloudinaryImageUrl = await uploadImageToCloudinary(File(profileImage.path));
          if (cloudinaryImageUrl != null) {
            await database.child(userTypePath).child(uid).update({
              'profileImageUrl': cloudinaryImageUrl,
            });
          }
        }

        return 'Account created successfully!';


    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors
      if (e.code == 'email-already-in-use') {
        return 'An account already exists with this email.';
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      } else if (e.code == 'weak-password') {
        return 'The password is too weak.';
      } else {
        return 'Authentication failed: ${e.message}';
      }
    } catch (e) {
      return 'An unexpected error occurred: ${e.toString()}';
    }
  }

  final Ref _ref;
  AuthService(this._ref);
  Future<Map<String, dynamic>> signIn({required String email, required String password}) async {
    try {
      final auth = _ref.read(firebaseAuthProvider);
      final database = _ref.read(firebaseDatabaseProvider);

      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        String uid = user.uid;
        String userType = '';

        // Check if user exists in Doctors node
        final doctorSnapshot = await database.child('Doctors').child(uid).get();
        if (doctorSnapshot.exists) {
          userType = 'Doctor';
        } else {
          // Check if user exists in Patients node
          final patientSnapshot = await database.child('Patients').child(uid).get();
          if (patientSnapshot.exists) {
            userType = 'Patient';
          }
        }

        return {
          'success': true,
          'message': 'Signed in successfully!',
          'userType': userType,
          'uid': uid
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to sign in. Please try again.',
          'userType': '',
          'uid': ''
        };
      }
    } on FirebaseAuthException catch (e) {
      // Handle Firebase Auth errors
      String errorMessage = 'Authentication failed';

      if (e.code == 'user-not-found') {
        errorMessage = 'No account found with this email address.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Incorrect password. Please try again.';
      } else if (e.code == 'user-disabled') {
        errorMessage = 'This account has been disabled. Please contact support.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'Please enter a valid email address.';
      } else if (e.code == 'too-many-requests') {
        errorMessage = 'Too many failed login attempts. Please try again later.';
      } else {
        errorMessage = 'Authentication failed: ${e.message}';
      }

      return {
        'success': false,
        'message': errorMessage,
        'userType': '',
        'uid': ''
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
        'userType': '',
        'uid': ''
      };
    }
  }
  Future<Map<String, dynamic>> resetPassword() async {
    final auth = _ref.read(firebaseAuthProvider);
    final email=_ref.read(forgotPasswordEmailProvider);
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      return {
        'success': false,
        'message': 'Please enter your email address.',
      };
    }

    try {
      await auth.sendPasswordResetEmail(email: trimmedEmail);
      _ref.read(forgotPasswordEmailProvider.notifier).state = '';
      return {
        'success': true,
        'message': 'A password reset link has been sent to your email.',
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Failed to send password reset email.';

      if (e.code == 'user-not-found') {
        errorMessage = 'No user found with this email address.';
      } else if (e.code == 'invalid-email') {
        errorMessage = 'The provided email address is not valid.';
      } else if (e.code == 'missing-email') {
        errorMessage = 'Email address is required.';
      } else {
        errorMessage = e.message ?? errorMessage;
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again later.',
      };
    }
  }


  Future<void> logout(BuildContext context) async {
    final auth = _ref.read(firebaseAuthProvider);

    try {
      await auth.signOut();

      if (auth.currentUser == null) {
        CustomSnackBarWidget.show(
          backgroundColor: AppColors.gradientGreen,
          context: context,
          text: 'You have been logged out successfully.',
        );
        _ref.read(bottomNavIndexProvider.notifier).state = 0;
        _ref.invalidate(currentSignInPatientDataProvider);
        _ref.invalidate(doctorsProvider);
        _ref.invalidate(favoriteDoctorUidsProvider);
        _ref.read(splashProvider.notifier).checkAuthUser();

      } else {
        CustomSnackBarWidget.show(
          backgroundColor: Colors.red,
          context: context,
          text: 'Logout failed. You are still signed in.',
        );
      }
    } catch (e) {
      CustomSnackBarWidget.show(
        backgroundColor: Colors.red,
        context: context,
        text: 'Failed to log out. Please try again.',
      );
    }
  }
}
