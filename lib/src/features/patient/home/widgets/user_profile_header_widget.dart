import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../drawer/views/patient_drawer_view.dart';
import '../../providers/patient_providers.dart';

class UserProfileHeaderWidget extends ConsumerWidget {
  const UserProfileHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(currentSignInPatientDataProvider);

    return Container(
      height: ScreenUtil.scaleHeight(context, 156),
      width: ScreenUtil.scaleWidth(context, 375),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundLinearGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                patientAsync.when(
                  data:
                      (patient) => CustomTextWidget(
                        text:
                            patient != null
                                ? 'Hi ${patient.fullName}!'
                                : 'Hi Guest!',
                        textStyle: TextStyle(
                          fontSize: FontSizes(context).size20,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFonts.rubik,
                        ),
                      ),
                  loading: () => const CircularProgressIndicator(),
                  error:
                      (error, stack) => CustomTextWidget(
                        text: 'Error loading user',
                        textStyle: TextStyle(
                          fontSize: FontSizes(context).size20,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFonts.rubik,
                          color: Colors.red,
                        ),
                      ),
                ),
                6.height,
                CustomTextWidget(
                  text: 'Find Your Doctor',
                  textStyle: TextStyle(
                    fontSize: FontSizes(context).size26,
                    color: AppColors.gradientWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Positioned(
              top: ScreenUtil.scaleHeight(context, 6),
              right: ScreenUtil.scaleWidth(context, 15),
              child: patientAsync.when(
                data:
                    (patient) => GestureDetector(
                      onTap: () {
                        if (patient != null) {
                          AppNavigation.push(const PatientDrawerView());
                        }
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage:
                            patient != null &&
                                    patient.profileImageUrl.isNotEmpty
                                ? NetworkImage(patient.profileImageUrl)
                                : null,
                        child:
                            patient == null || patient.profileImageUrl.isEmpty
                                ? Icon(
                                  Icons.person,
                                  size: 30,
                                  color: Colors.grey.shade600,
                                )
                                : null,
                      ),
                    ),
                loading: () => const CircularProgressIndicator(),
                error:
                    (error, stack) => CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(
                        Icons.error,
                        size: 30,
                        color: Colors.grey.shade600,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
