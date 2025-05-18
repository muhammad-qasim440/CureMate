import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/appointment_model.dart';

class RateDoctorState {
  final double rating;
  final String review;
  final bool isSubmitting;

  RateDoctorState({
    this.rating = 0.0,
    this.review = '',
    this.isSubmitting = false,
  });

  RateDoctorState copyWith({
    double? rating,
    String? review,
    bool? isSubmitting,
  }) {
    return RateDoctorState(
      rating: rating ?? this.rating,
      review: review ?? this.review,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class RateDoctorOnCompletedAppointmentNotifier extends StateNotifier<RateDoctorState> {
  RateDoctorOnCompletedAppointmentNotifier() : super(RateDoctorState());

  void updateRating(double rating) {
    state = state.copyWith(rating: rating);
  }

  void updateReview(String review) {
    state = state.copyWith(review: review);
  }

  Future<bool> submitRating(AppointmentModel appointment) async {
    if (state.rating == 0) {
      debugPrint('Rating submission failed: Rating is 0');
      return false;
    }
    if (appointment.isRated) {
      debugPrint('Rating submission failed: Appointment already rated');
      return false;
    }
    state = state.copyWith(isSubmitting: true);

    try {
      final database = FirebaseDatabase.instance.ref();
      final appointmentRef = database.child('Appointments').child(appointment.id);
      final doctorRef = database.child('Doctors').child(appointment.doctorUid);

      // Log current user
      final user = FirebaseAuth.instance.currentUser;
      debugPrint('Current user UID: ${user?.uid}');

      // Check patient userType
      final patientRef = database.child('Patients').child(user?.uid ?? '');
      final patientSnapshot = await patientRef.get();
      if (!patientSnapshot.exists) {
        debugPrint('Rating submission failed: Patient data not found for UID ${user?.uid}');
        return false;
      }
      final patientData = patientSnapshot.value as Map<dynamic, dynamic>;
      debugPrint('Patient userType: ${patientData['userType']}');

      // Fetch doctor data
      final doctorSnapshot = await doctorRef.get();
      if (!doctorSnapshot.exists) {
        debugPrint('Rating submission failed: Doctor not found for UID ${appointment.doctorUid}');
        throw Exception('Doctor not found');
      }

      final doctorData = doctorSnapshot.value as Map<dynamic, dynamic>;
      final currentRating = (doctorData['averageRatings'] as num?)?.toDouble() ?? 0.0;
      final currentReviews = (doctorData['totalReviews'] as num?)?.toInt() ?? 0;
      debugPrint('Current doctor data - averageRatings: $currentRating, totalReviews: $currentReviews');

      final newTotalReviews = currentReviews + 1;
      final newAverageRating = ((currentRating * currentReviews) + state.rating) / newTotalReviews;
      debugPrint('New values - averageRatings: $newAverageRating, totalReviews: $newTotalReviews');

      // Update Appointments node
      debugPrint('Attempting to update Appointments node for appointment ID: ${appointment.id}');
      await appointmentRef.update({
        'isRated': true,
        'rating': state.rating,
        'review': state.review.trim(),
        'ratedAt': DateTime.now().toIso8601String(),
      });
      debugPrint('Appointments node updated successfully');

      // Update Doctors node
      debugPrint('Attempting to update Doctors node for doctor UID: ${appointment.doctorUid}');
      await doctorRef.update({
        'averageRatings': newAverageRating,
        'totalReviews': newTotalReviews,
      });
      debugPrint('Doctors node updated successfully');

      return true;
    } catch (e) {
      debugPrint('Rating error: $e');
      return false;
    } finally {
      state = state.copyWith(isSubmitting: false);
    }
  }
}

final rateDoctorOnCompletedAppointmentProvider = StateNotifierProvider<RateDoctorOnCompletedAppointmentNotifier, RateDoctorState>(
      (ref) => RateDoctorOnCompletedAppointmentNotifier(),
);
