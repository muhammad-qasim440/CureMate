import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'doctor_time_picker_field_widget.dart';

class SlotTimePickers extends ConsumerWidget {
  final StateProvider<String> startProvider;
  final StateProvider<String> endProvider;
  final String startLabel;
  final String endLabel;

  const SlotTimePickers({
    super.key,
    required this.startProvider,
    required this.endProvider,
    required this.startLabel,
    required this.endLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: DoctorTimePickerFieldWidget(
            label: startLabel,
            provider: startProvider,
            hintText: 'Select start time',
          ),
        ),
        10.width,
        Expanded(
          child: DoctorTimePickerFieldWidget(
            label: endLabel,
            provider: endProvider,
            hintText: 'Select end time',
          ),
        ),
      ],
    );
  }
}
