import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../theme/app_colors.dart';

class TimeSlotWidget extends ConsumerWidget {
  final String time;
  final bool isAvailable;
  final VoidCallback onTap;

  const TimeSlotWidget({
    super.key,
    required this.time,
    required this.isAvailable,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomButtonWidget(
      text: time,
      onPressed: isAvailable ? onTap : null,
      backgroundColor: isAvailable ? AppColors.gradientGreen : Colors.grey.shade300,
      textColor: Colors.white,
      borderRadius: 10,
      width: 80,
      height: 40,
      isEnabled: isAvailable,
    );
  }
}