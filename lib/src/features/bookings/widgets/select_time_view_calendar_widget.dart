import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/app_strings.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../theme/app_colors.dart';
import '../../patient/providers/patient_providers.dart';
import '../views/select_time_view.dart';

class CalendarWidget extends ConsumerWidget {
  final Doctor doctor;
  final Function(DateTime, List<String>) onDaySelected;

  const CalendarWidget({
    super.key,
    required this.doctor,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableDays =
    doctor.availability.map((avail) => avail['day'] as String).toList();
    final selectedDay = ref.watch(selectedDayProvider);
    final focusedDay = ref.watch(focusedDayProvider);

    return NotificationListener<ScrollNotification>(
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
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) {
            return isSameDay(selectedDay, day);
          },
          onDaySelected: (selectedDay, focusedDay) {
            final dayName = AppStrings.daysOfWeek[selectedDay.weekday - 1];
            if (selectedDay.isBefore(
              DateTime.now().subtract(const Duration(days: 1)),
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
            ref.read(selectedDayProvider.notifier).state = selectedDay;
            ref.read(focusedDayProvider.notifier).state = focusedDay;
            onDaySelected(selectedDay, availableDays);
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
            leftChevronMargin: const EdgeInsets.only(left: 0),
            rightChevronMargin: const EdgeInsets.only(right: 0),
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
                AppStrings.daysOfWeek[DateTime.now().weekday - 1],
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
              final dayName = AppStrings.daysOfWeek[day.weekday - 1];
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
    );
  }
}