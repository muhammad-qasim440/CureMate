import 'dart:io';

import 'package:curemate/src/features/home/views/home_view.dart';
import 'package:curemate/src/features/signin/views/login_view.dart';
import 'package:curemate/src/features/signup/providers/signup_provider.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../signin/providers/auth-provider.dart';

class SignUpScreen extends ConsumerWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Extra fields for Doctor
  final TextEditingController specializationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController hospitalController = TextEditingController();
  final TextEditingController feesController = TextEditingController();

  // Extra fields for Patient
  final TextEditingController ageController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  File? _profileImage;

  SignUpScreen({super.key});

  // Method to pick an image
  // Future<void> _pickImage() async {
  //   final picker = ImagePicker();
  //   final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  //   if (pickedFile != null) {
  //     _profileImage = File(pickedFile.path);
  //   }
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final signupState = ref.watch(signupProvider);
    final signupNotifier = ref.read(signupProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Image Picker
            GestureDetector(
                // onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : const AssetImage('assets/default_profile.png'),
                child: const Icon(Icons.camera_alt),
              ),
            ),

            TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Full Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone Number')),

            // Role Selection Dropdown
            DropdownButton<String>(
              value: signupState.role,
              onChanged: (String? newValue) {
                signupNotifier.setRole(newValue!);
              },
              items: ['doctor', 'patient'].map((role) {
                return DropdownMenuItem(value: role, child: Text(role.toUpperCase()));
              }).toList(),
            ),

            // Extra Fields for Doctor
            if (signupState.role == 'doctor') ...[
              TextField(controller: specializationController, decoration: const InputDecoration(labelText: 'Specialization')),
              TextField(controller: experienceController, decoration: const InputDecoration(labelText: 'Experience (years)')),
              TextField(controller: hospitalController, decoration: const InputDecoration(labelText: 'Hospital Name')),
              TextField(controller: feesController, decoration: const InputDecoration(labelText: 'Consultation Fees')),

              // Add Availability Time
              const Text('Doctor Availability', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ListView.builder(
                shrinkWrap: true,
                itemCount: signupState.availability.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text("${signupState.availability[index]['day']} - ${signupState.availability[index]['time']}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        signupNotifier.removeAvailability(index);
                      },
                    ),
                  );
                },
              ),
              ElevatedButton(
                onPressed: () {
                  _addAvailabilityDialog(context, ref);
                },
                child: const Text('Add Availability Time'),
              ),
            ],

            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await ref.read(authProvider).signUp(
                  email: emailController.text,
                  password: passwordController.text,
                  role: signupState.role,
                  name: nameController.text,
                  phone: phoneController.text,
                  specialization: specializationController.text,
                  experience: experienceController.text,
                  hospital: hospitalController.text,
                  fees: int.tryParse(feesController.text),
                  availability: signupState.availability,
                  age: int.tryParse(ageController.text),
                  gender: genderController.text,
                );
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account Created! Please Login.')));
                AppNavigation.pushReplacement(const HomeView());

              },
              child: const Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                AppNavigation.pushReplacement(SignInView());

              },
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _addAvailabilityDialog(BuildContext context, WidgetRef ref) {
    String day = 'Monday';
    TextEditingController timeController = TextEditingController();
    final signupNotifier = ref.read(signupProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Availability'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButton<String>(
              value: day,
              onChanged: (String? newValue) {
                day = newValue!;
              },
              items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'].map((day) {
                return DropdownMenuItem(value: day, child: Text(day));
              }).toList(),
            ),
            TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Time Slot (e.g. 10 AM - 2 PM)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () {
            signupNotifier.addAvailability(day, timeController.text);
            Navigator.pop(context);
          }, child: const Text('Add')),
        ],
      ),
    );
  }
}
