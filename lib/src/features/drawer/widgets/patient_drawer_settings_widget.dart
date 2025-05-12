import 'package:curemate/assets/app_icons.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/providers/patient_providers.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:curemate/src/shared/widgets/custom_svg_picture_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../const/app_fonts.dart';
import '../../../theme/app_colors.dart';
import '../providers/settings_providers.dart';
import 'about_us_widget.dart';
import 'change_password_bottom_sheet_widget.dart';
import 'custom_toggle_swicth_widget.dart';

class PatientDrawerSettingsWidget extends ConsumerStatefulWidget {
  const PatientDrawerSettingsWidget({super.key});

  @override
  ConsumerState<PatientDrawerSettingsWidget> createState() =>
      _PatientDrawerSettingsWidgetState();
}

class _PatientDrawerSettingsWidgetState
    extends ConsumerState<PatientDrawerSettingsWidget> {
  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentSignInPatientDataProvider).when<Patient?>(data: (data) => data, error: (err, stack) => null, loading: () => null,);
    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomAppBarHeaderWidget(title: 'Settings'),
                  27.height,
                  CustomTextWidget(
                    text: 'Account Settings',
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubikMedium,
                      fontWeight: FontWeight.w500,
                      fontSize: FontSizes(context).size18,
                      color: AppColors.textColor,
                    ),
                  ),
                  10.height,
                  BuildSettingsListTileWidget(
                    svgIcon: AppIcons.changePasswordIc,
                    title: 'Change Password',
                    onTap: () {
                      ChangePasswordBottomSheet.show(context, ref);
                    },
                  ),
                  BuildSettingsListTileWidget(
                    svgIcon: AppIcons.aboutUsIc,
                    title: 'About US',
                    onTap: () {
                      AppNavigation.push(const AboutUsWidget());
                    },
                  ),
                  27.height,
                  CustomTextWidget(
                    text: 'More Options',
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubikMedium,
                      fontWeight: FontWeight.w500,
                      fontSize: FontSizes(context).size18,
                      color: AppColors.textColor,
                    ),
                  ),
                  10.height,
                  BuildSettingsListTileWidget(
                    title: 'Text Messages',
                    trailing: CustomToggleSwitchWidget(
                      userId: currentUser!.uid,
                      switchType: SwitchType.chat,
                      context: context,
                    ),
                    onTap: () {},
                  ),
                  BuildSettingsListTileWidget(
                    title: 'Phone Calls',
                    trailing: CustomToggleSwitchWidget(
                      userId: currentUser.uid,
                      switchType: SwitchType.call,
                      context: context,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BuildSettingsListTileWidget extends StatelessWidget {
  final String? svgIcon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;

  const BuildSettingsListTileWidget({
    super.key,
    this.svgIcon,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      splashColor: Colors.transparent,
      leading:
          svgIcon != null
              ? CustomSvgPictureWidget(
                icon: svgIcon!,
                width: ScreenUtil.scaleWidth(context, 32),
                height: ScreenUtil.scaleHeight(context, 32),
              )
              : null,
      title: CustomTextWidget(
        text: title,
        maxLines: 1,
        textStyle: TextStyle(
          color: AppColors.textColor,
          fontSize: FontSizes(context).size16,
          fontFamily: AppFonts.rubik,
          fontWeight: FontWeight.w300,
        ),
      ),
      trailing:
          trailing ??
          const Icon(Icons.chevron_right, color: AppColors.textColor),
      onTap: onTap,
    );
  }
}
