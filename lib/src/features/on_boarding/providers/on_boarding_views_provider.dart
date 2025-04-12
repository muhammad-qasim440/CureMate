import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

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
