import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../const/app_fonts.dart';
import '../../../const/app_strings.dart';
import '../../../const/font_sizes.dart';
import '../../features/patient/home/widgets/near_by_doctors_searching_radius_provider_widget.dart';
import '../../features/patient/providers/patient_providers.dart';
import '../../router/nav.dart';
import '../../theme/app_colors.dart';
import '../../utils/screen_utils.dart';
import 'custom_text_widget.dart';

class CustomAppBarHeaderWidget extends ConsumerWidget {
  final bool? isAllNearByDoctorsView;
  final String? title;

  const CustomAppBarHeaderWidget({
    super.key,
    this.title,
    this.isAllNearByDoctorsView,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            AppNavigation.pop(context);
          },
          child: Container(
            width: ScreenUtil.scaleWidth(context, 30),
            height: ScreenUtil.scaleHeight(context, 30),
            decoration: const BoxDecoration(
              color: AppColors.appBarBackBtnBgColor,
              borderRadius: BorderRadius.all(Radius.circular(5)),
            ),
            child: const Center(
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            ),
          ),
        ),
        if (title != null && title!.isNotEmpty) ...[
          19.width,
          CustomTextWidget(
            text: title!,
            textStyle: TextStyle(
              fontSize: FontSizes(context).size18,
              fontFamily: AppFonts.rubik,
              fontWeight: FontWeight.w500,
              color: AppColors.black,
            ),
          ),
        ],
        if (isAllNearByDoctorsView == true) ...[
          const Spacer(),
          const RadiusSelector(),
        ],
      ],
    );
  }
}

