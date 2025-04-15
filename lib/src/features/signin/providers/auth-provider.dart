import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curemate/const/app_strings.dart';
import 'package:curemate/src/features/doctor/home/views/doctor_home_view.dart';
import 'package:curemate/src/features/signup/providers/signup_form_provider.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/providers/drop_down_provider/custom_drop_down_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../theme/app_colors.dart';
import '../../patient/home/views/patient_home_view.dart';
import '../../signup/helpers/upload_profile_image_to_cloudinary.dart';
import '../../splash/providers/splash_provider.dart';
import '../views/signin_view.dart';

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
      final docCategory = _ref.read(docCategoryProvider);
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

      if (user != null) {
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
            'category': docCategory,
            'yearsOfExperience': docExperience,
            'totalReviews': 0,
            'averageRatings': 0.0,
            'numberOfReviews': 0,
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
      } else {
        return 'Something went wrong. Please try again.';
      }

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
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final auth = _ref.read(firebaseAuthProvider);

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Incorrect password.');
      } else {
        throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      throw Exception('An error occurred: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> handleSignIn(
      BuildContext context,
      WidgetRef ref, {
        required String email,
        required String password,
      }) async {
    final authService = ref.read(authProvider);
    String message = '';

    try {
      User? user = await authService.signIn(email: email, password: password);

      if (user == null) {
        return {
          'success': false,
          'message': 'Failed to sign in. Please try again.'
        };
      }

      final dbRef = ref.read(firebaseDatabaseProvider);
      String uid = user.uid;

      final doctorSnapshot = await dbRef.child('Doctors').child(uid).get();
      final patientSnapshot = await dbRef.child('Patients').child(uid).get();

      if (doctorSnapshot.exists) {
        return {
          'success': true,
          'userType': 'doctor',
          'message': 'Signed in successfully'
        };
      } else if (patientSnapshot.exists) {
        return {
          'success': true,
          'userType': 'patient',
          'message': 'Signed in successfully'
        };
      } else {
        return {
          'success': false,
          'message': 'User not found'
        };
      }
    } catch (e) {
      message = e.toString().replaceAll('Exception: ', '');
      return {
        'success': false,
        'message': message
      };
    }
  }

  Future<void> resetPassword({required String email}) async {
    final auth = _ref.read(firebaseAuthProvider);

    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else {
        throw Exception('Password reset error: ${e.message}');
      }
    } catch (e) {
      throw Exception('An error occurred during password reset: $e');
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
