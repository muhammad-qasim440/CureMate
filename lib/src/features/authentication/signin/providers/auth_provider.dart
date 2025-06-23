import 'dart:async';
import 'dart:io';
import 'package:curemate/const/app_strings.dart';
import 'package:curemate/src/features/authentication/signin/views/signin_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/providers/drop_down_provider/custom_drop_down_provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../core/lifecycle/observers/app_lifecycle_observer.dart';
import '../../../../app.dart';
import '../../../../shared/chat/providers/chatting_auth_providers.dart';
import '../../../../shared/chat/providers/chatting_providers.dart';
import '../../../../../core/utils/debug_print.dart';
import '../../../../shared/providers/profile_image_picker_provider/profile_image_picker_provider.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../appointments/providers/appointments_providers.dart';
import '../../../disease_diagnosis/providers/disease_diagnosis_providers.dart';
import '../../../doctor/doctor_main_view.dart';
import '../../../drawer/providers/drawer_providers.dart';
import '../../../patient/providers/patient_providers.dart';
import '../../../patient/views/patient_main_view.dart';
import '../../reset_password/providers/password_reset_providers.dart';
import '../../../../../core/utils/upload_profile_image_to_cloudinary.dart';
import '../../signup/providers/signup_form_provider.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>(
      (ref) => FirebaseAuth.instance,
);
final firebaseDatabaseProvider = Provider<DatabaseReference>(
      (ref) => FirebaseDatabase.instance.ref(),
);

final authProvider = Provider<AuthService>((ref) => AuthService(ref));

class AuthService {
  final Ref _ref;
  AuthService(this._ref);
  final List<StreamSubscription> _realtimeDbListeners = [];
  void addRealtimeDbListener(StreamSubscription subscription) {
    _realtimeDbListeners.add(subscription);
  }

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
      final gender=_ref.read(customDropDownProvider(AppStrings.genders));
      final age=_ref.read(ageProvider);
      final city = _ref.read(customDropDownProvider(AppStrings.cities));
      final latitude = _ref.read(locationLatitudeProvider);
      final longitude = _ref.read(locationLongitudeProvider);
      final docConsultationFee = _ref.read(docConsultancyFeeProvider);
      final docCategory = _ref.read(customDropDownProvider(AppStrings.docCategories));
      final docQualification = _ref.read(docQualificationProvider);
      final docExperience = _ref.read(docYearsOfExperienceProvider);
      final docHospital = _ref.read(docHospitalProvider);
      final daySlotConfigs = _ref.read(daySlotConfigsProvider);

      /// Check authentication state
      if (auth.currentUser != null) {
        logDebug('Already authenticated user: ${auth.currentUser!.uid}');
        // FirebaseAuth.instance.signOut();
        return 'User already authenticated. Please sign out first.';
      }

      /// Create user with Firebase Authentication
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


      User? user = userCredential.user;
      if (user == null) {
        logDebug('Failed to create user: No user returned');
        return 'Failed to create user.';
      }

      String uid = user.uid;
      logDebug('Authenticated user: $uid, email: $email');
      /// Minimal data to test write
      Map<String, dynamic> userData = {
        'uid': uid,
        'email': email,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'profileImageUrl': '',
        'profileImagePublicId': '',
        'dob': dateOfBirth,
        'gender':gender.selected,
        'age':age,
        'city': city.selected,
        'latitude': latitude,
        'longitude': longitude,
        'userType': userType.selected,
        'createdAt': DateTime.now().toIso8601String(),

      };

      if(userType.selected=="Patient"){
        userData.addAll({
          'favorites': {},
          'MedicalRecords': {},
        });
      }
      if (userType.selected == 'Doctor') {
        userData.addAll({
          'qualification': docQualification,
          'category': docCategory.selected,
          'yearsOfExperience': docExperience,
          'hospital': docHospital,
          'consultationFee': docConsultationFee,
          'totalReviews': 0,
          'averageRatings': 0.0,
          'totalPatientConsulted': 0,
          'profileViews': 0,
          'availability': daySlotConfigs,
        });
      }
      String userTypePath = userType.selected == 'Doctor' ? 'Doctors' : 'Patients';


