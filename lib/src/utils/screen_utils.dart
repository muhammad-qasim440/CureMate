import 'package:flutter/widgets.dart';

class ScreenUtil {
  static const double _designWidth = 375;  // e.g., iPhone 11 width
  static const double _designHeight = 812; // e.g., iPhone 11 height

  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
  }

  /// ✅ Same name as your original function — scales width
  static double scaleWidth(BuildContext context, double value) {
    return (value / _designWidth) * MediaQuery.of(context).size.width;
  }

  /// ✅ Same name as your original function — scales height
  static double scaleHeight(BuildContext context, double value) {
    return (value / _designHeight) * MediaQuery.of(context).size.height;
  }

  /// 🔤 Scaled font size based on screen width
  static double sp(BuildContext context, double fontSize) {
    return fontSize * (MediaQuery.of(context).size.width / _designWidth);
  }

  /// 📏 Percent of screen width
  static double wp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.width * percent;
  }

  /// 📐 Percent of screen height
  static double hp(BuildContext context, double percent) {
    return MediaQuery.of(context).size.height * percent;
  }

  /// 🔄 Full screen width
  static double fullWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  /// 🔄 Full screen height
  static double fullHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

}
