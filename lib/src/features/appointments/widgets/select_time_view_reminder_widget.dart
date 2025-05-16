import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../const/app_fonts.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../views/select_time_view.dart';

class ReminderWidget extends ConsumerWidget {
  const ReminderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomTextWidget(
          text: 'Remind Me Before',
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        16.height,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ['1 min', '40 min', '25 min', '10 min', '35 min'].map((reminder) {
              final isSelected = ref.watch(reminderProvider) == reminder;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    ref.read(reminderProvider.notifier).state = reminder;
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    width: ScreenUtil.scaleWidth(context, 60),
                    height: ScreenUtil.scaleHeight(context, 60),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.gradientGreen
                          : AppColors.gradientBlue.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: CustomTextWidget(
                        textAlignment: TextAlign.center,
                        text: reminder.replaceAll(' min', ' Min'),
                        textStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontFamily: AppFonts.rubik,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}