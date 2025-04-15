import 'dart:io';
import 'dart:ui';
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import '../../signup/providers/signup_form_provider.dart';

class SigningUpDialog extends ConsumerWidget {
  const SigningUpDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(signUpFormProvider);
    final image = ref.watch(userProfileProvider);
    final name = ref.watch(fullNameProvider);

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
                  if (image != null)
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: FileImage(File(image.path)),
                    ),
                  const SizedBox(height: 12),
                  CustomTextWidget(
                    text: "Hi, $name",
                    textStyle: TextStyle(
                      fontSize: FontSizes(context).size16,
                      fontWeight: FontWeight.bold,
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
                    text: "We're creating your account. Please wait...",
                    textStyle: TextStyle(
                      fontSize: FontSizes(context).size15,
                      fontFamily: AppFonts.rubik,
                      fontWeight: FontWeight.w400,

                    ),
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
