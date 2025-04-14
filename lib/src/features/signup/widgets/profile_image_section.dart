import 'package:curemate/src/shared/widgets/profile/profile_image_picker_widget.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';

class ProfileImageSection extends StatelessWidget {
  const ProfileImageSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: ScreenUtil.scaleHeight(context, 80),
        bottom: ScreenUtil.scaleHeight(context, 20),
        right: ScreenUtil.scaleWidth(context, 120),
        left: ScreenUtil.scaleWidth(context, 120),
      ),
      child: const ProfileImagePickerWidget(),
    );
  }
}