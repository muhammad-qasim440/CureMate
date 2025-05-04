// import 'package:curemate/core/extentions/widget_extension.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:table_calendar/table_calendar.dart';
// import 'package:intl/intl.dart';
// import '../../../../const/app_fonts.dart';
// import '../../../../const/app_strings.dart';
// import '../../../../const/font_sizes.dart';
// import '../../../router/nav.dart';
// import '../../../shared/providers/check_internet_connectivity_provider.dart';
// import '../../../shared/widgets/custom_appbar_header_widget.dart';
// import '../../../shared/widgets/custom_button_widget.dart';
// import '../../../shared/widgets/custom_snackbar_widget.dart';
// import '../../../shared/widgets/custom_text_form_field_widget.dart';
// import '../../../shared/widgets/custom_text_widget.dart';
// import '../../../theme/app_colors.dart';
// import '../../../utils/screen_utils.dart';
// import '../../bookings/models/appointment_model.dart';
// import '../../patient/providers/patient_providers.dart';
// import '../providers/booking_providers.dart';
// import 'confirmation_view.dart';
//
// class EditBookingView extends ConsumerStatefulWidget {
//   final AppointmentModel appointment;
//   final Doctor doctor;
//
//   const EditBookingView({super.key, required this.appointment, required this.doctor});
//
//   @override
//   ConsumerState<EditBookingView> createState() => _EditBookingViewState();
// }
//
// class _EditBookingViewState extends ConsumerState<EditBookingView> {
//   DateTime _focusedDay = DateTime.now();
//   DateTime? _selectedDay;
//   String? _selectedTimeSlot;
//   List<String> _availableTimeSlots = [];
//   final TextEditingController _notesController = TextEditingController();
//   final TextEditingController _patientNameController = TextEditingController();
//   final TextEditingController _patientNumberController = TextEditingController();
//   bool _isPending = true;
//
//   @override
//   void initState() {
//     super.initState();
//     try {
//       _selectedDay = DateFormat('yyyy-MM-dd').parse(widget.appointment.date);
//       _focusedDay = _selectedDay!;
//     } catch (e) {
//       _selectedDay = DateTime.now();
//       _focusedDay = _selectedDay!;
//     }
//     _selectedTimeSlot = widget.appointment.timeSlot;
//     _notesController.text = widget.appointment.patientNotes ?? '';
//     _patientNameController.text = widget.appointment.patientName;
//     _patientNumberController.text = widget.appointment.patientNumber;
//     _isPending = widget.appointment.status == 'pending';
//     if (_isPending) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         ref.read(bookingViewSelectedPatientLabelProvider.notifier).state = widget.appointment.patientType;
//         ref.read(bookingViewPatientNameProvider.notifier).state = widget.appointment.patientName;
//         ref.read(bookingViewPatientNumberProvider.notifier).state = widget.appointment.patientNumber;
//       });
//     }
//     _updateTimeSlots(_selectedDay!);
//   }
//
//   void _updateTimeSlots(DateTime selectedDay) {
//     final daysOfWeek = [
//       'Monday',
//       'Tuesday',
//       'Wednesday',
//       'Thursday',
//       'Friday',
//       'Saturday',
//       'Sunday'
//     ];
//     final dayName = daysOfWeek[selectedDay.weekday - 1];
//
//     final availability = widget.doctor.availability.firstWhere(
//           (avail) => avail['day'] == dayName,
//       orElse: () => {},
//     );
//
//     List<String> timeSlots = [];
//     if (availability.isNotEmpty) {
//       if (availability['isFullDay'] == true) {
//         timeSlots.add('${availability['startTime']} - ${availability['endTime']}');
//       } else {
//         if (availability['morning']?['isAvailable'] == true) {
//           timeSlots.add(
//               'Morning: ${availability['morning']['startTime']} - ${availability['morning']['endTime']}');
//         }
//         if (availability['afternoon']?['isAvailable'] == true) {
//           timeSlots.add(
//               'Afternoon: ${availability['afternoon']['startTime']} - ${availability['afternoon']['endTime']}');
//         }
//         if (availability['evening']?['isAvailable'] == true) {
//           timeSlots.add(
//               'Evening: ${availability['evening']['startTime']} - ${availability['evening']['endTime']}');
//         }
//       }
//     }
//
//     final now = DateTime.now();
//     if (selectedDay.day == now.day &&
//         selectedDay.month == now.month &&
//         selectedDay.year == now.year) {
//       timeSlots = timeSlots.where((slot) {
//         final startTimeStr = slot.contains(':') ? slot.split('-')[0].trim() : slot;
//         try {
//           final parsedTime = DateFormat('hh:mm a').parse(
//               startTimeStr.contains('Morning') ? startTimeStr.split(': ')[1] : startTimeStr);
//           final slotHour = parsedTime.hour;
//           final slotMinute = parsedTime.minute;
//           return slotHour > now.hour || (slotHour == now.hour && slotMinute > now.minute);
//         } catch (e) {
//           return true;
//         }
//       }).toList();
//     }
//
//     setState(() {
//       _availableTimeSlots = timeSlots;
//       if (!_availableTimeSlots.contains(_selectedTimeSlot)) {
//         _selectedTimeSlot = timeSlots.isNotEmpty ? timeSlots.first : null;
//       }
//     });
//   }
//
//   Future<bool> _checkAppointmentStatus() async {
//     final database = FirebaseDatabase.instance.ref();
//     final snapshot = await database.child('Appointments').child(widget.appointment.id).get();
//     if (snapshot.exists) {
//       final data = snapshot.value as Map<dynamic, dynamic>;
//       return data['status'] == 'pending';
//     }
//     return false;
//   }
//
//   @override
//   void dispose() {
//     _notesController.dispose();
//     _patientNameController.dispose();
//     _patientNumberController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final availableDays = widget.doctor.availability.map((avail) => avail['day'] as String).toList();
//     final selectedPatientLabel = ref.watch(bookingViewSelectedPatientLabelProvider);
//
//     if (!_isPending) {
//       return Scaffold(
//         body: SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const CustomAppBarHeaderWidget(title: 'Edit Appointment'),
//                 24.height,
//                 const CustomTextWidget(
//                   text: 'This appointment cannot be edited as it is no longer pending.',
//                   textStyle: TextStyle(
//                     fontFamily: AppFonts.rubik,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: AppColors.black,
//                   ),
//                 ),
//                 16.height,
//                 CustomButtonWidget(
//                   text: 'Back',
//                   height: ScreenUtil.scaleHeight(context, 50),
//                   width: double.infinity,
//                   backgroundColor: AppColors.gradientGreen,
//                   fontFamily: AppFonts.rubik,
//                   fontSize: FontSizes(context).size16,
//                   fontWeight: FontWeight.w500,
//                   textColor: Colors.white,
//                   onPressed: () => AppNavigation.pop(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     }
//
//     return Scaffold(
//       body: Stack(
//         children: [
//           SafeArea(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const CustomAppBarHeaderWidget(title: 'Edit Appointment'),
//                   24.height,
//                   Expanded(
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const CustomTextWidget(
//                             text: 'Booking For',
//                             textStyle: TextStyle(
//                               fontFamily: AppFonts.rubik,
//                               fontSize: 16,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.black,
//                             ),
//                           ),
//                           16.height,
//                           Wrap(
//                             spacing: 8,
//                             runSpacing: 8,
//                             children: ['Myself', 'Someone Else'].map((label) {
//                               final isSelected = selectedPatientLabel == label;
//                               return ChoiceChip(
//                                 label: Text(label),
//                                 selected: isSelected,
//                                 onSelected: (selected) {
//                                   ref.read(bookingViewSelectedPatientLabelProvider.notifier).state = label;
//                                   if (label == 'Myself') {
//                                     final patientData = ref.read(patientDataByUidProvider(widget.appointment.patientUid).future);
//                                     patientData.then((data) {
//                                       _patientNameController.text = data?.fullName ?? '';
//                                       _patientNumberController.text = data?.phoneNumber ?? '';
//                                       ref.read(bookingViewPatientNameProvider.notifier).state = data?.fullName ?? '';
//                                       ref.read(bookingViewPatientNumberProvider.notifier).state = data?.phoneNumber ?? '';
//                                     });
//                                   } else {
//                                     _patientNameController.clear();
//                                     _patientNumberController.clear();
//                                     ref.read(bookingViewPatientNameProvider.notifier).state = '';
//                                     ref.read(bookingViewPatientNumberProvider.notifier).state = '';
//                                   }
//                                 },
//                                 selectedColor: AppColors.gradientGreen,
//                                 labelStyle: TextStyle(
//                                   color: isSelected ? Colors.white : AppColors.subtextcolor,
//                                   fontFamily: AppFonts.rubik,
//                                 ),
//                               );
//                             }).toList(),
//                           ),
//                           if (selectedPatientLabel == 'Someone Else') ...[
//                             16.height,
//                             CustomTextFormFieldWidget(
//                               controller: _patientNameController,
//                               label: 'Patient Name',
//                               hintText: 'Enter patient name',
//                               onChanged: (value) {
//                                 ref.read(bookingViewPatientNameProvider.notifier).state = value;
//                               },
//                             ),
//                             16.height,
//                             CustomTextFormFieldWidget(
//                               controller: _patientNumberController,
//                               label: 'Patient Contact Number',
//                               hintText: 'Enter contact number',
//                               keyboardType: TextInputType.phone,
//                               onChanged: (value) {
//                                 ref.read(bookingViewPatientNumberProvider.notifier).state = value;
//                               },
//                             ),
//                           ],
//                           24.height,
//                           TableCalendar(
//                             firstDay: DateTime.now(),
//                             lastDay: DateTime.now().add(const Duration(days: 365)),
//                             focusedDay: _focusedDay,
//                             selectedDayPredicate: (day) {
//                               return isSameDay(_selectedDay, day);
//                             },
//                             onDaySelected: (selectedDay, focusedDay) {
//                               final dayName = AppStrings.daysOfWeek[selectedDay.weekday - 1];
//                               if (selectedDay.isBefore(DateTime.now().subtract(const Duration(days: 1)))) {
//                                 CustomSnackBarWidget.show(
//                                   context: context,
//                                   text: 'Cannot select a past date',
//                                 );
//                                 return;
//                               }
//                               if (!availableDays.contains(dayName)) {
//                                 CustomSnackBarWidget.show(
//                                   context: context,
//                                   text: 'Doctor is not available on this day',
//                                 );
//                                 return;
//                               }
//                               setState(() {
//                                 _selectedDay = selectedDay;
//                                 _focusedDay = focusedDay;
//                               });
//                               _updateTimeSlots(selectedDay);
//                             },
//                             calendarFormat: CalendarFormat.month,
//                             availableCalendarFormats: const {CalendarFormat.month: 'Month'},
//                             headerStyle: const HeaderStyle(
//                               formatButtonVisible: false,
//                               titleCentered: true,
//                             ),
//                             calendarStyle: const CalendarStyle(
//                               todayDecoration: BoxDecoration(
//                                 color: AppColors.gradientGreen,
//                                 shape: BoxShape.circle,
//                               ),
//                               selectedDecoration: BoxDecoration(
//                                 color: AppColors.gradientGreen,
//                                 shape: BoxShape.circle,
//                               ),
//                             ),
//                           ),
//                           24.height,
//                           if (_availableTimeSlots.isNotEmpty) ...[
//                             const CustomTextWidget(
//                               text: 'Available Time',
//                               textStyle: TextStyle(
//                                 fontFamily: AppFonts.rubik,
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.w500,
//                                 color: AppColors.black,
//                               ),
//                             ),
//                             16.height,
//                             Wrap(
//                               spacing: 8,
//                               runSpacing: 8,
//                               children: _availableTimeSlots.map((slot) {
//                                 final isSelected = _selectedTimeSlot == slot;
//                                 return ChoiceChip(
//                                   label: Text(slot),
//                                   selected: isSelected,
//                                   onSelected: (selected) {
//                                     setState(() {
//                                       _selectedTimeSlot = slot;
//                                     });
//                                   },
//                                   selectedColor: AppColors.gradientGreen,
//                                   labelStyle: TextStyle(
//                                     color: isSelected ? Colors.white : AppColors.subtextcolor,
//                                     fontFamily: AppFonts.rubik,
//                                   ),
//                                 );
//                               }).toList(),
//                             ),
//                           ],
//                           24.height,
//                           CustomTextFormFieldWidget(
//                             controller: _notesController,
//                             label: 'Notes (Optional)',
//                             hintText: 'Add any additional notes',
//                             maxLines: 3,
//                           ),
//                           24.height,
//                           CustomButtonWidget(
//                             text: 'Save Changes',
//                             height: ScreenUtil.scaleHeight(context, 50),
//                             width: double.infinity,
//                             backgroundColor: AppColors.gradientGreen,
//                             fontFamily: AppFonts.rubik,
//                             fontSize: FontSizes(context).size16,
//                             fontWeight: FontWeight.w500,
//                             textColor: Colors.white,
//                             onPressed: () async {
//                               if (_selectedTimeSlot == null) {
//                                 CustomSnackBarWidget.show(
//                                   context: context,
//                                   text: 'Please select a time slot',
//                                 );
//                                 return;
//                               }
//                               if (ref.read(bookingViewPatientNameProvider).isEmpty ||
//                                   ref.read(bookingViewPatientNumberProvider).isEmpty) {
//                                 CustomSnackBarWidget.show(
//                                   context: context,
//                                   text: 'Please enter patient name and contact number',
//                                 );
//                                 return;
//                               }
//
//                               final isConnected = await ref.read(checkInternetConnectionProvider.future);
//                               if (!isConnected) {
//                                 CustomSnackBarWidget.show(
//                                   context: context,
//                                   text: 'No Internet Connection',
//                                 );
//                                 return;
//                               }
//
//                               final isStillPending = await _checkAppointmentStatus();
//                               if (!isStillPending) {
//                                 CustomSnackBarWidget.show(
//                                   context: context,
//                                   text: 'Cannot save changes: Appointment is no longer pending',
//                                 );
//                                 AppNavigation.pop();
//                                 return;
//                               }
//
//                               try {
//                                 final updatedAppointment = widget.appointment.copyWith(
//                                   date: DateFormat('yyyy-MM-dd').format(_selectedDay!),
//                                   timeSlot: _selectedTimeSlot!,
//                                   patientNotes: _notesController.text.isEmpty ? null : _notesController.text,
//                                   status: 'pending',
//                                   updatedAt: DateTime.now().toIso8601String(),
//                                   patientName: ref.read(bookingViewPatientNameProvider),
//                                   patientNumber: ref.read(bookingViewPatientNumberProvider),
//                                   patientType: ref.read(bookingViewSelectedPatientLabelProvider),
//                                 );
//
//                                 await ref.read(bookingRepositoryProvider).updateBooking(updatedAppointment);
//
//                                 CustomSnackBarWidget.show(
//                                   context: context,
//                                   text: 'Booking updated successfully',
//                                 );
//
//                                 AppNavigation.pushReplacement(
//                                   ConfirmationView(
//                                     doctor: widget.doctor,
//                                     date: updatedAppointment.date,
//                                     timeSlot: updatedAppointment.timeSlot,
//                                   ),
//                                 );
//                               } catch (e) {
//                                 CustomSnackBarWidget.show(
//                                   context: context,
//                                   text: 'Failed to update booking: $e',
//                                 );
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }