import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/drawer/widgets/patient_drawer_settings_widget.dart';
import 'package:curemate/src/shared/widgets/custom_centered_text_widget.dart';
import 'package:curemate/src/shared/widgets/custom_confirmation_dialog_widget.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curemate/assets/app_assets.dart';
import 'package:curemate/src/features/patient/providers/patient_providers.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../core/utils/debug_print.dart';
import '../../../router/nav.dart';
import '../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../authentication/signin/providers/auth_provider.dart';
import '../../authentication/signin/views/signin_view.dart';
import '../widgets/patient_drawer_ratings_views_widget.dart';
import '../widgets/drawer_feedback_widget.dart';
import '../widgets/patient_drawer_medical_records.dart';
import '../widgets/patient_drawer_my_doctors_view.dart';
import '../widgets/drawer_privacy_policy_widget.dart';
import '../widgets/patient_drawer_profile_view_widget.dart';

class PatientDrawerView extends ConsumerWidget {
  const PatientDrawerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentSignInPatientDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF536184),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const CustomCenteredTextWidget(text: 'Please Sign in');
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
                          CircleAvatar(
                            radius: 28,
                            backgroundImage: NetworkImage(
                              user.profileImageUrl,
                            ),
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
                              backgroundColor: AppColors.gradientGreen,
                              child: Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                      50.height,
                      Expanded(
                        child: SizedBox(
                          width: ScreenUtil.scaleWidth(context, 230),
                          child: ListView(
                            children: [
                              _buildMenuTile(
                                context,
                                Icons.person,
                                'My Profile',
                                    () {
                                  AppNavigation.push(
                                    const PatientDrawerProfileViewWidget(),
                                  );
                                },
                              ),
                              _buildMenuTile(
                                context,
                                Icons.person,
                                'My Doctors',
                                () {
                                  AppNavigation.push(
                                    const PatientDrawerMyDoctorsView(),
                                  );
                                },
                              ),
                              _buildMenuTile(
                                context,
                                Icons.description,
                                'Medical Records',
                                () {
                                  AppNavigation.push(
                                    const PatientDrawerMedicalRecordsView(),
                                  );
                                },
                              ),
                              _buildMenuTile(
                                context,
                                Icons.star_rate,
                                'Ratings Submitted',
                                () {
                                  AppNavigation.push(
                                    const PatientDrawerRatingsViewsWidget(),
                                  );
                                },
                              ),
                              _buildMenuTile(
                                context,
                                Icons.privacy_tip,
                                'Privacy & Policy',
                                () {
                                  AppNavigation.push(const PrivacyPolicyScreen());
                                },
                              ),
                              _buildMenuTile(
                                context,
                                Icons.feedback_outlined,
                                'Feedback',
                                () {
                                  AppNavigation.push(const PatientDrawerFeedBackWidget());
                                },
                              ),
                              _buildMenuTile(
                                context,
                                Icons.settings,
                                'Settings',
                                () {
                                  AppNavigation.push(const DrawerSettingsWidget(isDoctor: false));

                                },
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
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => const CustomConfirmationDialogWidget(
                              title: 'Log Out',
                              content: 'Are you sure you want to logout?',
                              confirmText: 'Ok',
                            ),
                          );
                          if (confirm == true) {
                            final isNetworkAvailable = ref.read(checkInternetConnectionProvider);
                            final isConnected = isNetworkAvailable.whenData((value) => value).value ?? false;
                            final database = ref.read(firebaseDatabaseProvider);
                            final auth = ref.read(firebaseAuthProvider);
                            final userId = auth.currentUser?.uid;
                            if (!isConnected) {
                              CustomSnackBarWidget.show(
                                context: context,
                                backgroundColor: AppColors.gradientGreen,
                                text: 'No Internet Connection',
                              );
                              return;
                            }
                            try {
                              if (userId != null) {
                                await database.child('Users/$userId/status').update({
                                  'isOnline': false,
                                  'lastSeen': ServerValue.timestamp,
                                });
                                logDebug('User status updated to offline.');
                              }
                              await ref.read(authProvider).logout(context);
                            } catch (e) {
                              CustomSnackBarWidget.show(
                                context: context,
                                text: '$e',
                              );
                            }
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
        loading:
            () => const Center(
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
