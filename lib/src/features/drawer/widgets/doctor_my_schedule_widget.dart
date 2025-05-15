import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_confirmation_dialog_widget.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_form_field_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/app_strings.dart';
import '../../../../../const/font_sizes.dart';
import '../../../theme/app_colors.dart';
import '../helpers/doctor_schedule_services.dart';
import '../providers/doctor_schedule_providers.dart';

class DoctorMyScheduleViewWidget extends ConsumerStatefulWidget {
  const DoctorMyScheduleViewWidget({super.key});

  @override
  ConsumerState<DoctorMyScheduleViewWidget> createState() => _DoctorMyScheduleViewWidgetState();
}

class _DoctorMyScheduleViewWidgetState extends ConsumerState<DoctorMyScheduleViewWidget> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = DoctorScheduleService(ref);
      if (mounted) {
        service.loadAvailability();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final service = DoctorScheduleService(ref);
    final isShowInputUI = ref.watch(showInputUIProvider);
    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16),
              child: Column(
                children: [
                  const CustomAppBarHeaderWidget(title: 'My Schedule'),
                  25.height,
                  Expanded(
                    child: Form(
                      key: formKey,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final availabilityAsync = ref.watch(doctorAvailabilityProvider);
                          return availabilityAsync.when(
                            data: (data) {
                              return _buildContent(context, ref, service, formKey);
                            },
                            loading: () => const Center(child: CircularProgressIndicator()),
                            error: (error, _) => Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomTextWidget(
                                    text: 'Failed to load schedule. Please try again.',
                                    textStyle: TextStyle(
                                      fontFamily: AppFonts.rubik,
                                      fontSize: FontSizes(context).size14,
                                      color: Colors.red,
                                    ),
                                  ),
                                  10.height,
                                  CustomButtonWidget(
                                    text: 'Retry',
                                    height: ScreenUtil.scaleHeight(context, 40),
                                    width: ScreenUtil.scaleWidth(context, 150),
                                    backgroundColor: AppColors.gradientGreen,
                                    fontFamily: AppFonts.rubik,
                                    fontSize: FontSizes(context).size14,
                                    fontWeight: FontWeight.w600,
                                    textColor: Colors.white,
                                    onPressed: () {
                                      ref.invalidate(doctorAvailabilityProvider);
                                      if (mounted) {
                                        service.loadAvailability();
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: ScreenUtil.scaleHeight(context, 90),
            right: ScreenUtil.scaleHeight(context, 10),
            child: FloatingActionButton(
              onPressed: () {
                if (isShowInputUI) {
                  ref.read(showInputUIProvider.notifier).state = false;
                  service.resetTempProviders();
                } else {
                  ref.read(showInputUIProvider.notifier).state = true;
                }
                ref.read(editingDayProvider.notifier).state = null;
                service.resetTempProviders();
              },
              backgroundColor: AppColors.gradientGreen,
              mini: true,
              child: Icon(
                isShowInputUI ? Icons.close : Icons.add,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WidgetRef ref, DoctorScheduleService service, GlobalKey<FormState> formKey) {
    final showInputUI = ref.watch(showInputUIProvider);
    final editingDay = ref.watch(editingDayProvider);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ScheduleHeader(),
          10.height,
          ScheduleList(
            onEdit: (config) {
              ref.read(showInputUIProvider.notifier).state = true;
              ref.read(editingDayProvider.notifier).state = config['day']?.toString();
              service.loadConfigForEdit(config);
            },
            onDelete: (day) => _showDeleteConfirmationDialog(context, ref, service, day),
          ),
          20.height,
          if (showInputUI) ...[
            23.height,
            AddSlotForm(
              isEditing: editingDay != null,
              onAddOrUpdate: () async {
                final error = service.addOrUpdateConfig(editingDay: editingDay);
                if (error != null) {
                  CustomSnackBarWidget.show(context: context, text: error.toString());
                } else {
                  CustomSnackBarWidget.show(
                    context: context,
                    text: editingDay != null
                        ? '$editingDay updated successfully'
                        : 'Slot added successfully',
                  );
                  ref.read(showInputUIProvider.notifier).state = false;
                  ref.read(editingDayProvider.notifier).state = null;
                }
              },
              formKey: formKey,
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, WidgetRef ref, DoctorScheduleService service, String day) {
    showDialog(
      context: context,
      builder: (context) => CustomConfirmationDialogWidget(
        title: 'Confirm Deletion',
        content: 'Are you sure you want to remove $day\'s availability?',
        confirmText: 'Remove',
        cancelText: 'Cancel',
        onConfirm: () async {
          final editingDay = ref.read(editingDayProvider);
          final error = await service.deleteConfig(day, editingDay: editingDay);
          if (error != null) {
            CustomSnackBarWidget.show(context: context, text: error);
          } else {
            CustomSnackBarWidget.show(context: context, text: '$day removed successfully');
            if (editingDay == day) {
              ref.read(showInputUIProvider.notifier).state = false;
              ref.read(editingDayProvider.notifier).state = null;
            }
          }
        },
        onCancel: () {},
      ),
    );
  }
}

class ScheduleList extends ConsumerWidget {
  final Function(Map<String, dynamic>) onEdit;
  final Function(String) onDelete;

  const ScheduleList({
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
    print('ScheduleList configs: $scheduleConfigs');

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
        return ScheduleCard(
          config: config,
          onEdit: () => onEdit(config),
          onDelete: () => onDelete(config['day']?.toString() ?? ''),
        );
      },
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final Map<String, dynamic> config;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ScheduleCard({
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

class ScheduleHeader extends StatelessWidget {
  const ScheduleHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomTextWidget(
      text: 'Your Availability',
      textStyle: TextStyle(
        fontFamily: AppFonts.rubik,
        fontWeight: FontWeight.w500,
        fontSize: FontSizes(context).size16,
        color: AppColors.black,
      ),
    );
  }
}

class AddSlotForm extends ConsumerWidget {
  final bool isEditing;
  final VoidCallback onAddOrUpdate;
  final GlobalKey<FormState> formKey;

  const AddSlotForm({
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
        SlotCheckbox(
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
        SlotCheckbox(
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
        SlotCheckbox(
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
        SlotCheckbox(
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

class SlotCheckbox extends StatelessWidget {
  final String label;
  final bool isChecked;
  final bool isDisabled;
  final ValueChanged<bool?> onChanged;

  const SlotCheckbox({
    super.key,
    required this.label,
    required this.isChecked,
    this.isDisabled = false,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: isChecked,
          onChanged: isDisabled ? null : onChanged,
          activeColor: AppColors.gradientGreen,
        ),
        CustomTextWidget(
          text: label,
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size14,
            color: AppColors.subTextColor,
          ),
        ),
      ],
    );
  }
}

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
          child: TimePickerField(
            label: startLabel,
            provider: startProvider,
            hintText: 'Select start time',
          ),
        ),
        10.width,
        Expanded(
          child: TimePickerField(
            label: endLabel,
            provider: endProvider,
            hintText: 'Select end time',
          ),
        ),
      ],
    );
  }
}

class TimePickerField extends ConsumerWidget {
  final String label;
  final StateProvider<String> provider;
  final String hintText;

  const TimePickerField({
    super.key,
    required this.label,
    required this.provider,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeString = ref.watch(provider);
    TimeOfDay initialTime = TimeOfDay.now();

    if (timeString.isNotEmpty) {
      try {
        final format = DateFormat('h:mm a');
        final dateTime = format.parse(timeString);
        initialTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      } catch (e) {}
    }

    return InkWell(
      onTap: () async {
        final TimeOfDay? picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (BuildContext context, Widget? child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: AppColors.btnBgColor,
                  onPrimary: AppColors.gradientWhite,
                  onSurface: AppColors.subTextColor,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gradientGreen,
                  ),
                ),
              ),
              child: child!,
            );
          },
        );
        if (picked != null) {
          final formattedTime = picked.format(context);
          ref.read(provider.notifier).state = formattedTime;
        }
      },
      child: CustomTextFormFieldWidget(
        label: label,
        hintText: hintText,
        enabled: false,
        controller: TextEditingController(text: timeString),
        validator: (value) {
          if (timeString.isEmpty) {
            return 'Please select a time';
          }
          return null;
        },
        textStyle: TextStyle(
          fontFamily: AppFonts.rubik,
          fontWeight: FontWeight.w400,
          fontSize: FontSizes(context).size14,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(color: AppColors.grey),
        ),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: FontSizes(context).size14,
          fontFamily: AppFonts.rubik,
          color: AppColors.subTextColor,
        ),
      ),
    );
  }
}