      /// Write user data to /Doctors or /Patients
      try {
        logDebug('Attempting to write to $userTypePath/$uid: $userData');
        await database.child(userTypePath).child(uid).set(userData);
        logDebug('User data written successfully to $userTypePath/$uid');
      } catch (e) {
        logDebug('Error writing to $userTypePath/$uid: $e');
        return 'Failed to write user data: $e';
      }
     String? profileImageUrl='';
      /// Upload profile image if provided
      if (profileImage != null) {
        final cloudinaryImageData = await uploadImageToCloudinary(File(profileImage.path));
        if (cloudinaryImageData != null) {
           profileImageUrl = cloudinaryImageData['secure_url'];
          final profileImagePublicId = cloudinaryImageData['public_id'];
          try {
            await database.child(userTypePath).child(uid).update({
              'profileImageUrl': profileImageUrl,
              'profileImagePublicId': profileImagePublicId,
            });
            logDebug('Profile image updated: $profileImageUrl');
          } catch (e) {
            logDebug('Error updating profile image: $e');
            return 'Failed to update profile image: $e';
          }
        }
      }

      /// Write to /Users/$uid
      try {
        await database.child('Users/$uid').set({
          'fullName': fullName,
          'email': email,
          'userType': userType.selected,
          'profileImageUrl': profileImageUrl,
          'status': {
            'isOnline': true,
            'lastSeen': ServerValue.timestamp,
            'ping': ServerValue.timestamp,
          },
          'settings': {
            'allowChat': true,
            'allowCall': true,
          },
        });
        logDebug('User data written to /Users/$uid');
      } catch (e) {
        logDebug('Error writing to /Users/$uid: $e');
        return 'Failed to write to Users: $e';
      }

