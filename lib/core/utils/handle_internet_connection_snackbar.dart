import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../const/app_strings.dart';
import '../../src/shared/providers/check_internet_connectivity_provider.dart';
import '../../src/shared/widgets/custom_snackbar_widget.dart';


void showInternetSnackbarSafely({
  required BuildContext context,
  required WidgetRef ref,
  required bool isConnected,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    handleInternetSnackbar(
      context: context,
      ref: ref,
      isConnected: isConnected,
    );
  });
}

void handleInternetSnackbar({
  required BuildContext context,
  required WidgetRef ref,
  required bool isConnected,
}) {
  final lastStatus = ref.read(lastConnectionStatusProvider);
  final lastStatusNotifier = ref.read(lastConnectionStatusProvider.notifier);

  if (lastStatus != isConnected) {
    lastStatusNotifier.state = isConnected;

    final text = isConnected
        ? AppStrings.internetHasBeenConnectedInSnackBar
        : AppStrings.noInternetInSnackBar;

    CustomSnackBarWidget.show(
      context: context,
      text: text,
    );
  }
}
