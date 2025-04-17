import 'package:flutter/material.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/shared/widgets/uper_background_effects_widget.dart';

class SignInBackgroundWidget extends StatelessWidget {
  const SignInBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: [
        LowerBackgroundEffectsWidgets(),

        UpperBackgroundEffectsWidgets(),
      ],
    );
  }
}