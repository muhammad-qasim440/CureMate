import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../../core/utils/debug_print.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../providers/doctor_schedule_providers.dart';
import 'doctor_schedule_card_widget.dart';

class DoctorScheduleListWidget extends ConsumerWidget {
  final Function(Map<String, dynamic>) onEdit;
  final Function(String) onDelete;

  const DoctorScheduleListWidget({
    super.key,
    required this.onEdit,
    required this.onDelete,
  });

  static const List<String> dayOrder = [
    'Sunday',
    'Saturday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheduleConfigs = ref.watch(scheduleConfigsProvider);
    logDebug('ScheduleList configs: $scheduleConfigs');

    if (scheduleConfigs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.gradientWhite,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.grey.withOpacity(0.5)),
        ),
        child: CustomTextWidget(
          text: 'No availability times added yet. Please add your available days and times.',
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size14,
            color: AppColors.subTextColor,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
    }

    final sortedConfigs = List<Map<String, dynamic>>.from(scheduleConfigs)
      ..sort((a, b) {
        final dayA = a['day']?.toString() ?? '';
        final dayB = b['day']?.toString() ?? '';
        final indexA = dayOrder.indexOf(dayA);
        final indexB = dayOrder.indexOf(dayB);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });

    return ListView.builder(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: sortedConfigs.length,
      itemBuilder: (context, index) {
        final config = sortedConfigs[index];
        return DoctorScheduleCardWidget(
          config: config,
          onEdit: () => onEdit(config),
          onDelete: () => onDelete(config['day']?.toString() ?? ''),
        );
      },
    );
  }
}
