import 'dart:ui';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/app_strings.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../helpers/doctor_schedule_services.dart';
import '../providers/doctor_schedule_providers.dart';
import 'doctor_slot_checkbox_widget.dart';
import 'doctor_slot_time_picker_widget.dart';

class DoctorAddSlotFormWidget extends ConsumerWidget {
  final bool isEditing;
  final VoidCallback onAddOrUpdate;
  final GlobalKey<FormState> formKey;

  const DoctorAddSlotFormWidget({
    super.key,
    required this.isEditing,
    required this.onAddOrUpdate,
    required this.formKey,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFullDay = ref.watch(tempFullDayProvider);
    final service = DoctorScheduleService(ref);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          text: 'Select Day',
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w500,
            fontSize: FontSizes(context).size16,
            color: AppColors.black,
          ),
        ),
        10.height,
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: AppStrings.daysOfWeek.map((day) {
            final selectedDay = ref.watch(tempDayProvider);
            final isSelected = selectedDay == day;
            return ChoiceChip(
              label: Text(day),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(tempDayProvider.notifier).state = day;
                }
              },
              selectedColor: AppColors.gradientGreen,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.subTextColor,
                fontFamily: AppFonts.rubik,
              ),
            );
          }).toList(),
        ),
        23.height,
        CustomTextWidget(
          text: 'Select Available Slots',
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w500,
            fontSize: FontSizes(context).size16,
            color: AppColors.black,
          ),
        ),
        10.height,
        DoctorSlotCheckboxWidget(
          label: 'Full Day',
          isChecked: isFullDay,
          onChanged: (value) {
            ref.read(tempFullDayProvider.notifier).state = value ?? false;
            if (value == true) {
              ref.read(tempMorningAvailabilityProvider.notifier).state = false;
              ref.read(tempMorningStartTimeProvider.notifier).state = '';
              ref.read(tempMorningEndTimeProvider.notifier).state = '';
              ref.read(tempAfternoonAvailabilityProvider.notifier).state = false;
              ref.read(tempAfternoonStartTimeProvider.notifier).state = '';
              ref.read(tempAfternoonEndTimeProvider.notifier).state = '';
              ref.read(tempEveningAvailabilityProvider.notifier).state = false;
              ref.read(tempEveningStartTimeProvider.notifier).state = '';
              ref.read(tempEveningEndTimeProvider.notifier).state = '';
            }
          },
        ),
        if (isFullDay) ...[
          10.height,
          SlotTimePickers(
            startProvider: tempFullDayStartTimeProvider,
            endProvider: tempFullDayEndTimeProvider,
            startLabel: 'Start Time',
            endLabel: 'End Time',
          ),
        ],
        10.height,
        DoctorSlotCheckboxWidget(
          label: 'Morning',
          isChecked: ref.watch(tempMorningAvailabilityProvider),
          isDisabled: isFullDay,
          onChanged: (value) {
            ref.read(tempMorningAvailabilityProvider.notifier).state = value ?? false;
            if (value == true) {
              ref.read(tempFullDayProvider.notifier).state = false;
              ref.read(tempFullDayStartTimeProvider.notifier).state = '';
              ref.read(tempFullDayEndTimeProvider.notifier).state = '';
            }
            if (!(value ?? false)) {
              ref.read(tempMorningStartTimeProvider.notifier).state = '';
              ref.read(tempMorningEndTimeProvider.notifier).state = '';
            }
          },
        ),
        if (ref.watch(tempMorningAvailabilityProvider)) ...[
          10.height,
          SlotTimePickers(
            startProvider: tempMorningStartTimeProvider,
            endProvider: tempMorningEndTimeProvider,
            startLabel: 'Morning Start Time',
            endLabel: 'Morning End Time',
          ),
        ],
        10.height,
        DoctorSlotCheckboxWidget(
          label: 'Afternoon',
          isChecked: ref.watch(tempAfternoonAvailabilityProvider),
          isDisabled: isFullDay,
          onChanged: (value) {
            ref.read(tempAfternoonAvailabilityProvider.notifier).state = value ?? false;
            if (value == true) {
              ref.read(tempFullDayProvider.notifier).state = false;
              ref.read(tempFullDayStartTimeProvider.notifier).state = '';
              ref.read(tempFullDayEndTimeProvider.notifier).state = '';
            }
            if (!(value ?? false)) {
              ref.read(tempAfternoonStartTimeProvider.notifier).state = '';
              ref.read(tempAfternoonEndTimeProvider.notifier).state = '';
            }
          },
        ),
        if (ref.watch(tempAfternoonAvailabilityProvider)) ...[
          10.height,
          SlotTimePickers(
            startProvider: tempAfternoonStartTimeProvider,
            endProvider: tempAfternoonEndTimeProvider,
            startLabel: 'Afternoon Start Time',
            endLabel: 'Afternoon End Time',
          ),
        ],
        10.height,
        DoctorSlotCheckboxWidget(
          label: 'Evening',
          isChecked: ref.watch(tempEveningAvailabilityProvider),
          isDisabled: isFullDay,
          onChanged: (value) {
            ref.read(tempEveningAvailabilityProvider.notifier).state = value ?? false;
            if (value == true) {
              ref.read(tempFullDayProvider.notifier).state = false;
              ref.read(tempFullDayStartTimeProvider.notifier).state = '';
              ref.read(tempFullDayEndTimeProvider.notifier).state = '';
            }
            if (!(value ?? false)) {
              ref.read(tempEveningStartTimeProvider.notifier).state = '';
              ref.read(tempEveningEndTimeProvider.notifier).state = '';
            }
          },
        ),
        if (ref.watch(tempEveningAvailabilityProvider)) ...[
          10.height,
          SlotTimePickers(
            startProvider: tempEveningStartTimeProvider,
            endProvider: tempEveningEndTimeProvider,
            startLabel: 'Evening Start Time',
            endLabel: 'Evening End Time',
          ),
        ],
        23.height,
        Center(
          child: CustomButtonWidget(
            text: isEditing ? 'Update Slot' : 'Add Slot',
            height: ScreenUtil.scaleHeight(context, 40),
            width: ScreenUtil.scaleWidth(context, 150),
            backgroundColor: AppColors.gradientWhite,
            borderColor: AppColors.btnBgColor,
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size14,
            fontWeight: FontWeight.w600,
            textColor: AppColors.btnBgColor,
            icon: const Icon(Icons.add, color: AppColors.btnBgColor, size: 20),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final error = await service.addOrUpdateConfig(editingDay: ref.read(editingDayProvider));
                if (error != null) {
                  CustomSnackBarWidget.show(context: context, text: error);
                } else {
                  print('Schedule configs after update: ${ref.read(scheduleConfigsProvider)}');
                  ref.read(showInputUIProvider.notifier).state = false;
                  ref.read(editingDayProvider.notifier).state = null;
                  CustomSnackBarWidget.show(
                    context: context,
                    text: isEditing
                        ? '${ref.read(editingDayProvider) ?? 'Slot'} updated successfully'
                        : 'Slot added successfully',
                  );
                }
              }
            },
          ),
        ),
      ],
    );
  }
}
