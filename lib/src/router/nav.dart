import 'package:flutter/material.dart';

class AppNavigation {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static bool canPop() => navigatorKey.currentState!.canPop();

  static Future<dynamic> push(Widget page, {String? routeName}) async {
    return await navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => page,
        settings: RouteSettings(name: routeName),
      ),
    );
  }

  static Future<dynamic> pushReplacement(Widget page, {String? routeName}) async {
    return await navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(
        settings: RouteSettings(name: routeName),
        builder: (context) => page,
      ),
    );
  }

  static Future<dynamic> pushAndRemoveUntil(
    Widget page, {
    String? screenName,
  String? routeName,
  }) async {
    _logScreenView(screenName ?? _getScreenName(page));
    return await navigatorKey.currentState!.pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => page,
        settings: RouteSettings(name: routeName),
      ),
      (route) => false,
    );
  }

  static void popAll() {
    return navigatorKey.currentState!.popUntil((route) => false);
  }

  static void pop([dynamic data]) {
    navigatorKey.currentState!.pop(data);
  }

  static void _logScreenView(String screenName) {
    // _analyticsService
    //     .logEvent('view_$screenName', parameters: {'screen_name': screenName});
    // _analyticsService.setCurrentScreen(screenName, screenName);
  }

  static String _getScreenName(Widget page) {
    return page.runtimeType.toString().toLowerCase();
  }
}
