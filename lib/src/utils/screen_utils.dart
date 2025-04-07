import 'package:flutter/widgets.dart';

class ScreenUtil {
  static late double baseWidth;
  static late double baseHeight;

  /// Call this in main.dart before running the app
  static void init(BuildContext context) {
    baseWidth = MediaQuery.of(context).size.width;
    baseHeight = MediaQuery.of(context).size.height;
  }

  /// Scale width proportionally
  static double scaleWidth(BuildContext context, double pixelWidth) {
    return (pixelWidth / baseWidth) * MediaQuery.of(context).size.width;
  }

  /// Scale height proportionally
  static double scaleHeight(BuildContext context, double pixelHeight) {
    return (pixelHeight / baseHeight) * MediaQuery.of(context).size.height;
  }
}
