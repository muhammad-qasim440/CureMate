import 'dart:ui';
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';

import '../../../theme/app_colors.dart';

class SigningInDialogWidget extends ConsumerWidget {
  final String email;
  const SigningInDialogWidget({super.key, required this.email});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(color: Colors.black.withOpacity(0.3)),
        ),
        Center(
          child: Material(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            elevation: 10,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_open_rounded,
                    size: 48,
                    color: AppColors.gradientGreen,
                  ),
                  const SizedBox(height: 12),
                  CustomTextWidget(
                    text: "Welcome back!",
                    textStyle: TextStyle(
                      fontSize: FontSizes(context).size16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  CustomTextWidget(
                    text: email,
                    textStyle: TextStyle(
                      fontSize: FontSizes(context).size14,
                      fontFamily: AppFonts.rubik,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 120,
                    child: Lottie.asset(
                      'assets/animations/signing_up.json',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomTextWidget(
                    text: "Signing you in. Please wait...",
                    textStyle: TextStyle(
                      fontSize: FontSizes(context).size15,
                      fontFamily: AppFonts.rubik,
                      fontWeight: FontWeight.w400,
                    ),
                    applyShadow: true,
                    shadowColor: Colors.deepPurple.shade100,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
