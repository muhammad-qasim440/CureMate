import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_centered_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../../../../assets/app_assets.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/app_strings.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../../core/utils/debug_print.dart';
import '../../../../shared/chat/providers/chatting_providers.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../shared/widgets/custom_drop_down_menu_widget.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../shared/widgets/lower_background_effects_widgets.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../../appointments/providers/appointments_providers.dart';
import '../../../appointments/utils/appointment_utils.dart';
import '../../../patient/providers/patient_providers.dart';
import 'patient_details_view.dart';
import 'doctor_appointment_details_view.dart';
import '../../../../router/nav.dart';

final doctorAppointmentsViewSearchQueryProvider=StateProvider<String>((ref)=>'');

class DoctorAppointmentsView extends ConsumerWidget {
  const DoctorAppointmentsView({super.key});

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Consumer(
        builder: (context, ref, _) {
          final filterOption = ref.watch(appointmentsFilterOptionProvider);
          final dateFilter = ref.watch(appointmentsDateFilterProvider);
          final isGroupedByPatient = ref.watch(appointmentsGroupByPatientProvider);

          return Container(
            decoration: const BoxDecoration(
              color: AppColors.gradientWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomTextWidget(
                      text: 'Filters',
                      textStyle: TextStyle(
                        fontFamily: AppFonts.rubik,
                        fontSize: FontSizes(context).size20,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomTextWidget(
                  text: 'Status',
                  textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                CustomDropdown(
                  items: AppStrings.appointmentFilterOptions,
                  initialValue: filterOption,
                  label: '',
                  onChanged: (value) {
                    ref.read(appointmentsFilterOptionProvider.notifier).state = value;
                    Navigator.pop(context);
                  },
                  backgroundColor: AppColors.gradientWhite,
                ),
                const SizedBox(height: 16),
                CustomTextWidget(
                  text: 'Date',
                  textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 8),
                CustomDropdown(
                  items: const ['All', 'Today', 'This Week', 'This Month'],
                  initialValue: dateFilter,
                  label: '',
                  onChanged: (value) {
                    ref.read(appointmentsDateFilterProvider.notifier).state = value;
                    Navigator.pop(context);
                  },
                  backgroundColor: AppColors.gradientWhite,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    CustomTextWidget(
                      text: 'Group by Patient',
                      textStyle: TextStyle(
                        fontFamily: AppFonts.rubik,
                        fontSize: FontSizes(context).size16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black,
                      ),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: isGroupedByPatient,
                      onChanged: (value) {
                        ref.read(appointmentsGroupByPatientProvider.notifier).state = value;
                        Navigator.pop(context);
                      },
                      activeColor: AppColors.gradientGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                CustomButtonWidget(
                  text: 'Reset Filters',
                  height: 45,
                  backgroundColor: Colors.transparent,
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size16,
                  fontWeight: FontWeight.w500,
                  textColor: AppColors.gradientGreen,
                  border: const BorderSide(color: AppColors.gradientGreen),
                  onPressed: () {
                    ref.read(appointmentsFilterOptionProvider.notifier).state = 'All';
                    ref.read(appointmentsDateFilterProvider.notifier).state = 'All';
                    ref.read(appointmentsGroupByPatientProvider.notifier).state = false;
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getActiveFiltersText(String status, String date, bool isGroupedByPatient) {
    List<String> activeFilters = [];
    if (status != 'All') activeFilters.add('Status: $status');
    if (date != 'All') activeFilters.add('Date: $date');
    if (isGroupedByPatient) activeFilters.add('Grouped by Patient');
    return activeFilters.join(' • ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final filterOption = ref.watch(appointmentsFilterOptionProvider);
    final dateFilter = ref.watch(appointmentsDateFilterProvider);
    final isGroupedByPatient = ref.watch(appointmentsGroupByPatientProvider);
    final searchQuery=ref.watch(doctorAppointmentsViewSearchQueryProvider);
    final bool hasActiveFilters = filterOption != 'All' ||
        dateFilter != 'All' ||
        isGroupedByPatient;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.gradientGreen,
        automaticallyImplyLeading: false,
        titleSpacing: 10,
        title: CustomTextWidget(
          text: 'My Appointments',
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w500,
            fontSize: FontSizes(context).size24,
            color: AppColors.gradientWhite,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white),
                onPressed: () => _showFilterBottomSheet(context, ref),
              ),
              if (hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  70.height,
                  if (hasActiveFilters) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.gradientWhite,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list,
                            color: AppColors.gradientGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextWidget(
                              text: _getActiveFiltersText(filterOption, dateFilter, isGroupedByPatient),
                              textStyle: TextStyle(
                                fontFamily: AppFonts.rubik,
                                fontSize: FontSizes(context).size14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.subTextColor,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ref.read(appointmentsFilterOptionProvider.notifier).state = 'All';
                              ref.read(appointmentsDateFilterProvider.notifier).state = 'All';
                              ref.read(appointmentsGroupByPatientProvider.notifier).state = false;
                            },
                            child: const Icon(Icons.close,
                              color: AppColors.gradientGreen,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: appointmentsAsync.when(
                      data: (appointments) {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          return const CustomCenteredTextWidget(
                            text: 'Please sign in to view bookings',
                          );
                        }

                        final filteredAppointments = filterAndSortAppointments(
                          appointments: appointments,
                          filterOption: filterOption,
                          dateFilter: dateFilter,
                          groupByField: isGroupedByPatient ? 'patientUid' : null,
                          userUid: user.uid,
                        );

                        final searchedAppointments = searchQuery.isEmpty
                            ? filteredAppointments
                            : filteredAppointments.where((appointment) {
                          return appointment.patientName.toLowerCase().contains(searchQuery) ||
                              appointment.bookerName.toLowerCase().contains(searchQuery) ||
                              appointment.id.toLowerCase().contains(searchQuery) ||
                              appointment.status.toLowerCase().contains(searchQuery) ||
                              appointment.timeSlot.toLowerCase().contains(searchQuery) ||
                              appointment.date.toLowerCase().contains(searchQuery);
                        }).toList();


                        if (searchedAppointments.isEmpty) {
                          return const CustomCenteredTextWidget(
                            text: 'No Bookings Found',
                          );
                        }

                        return ListView.builder(
                          itemCount: searchedAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = searchedAppointments[index];
                            final patientAsync = ref.watch(
                              patientDataByUidProvider(appointment.patientUid),
                            );

                            // Check if 30 minutes have passed since the appointment time
                            bool canComplete = false;
                            if (appointment.status == 'accepted') {
                              try {
                                final dateFormat = DateFormat('yyyy-MM-dd');
                                final timeFormat = DateFormat('hh:mm a');
                                final appointmentDate =
                                dateFormat.parse(appointment.date);
                                final appointmentTime =
                                timeFormat.parse(appointment.timeSlot);
                                final appointmentDateTime = DateTime(
                                  appointmentDate.year,
                                  appointmentDate.month,
                                  appointmentDate.day,
                                  appointmentTime.hour,
                                  appointmentTime.minute,
                                );
                                final now = DateTime.now();
                                final difference =
                                now.difference(appointmentDateTime);
                                canComplete = difference.inMinutes >= 1;
                              } catch (e) {
                                logDebug('Error parsing date/time: $e');
                              }
                            }

                            // Add a header for each new patient group
                            Widget? header;
                            if (isGroupedByPatient && (index == 0 ||
                                filteredAppointments[index].patientUid !=
                                    filteredAppointments[index - 1].patientUid)) {
                              header = Padding(
                                padding: const EdgeInsets.only(bottom: 15, left: 70),
                                child: CustomTextWidget(
                                  text: 'By: ${appointment.bookerName}',
                                  textStyle: TextStyle(
                                    fontFamily: AppFonts.rubik,
                                    fontSize: FontSizes(context).size18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gradientGreen,
                                  ),
                                ),
                              );
                            }

                            return patientAsync.when(
                              data: (patient) {
                                final displayPatient = patient ??
                                    Patient(
                                      uid: appointment.patientUid,
                                      fullName: 'Unknown Patient',
                                      email: '',
                                      city: '',
                                      dob: '',
                                      gender:'',
                                      age: 0,
                                      phoneNumber: '',
                                      profileImageUrl: '',
                                      profileImagePublicId: '',
                                      userType: 'Patient',
                                      latitude: 0.0,
                                      longitude: 0.0,
                                      createdAt: '',
                                      favorites: {},
                                      medicalRecords: {},
                                    );
                                final isOnline =
                                    ref
                                        .watch(formattedStatusProvider(patient!.uid))
                                        .value ==
                                        'Online';
                                return GestureDetector(
                                  onTap: () {
                                    AppNavigation.push(DoctorAppointmentDetailsView(
                                      appointment: appointment,
                                      patient: displayPatient,
                                    ));
                                  },
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 16),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.gradientWhite,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (header != null) header,
                                        Row(
                                          children: [
                                            Stack(
                                              children:[ ClipRRect(
                                                borderRadius: BorderRadius.circular(8),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    AppNavigation.push(PatientDetailsView(patient: displayPatient));
                                                  },
                                                  child: SizedBox(
                                                    width: ScreenUtil.scaleWidth(context, 60),
                                                    height: ScreenUtil.scaleHeight(context, 60),
                                                    child: displayPatient.profileImageUrl.isNotEmpty
                                                        ? Image.network(
                                                      displayPatient.profileImageUrl,
                                                      fit: BoxFit.cover,
                                                    )
                                                        : Image.asset(
                                                      AppAssets.defaultPatientImg,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                                Positioned(
                                                  top: 2,
                                                  left: 2,
                                                  child: Container(
                                                    width: 13,
                                                    height: 13,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color:
                                                      isOnline
                                                          ? AppColors
                                                          .gradientGreen
                                                          : AppColors
                                                          .subTextColor,
                                                      border: Border.all(
                                                        color: AppColors.black,
                                                        width: 1,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                             ],
                                            ),
                                            12.width,
                                            Expanded(
                                              child: GestureDetector(
                                                onTap: () {
                                                  AppNavigation.push(PatientDetailsView(patient: displayPatient));
                                                },
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomTextWidget(
                                                      text: displayPatient.fullName,
                                                      textStyle: TextStyle(
                                                        fontFamily: AppFonts.rubik,
                                                        fontSize: FontSizes(context).size18,
                                                        fontWeight: FontWeight.w600,
                                                        color: AppColors.black,
                                                      ),
                                                    ),
                                                    4.height,
                                                    CustomTextWidget(
                                                      text: appointment.patientType == 'My Self'
                                                          ? 'Patient: My Self'
                                                          : 'Patient: ${appointment.patientName}',
                                                      textStyle: TextStyle(
                                                        fontFamily: AppFonts.rubik,
                                                        fontSize: FontSizes(context).size14,
                                                        fontWeight: FontWeight.w400,
                                                        color: AppColors.subTextColor,
                                                      ),
                                                    ),
                                                    4.height,
                                                    appointment.patientType != 'My Self'
                                                        ? CustomTextWidget(
                                                      text: 'Relation with patient: ${appointment.patientType}',
                                                      textStyle: TextStyle(
                                                        fontFamily: AppFonts.rubik,
                                                        fontSize: FontSizes(context).size14,
                                                        fontWeight: FontWeight.w400,
                                                        color: AppColors.subTextColor,
                                                      ),
                                                    )
                                                        : const SizedBox.shrink(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        12.height,
                                        CustomTextWidget(
                                          text: 'ID : ${appointment.id}',
                                          textStyle: TextStyle(
                                            fontFamily: AppFonts.rubik,
                                            fontSize: FontSizes(context).size14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.subTextColor,
                                          ),
                                        ),
                                        4.height,
                                        CustomTextWidget(
                                          text: 'Patient Gender: ${appointment.patientGender}',
                                          textStyle: TextStyle(
                                            fontFamily: AppFonts.rubik,
                                            fontSize: FontSizes(context).size14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.subTextColor,
                                          ),
                                        ),
                                        4.height,
                                        CustomTextWidget(
                                          text: 'Patient Age: ${appointment.patientAge}',
                                          textStyle: TextStyle(
                                            fontFamily: AppFonts.rubik,
                                            fontSize: FontSizes(context).size14,
                                            fontWeight: FontWeight.w400,
                                            color:  AppColors.subTextColor,
                                          ),
                                        ),
                                        4.height,
                                        CustomTextWidget(
                                          text: 'Booked by: ${appointment.bookerName}',
                                          textStyle: TextStyle(
                                            fontFamily: AppFonts.rubik,
                                            fontSize: FontSizes(context).size14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.subTextColor,
                                          ),
                                        ),
                                        4.height,

                                        CustomTextWidget(
                                          text: 'Created At: ${appointment.createdAt.formattedDateTime}',
                                          textStyle: TextStyle(
                                            fontFamily: AppFonts.rubik,
                                            fontSize: FontSizes(context).size14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.subTextColor,
                                          ),
                                        ),
                                        if (appointment.updatedAt != null) ...[
                                          4.height,
                                          CustomTextWidget(
                                            text: 'Updated At: ${appointment.updatedAt!.formattedDateTime}',
                                            textStyle: TextStyle(
                                              fontFamily: AppFonts.rubik,
                                              fontSize: FontSizes(context).size14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.subTextColor,
                                            ),
                                          ),
                                        ],
                                        4.height,
                                        CustomTextWidget(
                                          text: 'Appointment Date: ${appointment.date.formattedDateMonthYear}',
                                          textStyle: TextStyle(
                                            fontFamily: AppFonts.rubik,
                                            fontSize: FontSizes(context).size14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.subTextColor,
                                          ),
                                        ),
                                        4.height,
                                        CustomTextWidget(
                                          text: 'Consultation Time: ${appointment.slotType} ${appointment.timeSlot}',
                                          textStyle: TextStyle(
                                            fontFamily: AppFonts.rubik,
                                            fontSize: FontSizes(context).size14,
                                            fontWeight: FontWeight.w400,
                                            color: AppColors.subTextColor,
                                          ),
                                        ),
                                        4.height,
                                        CustomTextWidget(
                                          text: 'Status: ${appointment.status.capitalize()}',
                                          textStyle: TextStyle(
                                            fontFamily: AppFonts.rubik,
                                            fontSize: FontSizes(context).size14,
                                            fontWeight: FontWeight.w500,
                                            color: AppColors.getStatusColor(appointment.status),
                                          ),
                                        ),
                                        if (appointment.patientNotes != null) ...[
                                          4.height,
                                          CustomTextWidget(
                                            text: 'Notes: ${appointment.patientNotes}',
                                            textStyle: TextStyle(
                                              fontFamily: AppFonts.rubik,
                                              fontSize: FontSizes(context).size14,
                                              fontWeight: FontWeight.w400,
                                              color: AppColors.subTextColor,
                                            ),
                                          ),
                                        ],
                                        16.height,
                                        if (appointment.status == 'pending') ...[
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              CustomButtonWidget(
                                                text: 'Accept',
                                                height: ScreenUtil.scaleHeight(context, 40),
                                                width: ScreenUtil.scaleWidth(context, 100),
                                                backgroundColor: AppColors.gradientGreen,
                                                fontFamily: AppFonts.rubik,
                                                fontSize: FontSizes(context).size14,
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.white,
                                                onPressed: () async {
                                                  final isConnected = await ref.read(
                                                      checkInternetConnectionProvider.future);
                                                  if (!isConnected) {
                                                    CustomSnackBarWidget.show(
                                                      context: context,
                                                      text: 'No Internet Connection',
                                                    );
                                                    return;
                                                  }

                                                  final database = FirebaseDatabase.instance.ref();
                                                  await database
                                                      .child('Appointments')
                                                      .child(appointment.id)
                                                      .update({
                                                    'status': 'accepted',
                                                  });

                                                  CustomSnackBarWidget.show(
                                                    context: context,
                                                    text: 'Booking accepted successfully',
                                                  );
                                                },
                                              ),
                                              CustomButtonWidget(
                                                text: 'Reject',
                                                height: ScreenUtil.scaleHeight(context, 40),
                                                width: ScreenUtil.scaleWidth(context, 100),
                                                backgroundColor: Colors.transparent,
                                                fontFamily: AppFonts.rubik,
                                                fontSize: FontSizes(context).size14,
                                                fontWeight: FontWeight.w500,
                                                textColor: Colors.red,
                                                border: const BorderSide(color: Colors.red),
                                                onPressed: () async {
                                                  final isConnected = await ref.read(
                                                      checkInternetConnectionProvider.future);
                                                  if (!isConnected) {
                                                    CustomSnackBarWidget.show(
                                                      context: context,
                                                      text: 'No Internet Connection',
                                                    );
                                                    return;
                                                  }

                                                  final database = FirebaseDatabase.instance.ref();
                                                  await database
                                                      .child('Appointments')
                                                      .child(appointment.id)
                                                      .update({
                                                    'status': 'rejected',
                                                  });

                                                  CustomSnackBarWidget.show(
                                                    context: context,
                                                    text: 'Booking rejected successfully',
                                                  );
                                                },
                                              ),
                                            ],
                                          ),
                                        ],
                                        if (appointment.status == 'accepted' && canComplete) ...[
                                          8.height,
                                          CustomButtonWidget(
                                            text: 'Complete',
                                            height: ScreenUtil.scaleHeight(context, 40),
                                            width: ScreenUtil.scaleWidth(context, 100),
                                            backgroundColor: Colors.blue,
                                            fontFamily: AppFonts.rubik,
                                            fontSize: FontSizes(context).size14,
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.white,
                                            onPressed: () async {
                                              final isConnected = await ref.read(
                                                  checkInternetConnectionProvider.future);
                                              if (!isConnected) {
                                                CustomSnackBarWidget.show(
                                                  context: context,
                                                  text: 'No Internet Connection',
                                                );
                                                return;
                                              }

                                              final database = FirebaseDatabase.instance.ref();
                                              await database
                                                  .child('Appointments')
                                                  .child(appointment.id)
                                                  .update({
                                                'status': 'completed',
                                              });
                                              final doctorRef = database.child('Doctors').child(appointment.doctorUid);
                                              await doctorRef.update({
                                                'totalPatientConsulted': ServerValue.increment(1),
                                              });
                                              CustomSnackBarWidget.show(
                                                context: context,
                                                text: 'Appointment marked as completed',
                                              );
                                            },
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (error, stack) {
                                logDebug('Error loading patient data: $error');
                                return Center(
                                  child: Text('Error loading patient: $error'),
                                );
                              },
                            );
                          },
                        );
                      },
                      loading: () =>
                      const Center(child: CircularProgressIndicator(color: AppColors.gradientGreen,)),
                      error: (error, stack) {
                        logDebug('Error loading appointments: $error');
                        return Center(child: Text('Error: $error'));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBarWidget(provider:doctorAppointmentsViewSearchQueryProvider),
          ),

        ],
      ),
    );
  }
}