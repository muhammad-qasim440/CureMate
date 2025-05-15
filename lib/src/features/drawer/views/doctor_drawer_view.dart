import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/drawer/widgets/patient_drawer_settings_widget.dart';
import 'package:curemate/src/shared/widgets/custom_centered_text_widget.dart';
import 'package:curemate/src/shared/widgets/custom_confirmation_dialog_widget.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curemate/assets/app_assets.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../router/nav.dart';
import '../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../authentication/signin/providers/auth_provider.dart';
import '../../authentication/signin/views/signin_view.dart';
import '../../doctor/providers/doctor_providers.dart';
import '../widgets/doctor_drawer_profile_view_widget.dart';
import '../widgets/doctor_my_schedule_widget.dart';
import '../widgets/drawer_feedback_widget.dart';
import '../widgets/drawer_privacy_policy_widget.dart';

class DoctorDrawerView extends ConsumerWidget {
  const DoctorDrawerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentSignInDoctorDataProvider);

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
                      100.height,
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
                                    const DoctorDrawerProfileViewWidget(),
                                  );
                                },
                              ),
                              _buildMenuTile(
                                context,
                                Icons.schedule,
                                'My Schedule',
                                    () {
                                      AppNavigation.push(const DoctorMyScheduleViewWidget());
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
                                  AppNavigation.push(const DrawerSettingsWidget(isDoctor: true,));

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
                            builder: (ctx) =>const CustomConfirmationDialogWidget(
                              title: 'Log Out',
                              content: 'Are you sure you want to logout?',
                              confirmText: 'Ok',
                            ),
                          );
                          if(confirm==true){
                            Navigator.pop(context);
                            final isNetworkAvailable = ref.read(
                              checkInternetConnectionProvider,
                            );
                            final isConnected =
                                isNetworkAvailable
                                    .whenData((value) => value)
                                    .value ??
                                    false;

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
