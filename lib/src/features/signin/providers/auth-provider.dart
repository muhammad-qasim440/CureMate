import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:curemate/const/app_strings.dart';
import 'package:curemate/src/features/signup/providers/signup_form_provider.dart';
import 'package:curemate/src/shared/providers/drop_down_provider/custom_drop_down_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../signup/helpers/upload_profile_image_to_cloudinary.dart';

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
        throw Exception('Wrong password provided.');
      } else {
        throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      throw Exception('An error occurred during sign-in: $e');
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
}
