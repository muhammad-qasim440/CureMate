import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Firebase Providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

// Auth Service Provider
final authProvider = Provider<AuthService>((ref) {
  return AuthService(ref);
});

class AuthService {
  final Ref _ref;
  AuthService(this._ref);

  // 📌 Sign Up Function (Creates Firestore User Document)
  Future<void> signUp({
    required String email,
    required String password,
    required String role,
    required String name,
    required String phone,
    File? profileImage, // Add this parameter
    String? specialization,
    String? experience,
    String? hospital,
    List<Map<String, String>>? availability,
    int? fees,
    int? age,
    String? gender,
    List<String>? medicalHistory,
  }) async {
    final auth = _ref.read(firebaseAuthProvider);
    final firestore = _ref.read(firestoreProvider);
    // 🔹 Create user in Firebase Authentication
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = userCredential.user!.uid;  // Get user UID from Firebase Auth
// Upload profile image if provided
    String? profileImageUrl;

    // 🔹 Create User Data Map
    Map<String, dynamic> userData = {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'phone': phone,
      'profileImageUrl': profileImageUrl, // Add this field
      'createdAt': FieldValue.serverTimestamp(),
    };

    // 🔹 Add extra fields if user is a Doctor
    if (role == 'doctor') {
      userData.addAll({
        'specialization': specialization,
        'experience': experience,
        'hospital': hospital,
        'availability': availability ?? [],
        'fees': fees,
      });
    }

    // 🔹 Add extra fields if user is a Patient
    if (role == 'patient') {
      userData.addAll({
        'age': age,
        'gender': gender,
        'medicalHistory': medicalHistory ?? [],
      });
    }

    // 🔹 Store user data in Firestore (UID as Document ID)
    await firestore.collection('users').doc(uid).set(userData);
  }

  // 📌 Sign In Function
  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final auth = _ref.read(firebaseAuthProvider);

    try {
      // 🔹 Sign in with email and password
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔹 Return the signed-in user
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      // 🔹 Handle specific Firebase Auth errors
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        throw Exception('Wrong password provided.');
      } else {
        throw Exception('Authentication error: ${e.message}');
      }
    } catch (e) {
      // 🔹 Handle any other errors
      throw Exception('An error occurred during sign-in: $e');
    }
  }

  // 📌 Reset Password Function
  Future<void> resetPassword({required String email}) async {
    final auth = _ref.read(firebaseAuthProvider);

    try {
      // 🔹 Send password reset email
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // 🔹 Handle specific Firebase Auth errors
      if (e.code == 'user-not-found') {
        throw Exception('No user found for that email.');
      } else {
        throw Exception('Password reset error: ${e.message}');
      }
    } catch (e) {
      // 🔹 Handle any other errors
      throw Exception('An error occurred during password reset: $e');
    }
  }
}
