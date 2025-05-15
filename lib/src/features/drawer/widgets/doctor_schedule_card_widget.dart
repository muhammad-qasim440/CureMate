import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';

import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';

class DoctorScheduleCardWidget extends StatelessWidget {
  final Map<String, dynamic> config;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const DoctorScheduleCardWidget({
    super.key,
    required this.config,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    print('ScheduleCard config for ${config['day']}: $config');
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomTextWidget(
                  text: config['day']?.toString() ?? 'Unknown',
                  textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontWeight: FontWeight.w600,
                    fontSize: FontSizes(context).size16,
                    color: AppColors.black,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: AppColors.gradientGreen, size: 22),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (config['isFullDay'] == true) ...[
              CustomTextWidget(
                text: 'Full Day: ${config['startTime'] ?? ''} - ${config['endTime'] ?? ''}',
                textStyle: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size14,
                  color: AppColors.subTextColor,
                ),
                maxLines: 2,
              ),
            ] else ...[
              if (config['morning']?['isAvailable'] == true) ...[
                CustomTextWidget(
                  text:
                  'Morning: ${config['morning']['startTime'] ?? ''} - ${config['morning']['endTime'] ?? ''}',
                  textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size14,
                    color: AppColors.subTextColor,
                  ),
                  maxLines: 2,
                ),
                6.height,
              ],
              if (config['afternoon']?['isAvailable'] == true) ...[
                CustomTextWidget(
                  text:
                  'Afternoon: ${config['afternoon']['startTime'] ?? ''} - ${config['afternoon']['endTime'] ?? ''}',
                  textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size14,
                    color: AppColors.subTextColor,
                  ),
                  maxLines: 2,
                ),
                6.height,
              ],
              if (config['evening']?['isAvailable'] == true) ...[
                CustomTextWidget(
                  text:
                  'Evening: ${config['evening']['startTime'] ?? ''} - ${config['evening']['endTime'] ?? ''}',
                  textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size14,
                    color: AppColors.subTextColor,
                  ),
                  maxLines: 2,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}