      return 'Account created successfully!';
    } on FirebaseAuthException catch (e) {
      logDebug('FirebaseAuthException: ${e.code}, ${e.message}');
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
      logDebug('Unexpected error: $e');
      return 'An unexpected error occurred: $e';
    }
  }
  // Future<String> signUp() async {
  //   try {
  //     final auth = _ref.read(firebaseAuthProvider);
  //     final database = _ref.read(firebaseDatabaseProvider);
  //     final userType = _ref.read(customDropDownProvider(AppStrings.userTypes));
  //     final profileImage = _ref.read(userProfileProvider);
  //     final email = _ref.read(emailProvider);
  //     final password = _ref.read(passwordProvider);
  //     final fullName = _ref.read(fullNameProvider);
  //     final phoneNumber = _ref.read(phoneNumberProvider);
  //     final dateOfBirth = _ref.read(dateOfBirthProvider);
  //     final city = _ref.read(customDropDownProvider(AppStrings.cities));
  //     final latitude = _ref.read(locationLatitudeProvider);
  //     final longitude = _ref.read(locationLongitudeProvider);
  //     final docConsultationFee = _ref.read(docConsultancyFeeProvider);
  //     final docCategory = _ref.read(customDropDownProvider(AppStrings.docCategories));
  //     final docQualification = _ref.read(docQualificationProvider);
  //     final docExperience = _ref.read(docYearsOfExperienceProvider);
  //     final docHospital = _ref.read(docHospitalProvider);
  //     final daySlotConfigs = _ref.read(daySlotConfigsProvider);
  //     await FirebaseDatabase.instance.goOnline();
  //     /// Check authentication state
  //     if (auth.currentUser != null) {
  //       logDebug('Already authenticated user: ${auth.currentUser!.uid}');
  //       return 'User already authenticated. Please sign out first.';
  //     }
  //
  //     UserCredential userCredential = await auth.createUserWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //
  //     User? user = userCredential.user;
  //     if (user == null) {
  //       return 'Failed to create user.';
  //     }
  //
  //     String uid = user.uid;
  //     String? profileImageUrl = "";
  //     String? profileImagePublicId = "";
  //
  //     String userTypePath = userType.selected == 'Doctor' ? 'Doctors' : 'Patients';
  //
  //     Map<String, dynamic> userData = {
  //       'uid': uid,
  //       'email': email,
  //       'fullName': fullName,
  //       'phoneNumber': phoneNumber,
  //       'profileImageUrl': profileImageUrl,
  //       'profileImagePublicId': profileImagePublicId,
  //       'dob': dateOfBirth,
  //       'city': city.selected,
  //       'latitude': latitude,
  //       'longitude': longitude,
  //       'userType': userType.selected,
  //       'createdAt': DateTime.now().toIso8601String(),
  //       'favorites': {},
  //       'MedicalRecords': {},
  //     };
  //
  //     if (userType.selected == 'Doctor') {
  //       userData.addAll({
  //         'qualification': docQualification,
  //         'category': docCategory.selected,
  //         'yearsOfExperience': docExperience,
  //         'hospital': docHospital,
  //         'consultationFee': docConsultationFee,
  //         'totalReviews': 0,
  //         'averageRatings': 0.0,
  //         'totalPatientConsulted': 0,
  //         'profileViews': 0,
  //         'viewedBy': {},
  //         'availability': daySlotConfigs,
  //       });
  //     }
  //
  //     await database.child(userTypePath).child(uid).set(userData);
  //     logDebug('User data : $userData');
  //
  //     if (profileImage != null) {
  //       final cloudinaryImageData = await uploadImageToCloudinary(File(profileImage.path));
  //       if (cloudinaryImageData != null) {
  //         logDebug('i am here');
  //         profileImageUrl = cloudinaryImageData['secure_url'];
  //         profileImagePublicId = cloudinaryImageData['public_id'];
  //         await database.child(userTypePath).child(uid).update({
  //           'profileImageUrl': profileImageUrl,
  //           'profileImagePublicId': profileImagePublicId,
  //         });
  //       }
  //     }
  //     logDebug('User data2222 : $userData');
  //
  //     await database.child('Users/$uid').set({
  //       'fullName': fullName,
  //       'email': email,
  //       'userType': userType.selected,
  //       'profileImageUrl': profileImageUrl,
  //       'status': {
  //         'isOnline': true,
  //         'lastSeen': ServerValue.timestamp,
  //         'ping': ServerValue.timestamp,
  //       },
  //       'settings': {
  //         'allowChat': true,
  //         'allowCall':true,
  //       },
  //     });
  //
  //     return 'Account created successfully!';
  //   } on FirebaseAuthException catch (e) {
  //     if (e.code == 'email-already-in-use') {
  //       return 'An account already exists with this email.';
  //     } else if (e.code == 'invalid-email') {
  //       return 'The email address is not valid.';
  //     } else if (e.code == 'weak-password') {
  //       return 'The password is too weak.';
  //     } else {
  //       return 'Authentication failed: ${e.message}';
  //     }
  //   } catch (e) {
  //     return 'An unexpected error occurred: ${e.toString()}';
  //   }
  // }

  Future<Map<String, dynamic>> signIn({required String email, required String password}) async {
    try {
      final auth = _ref.read(firebaseAuthProvider);
      final database = _ref.read(firebaseDatabaseProvider);
      await FirebaseDatabase.instance.goOnline();
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;
      if (user == null) {
        return {
          'success': false,
          'message': 'Failed to sign in. Please try again.',
          'userType': '',
          'uid': '',
        };
      }

      String uid = user.uid;
      String userType = '';

      final doctorSnapshot = await database.child('Doctors').child(uid).get();
      if (doctorSnapshot.exists) {
        userType = 'Doctor';
      } else {
        final patientSnapshot = await database.child('Patients').child(uid).get();
        if (patientSnapshot.exists) {
          userType = 'Patient';
        }
      }

      final userRef = database.child('Users/$uid');
      final statusRef = userRef.child('status');
      final userSnapshot = await userRef.get();

      if (!userSnapshot.exists) {
        await userRef.set({
          'fullName': '',
          'email': email,
          'userType': userType,
          'profileImageUrl': '',
          'status': {
            'isOnline': true,
            'lastSeen': ServerValue.timestamp,
            'ping': ServerValue.timestamp,
          },
          'settings': {
            'allowChat': true,
          },
        });
      } else if (!(await statusRef.get()).exists) {
        await statusRef.set({
          'isOnline': true,
          'lastSeen': ServerValue.timestamp,
          'ping': ServerValue.timestamp,
        });
      }

      return {
        'success': true,
        'message': 'Signed in successfully!',
        'userType': userType,
        'uid': uid,
      };
    } on FirebaseAuthException catch (e) {
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
        'uid': '',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: ${e.toString()}',
        'userType': '',
        'uid': '',
      };
    }
  }
  Future<Map<String, dynamic>> resetPassword() async {
    final auth = _ref.read(firebaseAuthProvider);
    final email = _ref.read(forgotPasswordEmailProvider);
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
      logDebug('Starting logout process...');
      await FirebaseDatabase.instance.goOffline();
      for (var subscription in _realtimeDbListeners) {
        await subscription.cancel();
      }
      _realtimeDbListeners.clear();
      logDebug('Realtime DB listeners cleared.');
      final appLifecycleObserver = _ref.read(appLifecycleObserverProvider);
      appLifecycleObserver.dispose();
      logDebug('App lifecycle observer disposed.');
      await auth.signOut();
      logDebug('Firebase Auth sign-out completed.');
      if (context.mounted) {
        CustomSnackBarWidget.show(
          backgroundColor: AppColors.gradientGreen,
          context: context,
          text: 'You have been logged out successfully.',
        );
      }
      if (context.mounted) {
        AppWrapper.of(context)?.restartApp();
        AppNavigation.pushAndRemoveUntil(const SignInView());
      }

    } catch (e, stackTrace) {
      logDebug('Logout error: $e\nStackTrace: $stackTrace');
      if (context.mounted) {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Failed to log out: $e',
        );
      }
    }
  }

}