import 'package:flutter_riverpod/flutter_riverpod.dart';

// Signup State Model
class SignupState {
  final String role;
  final List<Map<String, String>> availability;

  SignupState({this.role = 'patient', this.availability = const []});

  SignupState copyWith({String? role, List<Map<String, String>>? availability}) {
    return SignupState(
      role: role ?? this.role,
      availability: availability ?? this.availability,
    );
  }
}

// Signup StateNotifier
class SignupNotifier extends StateNotifier<SignupState> {
  SignupNotifier() : super(SignupState());

  void setRole(String newRole) {
    state = state.copyWith(role: newRole);
  }

  void addAvailability(String day, String time) {
    final newAvailability = List<Map<String, String>>.from(state.availability)
      ..add({'day': day, 'time': time});
    state = state.copyWith(availability: newAvailability);
  }

  void removeAvailability(int index) {
    final newAvailability = List<Map<String, String>>.from(state.availability);
    newAvailability.removeAt(index);
    state = state.copyWith(availability: newAvailability);
  }
}

// Provider for Signup State
final signupProvider = StateNotifierProvider<SignupNotifier, SignupState>((ref) {
  return SignupNotifier();
});
