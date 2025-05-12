import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../theme/app_colors.dart';

/// Providers for password fields
final currentPasswordProvider = StateProvider<String>((ref) => '');
final newPasswordProvider = StateProvider<String>((ref) => '');
final confirmNewPasswordProvider = StateProvider<String>((ref) => '');

/// Providers for visibility toggles
final hideCurrentPasswordProvider = StateProvider<bool>((ref) => true);
final hideNewPasswordProvider = StateProvider<bool>((ref) => true);
final hideConfirmPasswordProvider = StateProvider<bool>((ref) => true);

/// Provider for loading state
final isUpdatingPasswordProvider = StateProvider<bool>((ref) => false);

/// Provider for checking if all fields are filled
final allFieldsFilledProvider = Provider<bool>((ref) {
  final currentPassword = ref.watch(currentPasswordProvider);
  final newPassword = ref.watch(newPasswordProvider);
  final confirmPassword = ref.watch(confirmNewPasswordProvider);
  return currentPassword.isNotEmpty && newPassword.isNotEmpty && confirmPassword.isNotEmpty;
});

/// Providers for error messages
final currentPasswordErrorProvider = StateProvider<String?>((ref) => null);
final confirmPasswordErrorProvider = StateProvider<String?>((ref) => null);
final errorMessageProvider = StateProvider<String?>((ref) => null);

/// Provider for internet connectivity
final checkInternetConnectionProvider = StreamProvider<bool>((ref) async* {
  await for (var connectivityResult in Connectivity().onConnectivityChanged) {
    yield connectivityResult != ConnectivityResult.none;
  }
});

/// Provider for password update logic
final passwordUpdateProvider = Provider<PasswordUpdate>((ref) {
  return PasswordUpdate(ref);
});

class PasswordUpdate {
  final Ref ref;

  PasswordUpdate(this.ref);

  Future<void> updatePassword(BuildContext context, GlobalKey<FormState> formKey) async {
    final currentPassword = ref.read(currentPasswordProvider);
    final newPassword = ref.read(newPasswordProvider);
    final confirmPassword = ref.read(confirmNewPasswordProvider);

    /// Reset previous errors
    ref.read(currentPasswordErrorProvider.notifier).state = null;
    ref.read(confirmPasswordErrorProvider.notifier).state = null;
    ref.read(errorMessageProvider.notifier).state = null;

    /// Check internet connection
    final connectivityState = ref.read(checkInternetConnectionProvider);
    final hasInternet = connectivityState.asData?.value ?? false;
    if (!hasInternet) {
      ref.read(errorMessageProvider.notifier).state = 'No internet connection. Please check your network.';
      return;
    }

    /// Validate passwords match
    if (newPassword != confirmPassword) {
      ref.read(confirmPasswordErrorProvider.notifier).state = 'Passwords do not match';
      formKey.currentState!.validate();
      return;
    }

    ref.read(isUpdatingPasswordProvider.notifier).state = true;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ref.read(errorMessageProvider.notifier).state = 'No user is signed in.';
        ref.read(isUpdatingPasswordProvider.notifier).state = false;
        return;
      }

      /// Reauthenticate user with current password
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
      CustomSnackBarWidget.show(
        context: context,
        text: 'Password updated successfully.',
        backgroundColor: AppColors.gradientGreen,
        duration: const Duration(seconds: 2),
      );
      await Future.delayed(const Duration(seconds: 2));
      resetProviders();
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'wrong-password':
          ref.read(currentPasswordErrorProvider.notifier).state = 'Current password is incorrect.';
          formKey.currentState!.validate();
          break;
        case 'weak-password':
          ref.read(errorMessageProvider.notifier).state = 'New password is too weak. It must be at least 6 characters.';
          break;
        case 'requires-recent-login':
          ref.read(errorMessageProvider.notifier).state = 'Please sign in again to update your password.';
          break;
        default:
          ref.read(errorMessageProvider.notifier).state = 'An error occurred: ${e.message}';
      }
    } catch (e) {
      ref.read(errorMessageProvider.notifier).state = 'An unexpected error occurred.';
    } finally {
      ref.read(isUpdatingPasswordProvider.notifier).state = false;
    }
  }

  void resetProviders() {
    ref.read(currentPasswordProvider.notifier).state = '';
    ref.read(newPasswordProvider.notifier).state = '';
    ref.read(confirmNewPasswordProvider.notifier).state = '';
    ref.read(hideCurrentPasswordProvider.notifier).state = true;
    ref.read(hideNewPasswordProvider.notifier).state = true;
    ref.read(hideConfirmPasswordProvider.notifier).state = true;
    ref.read(isUpdatingPasswordProvider.notifier).state = false;
    ref.read(currentPasswordErrorProvider.notifier).state = null;
    ref.read(confirmPasswordErrorProvider.notifier).state = null;
    ref.read(errorMessageProvider.notifier).state = null;
  }
}