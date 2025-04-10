import 'package:flutter/material.dart';

class AppColors {
  static const Color black = Colors.black;

  static const Color gradientGreen = Color(0xFF0EBE7E);
  static const Color gradientBlue = Color(0xFF61CEFF);
  static const Color gradientWhite = Color(0xFFFFFFFF);
  static const Color gradientEmeraldGreen = Color(0xFF0EBE7E);
  static const Color gradientTurquoiseGreen = Color(0xFF07D9AD);

  static const LinearGradient backgroundLinearGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.gradientEmeraldGreen, AppColors.gradientTurquoiseGreen],
  );
}
