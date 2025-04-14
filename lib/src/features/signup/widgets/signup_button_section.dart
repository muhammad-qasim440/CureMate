import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/app_strings.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/src/features/home/views/home_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../signin/providers/auth-provider.dart';
import '../providers/signup_form_provider.dart';

class SignupButtonSection extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  const SignupButtonSection({super.key, required this.formKey});

  @override
  ConsumerState<SignupButtonSection> createState() =>
      _SignupButtonSectionState();
}

class _SignupButtonSectionState extends ConsumerState<SignupButtonSection> {
  @override
  Widget build(BuildContext context) {
    final internetStatus = ref.watch(checkInternetConnectionProvider);
    return CustomButtonWidget(
      text: AppStrings.signUp,
      height: ScreenUtil.scaleHeight(context, 54),
      backgroundColor: AppColors.btnBgColor,
      fontFamily: AppFonts.rubik,
      fontSize: FontSizes(context).size18,
      fontWeight: FontWeight.w900,
      textColor: AppColors.gradientWhite,
      onPressed: () async {
        if (widget.formKey.currentState!.validate()) {
          internetStatus.when(
            data: (data) async {
              ref.read(isSigningUpProvider.notifier).state = true;
              try {
                final user = await ref.read(authProvider).signUp();
                if (user != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sign Up Successful!')),
                  );
                  AppNavigation.pushReplacement(const HomeView());
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(e.toString())));
                }
              }finally{
                ref.read(isSigningUpProvider.notifier).state=false;
              }
            },
            loading:
                () => {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Waiting for internet')),
                  ),
                },
            error:
                (err, _) => {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(err.toString()))),
                },
          );
        }
      },
    );
  }
}
