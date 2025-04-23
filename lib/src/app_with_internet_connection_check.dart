import 'package:curemate/const/app_routes.dart';
import 'package:curemate/src/shared/providers/check_internet_connectivity_provider.dart';
import 'package:curemate/src/shared/views/no_internet_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppWithConnectionCheck extends ConsumerStatefulWidget {
  final Widget child;
  const AppWithConnectionCheck({super.key, required this.child});

  @override
  ConsumerState<AppWithConnectionCheck> createState() => _AppWithConnectionCheckState();
}

class _AppWithConnectionCheckState extends ConsumerState<AppWithConnectionCheck> {
  bool _wasDisconnected = false;

  final List<String> _excludedRoutes = [
    // AppRoutes.onBoardingFirstView,
    // AppRoutes.onBoardingSecondView,
    // AppRoutes.onBoardingThirdView,
    // AppRoutes.signInView,
    // AppRoutes.signupView,
  ];

  bool _shouldShowInternetDialog(String? currentRoute) {
    return !_excludedRoutes.contains(currentRoute);
  }

  void _handleConnectionChange(bool isConnected) {
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    final String? currentRoute = route?.settings.name;

    if (!isConnected && !_wasDisconnected && _shouldShowInternetDialog(currentRoute)) {
      _wasDisconnected = true;

      Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => NoInternetView(
          onTryAgain: () {
          },
        ),
      ));
    } else if (isConnected && _wasDisconnected) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      _wasDisconnected = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(checkInternetConnectionProvider, (previous, next) {
      final isConnected = next.value ?? false;
      _handleConnectionChange(isConnected);
    });

    return widget.child;
  }
}



