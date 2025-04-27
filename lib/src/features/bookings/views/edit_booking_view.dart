// edit_booking_view.dart
import 'package:curemate/core/extentions/widget_extension.dart';
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
import '../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../patient/providers/patient_providers.dart';
import '../providers/booking_providers.dart';
import 'confirmation_view.dart';
import 'select_time_view.dart';

class EditBookingView extends ConsumerStatefulWidget {
  final Appointment appointment;
  final Doctor doctor;

  const EditBookingView({super.key, required this.appointment, required this.doctor});

  @override
  ConsumerState<EditBookingView> createState() => _EditBookingViewState();
}

class _EditBookingViewState extends ConsumerState<EditBookingView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedTimeSlot;
  List<String> _availableTimeSlots = [];
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final dateParts = widget.appointment.date.split('-');
    _selectedDay = DateTime(
      int.parse(dateParts[0]),
      int.parse(dateParts[1]),
      int.parse(dateParts[2]),
    );
    _focusedDay = _selectedDay!;
    _selectedTimeSlot = widget.appointment.timeSlot;
    _notesController.text = widget.appointment.patientNotes ?? '';
    _updateTimeSlots(_selectedDay!);
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
      if (!_availableTimeSlots.contains(_selectedTimeSlot)) {
        _selectedTimeSlot = timeSlots.isNotEmpty ? timeSlots.first : null;
      }
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
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

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomAppBarHeaderWidget(title: 'Edit Appointment'),
                  24.height,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          ],
                          24.height,
                          CustomTextFormFieldWidget(
                            controller: _notesController,
                            label: 'Notes (Optional)',
                            hintText: 'Add any additional notes',
                            maxLines: 3,
                          ),
                          24.height,
                          CustomButtonWidget(
                            text: 'Save Changes',
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

                              final database = FirebaseDatabase.instance.ref();
                              final updatedAppointment = {
                                'date': '${_selectedDay!.year}-${_selectedDay!.month}-${_selectedDay!.day}',
                                'timeSlot': _selectedTimeSlot!,
                                'patientNotes': _notesController.text.isEmpty ? null : _notesController.text,
                                'status': 'pending', // Reset status to pending after edit
                              };

                              await database
                                  .child('Appointments')
                                  .child(widget.appointment.id)
                                  .update(updatedAppointment);

                              CustomSnackBarWidget.show(
                                context: context,
                                text: 'Booking updated successfully',
                              );

                              AppNavigation.pushReplacement(
                                ConfirmationView(
                                  doctor: widget.doctor,
                                  date: updatedAppointment['date']!,
                                  timeSlot: updatedAppointment['timeSlot']!,
                                ),
                              );
                            },
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