import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/appointments/providers/appointments_providers.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../const/app_strings.dart';
import '../../../shared/widgets/custom_appbar_header_widget.dart';
import '../../../theme/app_colors.dart';
import '../../patient/providers/patient_providers.dart';
import '../models/appointment_model.dart';
import '../widgets/select_time-view_time_slots_widget.dart';
import '../widgets/select_time_view_calendar_widget.dart';
import '../widgets/select_time_view_confirm_booking_button_widget.dart';
import '../widgets/select_time_view_doctor_availability_dialog_widget.dart';
import '../widgets/select_time_view_reminder_widget.dart';

final selectedDayProvider = StateProvider<DateTime?>((ref) => null);
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedTimeSlotProvider = StateProvider<String?>((ref) => null);
final selectedSlotTypeProvider = StateProvider<String?>((ref) => null);
final reminderProvider = StateProvider<String?>((ref) => 'No Reminder');
final categorizedTimeSlotsProvider = StateProvider<Map<String, List<String>>>(
      (ref) => {},
);
class SelectTimeView extends ConsumerStatefulWidget {
  final Doctor doctor;
  final AppointmentModel? appointment;

  const SelectTimeView({super.key, required this.doctor, this.appointment});

  @override
  ConsumerState<SelectTimeView> createState() => _SelectTimeViewState();
}
class _SelectTimeViewState extends ConsumerState<SelectTimeView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final availableDays =
      widget.doctor.availability.map((avail) => avail['day'] as String).toList();
      DateTime initialDay;
      String? initialTimeSlot;
      String? initialSlotType;

      if (widget.appointment != null) {
        try {
          initialDay = DateFormat('yyyy-MM-dd').parse(widget.appointment!.date);
          final now = DateTime.now();
          initialDay = initialDay.isBefore(now)
              ? DateTime(now.year, now.month, now.day)
              : initialDay;
          initialTimeSlot = widget.appointment!.timeSlot;
          initialSlotType = widget.appointment!.slotType;
        } catch (e) {
          initialDay = _findNextAvailableDay(
            availableDays,
            widget.doctor.availability,
          );
          initialTimeSlot = null;
          initialSlotType = null;
        }
      } else {
        initialDay = _findNextAvailableDay(
          availableDays,
          widget.doctor.availability,
        );
      }

      ref.read(selectedDayProvider.notifier).state = initialDay;
      ref.read(focusedDayProvider.notifier).state = initialDay;
      ref.read(selectedTimeSlotProvider.notifier).state = initialTimeSlot;
      ref.read(selectedSlotTypeProvider.notifier).state = initialSlotType;
      _updateTimeSlots(initialDay, availableDays);
    });
  }

  DateTime _findNextAvailableDay(
      List<String> availableDays,
      List<Map<String, dynamic>> doctorAvailability,
      ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (int i = 0; i < 7; i++) {
      final day = today.add(Duration(days: i));
      final dayName = AppStrings.daysOfWeek[day.weekday - 1];

      if (availableDays.contains(dayName)) {
        final availability = doctorAvailability.firstWhere(
              (avail) => avail['day'] == dayName,
          orElse: () => {},
        );

        if (availability.isEmpty) continue;

        List<String> slots = [];

        if (availability['isFullDay'] == true) {
          slots = _generateHourlySlots(
            availability['startTime'],
            availability['endTime'],
          );
        } else {
          if (availability['morning']?['isAvailable'] == true) {
            slots.addAll(
              _generateHourlySlots(
                availability['morning']['startTime'],
                availability['morning']['endTime'],
              ),
            );
          }
          if (availability['afternoon']?['isAvailable'] == true) {
            slots.addAll(
              _generateHourlySlots(
                availability['afternoon']['startTime'],
                availability['afternoon']['endTime'],
              ),
            );
          }
          if (availability['evening']?['isAvailable'] == true) {
            slots.addAll(
              _generateHourlySlots(
                availability['evening']['startTime'],
                availability['evening']['endTime'],
              ),
            );
          }
        }

        if (slots.isEmpty) continue;

        if (i == 0) {
          final remainingSlots = slots.where((slot) {
            final parsedTime = DateFormat('hh:mm a').parse(slot);
            final slotTime = DateTime(
              day.year,
              day.month,
              day.day,
              parsedTime.hour,
              parsedTime.minute,
            );
            return slotTime.isAfter(now);
          }).toList();

          if (remainingSlots.isEmpty) {
            continue;
          }
        }

        return day;
      }
    }

    return today;
  }

  void _updateTimeSlots(DateTime selectedDay, List<String> availableDays) {
    final dayName = AppStrings.daysOfWeek[selectedDay.weekday - 1];
    final availability = widget.doctor.availability.firstWhere(
          (avail) => avail['day'] == dayName,
      orElse: () => {},
    );

    Map<String, List<String>> categorizedSlots = {
      'Morning': [],
      'Afternoon': [],
      'Evening': [],
      'FullDay': [],
    };

    if (availability.isNotEmpty) {
      if (availability['isFullDay'] == true) {
        categorizedSlots['FullDay'] = _generateHourlySlots(
          availability['startTime'],
          availability['endTime'],
        );
      } else {
        if (availability['morning']?['isAvailable'] == true) {
          categorizedSlots['Morning'] = _generateHourlySlots(
            availability['morning']['startTime'],
            availability['morning']['endTime'],
          );
        }
        if (availability['afternoon']?['isAvailable'] == true) {
          categorizedSlots['Afternoon'] = _generateHourlySlots(
            availability['afternoon']['startTime'],
            availability['afternoon']['endTime'],
          );
        }
        if (availability['evening']?['isAvailable'] == true) {
          categorizedSlots['Evening'] = _generateHourlySlots(
            availability['evening']['startTime'],
            availability['evening']['endTime'],
          );
        }
      }
    }

    final now = DateTime.now();
    if (selectedDay.day == now.day &&
        selectedDay.month == now.month &&
        selectedDay.year == now.year) {
      categorizedSlots = categorizedSlots.map((category, slots) {
        return MapEntry(
          category,
          slots.where((slot) {
            final parsedTime = DateFormat('hh:mm a').parse(slot);
            final slotHour = parsedTime.hour;
            final slotMinute = parsedTime.minute;
            return slotHour > now.hour ||
                (slotHour == now.hour && slotMinute > now.minute);
          }).toList(),
        );
      });
    }

    ref.read(categorizedTimeSlotsProvider.notifier).state = categorizedSlots;

    String? selectedTimeSlot = ref.read(selectedTimeSlotProvider);
    String? selectedSlotType = ref.read(selectedSlotTypeProvider);

    if (selectedTimeSlot != null &&
        categorizedSlots[selectedSlotType]?.contains(selectedTimeSlot) == true) {
    } else if (categorizedSlots['FullDay']!.isNotEmpty) {
      ref.read(selectedTimeSlotProvider.notifier).state =
          categorizedSlots['FullDay']!.first;
      ref.read(selectedSlotTypeProvider.notifier).state = 'FullDay';
    } else if (categorizedSlots['Morning']!.isNotEmpty) {
      ref.read(selectedTimeSlotProvider.notifier).state =
          categorizedSlots['Morning']!.first;
      ref.read(selectedSlotTypeProvider.notifier).state = 'Morning';
    } else if (categorizedSlots['Afternoon']!.isNotEmpty) {
      ref.read(selectedTimeSlotProvider.notifier).state =
          categorizedSlots['Afternoon']!.first;
      ref.read(selectedSlotTypeProvider.notifier).state = 'Afternoon';
    } else if (categorizedSlots['Evening']!.isNotEmpty) {
      ref.read(selectedTimeSlotProvider.notifier).state =
          categorizedSlots['Evening']!.first;
      ref.read(selectedSlotTypeProvider.notifier).state = 'Evening';
    } else {
      ref.read(selectedTimeSlotProvider.notifier).state = null;
      ref.read(selectedSlotTypeProvider.notifier).state = null;
    }
  }

  List<String> _generateHourlySlots(String startTime, String endTime) {
    List<String> slots = [];
    DateTime start = DateFormat('hh:mm a').parse(startTime);
    DateTime end = DateFormat('hh:mm a').parse(endTime);

    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    DateTime current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      slots.add(DateFormat('hh:mm a').format(current));
      current = current.add(const Duration(minutes: 5));
    }

    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointment != null;
    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomAppBarHeaderWidget(
                        title: isEditing ? 'Edit Appointment' : 'Appointment',
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.info_outline,
                          color: AppColors.gradientGreen,
                          size: 24,
                        ),
                        onPressed: () => DoctorAvailabilityDialog.show(context, widget.doctor),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CalendarWidget(
                            doctor: widget.doctor,
                            onDaySelected: _updateTimeSlots,
                          ),
                          30.height,
                          const TimeSlotsWidget(),
                          24.height,
                          ReminderWidget(reminderTime:isEditing?widget.appointment!.reminderTime:''),
                          24.height,
                          ConfirmButtonWidget(
                            doctor: widget.doctor,
                            appointment: widget.appointment,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}








