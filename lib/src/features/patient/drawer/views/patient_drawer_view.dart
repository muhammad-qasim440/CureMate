import 'dart:io';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/drawer/widgets/patient_medical_records.dart';
import 'package:curemate/src/shared/widgets/custom_centered_text_widget.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curemate/assets/app_assets.dart';
import 'package:curemate/src/features/patient/providers/patient_providers.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../router/nav.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../authentication/signin/providers/auth-provider.dart';
import '../../../authentication/signin/views/signin_view.dart';
import '../widgets/my_doctors_view.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../core/utils/upload_profile_image_to_cloudinary.dart';

class PatientDrawerView extends ConsumerWidget {
  const PatientDrawerView({super.key});

  Future<void> _pickImage(BuildContext context, WidgetRef ref) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final user = ref.read(currentSignInPatientDataProvider).value;
      if (user != null) {
        final result = await uploadImageToCloudinary(File(pickedFile.path));
        if (result != null) {
          if (user.profileImagePublicId.isNotEmpty) {
            await deleteImageFromCloudinary(user.profileImagePublicId);
          }
          await FirebaseDatabase.instance
              .ref()
              .child('Patients')
              .child(FirebaseAuth.instance.currentUser!.uid)
              .update({
            'profileImageUrl': result['secure_url'],
            'profileImagePublicId': result['public_id'],
          });
          CustomSnackBarWidget.show(
            context: context,
            text: 'Profile image updated successfully.',
          );
        } else {
          CustomSnackBarWidget.show(
            context: context,
            text: 'Failed to update profile image.',
          );
        }
      }
    }
  }

  Future<void> _deleteProfileImage(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentSignInPatientDataProvider).value;
    if (user != null && user.profileImagePublicId.isNotEmpty) {
      await deleteImageFromCloudinary(user.profileImagePublicId);
      await FirebaseDatabase.instance
          .ref()
          .child('Patients')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'profileImageUrl': '',
        'profileImagePublicId': '',
      });
      CustomSnackBarWidget.show(
        context: context,
        text: 'Profile image deleted successfully.',
      );
    } else {
      CustomSnackBarWidget.show(
        context: context,
        text: 'No profile image to delete.',
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentSignInPatientDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF536184),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const CustomCenteredTextWidget(text: 'Please log in');
          }

          return Stack(
            children: [
              Positioned(
                right: ScreenUtil.scaleWidth(context, -80),
                top: ScreenUtil.scaleHeight(context, 160),
                child: Image.asset(
                  AppAssets.patientDrawerSideBarImg,
                  height: ScreenUtil.scaleHeight(context, 450),
                  fit: BoxFit.cover,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundImage: NetworkImage(user.profileImageUrl),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.green,
                                  child: IconButton(
                                    icon: const Icon(Icons.edit, size: 14, color: Colors.white),
                                    onPressed: () => _pickImage(context, ref),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.fullName,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.phone,
                                      size: 14,
                                      color: Colors.white70,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      user.phoneNumber,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          5.width,
                          InkWell(
                            onTap: () => Navigator.pop(context),
                            child: const CircleAvatar(
                              maxRadius: 15,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.close, color: Colors.white, size: 15),
                            ),
                          ),
                        ],
                      ),
                      // 20.height,
                      // Row(
                      //   children: [
                      //     ElevatedButton(
                      //       onPressed: () => _pickImage(context, ref),
                      //       child: const Text('Change Profile Picture'),
                      //     ),
                      //     10.width,
                      //     ElevatedButton(
                      //       onPressed: () => _deleteProfileImage(context, ref),
                      //       style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      //       child: const Text('Delete Profile Picture'),
                      //     ),
                      //   ],
                      // ),
                      100.height,
                      Expanded(
                        child: SizedBox(
                          width: ScreenUtil.scaleWidth(context, 230),
                          child: ListView(
                            children: [
                              _buildMenuTile(
                                context,
                                Icons.person,
                                'My Doctors',
                                    () {
                                  AppNavigation.push(const MyDoctorsView());
                                },
                              ),
                              _buildMenuTile(
                                context,
                                Icons.description,
                                'Medical Records',
                                    () {
                                  AppNavigation.push(const PatientMedicalRecords());
                                },
                              ),
                              _buildMenuTile(
                                context,
                                Icons.privacy_tip,
                                'Privacy & Policy',
                                    () {},
                              ),
                              _buildMenuTile(
                                context,
                                Icons.help_outline,
                                'Help Center',
                                    () {},
                              ),
                              _buildMenuTile(
                                context,
                                Icons.settings,
                                'Settings',
                                    () {},
                              ),
                            ],
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.white),
                        title: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        onTap: () async {
                          Navigator.pop(context);
                          final isNetworkAvailable = ref.read(checkInternetConnectionProvider);
                          final isConnected = await isNetworkAvailable.whenData((value) => value).value ?? false;

                          if (!isConnected) {
                            CustomSnackBarWidget.show(
                              context: context,
                              backgroundColor: AppColors.gradientGreen,
                              text: 'No Internet Connection',
                            );
                            return;
                          }
                          try {
                            await ref.read(authProvider).logout(context);
                            AppNavigation.pushReplacement(const SignInView());
                          } catch (e) {
                            CustomSnackBarWidget.show(
                              context: context,
                              text: '$e',
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gradientGreen),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildMenuTile(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white10,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: CustomTextWidget(
          text: title,
          maxLines: 1,
          textStyle: TextStyle(
            color: AppColors.gradientWhite,
            fontSize: FontSizes(context).size15,
            fontFamily: AppFonts.rubik,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}