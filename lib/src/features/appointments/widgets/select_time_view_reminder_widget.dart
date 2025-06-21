import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../../core/utils/debug_print.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../views/select_time_view.dart';

class ReminderWidget extends ConsumerStatefulWidget {
  final String? reminderTime;

  const ReminderWidget({super.key, this.reminderTime});

  @override
  ConsumerState<ReminderWidget> createState() => _ReminderWidgetState();
}

  class _ReminderWidgetState extends ConsumerState<ReminderWidget> {
  @override
  void initState() {
  super.initState();
  Future.microtask(() {
  final reminderOptions = ['No Reminder', '5 min', '10 min', '25 min', '40 min'];
  final incomingReminder = widget.reminderTime;

  final isKnownOption = reminderOptions.contains(incomingReminder);
  final newReminder = incomingReminder == null || incomingReminder.trim().isEmpty
  ? 'No Reminder'
      : isKnownOption
  ? incomingReminder
      : 'Custom';

  ref.read(reminderProvider.notifier).state = newReminder;
  });
  }

  void _showCustomReminderDialog(BuildContext context, WidgetRef ref, String? reminderTime) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const CustomTextWidget(
          text: 'Custom Reminder',
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText:reminderTime ?? 'Enter minutes 1-1440(max one day) ',
            labelStyle: TextStyle(fontSize: FontSizes(context).size12,fontFamily: AppFonts.rubik),
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const CustomTextWidget(
              text: 'Cancel',
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: 14,
                color: AppColors.gradientBlue,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final input = controller.text.trim();
              final minutes = int.tryParse(input);
              if (minutes != null && minutes > 0 && minutes <= 1440) {
                ref.read(reminderProvider.notifier).state = '$minutes min';
                logDebug('Custom reminder set to $minutes min');
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid number between 1 and 1440'),
                  ),
                );
              }
            },
            child: const CustomTextWidget(
              text: 'Set',
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: 14,
                color: AppColors.gradientGreen,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reminderOptions = ['No Reminder', '5 min', '10 min', '25 min', '40 min', 'Custom'];
    final currentReminder = ref.watch(reminderProvider);
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
            children: reminderOptions.map((reminder) {
              final isSelected = currentReminder == reminder;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: GestureDetector(
                  onTap: () {
                    if (reminder == 'Custom') {
                      _showCustomReminderDialog(context, ref,widget.reminderTime);
                    }
                    ref.read(reminderProvider.notifier).state = reminder;
                      logDebug('Reminder set to: $reminder');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    width: ScreenUtil.scaleWidth(context, 80),
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
                          color: isSelected ? AppColors.gradientWhite : AppColors.black,
                          fontFamily: AppFonts.rubik,
                          fontSize:reminder=='No Reminder'|| reminder=='Custom'?9.5: 14,
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