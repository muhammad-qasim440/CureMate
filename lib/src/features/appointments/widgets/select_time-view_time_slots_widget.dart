// TimeSlotsWidget
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../views/select_time_view.dart';

class TimeSlotsWidget extends ConsumerWidget {
  const TimeSlotsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categorizedTimeSlots = ref.watch(categorizedTimeSlotsProvider);

    if (!categorizedTimeSlots.values.any((slots) => slots.isNotEmpty)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomTextWidget(
            text: 'Available Time',
            textStyle: TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          10.height,
          Center(
            child: CustomTextWidget(
              textAlignment: TextAlign.center,
              text: 'Available time ends, Please select any other\n available date or day.',
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size12,
                fontWeight: FontWeight.w500,
                color: AppColors.red,
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CustomTextWidget(
          text: 'Available Time',
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        16.height,
        if (categorizedTimeSlots['FullDay']!.isNotEmpty) ...[
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categorizedTimeSlots['FullDay']!.map((slot) {
                final isSelected = ref.watch(selectedTimeSlotProvider) == slot;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () {
                      ref.read(selectedTimeSlotProvider.notifier).state = slot;
                      ref.read(selectedSlotTypeProvider.notifier).state = 'FullDay';
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10.0,
                        vertical: 4.0,
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
                          text: slot,
                          textAlignment: TextAlign.center,
                          textStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontFamily: AppFonts.rubik,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ] else ...[
          if (categorizedTimeSlots['Morning']!.isNotEmpty) ...[
            const CustomTextWidget(
              text: 'Morning',
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            8.height,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categorizedTimeSlots['Morning']!.map((slot) {
                  final isSelected = ref.watch(selectedTimeSlotProvider) == slot;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedTimeSlotProvider.notifier).state = slot;
                        ref.read(selectedSlotTypeProvider.notifier).state = 'Morning';
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
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
                            text: slot,
                            textAlignment: TextAlign.center,
                            textStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontFamily: AppFonts.rubik,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            16.height,
          ],
          if (categorizedTimeSlots['Afternoon']!.isNotEmpty) ...[
            const CustomTextWidget(
              text: 'Afternoon',
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            8.height,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categorizedTimeSlots['Afternoon']!.map((slot) {
                  final isSelected = ref.watch(selectedTimeSlotProvider) == slot;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedTimeSlotProvider.notifier).state = slot;
                        ref.read(selectedSlotTypeProvider.notifier).state = 'Afternoon';
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
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
                            text: slot,
                            textAlignment: TextAlign.center,
                            textStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontFamily: AppFonts.rubik,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            16.height,
          ],
          if (categorizedTimeSlots['Evening']!.isNotEmpty) ...[
            const CustomTextWidget(
              text: 'Evening',
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            8.height,
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categorizedTimeSlots['Evening']!.map((slot) {
                  final isSelected = ref.watch(selectedTimeSlotProvider) == slot;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedTimeSlotProvider.notifier).state = slot;
                        ref.read(selectedSlotTypeProvider.notifier).state = 'Evening';
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 4.0,
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
                            text: slot,
                            textAlignment: TextAlign.center,
                            textStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontFamily: AppFonts.rubik,
                              fontSize: 13,
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
        ],
      ],
    );
  }
}