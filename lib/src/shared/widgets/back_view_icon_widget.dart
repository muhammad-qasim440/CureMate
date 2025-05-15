import 'package:flutter/material.dart';

import '../../router/nav.dart';
import '../../theme/app_colors.dart';
import '../../utils/screen_utils.dart';

class BackViewIconWidget extends StatelessWidget {
  final VoidCallback? onPressed;
  const BackViewIconWidget({super.key,this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      padding: const EdgeInsets.all(0),
      icon: Container(
        width: ScreenUtil.scaleWidth(context, 25),
        height: ScreenUtil.scaleHeight(context, 25),
        decoration: const BoxDecoration(
          color: AppColors.appBarBackBtnBgColor,
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
        child: const Center(
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
        ),
      ),
      onPressed:onPressed ?? () {
        AppNavigation.pop(context);
      },
    );
  }
}

