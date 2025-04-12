import 'dart:async';
import 'package:curemate/src/features/on_boarding/views/on_boarding_first_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../router/nav.dart';
import '../../../utils/delay_utils.dart';
import '../../doctor/home/views/doctor_home_view.dart';
import '../../on_boarding/providers/on_boarding_views_provider.dart';
import '../../patient/home/views/patient_home_view.dart';
import '../../signin/views/login_view.dart';

class SplashNotifier extends StateNotifier<SplashState> {
  SplashNotifier(this._ref) : super(SplashState(progress: 0.0)) {
    _startProgressTimer();
  }
  final Ref _ref;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  Timer? _progressTimer;

  void _startProgressTimer() {
    _progressTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) async {
      if (state.progress < 1.0) {
        state = state.copyWith(progress: state.progress + 0.01);
      } else {
        timer.cancel();
        await wait(const Duration(milliseconds: 100));
        final hasSeenOnboarding =
        _ref.read(onBoardingViewsProvider);

        if (hasSeenOnboarding == false) {
          AppNavigation.push(const OnBoardingFirstView());
          return;
        }else {
          checkAuthUser();
        }
      }
    });
  }

  Future<void> checkAuthUser() async {
    User? user = _auth.currentUser;
    if (user == null) {
      AppNavigation.push(SignInView());
      // AppNavigation.push(const OnBoardingFirstView());
    } else {
      DatabaseReference userRef = _database.child('Doctor').child(user.uid);
      DataSnapshot snapshot = await userRef.get();
      if (snapshot.exists) {
        AppNavigation.push(const DoctorHomeView());
      } else {
        userRef = _database.child('Patient').child(user.uid);
        DataSnapshot snapshot = await userRef.get();
        if (snapshot.exists) {
          AppNavigation.push(const PatientHomeView());
        } else {
          AppNavigation.push(SignInView());
        }
      }
    }
  }

  @override
  void dispose() {
    _progressTimer?.cancel();
    super.dispose();
  }
}

class SplashState {
  final double progress;
  SplashState({required this.progress});
  SplashState copyWith({double? progress}) {
    return SplashState(progress: progress ?? this.progress);
  }
}

final splashProvider =
StateNotifierProvider<SplashNotifier, SplashState>((ref) {
  return SplashNotifier(ref);
});
