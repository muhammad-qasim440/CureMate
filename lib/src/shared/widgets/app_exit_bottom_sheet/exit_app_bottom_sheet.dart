import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../const/font_sizes.dart';
import '../../../theme/app_colors.dart';

class ExitAppBottomSheet extends ConsumerStatefulWidget {
  const ExitAppBottomSheet({super.key, required this.exit});

  final VoidCallback exit;
  Future<bool> show(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isDismissible: true,
      builder: (_) => this,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      isScrollControlled: true,
      constraints: BoxConstraints(
        maxWidth: MediaQuery.sizeOf(context).width,
      ),
    );
    return result ?? false;
  }

  @override
  ConsumerState<ExitAppBottomSheet> createState() =>
      _FilenameFieldDialogState();
}

class _FilenameFieldDialogState extends ConsumerState<ExitAppBottomSheet> {

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {
        Navigator.of(context).pop(false);
        return false;
      },
      child: Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 16,
            left: 24,
            right: 17),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           CustomTextWidget(
              text:'Exit',
             textStyle:  TextStyle(
               fontSize: FontSizes(context).size18,
               fontFamily: AppFonts.rubik,
               fontWeight: FontWeight.w600,
               color: AppColors.gradientGreen,
             ),
            ),
            5.height,
            CustomTextWidget(
              text:"Are you sure you want to exist?",
              textStyle:  TextStyle(
                fontSize: FontSizes(context).size14,
                fontWeight: FontWeight.w300,
                fontFamily: AppFonts.rubik,
              ),
              textAlignment: TextAlign.center,
            ),
            10.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                    widget.exit();
                  },
                  child:  CustomTextWidget(
                    text:"Exit",
                    textStyle:  TextStyle(
                      fontSize: FontSizes(context).size14,
                      fontFamily: AppFonts.poppins,
                      fontWeight: FontWeight.w300,
                      color: AppColors.black
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(false);
                  },
                  child: CustomTextWidget(
                    text:"Not now",
                    textStyle:  TextStyle(
                      fontSize: FontSizes(context).size14,
                      fontWeight: FontWeight.w400,
                      fontFamily: AppFonts.poppins,
                      color: AppColors.gradientGreen,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




