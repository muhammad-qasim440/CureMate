import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/app_strings.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../../signin/providers/auth-provider.dart';

class DoctorHomeView extends ConsumerWidget {
  const DoctorHomeView({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Centers content vertically
          children: [
            const Text(
              'Doctor screen',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            CustomButtonWidget(
                text: 'logout',
                height: ScreenUtil.scaleHeight(context, 45),
                backgroundColor: AppColors.btnBgColor,
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size18,
                fontWeight: FontWeight.w900,
                textColor: AppColors.gradientWhite,
                width: ScreenUtil.scaleWidth(context, 320),
                onPressed: () async {
                  final isNetworkAvailable = ref.read(
                    checkInternetConnectionProvider,
                  );
                  final isConnected =
                      await isNetworkAvailable
                          .whenData((value) => value)
                          .value ??
                          false;

                  if (!isConnected) {
                    CustomSnackBarWidget.show(
                      context: context,
                      backgroundColor: AppColors.gradientGreen,
                      text: "No Internet Connection",
                    );
                    return;
                  }
                  try {

                    await ref
                        .read(authProvider)
                        .logout(
                      context,
                    );
                  } catch (e) {
                    CustomSnackBarWidget.show(
                      context: context,
                      text: "$e",
                    );
                  }
                }
            ),

          ],
        ),
      ),
    );
  }
}
