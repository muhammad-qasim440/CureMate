import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../../assets/app_assets.dart';
import '../../../../const/app_strings.dart';
import '../views/on_boarding_carousel_view.dart';

final onBoardingViewsProvider =
    StateNotifierProvider<OnBoardingViewNotifier, bool?>((ref) {
      return OnBoardingViewNotifier();
    });

class OnBoardingViewNotifier extends StateNotifier<bool?> {
  OnBoardingViewNotifier() : super(null) {
    _load();
  }

  static const _key = 'hasSeenOnBoardingViews';
  final Box _box = Hive.box('showOnBoardingViewDbBox');

  void _load() {
    state = _box.get(_key, defaultValue: false);
  }

  void onBoardingViewShownORSkipped() {
    state = true;
    _box.put(_key, true);
  }
}
final currentOnboardingPageProvider = StateProvider<int>((ref) => 0);
final isUserInteractingProvider = StateProvider<bool>((ref) => false);

final onboardingPagesProvider = Provider<List<OnBoardingPageData>>((ref) {
  return [
    OnBoardingPageData(
      image: AppAssets.doctorImg1,
      title: AppStrings.findTrustedDoctors,
      description: AppStrings.findTrustedDoctorsDesc,
      isGradientLeft: true,
    ),
    OnBoardingPageData(
      image: AppAssets.doctorImg2,
      title: AppStrings.chooseBestDoctors,
      description: AppStrings.chooseBestDoctorsDesc,
      isGradientLeft: false,
    ),
    OnBoardingPageData(
      image: AppAssets.doctorImg3,
      title: AppStrings.easyAppointment,
      description: AppStrings.easyAppointmentDesc,
      isGradientLeft: true,
    ),
  ];
});