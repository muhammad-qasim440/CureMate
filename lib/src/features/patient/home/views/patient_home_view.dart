import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/providers/patient_providers.dart';
import 'package:curemate/src/shared/providers/check_internet_connectivity_provider.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_strings.dart';
import '../../../../shared/widgets/lower_background_effects_widgets.dart';
import '../../../../theme/app_colors.dart';
import '../widgets/doctor_search_bar_widget.dart';
import '../widgets/doctors_speciality_icons_list_widget.dart';
import '../widgets/featured_doctors_list_widget.dart';
import '../widgets/near_by_doctors_list_widget.dart';
import '../widgets/popular_doctors_list_widget.dart';
import '../widgets/user_profile_header_widget.dart';

class PatientHomeView extends ConsumerWidget {
  const PatientHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected =
        ref.watch(checkInternetConnectionProvider).value ?? false;
    return Stack(
      children: [
        const LowerBackgroundEffectsWidgets(),
        RefreshIndicator(
          displacement: ScreenUtil.scaleHeight(context, 130),
          backgroundColor: AppColors.gradientGreen,
          color: AppColors.gradientWhite,
          onRefresh: () async {
            if (!isConnected) {
              CustomSnackBarWidget.show(
                context: context,
                text: AppStrings.noInternetInSnackBar,
              );
              return;
            }
            ref.refresh(doctorsProvider);
            ref.refresh(favoriteDoctorUidsProvider);
          },
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                220.height,
                DoctorsSpecialityIconsListWidget(),
                const NearbyDoctorsListWidget(),
                const PopularDoctorsListWidget(),
                const FeaturedDoctorsListWidget(),
              ],
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const UserProfileHeaderWidget(),
              Transform.translate(
                offset: const Offset(0, -40),
                child: const DoctorSearchBarWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
