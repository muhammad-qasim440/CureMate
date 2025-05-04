import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/app_strings.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../../theme/app_colors.dart';
import '../providers/signup_form_provider.dart';
import 'package:intl/intl.dart';



class DaySlotSelectorWidget extends ConsumerStatefulWidget {
  const DaySlotSelectorWidget({super.key});

  @override
  ConsumerState<DaySlotSelectorWidget> createState() => _DaySlotSelectorWidgetState();
}

class _DaySlotSelectorWidgetState extends ConsumerState<DaySlotSelectorWidget> {
  final _formKey = GlobalKey<FormState>();
  bool _showInputUI = false;
  String? _editingDay; // Tracks the day being edited, if any

  @override
  Widget build(BuildContext context) {
    final daySlotConfigs = ref.watch(daySlotConfigsProvider);
    final isFullDay = ref.watch(tempFullDayProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Availability Times Section
          const Text(
            'Availability Times',
            style: TextStyle(
              fontFamily: AppFonts.rubik,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: AppColors.black,
            ),
          ),
          10.height,
          if (daySlotConfigs.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.gradientWhite,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.grey.withOpacity(0.5)),
              ),
              child: const Text(
                'No availability times added yet. Please add your available days and times.',
                style: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontSize: 14,
                  color: AppColors.subtextcolor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            10.height,
          ] else ...[
            ...daySlotConfigs.map((config) {
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            config['day'],
                            style: const TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.black,
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: AppColors.gradientGreen, size: 22),
                                onPressed: () => _loadConfigForEdit(config),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                                onPressed: () => _showDeleteConfirmationDialog(context, config['day']),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (config['isFullDay'] == true) ...[
                        Text(
                          'Day: ${config['startTime']} - ${config['endTime']}',
                          style: const TextStyle(
                            fontFamily: AppFonts.rubik,
                            fontSize: 14,
                            color: AppColors.subtextcolor,
                          ),
                        ),
                      ] else ...[
                        if (config['morning']['isAvailable']) ...[
                          Text(
                            'Morning: ${config['morning']['startTime']} - ${config['morning']['endTime']}',
                            style: const TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: 14,
                              color: AppColors.subtextcolor,
                            ),
                          ),
                          4.height,
                        ],
                        if (config['afternoon']['isAvailable']) ...[
                          Text(
                            'Afternoon: ${config['afternoon']['startTime']} - ${config['afternoon']['endTime']}',
                            style: const TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: 14,
                              color: AppColors.subtextcolor,
                            ),
                          ),
                          4.height,
                        ],
                        if (config['evening']['isAvailable']) ...[
                          Text(
                            'Evening: ${config['evening']['startTime']} - ${config['evening']['endTime']}',
                            style: const TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: 14,
                              color: AppColors.subtextcolor,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
            10.height,
          ],
          // Add Availability Time Button
          Center(
            child: CustomButtonWidget(
              text: 'Add',
              height: ScreenUtil.scaleHeight(context, 40),
              width: ScreenUtil.scaleWidth(context, 100),
              backgroundColor: AppColors.gradientWhite,
              borderColor: AppColors.btnBgColor,
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size14,
              fontWeight: FontWeight.w600,
              textColor: AppColors.btnBgColor,
              icon: const Icon(Icons.add, color: AppColors.btnBgColor, size: 20),
              onPressed: () {
                setState(() {
                  _showInputUI = true;
                  _editingDay = null;
                  ref.read(tempDayProvider.notifier).state = '';
                  ref.read(tempFullDayProvider.notifier).state = false;
                  ref.read(tempFullDayStartTimeProvider.notifier).state = '';
                  ref.read(tempFullDayEndTimeProvider.notifier).state = '';
                  ref.read(tempMorningAvailabilityProvider.notifier).state = false;
                  ref.read(tempMorningStartTimeProvider.notifier).state = '';
                  ref.read(tempMorningEndTimeProvider.notifier).state = '';
                  ref.read(tempAfternoonAvailabilityProvider.notifier).state = false;
                  ref.read(tempAfternoonStartTimeProvider.notifier).state = '';
                  ref.read(tempAfternoonEndTimeProvider.notifier).state = '';
                  ref.read(tempEveningAvailabilityProvider.notifier).state = false;
                  ref.read(tempEveningStartTimeProvider.notifier).state = '';
                  ref.read(tempEveningEndTimeProvider.notifier).state = '';
                });
              },
            ),
          ),
          // Input UI (Shown when _showInputUI is true)
          if (_showInputUI) ...[
            23.height,
            const Text(
              'Select Day',
              style: TextStyle(
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w500,
                fontSize: 16,
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
                    color: isSelected ? Colors.white : AppColors.subtextcolor,
                    fontFamily: AppFonts.rubik,
                  ),
                );
              }).toList(),
            ),
            23.height,
            const Text(
              'Select Available Slots',
              style: TextStyle(
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppColors.black,
              ),
            ),
            10.height,
            // Full Day Slot
            Row(
              children: [
                Checkbox(
                  value: isFullDay,
                  onChanged: (value) {
                    ref.read(tempFullDayProvider.notifier).state = value ?? false;
                    if (value == true) {
                      // Clear other slots
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
                  activeColor: AppColors.gradientGreen,
                ),
                const Text(
                  'Full Day',
                  style: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: 14,
                    color: AppColors.subtextcolor,
                  ),
                ),
              ],
            ),
            if (isFullDay) ...[
              10.height,
              Row(
                children: [
                  Expanded(
                    child: _buildTimePickerField(
                      context,
                      'Start Time',
                      tempFullDayStartTimeProvider,
                      'Select start time',
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: _buildTimePickerField(
                      context,
                      'End Time',
                      tempFullDayEndTimeProvider,
                      'Select end time',
                    ),
                  ),
                ],
              ),
            ],
            10.height,
            // Morning Slot
            Row(
              children: [
                Checkbox(
                  value: ref.watch(tempMorningAvailabilityProvider),
                  onChanged: isFullDay
                      ? null
                      : (value) {
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
                  activeColor: AppColors.gradientGreen,
                ),
                const Text(
                  'Morning',
                  style: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: 14,
                    color: AppColors.subtextcolor,
                  ),
                ),
              ],
            ),
            if (ref.watch(tempMorningAvailabilityProvider)) ...[
              10.height,
              Row(
                children: [
                  Expanded(
                    child: _buildTimePickerField(
                      context,
                      'Morning Start Time',
                      tempMorningStartTimeProvider,
                      'Select start time',
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: _buildTimePickerField(
                      context,
                      'Morning End Time',
                      tempMorningEndTimeProvider,
                      'Select end time',
                    ),
                  ),
                ],
              ),
            ],
            10.height,
            // Afternoon Slot
            Row(
              children: [
                Checkbox(
                  value: ref.watch(tempAfternoonAvailabilityProvider),
                  onChanged: isFullDay
                      ? null
                      : (value) {
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
                  activeColor: AppColors.gradientGreen,
                ),
                const Text(
                  'Afternoon',
                  style: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: 14,
                    color: AppColors.subtextcolor,
                  ),
                ),
              ],
            ),
            if (ref.watch(tempAfternoonAvailabilityProvider)) ...[
              10.height,
              Row(
                children: [
                  Expanded(
                    child: _buildTimePickerField(
                      context,
                      'Afternoon Start Time',
                      tempAfternoonStartTimeProvider,
                      'Select start time',
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: _buildTimePickerField(
                      context,
                      'Afternoon End Time',
                      tempAfternoonEndTimeProvider,
                      'Select end time',
                    ),
                  ),
                ],
              ),
            ],
            10.height,
            // Evening Slot
            Row(
              children: [
                Checkbox(
                  value: ref.watch(tempEveningAvailabilityProvider),
                  onChanged: isFullDay
                      ? null
                      : (value) {
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
                  activeColor: AppColors.gradientGreen,
                ),
                const Text(
                  'Evening',
                  style: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: 14,
                    color: AppColors.subtextcolor,
                  ),
                ),
              ],
            ),
            if (ref.watch(tempEveningAvailabilityProvider)) ...[
              10.height,
              Row(
                children: [
                  Expanded(
                    child: _buildTimePickerField(
                      context,
                      'Evening Start Time',
                      tempEveningStartTimeProvider,
                      'Select start time',
                    ),
                  ),
                  10.width,
                  Expanded(
                    child: _buildTimePickerField(
                      context,
                      'Evening End Time',
                      tempEveningEndTimeProvider,
                      'Select end time',
                    ),
                  ),
                ],
              ),
            ],
            23.height,
            // Add to List Button
            Center(
              child: CustomButtonWidget(
                text: _editingDay != null ? 'Update' : 'Add to List',
                height: ScreenUtil.scaleHeight(context, 40),
                width: ScreenUtil.scaleWidth(context, 150),
                backgroundColor: AppColors.gradientWhite,
                borderColor: AppColors.btnBgColor,
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size14,
                fontWeight: FontWeight.w600,
                textColor: AppColors.btnBgColor,
                icon: const Icon(Icons.add, color: AppColors.btnBgColor, size: 20),
                onPressed: _isInputValid() ? () => _addOrUpdateConfig(context) : null,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _isInputValid() {
    final day = ref.read(tempDayProvider);
    final isFullDay = ref.read(tempFullDayProvider);
    final fullDayStart = ref.read(tempFullDayStartTimeProvider);
    final fullDayEnd = ref.read(tempFullDayEndTimeProvider);
    final morningAvailable = ref.read(tempMorningAvailabilityProvider);
    final morningStart = ref.read(tempMorningStartTimeProvider);
    final morningEnd = ref.read(tempMorningEndTimeProvider);
    final afternoonAvailable = ref.read(tempAfternoonAvailabilityProvider);
    final afternoonStart = ref.read(tempAfternoonStartTimeProvider);
    final afternoonEnd = ref.read(tempAfternoonEndTimeProvider);
    final eveningAvailable = ref.read(tempEveningAvailabilityProvider);
    final eveningStart = ref.read(tempEveningStartTimeProvider);
    final eveningEnd = ref.read(tempEveningEndTimeProvider);

    if (day.isEmpty) return false;
    if (isFullDay) {
      return _isValidTimeRange(fullDayStart, fullDayEnd);
    } else {
      if (!morningAvailable && !afternoonAvailable && !eveningAvailable) return false;
      if (morningAvailable && !_isValidTimeRange(morningStart, morningEnd)) return false;
      if (afternoonAvailable && !_isValidTimeRange(afternoonStart, afternoonEnd)) return false;
      if (eveningAvailable && !_isValidTimeRange(eveningStart, eveningEnd)) return false;
      return true;
    }
  }

  bool _isValidTimeRange(String startTime, String endTime) {
    if (startTime.isEmpty || endTime.isEmpty) return false;
    try {
      final format = DateFormat('h:mm a');
      final start = format.parse(startTime);
      final end = format.parse(endTime);
      // Ensure end time is after start time and within the same day
      return end.isAfter(start) && end.difference(start).inMinutes > 0;
    } catch (e) {
      return false;
    }
  }

  bool _isFullDaySlot(String startTime, String endTime) {
    try {
      final format = DateFormat('h:mm a');
      final start = format.parse(startTime);
      final end = format.parse(endTime);
      final duration = end.difference(start).inHours;
      final startHour = start.hour;
      final endHour = end.hour;

      // Full-day if duration is 8 hours or more OR spans morning to evening
      return duration >= 8 || (startHour < 12 && endHour >= 16);
    } catch (e) {
      return false;
    }
  }

  Map<String, dynamic>? _mergeSlots({
    required bool morningAvailable,
    required String morningStart,
    required String morningEnd,
    required bool afternoonAvailable,
    required String afternoonStart,
    required String afternoonEnd,
    required bool eveningAvailable,
    required String eveningStart,
    required String eveningEnd,
  }) {
    final format = DateFormat('h:mm a');
    List<Map<String, dynamic>> slots = [];

    // Collect all selected slots
    if (morningAvailable && morningStart.isNotEmpty && morningEnd.isNotEmpty) {
      slots.add({
        'start': format.parse(morningStart),
        'end': format.parse(morningEnd),
      });
    }
    if (afternoonAvailable && afternoonStart.isNotEmpty && afternoonEnd.isNotEmpty) {
      slots.add({
        'start': format.parse(afternoonStart),
        'end': format.parse(afternoonEnd),
      });
    }
    if (eveningAvailable && eveningStart.isNotEmpty && eveningEnd.isNotEmpty) {
      slots.add({
        'start': format.parse(eveningStart),
        'end': format.parse(eveningEnd),
      });
    }

    if (slots.isEmpty) return null;

    // Sort slots by start time
    slots.sort((a, b) => a['start'].compareTo(b['start']));

    // Merge overlapping or continuous slots
    List<Map<String, dynamic>> merged = [];
    var current = slots[0];
    for (var i = 1; i < slots.length; i++) {
      if (slots[i]['start'].isBefore(current['end']) || slots[i]['start'] == current['end']) {
        current['end'] = slots[i]['end'].isAfter(current['end']) ? slots[i]['end'] : current['end'];
      } else {
        merged.add(current);
        current = slots[i];
      }
    }
    merged.add(current);

    // Check if the merged range qualifies as full-day
    if (merged.length == 1 && _isFullDaySlot(format.format(merged[0]['start']), format.format(merged[0]['end']))) {
      return {
        'isFullDay': true,
        'startTime': format.format(merged[0]['start']),
        'endTime': format.format(merged[0]['end']),
      };
    }

    // Return standard multi-slot config if not full-day
    return {
      'isFullDay': false,
      'morning': {
        'isAvailable': morningAvailable,
        'startTime': morningStart,
        'endTime': morningEnd,
      },
      'afternoon': {
        'isAvailable': afternoonAvailable,
        'startTime': afternoonStart,
        'endTime': afternoonEnd,
      },
      'evening': {
        'isAvailable': eveningAvailable,
        'startTime': eveningStart,
        'endTime': eveningEnd,
      },
    };
  }

  void _addOrUpdateConfig(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    final day = ref.read(tempDayProvider);
    final isFullDay = ref.read(tempFullDayProvider);
    final fullDayStart = ref.read(tempFullDayStartTimeProvider);
    final fullDayEnd = ref.read(tempFullDayEndTimeProvider);
    final morningAvailable = ref.read(tempMorningAvailabilityProvider);
    final morningStart = ref.read(tempMorningStartTimeProvider);
    final morningEnd = ref.read(tempMorningEndTimeProvider);
    final afternoonAvailable = ref.read(tempAfternoonAvailabilityProvider);
    final afternoonStart = ref.read(tempAfternoonStartTimeProvider);
    final afternoonEnd = ref.read(tempAfternoonEndTimeProvider);
    final eveningAvailable = ref.read(tempEveningAvailabilityProvider);
    final eveningStart = ref.read(tempEveningStartTimeProvider);
    final eveningEnd = ref.read(tempEveningEndTimeProvider);

    Map<String, dynamic> config;

    if (isFullDay) {
      config = {
        'day': day,
        'isFullDay': true,
        'startTime': fullDayStart,
        'endTime': fullDayEnd,
      };
    } else {
      final configData = _mergeSlots(
        morningAvailable: morningAvailable,
        morningStart: morningStart,
        morningEnd: morningEnd,
        afternoonAvailable: afternoonAvailable,
        afternoonStart: afternoonStart,
        afternoonEnd: afternoonEnd,
        eveningAvailable: eveningAvailable,
        eveningStart: eveningStart,
        eveningEnd: eveningEnd,
      );

      if (configData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid configuration')),
        );
        return;
      }

      config = {'day': day, ...configData};
    }

    final currentConfigs = ref.read(daySlotConfigsProvider);
    if (_editingDay == null && currentConfigs.any((c) => c['day'] == day)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$day is already added. Please edit the existing configuration.')),
      );
      return;
    }
    if (_editingDay != null) {
      // Update existing configuration
      ref.read(daySlotConfigsProvider.notifier).state = [
        ...currentConfigs.where((c) => c['day'] != _editingDay),
        config,
      ];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$day updated successfully')),
      );
    } else {
      ref.read(daySlotConfigsProvider.notifier).state = [...currentConfigs, config];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$day added successfully')),
      );
    }
    // Hide input UI and reset
    setState(() {
      _showInputUI = false;
      _editingDay = null;
    });
    ref.read(tempDayProvider.notifier).state = '';
    ref.read(tempFullDayProvider.notifier).state = false;
    ref.read(tempFullDayStartTimeProvider.notifier).state = '';
    ref.read(tempFullDayEndTimeProvider.notifier).state = '';
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

  void _loadConfigForEdit(Map<String, dynamic> config) {
    setState(() {
      _showInputUI = true;
      _editingDay = config['day'];
    });
    ref.read(tempDayProvider.notifier).state = config['day'];
    if (config['isFullDay'] == true) {
      // Load full-day configuration
      ref.read(tempFullDayProvider.notifier).state = true;
      ref.read(tempFullDayStartTimeProvider.notifier).state = config['startTime'];
      ref.read(tempFullDayEndTimeProvider.notifier).state = config['endTime'];
      ref.read(tempMorningAvailabilityProvider.notifier).state = false;
      ref.read(tempMorningStartTimeProvider.notifier).state = '';
      ref.read(tempMorningEndTimeProvider.notifier).state = '';
      ref.read(tempAfternoonAvailabilityProvider.notifier).state = false;
      ref.read(tempAfternoonStartTimeProvider.notifier).state = '';
      ref.read(tempAfternoonEndTimeProvider.notifier).state = '';
      ref.read(tempEveningAvailabilityProvider.notifier).state = false;
      ref.read(tempEveningStartTimeProvider.notifier).state = '';
      ref.read(tempEveningEndTimeProvider.notifier).state = '';
    } else {
      // Load standard multi-slot configuration
      ref.read(tempFullDayProvider.notifier).state = false;
      ref.read(tempFullDayStartTimeProvider.notifier).state = '';
      ref.read(tempFullDayEndTimeProvider.notifier).state = '';
      ref.read(tempMorningAvailabilityProvider.notifier).state = config['morning']['isAvailable'];
      ref.read(tempMorningStartTimeProvider.notifier).state = config['morning']['startTime'];
      ref.read(tempMorningEndTimeProvider.notifier).state = config['morning']['endTime'];
      ref.read(tempAfternoonAvailabilityProvider.notifier).state = config['afternoon']['isAvailable'];
      ref.read(tempAfternoonStartTimeProvider.notifier).state = config['afternoon']['startTime'];
      ref.read(tempAfternoonEndTimeProvider.notifier).state = config['afternoon']['endTime'];
      ref.read(tempEveningAvailabilityProvider.notifier).state = config['evening']['isAvailable'];
      ref.read(tempEveningStartTimeProvider.notifier).state = config['evening']['startTime'];
      ref.read(tempEveningEndTimeProvider.notifier).state = config['evening']['endTime'];
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String day) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Confirm Deletion',
          style: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove $day\'s availability?',
          style: const TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontFamily: AppFonts.rubik,
                color: AppColors.subtextcolor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              final daySlotConfigs = ref.read(daySlotConfigsProvider);
              ref.read(daySlotConfigsProvider.notifier).state =
                  daySlotConfigs.where((c) => c['day'] != day).toList();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$day removed successfully')),
              );
              // Hide input UI if editing the removed day
              if (_editingDay == day) {
                setState(() {
                  _showInputUI = false;
                  _editingDay = null;
                });
                ref.read(tempDayProvider.notifier).state = '';
                ref.read(tempFullDayProvider.notifier).state = false;
                ref.read(tempFullDayStartTimeProvider.notifier).state = '';
                ref.read(tempFullDayEndTimeProvider.notifier).state = '';
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
            child: const Text(
              'Remove',
              style: TextStyle(
                fontFamily: AppFonts.rubik,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerField(
      BuildContext context,
      String label,
      StateProvider<String> provider,
      String hintText,
      ) {
    final timeString = ref.watch(provider);
    TimeOfDay initialTime = TimeOfDay.now();

    // Parse stored time for pre-population
    if (timeString.isNotEmpty) {
      try {
        final format = DateFormat('h:mm a');
        final dateTime = format.parse(timeString);
        initialTime = TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
      } catch (e) {
        // Fallback to current time if parsing fails
      }
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
                  onSurface: AppColors.subtextcolor,
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
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          fontFamily: AppFonts.rubik,
          color: AppColors.subtextcolor,
        ),
      ),
    );
  }
}