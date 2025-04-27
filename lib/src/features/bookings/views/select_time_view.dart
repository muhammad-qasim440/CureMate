// select_time_view.dart
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../router/nav.dart';
import '../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../shared/widgets/custom_appbar_header_widget.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../patient/providers/patient_providers.dart';
import '../providers/booking_providers.dart';
import 'confirmation_view.dart';
import 'select_time_view.dart';


class SelectTimeView extends ConsumerStatefulWidget {
  final Doctor doctor;
  final String patientName;
  final String contactNumber;

  const SelectTimeView({
    super.key,
    required this.doctor,
    required this.patientName,
    required this.contactNumber,
  });

  @override
  ConsumerState<SelectTimeView> createState() => _SelectTimeViewState();
}

class _SelectTimeViewState extends ConsumerState<SelectTimeView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTimeSlot;
  String _reminder = '30 min';
  List<String> _availableTimeSlots = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _findNextAvailableDay();
    _updateTimeSlots(_selectedDay!);
  }

  DateTime _findNextAvailableDay() {
    final now = DateTime.now();
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final availableDays = widget.doctor.availability['days'] as List<dynamic>? ?? [];

    for (int i = 0; i < 7; i++) {
      final day = now.add(Duration(days: i));
      final dayName = daysOfWeek[day.weekday - 1];
      if (availableDays.contains(dayName)) {
        if (day.isAfter(now) || (day.day == now.day && day.month == now.month && day.year == now.year)) {
          return DateTime(day.year, day.month, day.day);
        }
      }
    }
    return now;
  }

  void _updateTimeSlots(DateTime selectedDay) {
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final dayName = daysOfWeek[selectedDay.weekday - 1];
    final availableDays = widget.doctor.availability['days'] as List<dynamic>? ?? [];
    final morning = widget.doctor.availability['morning'] as bool? ?? false;
    final afternoon = widget.doctor.availability['afternoon'] as bool? ?? false;
    final evening = widget.doctor.availability['evening'] as bool? ?? false;

    List<String> timeSlots = [];
    if (availableDays.contains(dayName)) {
      if (morning) {
        timeSlots.addAll(['09:00 AM', '10:00 AM', '11:00 AM']);
      }
      if (afternoon) {
        timeSlots.addAll(['12:00 PM', '01:00 PM', '02:00 PM']);
      }
      if (evening) {
        timeSlots.addAll(['03:00 PM', '04:00 PM', '05:00 PM']);
      }
    }

    // Filter out past time slots if the selected day is today
    final now = DateTime.now();
    if (selectedDay.day == now.day &&
        selectedDay.month == now.month &&
        selectedDay.year == now.year) {
      timeSlots = timeSlots.where((slot) {
        final hour = int.parse(slot.split(':')[0]);
        final isPM = slot.contains('PM');
        final slotHour = isPM && hour != 12 ? hour + 12 : hour;
        return slotHour > now.hour;
      }).toList();
    }

    setState(() {
      _availableTimeSlots = timeSlots;
      _selectedTimeSlot = timeSlots.isNotEmpty ? timeSlots.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysOfWeek = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final availableDays = widget.doctor.availability['days'] as List<dynamic>? ?? [];
    final nextAvailableDay = _findNextAvailableDay();
    final nextAvailableDayName = daysOfWeek[nextAvailableDay.weekday - 1];
    final nextAvailableDate = '${nextAvailableDay.day} ${nextAvailableDay.month == 2 ? 'Feb' : 'Unknown'}';

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.gradientGreen.withOpacity(0.1),
                child: SafeArea(
                  child: Column(
                    children: [
                      const CustomAppBarHeaderWidget(title: 'Select Time'),
                      16.height,
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: ScreenUtil.scaleWidth(context, 60),
                              height: ScreenUtil.scaleHeight(context, 60),
                              child: widget.doctor.profileImageUrl.isNotEmpty
                                  ? Image.network(
                                widget.doctor.profileImageUrl,
                                fit: BoxFit.cover,
                              )
                                  : Image.asset(
                                'assets/default_doctor.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          12.width,
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextWidget(
                                text: widget.doctor.fullName,
                                textStyle: TextStyle(
                                  fontFamily: AppFonts.rubik,
                                  fontSize: FontSizes(context).size18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.black,
                                ),
                              ),
                              CustomTextWidget(
                                text: widget.doctor.category,
                                textStyle: TextStyle(
                                  fontFamily: AppFonts.rubik,
                                  fontSize: FontSizes(context).size14,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.subtextcolor,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.favorite,
                            color: Colors.red,
                            size: 24,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomTextWidget(
                              text: 'Today, ${DateTime.now().day} Feb',
                              textStyle: TextStyle(
                                fontFamily: AppFonts.rubik,
                                fontSize: FontSizes(context).size14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.subtextcolor,
                              ),
                            ),
                            CustomTextWidget(
                              text: 'Tomorrow, ${DateTime.now().add(const Duration(days: 1)).day} Feb',
                              textStyle: TextStyle(
                                fontFamily: AppFonts.rubik,
                                fontSize: FontSizes(context).size14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.subtextcolor,
                              ),
                            ),
                          ],
                        ),
                        16.height,
                        CustomTextWidget(
                          text: availableDays.contains(nextAvailableDayName)
                              ? 'Next availability on $nextAvailableDayName, $nextAvailableDate'
                              : 'Contact Clinic',
                          textStyle: TextStyle(
                            fontFamily: AppFonts.rubik,
                            fontSize: FontSizes(context).size16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                        16.height,
                        TableCalendar(
                          firstDay: DateTime.now(),
                          lastDay: DateTime.now().add(const Duration(days: 365)),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) {
                            return isSameDay(_selectedDay, day);
                          },
                          onDaySelected: (selectedDay, focusedDay) {
                            final dayName = daysOfWeek[selectedDay.weekday - 1];
                            if (selectedDay.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
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
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                            _updateTimeSlots(selectedDay);
                          },
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                          ),
                          calendarStyle: const CalendarStyle(
                            todayDecoration: BoxDecoration(
                              color: AppColors.gradientGreen,
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: BoxDecoration(
                              color: AppColors.gradientGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        24.height,
                        if (_availableTimeSlots.isNotEmpty) ...[
                          const CustomTextWidget(
                            text: 'Available Time',
                            textStyle: TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black,
                            ),
                          ),
                          16.height,
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _availableTimeSlots.map((slot) {
                              final isSelected = _selectedTimeSlot == slot;
                              return ChoiceChip(
                                label: Text(slot),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedTimeSlot = slot;
                                  });
                                },
                                selectedColor: AppColors.gradientGreen,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.subtextcolor,
                                  fontFamily: AppFonts.rubik,
                                ),
                              );
                            }).toList(),
                          ),
                          24.height,
                          const CustomTextWidget(
                            text: 'Remind Me Before',
                            textStyle: TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.black,
                            ),
                          ),
                          16.height,
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: ['30 min', '15 min', '10 min'].map((reminder) {
                              final isSelected = _reminder == reminder;
                              return ChoiceChip(
                                label: Text(reminder),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _reminder = reminder;
                                  });
                                },
                                selectedColor: AppColors.gradientGreen,
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : AppColors.subtextcolor,
                                  fontFamily: AppFonts.rubik,
                                ),
                              );
                            }).toList(),
                          ),
                          24.height,
                          CustomButtonWidget(
                            text: 'Confirm',
                            height: ScreenUtil.scaleHeight(context, 50),
                            width: double.infinity,
                            backgroundColor: AppColors.gradientGreen,
                            fontFamily: AppFonts.rubik,
                            fontSize: FontSizes(context).size16,
                            fontWeight: FontWeight.w500,
                            textColor: Colors.white,
                            onPressed: () async {
                              if (_selectedTimeSlot == null) {
                                CustomSnackBarWidget.show(
                                  context: context,
                                  text: 'Please select a time slot',
                                );
                                return;
                              }

                              final isConnected = await ref.read(checkInternetConnectionProvider.future);
                              if (!isConnected) {
                                CustomSnackBarWidget.show(
                                  context: context,
                                  text: 'No Internet Connection',
                                );
                                return;
                              }

                              final user = FirebaseAuth.instance.currentUser;
                              if (user == null) {
                                CustomSnackBarWidget.show(
                                  context: context,
                                  text: 'Please sign in to book an appointment',
                                );
                                return;
                              }

                              final database = FirebaseDatabase.instance.ref();
                              final appointmentRef = database.child('Appointments').push();
                              final appointment = Appointment(
                                id: appointmentRef.key!,
                                patientUid: user.uid,
                                doctorUid: widget.doctor.uid,
                                date: '${_selectedDay!.year}-${_selectedDay!.month}-${_selectedDay!.day}',
                                timeSlot: _selectedTimeSlot!,
                                status: 'pending',
                                createdAt: DateTime.now().toIso8601String(),
                                patientNotes: null,
                              );

                              await appointmentRef.set(appointment.toMap());

                              AppNavigation.push(
                                ConfirmationView(
                                  doctor: widget.doctor,
                                  date: appointment.date,
                                  timeSlot: appointment.timeSlot,
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}