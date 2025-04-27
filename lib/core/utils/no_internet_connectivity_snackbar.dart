import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../src/shared/providers/check_internet_connectivity_provider.dart';
import '../../src/shared/widgets/custom_snackbar_widget.dart';

Future<bool> checkInternetConnection({
  required BuildContext context,
  required WidgetRef ref,
  bool showSnackbar = true,
}) async {
  final connectivity = await ref.read(checkInternetConnectionProvider.future);
  if (!connectivity && showSnackbar) {
    CustomSnackBarWidget.show(
      context: context,
      text: "No internet connection. Please check your network.",
    );
  }
  return connectivity;
}
