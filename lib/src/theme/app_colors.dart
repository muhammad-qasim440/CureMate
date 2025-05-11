import 'package:flutter/material.dart';

class AppColors {
  static const Color black = Colors.black;
  static const grey = Color(0xff4B5563);
  static const subTextColor = Color(0xFF9D9D9D);
  static const appBarBackBtnBgColor = Color(0xFFF2F2F4);


  static const Color gradientGreen = Color(0xFF0EBE7E);
  static const Color lightGreen = Color(0xFFE7F8F2);
  static const Color gradientDarkGreen = Color(0xFF0BA56F);
  static const Color gradientBlue = Color(0xFF61CEFF);
  static const Color gradientWhite = Color(0xFFFFFFFF);
  static const Color gradientEmeraldGreen = Color(0xFF0EBE7E);
  static const Color gradientTurquoiseGreen = Color(0xFF07D9AD);

  /// on boarding view colors
  static const Color detailsTextColor = Color(0xFF677294);
  static const Color btnBgColor = Color(0xFF0EBE7F);

  static const LinearGradient backgroundLinearGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientEmeraldGreen, AppColors.gradientTurquoiseGreen],
  );

}
