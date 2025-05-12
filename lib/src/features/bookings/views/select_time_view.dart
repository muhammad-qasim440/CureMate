import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/core/utils/debug_print.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/app_strings.dart';
import '../../../../const/font_sizes.dart';
import '../../../router/nav.dart';
import '../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../shared/widgets/custom_appbar_header_widget.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../bookings/models/appointment_model.dart';
import '../../patient/providers/patient_providers.dart';
import '../providers/booking_providers.dart';
import 'confirmation_view.dart';

final selectedDayProvider = StateProvider<DateTime?>((ref) => null);
final focusedDayProvider = StateProvider<DateTime>((ref) => DateTime.now());
final selectedTimeSlotProvider = StateProvider<String?>((ref) => null);
final selectedSlotTypeProvider = StateProvider<String?>((ref) => null);
final reminderProvider = StateProvider<String>((ref) => '25 min');
final categorizedTimeSlotsProvider = StateProvider<Map<String, List<String>>>(
      (ref) => {},
);

class SelectTimeView extends ConsumerStatefulWidget {
  final Doctor doctor;
  final AppointmentModel? appointment; // Add this for editing

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
          // Clamp initialDay to at least DateTime.now()
          final now = DateTime.now();
          initialDay = initialDay.isBefore(now)
              ? DateTime(now.year, now.month, now.day)
              : initialDay;
          initialTimeSlot = widget.appointment!.timeSlot;
          initialSlotType = widget.appointment!.slotType;
        } catch (e) {
          initialDay = findNextAvailableDay(
            availableDays,
            widget.doctor.availability,
          );
          initialTimeSlot = null;
          initialSlotType = null;
        }
      } else {
        initialDay = findNextAvailableDay(
          availableDays,
          widget.doctor.availability,
        );
      }

      ref.read(selectedDayProvider.notifier).state = initialDay;
      ref.read(focusedDayProvider.notifier).state = initialDay;
      ref.read(selectedTimeSlotProvider.notifier).state = initialTimeSlot;
      ref.read(selectedSlotTypeProvider.notifier).state = initialSlotType;
      updateTimeSlots(initialDay, availableDays);
    });
  }

  DateTime findNextAvailableDay(
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
          slots = generateHourlySlots(
            availability['startTime'],
            availability['endTime'],
          );
        } else {
          if (availability['morning']?['isAvailable'] == true) {
            slots.addAll(
              generateHourlySlots(
                availability['morning']['startTime'],
                availability['morning']['endTime'],
              ),
            );
          }
          if (availability['afternoon']?['isAvailable'] == true) {
            slots.addAll(
              generateHourlySlots(
                availability['afternoon']['startTime'],
                availability['afternoon']['endTime'],
              ),
            );
          }
          if (availability['evening']?['isAvailable'] == true) {
            slots.addAll(
              generateHourlySlots(
                availability['evening']['startTime'],
                availability['evening']['endTime'],
              ),
            );
          }
        }

        if (slots.isEmpty) continue;

        /// Check if today's slots are all in the past
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

    // Fallback to today if no day is available
    return today;
  }

  void updateTimeSlots(DateTime selectedDay, List<String> availableDays) {
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
        categorizedSlots['FullDay'] = generateHourlySlots(
          availability['startTime'],
          availability['endTime'],
        );
      } else {
        if (availability['morning']?['isAvailable'] == true) {
          categorizedSlots['Morning'] = generateHourlySlots(
            availability['morning']['startTime'],
            availability['morning']['endTime'],
          );
        }
        if (availability['afternoon']?['isAvailable'] == true) {
          categorizedSlots['Afternoon'] = generateHourlySlots(
            availability['afternoon']['startTime'],
            availability['afternoon']['endTime'],
          );
        }
        if (availability['evening']?['isAvailable'] == true) {
          categorizedSlots['Evening'] = generateHourlySlots(
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

  List<String> generateHourlySlots(String startTime, String endTime) {
    List<String> slots = [];
    DateTime start = DateFormat('hh:mm a').parse(startTime);
    DateTime end = DateFormat('hh:mm a').parse(endTime);

    if (end.isBefore(start)) {
      end = end.add(const Duration(days: 1));
    }

    DateTime current = start;
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      slots.add(DateFormat('hh:mm a').format(current));
      current = current.add(const Duration(hours: 1));
    }

    return slots;
  }

  void showDoctorAvailability(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Doctor Availability',
            style: TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: doctor.availability.map((avail) {
                final day = avail['day'] as String;
                List<String> slots = [];
                if (avail['isFullDay'] == true) {
                  slots.add(
                    '${avail['startTime']} - ${avail['endTime']} (Full Day)',
                  );
                } else {
                  if (avail['morning']?['isAvailable'] == true) {
                    slots.add(
                      'Morning: ${avail['morning']['startTime']} - ${avail['morning']['endTime']}',
                    );
                  }
                  if (avail['afternoon']?['isAvailable'] == true) {
                    slots.add(
                      'Afternoon: ${avail['afternoon']['startTime']} - ${avail['afternoon']['endTime']}',
                    );
                  }
                  if (avail['evening']?['isAvailable'] == true) {
                    slots.add(
                      'Evening: ${avail['evening']['startTime']} - ${avail['evening']['endTime']}',
                    );
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontFamily: AppFonts.rubik,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                      ...slots.map(
                            (slot) => Padding(
                          padding: const EdgeInsets.only(
                            left: 8.0,
                            top: 4.0,
                          ),
                          child: Text(
                            slot,
                            style: const TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: 14,
                              color: AppColors.subTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontSize: 14,
                  color: AppColors.gradientGreen,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableDays =
    widget.doctor.availability.map((avail) => avail['day'] as String).toList();
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);
    final categorizedTimeSlots = ref.watch(categorizedTimeSlotsProvider);
    final isEditing = widget.appointment != null;

    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 15.0,
              ),
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
                        onPressed: () => showDoctorAvailability(context, widget.doctor),
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          NotificationListener<ScrollNotification>(
                            onNotification: (scrollNotification) {
                              return false;
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TableCalendar(
                                firstDay: DateTime.now(),
                                lastDay: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                                focusedDay: focusedDay,
                                selectedDayPredicate: (day) {
                                  return isSameDay(selectedDay, day);
                                },
                                onDaySelected: (selectedDay, focusedDay) {
                                  final dayName =
                                  AppStrings.daysOfWeek[selectedDay.weekday - 1];
                                  if (selectedDay.isBefore(
                                    DateTime.now().subtract(
                                      const Duration(days: 1),
                                    ),
                                  )) {
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Cannot select a past date',
                                    );
                                    return;
                                  }
                                  if (!availableDays.contains(dayName)) {
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Doctor is not available on this day',
                                    );
                                    return;
                                  }
                                  ref.read(selectedDayProvider.notifier).state =
                                      selectedDay;
                                  ref.read(focusedDayProvider.notifier).state =
                                      focusedDay;
                                  updateTimeSlots(selectedDay, availableDays);
                                },
                                calendarFormat: CalendarFormat.month,
                                availableCalendarFormats: const {
                                  CalendarFormat.month: 'Month',
                                },
                                headerStyle: HeaderStyle(
                                  headerPadding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.gradientGreen,
                                    borderRadius: BorderRadius.circular(16.0),
                                  ),
                                  formatButtonVisible: false,
                                  titleCentered: true,
                                  leftChevronPadding: EdgeInsets.zero,
                                  rightChevronPadding: EdgeInsets.zero,
                                  leftChevronMargin: const EdgeInsets.only(
                                    left: 0,
                                  ),
                                  rightChevronMargin: const EdgeInsets.only(
                                    right: 0,
                                  ),
                                  titleTextStyle: const TextStyle(
                                    fontFamily: AppFonts.rubik,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                  leftChevronIcon: const Icon(
                                    Icons.chevron_left,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  rightChevronIcon: const Icon(
                                    Icons.chevron_right,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                daysOfWeekHeight: 40,
                                daysOfWeekStyle: const DaysOfWeekStyle(
                                  weekdayStyle: TextStyle(
                                    fontFamily: AppFonts.rubik,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                  weekendStyle: TextStyle(
                                    fontFamily: AppFonts.rubik,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 14,
                                  ),
                                ),
                                calendarStyle: CalendarStyle(
                                  cellMargin: const EdgeInsets.all(4.0),
                                  cellPadding: const EdgeInsets.all(2.0),
                                  outsideDaysVisible: false,
                                  todayDecoration: BoxDecoration(
                                    color: availableDays.contains(
                                      AppStrings.daysOfWeek[
                                      DateTime.now().weekday - 1],
                                    )
                                        ? AppColors.gradientGreen.withOpacity(0.3)
                                        : Colors.redAccent.withOpacity(0.3),
                                    shape: BoxShape.circle,
                                  ),
                                  selectedDecoration: const BoxDecoration(
                                    color: AppColors.gradientGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  defaultDecoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  outsideDecoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                  ),
                                  defaultTextStyle: const TextStyle(
                                    fontFamily: AppFonts.rubik,
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                  weekendTextStyle: const TextStyle(
                                    fontFamily: AppFonts.rubik,
                                    color: Colors.black,
                                    fontSize: 14,
                                  ),
                                  outsideTextStyle: const TextStyle(
                                    fontFamily: AppFonts.rubik,
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                  markerDecoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                calendarBuilders: CalendarBuilders(
                                  defaultBuilder: (context, day, focusedDay) {
                                    final dayName =
                                    AppStrings.daysOfWeek[day.weekday - 1];
                                    if (availableDays.contains(dayName) &&
                                        !isSameDay(day, selectedDay) &&
                                        !isSameDay(day, DateTime.now())) {
                                      return Container(
                                        margin: const EdgeInsets.all(4.0),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.withOpacity(0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${day.day}',
                                            style: const TextStyle(
                                              fontFamily: AppFonts.rubik,
                                              color: Colors.black,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          30.height,
                          if (categorizedTimeSlots.values.any(
                                (slots) => slots.isNotEmpty,
                          )) ...[
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
                                  children: categorizedTimeSlots['FullDay']!.map((
                                      slot,
                                      ) {
                                    final isSelected =
                                        ref.watch(selectedTimeSlotProvider) == slot;
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: GestureDetector(
                                        onTap: () {
                                          ref
                                              .read(selectedTimeSlotProvider.notifier)
                                              .state = slot;
                                          ref
                                              .read(selectedSlotTypeProvider.notifier)
                                              .state = 'FullDay';
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
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black,
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
                                    children: categorizedTimeSlots['Morning']!.map((
                                        slot,
                                        ) {
                                      final isSelected =
                                          ref.watch(selectedTimeSlotProvider) == slot;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            ref
                                                .read(selectedTimeSlotProvider.notifier)
                                                .state = slot;
                                            ref
                                                .read(selectedSlotTypeProvider.notifier)
                                                .state = 'Morning';
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
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black,
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
                                    children: categorizedTimeSlots['Afternoon']!.map((
                                        slot,
                                        ) {
                                      final isSelected =
                                          ref.watch(selectedTimeSlotProvider) == slot;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            ref
                                                .read(selectedTimeSlotProvider.notifier)
                                                .state = slot;
                                            ref
                                                .read(selectedSlotTypeProvider.notifier)
                                                .state = 'Afternoon';
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
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black,
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
                                    children: categorizedTimeSlots['Evening']!.map((
                                        slot,
                                        ) {
                                      final isSelected =
                                          ref.watch(selectedTimeSlotProvider) == slot;
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0,
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            ref
                                                .read(selectedTimeSlotProvider.notifier)
                                                .state = slot;
                                            ref
                                                .read(selectedSlotTypeProvider.notifier)
                                                .state = 'Evening';
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
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black,
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
                            24.height,
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
                                children: [
                                  '30 min',
                                  '40 min',
                                  '25 min',
                                  '10 min',
                                  '35 min',
                                ].map((reminder) {
                                  final isSelected = ref.watch(reminderProvider) == reminder;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        ref.read(reminderProvider.notifier).state = reminder;
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0,
                                          vertical: 8.0,
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
                                            textAlignment: TextAlign.center,
                                            text: reminder.replaceAll(' min', ' Min'),
                                            textStyle: TextStyle(
                                              color: isSelected ? Colors.white : Colors.black,
                                              fontFamily: AppFonts.rubik,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            24.height,
                            Center(
                              child: CustomButtonWidget(
                                text: isEditing ? 'Save Changes' : 'Confirm',
                                height: ScreenUtil.scaleHeight(context, 50),
                                width: double.infinity,
                                backgroundColor: AppColors.gradientGreen,
                                fontFamily: AppFonts.rubik,
                                fontSize: FontSizes(context).size16,
                                fontWeight: FontWeight.w500,
                                textColor: Colors.white,
                                onPressed: () async {
                                  logDebug('Starting onPressed for appointment editing');
                                  logDebug('isEditing: $isEditing');
                                  // Retrieve and trim input values with null safety
                                  final selectedTimeSlot = ref.read(selectedTimeSlotProvider)?.trim();
                                  final selectedSlotType = ref.read(selectedSlotTypeProvider)?.trim();
                                  final patientName = ref.read(bookingViewPatientNameProvider).trim();
                                  final patientNumber = ref.read(bookingViewPatientNumberProvider).trim();
                                  final patientType = ref.read(bookingViewSelectedPatientLabelProvider).trim();
                                  final patientNotes = ref.read(bookingViewPatientNoteProvider).trim();

                                  // Log input values
                                  logDebug('Input values:');
                                  logDebug('  patientName: "$patientName" (length: ${patientName.length})');
                                  logDebug('  patientNumber: "$patientNumber" (length: ${patientNumber.length})');
                                  logDebug('  patientType: "$patientType" (length: ${patientType.length})');
                                  logDebug('  slotType: "$selectedSlotType"');
                                  logDebug('  timeSlot: "$selectedTimeSlot"');
                                  logDebug('  patientNotes: "$patientNotes"');
                                  logDebug('  selectedDay: ${selectedDay?.toIso8601String() ?? "null"}');

                                  // Validate inputs
                                  if (selectedDay == null) {
                                    logDebug('Validation failed: selectedDay is null');
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Please select a valid date',
                                    );
                                    return;
                                  }
                                  logDebug('Validated: selectedDay is not null');

                                  if (selectedDay.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
                                    logDebug('Validation failed: selectedDay is in the past');
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Cannot edit or book appointments in the past',
                                    );
                                    return;
                                  }
                                  logDebug('Validated: selectedDay is not in the past');

                                  if (selectedTimeSlot == null || selectedTimeSlot.isEmpty) {
                                    logDebug('Validation failed: selectedTimeSlot is null or empty');
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Please select a valid time slot',
                                    );
                                    return;
                                  }
                                  logDebug('Validated: selectedTimeSlot is "$selectedTimeSlot"');

                                  if (selectedSlotType == null || !['Morning', 'Afternoon', 'Evening', 'FullDay'].contains(selectedSlotType)) {
                                    logDebug('Validation failed: invalid slotType "$selectedSlotType"');
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Invalid slot type: ${selectedSlotType ?? "null"}',
                                    );
                                    return;
                                  }
                                  logDebug('Validated: slotType is "$selectedSlotType"');

                                  if (patientName.isEmpty) {
                                    logDebug('Validation failed: patientName is empty');
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Please enter a valid patient name',
                                    );
                                    return;
                                  }
                                  logDebug('Validated: patientName is "$patientName"');

                                  if (patientNumber.isEmpty) {
                                    logDebug('Validation failed: patientNumber is empty');
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Please enter a valid patient phone number',
                                    );
                                    return;
                                  }
                                  logDebug('Validated: patientNumber is "$patientNumber"');

                                  if (patientType.isEmpty) {
                                    logDebug('Validation failed: patientType is empty');
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Please select a valid patient type',
                                    );
                                    return;
                                  }
                                  logDebug('Validated: patientType is "$patientType"');

                                  logDebug('Checking internet connection');
                                  final isConnected = await ref.read(checkInternetConnectionProvider.future);
                                  if (!isConnected) {
                                    logDebug('Validation failed: no internet connection');
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'No Internet Connection',
                                    );
                                    return;
                                  }
                                  logDebug('Validated: internet connection is available');

                                  logDebug('Checking authentication');
                                  final user = FirebaseAuth.instance.currentUser;
                                  if (user == null) {
                                    logDebug('Validation failed: user is not authenticated');
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Please sign in to book an appointment',
                                    );
                                    return;
                                  }
                                  logDebug('Authenticated user UID: ${user.uid}');

                                  try {
                                    if (isEditing) {
                                      logDebug('Processing edit for appointment ID: ${widget.appointment!.id}');

                                      // Fetch the existing appointment
                                      logDebug('Fetching appointment from Firebase');
                                      final database = FirebaseDatabase.instance.ref();
                                      final snapshot = await database
                                          .child('Appointments')
                                          .child(widget.appointment!.id)
                                          .get();
                                      if (!snapshot.exists) {
                                        logDebug('Appointment not found: ${widget.appointment!.id}');
                                        CustomSnackBarWidget.show(
                                          context: context,
                                          text: 'Appointment not found',
                                        );
                                        AppNavigation.pop();
                                        return;
                                      }
                                      logDebug('Appointment fetched successfully');

                                      final data = snapshot.value as Map<dynamic, dynamic>;
                                      logDebug('Appointment data: $data');

                                      // Verify user authorization
                                      if (data['patientUid'] != user.uid) {
                                        logDebug(
                                          'Authorization failed: patientUid ${data['patientUid']} does not match user UID ${user.uid}',
                                        );
                                        CustomSnackBarWidget.show(
                                          context: context,
                                          text: 'You are not authorized to edit this appointment',
                                        );
                                        AppNavigation.pop();
                                        return;
                                      }
                                      logDebug('Validated: user is authorized to edit appointment');

                                      // Verify appointment status
                                      if (data['status'] != 'pending') {
                                        logDebug(
                                          'Validation failed: appointment status is "${data['status']}", expected "pending"',
                                        );
                                        CustomSnackBarWidget.show(
                                          context: context,
                                          text: 'Only pending appointments can be edited',
                                        );
                                        AppNavigation.pop();
                                        return;
                                      }
                                      logDebug('Validated: appointment status is "pending"');

                                      // Update the appointment
                                      logDebug('Creating updated appointment model');
                                      final updatedAppointment = widget.appointment!.copyWith(
                                        date: DateFormat('yyyy-MM-dd').format(selectedDay),
                                        timeSlot: selectedTimeSlot,
                                        slotType: selectedSlotType,
                                        patientNotes: patientNotes.isEmpty ? null : patientNotes,
                                        patientName: patientName,
                                        patientNumber: patientNumber,
                                        patientType: patientType,
                                        updatedAt: DateTime.now().toIso8601String(),
                                      );
                                      logDebug('Updated appointment data: ${updatedAppointment.toMap()}');

                                      logDebug('Calling updateBooking');
                                      await ref
                                          .read(bookingRepositoryProvider)
                                          .updateBooking(updatedAppointment);
                                      logDebug('updateBooking completed successfully');

                                      CustomSnackBarWidget.show(
                                        context: context,
                                        text: 'Appointment updated successfully',
                                      );
                                      logDebug('Clearing input providers');
                                      ref.read(bookingViewPatientNameProvider.notifier).state = '';
                                      ref.read(bookingViewPatientNumberProvider.notifier).state = '';
                                      ref.read(bookingViewPatientNoteProvider.notifier).state = '';
                                      ref.read(bookingViewSelectedPatientLabelProvider.notifier).state = 'My Self';

                                      logDebug('Navigating to ConfirmationView');
                                        ConfirmationDialog.show(
                                          context: context,
                                          doctor: widget.doctor,
                                          date: DateFormat('yyyy-MM-dd').format(selectedDay),
                                          timeSlot: selectedTimeSlot,
                                          isEditing: isEditing,
                                          appointment: updatedAppointment,
                                        );
                                    } else {
                                      logDebug('Processing new appointment creation');

                                      // Create new appointment
                                      logDebug('Fetching patient data for UID: ${user.uid}');
                                      final patientData = await ref.read(patientDataByUidProvider(user.uid).future);
                                      if (patientData == null) {
                                        logDebug('Failed to load patient data');
                                        CustomSnackBarWidget.show(
                                          context: context,
                                          text: 'Failed to load patient data',
                                        );
                                        return;
                                      }
                                      logDebug('Patient data loaded: fullName=${patientData.fullName}');

                                      final bookerName = patientData.fullName;
                                      logDebug('Creating new AppointmentModel');
                                      final appointment = AppointmentModel(
                                        id: FirebaseDatabase.instance.ref().child('Appointments').push().key!,
                                        patientUid: user.uid,
                                        doctorUid: widget.doctor.uid,
                                        doctorName: widget.doctor.fullName,
                                        doctorCategory: widget.doctor.category,
                                        hospital: widget.doctor.hospital,
                                        date: DateFormat('yyyy-MM-dd').format(selectedDay),
                                        timeSlot: selectedTimeSlot,
                                        slotType: selectedSlotType,
                                        status: 'pending',
                                        consultationFee: widget.doctor.consultationFee,
                                        createdAt: DateTime.now().toIso8601String(),
                                        patientNotes: patientNotes.isEmpty ? null : patientNotes,
                                        bookerName: bookerName,
                                        patientName: patientName,
                                        patientNumber: patientNumber,
                                        patientType: patientType,
                                      );
                                      logDebug('New appointment data: ${appointment.toMap()}');

                                      logDebug('Calling createBooking');
                                      await ref.read(bookingRepositoryProvider).createBooking(appointment);
                                      logDebug('createBooking completed successfully');

                                      CustomSnackBarWidget.show(
                                        context: context,
                                        text: 'Booking created successfully',
                                      );
                                      logDebug('Clearing input providers');
                                      ref.read(bookingViewPatientNameProvider.notifier).state = '';
                                      ref.read(bookingViewPatientNumberProvider.notifier).state = '';
                                      ref.read(bookingViewPatientNoteProvider.notifier).state = '';
                                      ref.read(bookingViewSelectedPatientLabelProvider.notifier).state = 'My Self';

                                      logDebug('Navigating to ConfirmationView');

                                        ConfirmationDialog.show(
                                          context: context,
                                          doctor: widget.doctor,
                                          date: DateFormat('yyyy-MM-dd').format(selectedDay),
                                          timeSlot: selectedTimeSlot,
                                          isEditing: isEditing,
                                          appointment: appointment,
                                        );

                                    }
                                  } catch (e) {
                                    logDebug('Error processing appointment: $e');
                                    if (e.toString().contains('No changes to update')) {
                                      logDebug('No changes to update');
                                      CustomSnackBarWidget.show(
                                        context: context,
                                        text: 'No changes to save',
                                      );
                                    } else if (e.toString().contains('permission-denied')) {
                                      logDebug('Failed to Update appointment: ${e.toString()}');
                                      CustomSnackBarWidget.show(
                                        context: context,
                                        text: 'Failed to update appointment. Ensure name, phone number, patient type, and slot type are valid and the appointment is still pending.',
                                      );
                                    } else {
                                      logDebug(
                                        'Failed to ${isEditing ? "update" : "create"} appointment: ${e.toString()}',
                                      );
                                      CustomSnackBarWidget.show(
                                        context: context,
                                        text: isEditing
                                            ? 'Failed to update appointment: $e'
                                            : 'Failed to create booking: $e',
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ] else ...[
                            100.height,
                            Center(
                              child: CustomTextWidget(
                                textAlignment: TextAlign.center,
                                text:
                                'Not Available Now, Next Available on ${findNextAvailableDay(availableDays, widget.doctor.availability).toString().dayMonthDisplay}',
                                textStyle: TextStyle(
                                  color: AppColors.gradientGreen,
                                  fontFamily: AppFonts.rubik,
                                  fontSize: FontSizes(context).size16,
                                ),
                              ),
                            ),
                          ],
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