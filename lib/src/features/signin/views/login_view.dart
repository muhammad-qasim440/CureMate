import 'package:curemate/src/features/home/views/home_view.dart';
import 'package:curemate/src/features/reset_password/views/reset_password_view.dart';
import 'package:curemate/src/features/signup/signup-view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../providers/auth-provider.dart';

class SignInView extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  SignInView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () {
                AppNavigation.pushReplacement(const ResetPasswordView());
              },
              child: const Text('Forget password?'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  User? user = await ref.read(authProvider).signIn(
                    email: emailController.text.trim(),
                    password: passwordController.text.trim(),
                  );
                  if (user != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sign In Successful!')),
                    );
                    AppNavigation.push(const HomeView());
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString())),
                  );
                }
              },
              child: const Text('Sign In'),
            ),
            TextButton(
              onPressed: () {
                AppNavigation.pushReplacement(SignUpScreen());
              },
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
