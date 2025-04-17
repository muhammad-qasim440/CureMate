
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../providers/signin_form_providers.dart';
import '../widgets/signin_background_widget.dart';
import '../widgets/signin_form_widget.dart';
import '../widgets/signin_header_widget.dart';
import '../widgets/signing_in_dialog_widget.dart';

final hidePasswordProvider = StateProvider<bool>((ref) => true);

class SignInView extends ConsumerStatefulWidget {
  const SignInView({super.key});

  @override
  ConsumerState<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends ConsumerState<SignInView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FocusNode emailFocus = FocusNode();
  final FocusNode passwordFocus = FocusNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(isSigningInProvider, (previous, next) {
      if (next) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => SigningInDialogWidget(email: emailController.text.trim()),
        );
      } else {
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
      }
    });

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.gradientWhite,
        body: Form(
          key: _formKey,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const SignInBackgroundWidget(),
              SignInHeaderWidget(keyboardHeight: keyboardHeight),
              SignInFormWidget(
                formKey: _formKey,
                emailController: emailController,
                passwordController: passwordController,
                emailFocus: emailFocus,
                passwordFocus: passwordFocus,
                keyboardHeight: keyboardHeight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}