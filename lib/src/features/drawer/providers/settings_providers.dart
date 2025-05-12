import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';

import '../../../shared/providers/check_internet_connectivity_provider.dart';

enum SwitchType { chat, call }
class SwitchState {
  final bool isEnabled;
  final bool isLoading;

  SwitchState({required this.isEnabled, this.isLoading = false});

  SwitchState copyWith({bool? isEnabled, bool? isLoading}) {
    return SwitchState(
      isEnabled: isEnabled ?? this.isEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SwitchNotifier extends StateNotifier<SwitchState> {
  final String userId;
  final SwitchType switchType;
  final DatabaseReference _dbRef;
  final BuildContext context;
  final Ref ref;

  SwitchNotifier(this.userId, this.switchType, bool initialValue, this.context, this.ref)
      : _dbRef = FirebaseDatabase.instance
      .ref('Users/$userId/settings/${switchType == SwitchType.chat ? 'allowChat' : 'allowCall'}'),
        super(SwitchState(isEnabled: initialValue)) {
    _init();
  }

  Future<void> _init() async {
    final snapshot = await _dbRef.get();
    if (snapshot.exists) {
      state = SwitchState(isEnabled: snapshot.value as bool);
    }
  }

  Future<void> toggle() async {
    final connectivityState = ref.read(checkInternetConnectionProvider);
    final hasInternet = connectivityState.asData?.value ?? false;
    if (!hasInternet) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'No internet connection. Please check your network.',
      );
      return;
    }
    state = state.copyWith(isLoading: true);
    final previousValue = state.isEnabled;
    state = state.copyWith(isEnabled: !previousValue, isLoading: true);

    try {
      await _dbRef.set(!previousValue);
      state = state.copyWith(isEnabled: !previousValue, isLoading: false);
    } catch (e) {
      state = state.copyWith(isEnabled: previousValue, isLoading: false);
      CustomSnackBarWidget.show(
        context: context,
        text: 'Failed to update settings. Please try again.',
      );
    }
  }
}

/// Provider for chat switch
final chatSwitchProvider =
StateNotifierProvider.family<SwitchNotifier, SwitchState, ({String userId, BuildContext context})>(
      (ref, params) => SwitchNotifier(params.userId, SwitchType.chat, true, params.context, ref),
);

/// Provider for call switch
final callSwitchProvider =
StateNotifierProvider.family<SwitchNotifier, SwitchState, ({String userId, BuildContext context})>(
      (ref, params) => SwitchNotifier(params.userId, SwitchType.call, true, params.context, ref),
);