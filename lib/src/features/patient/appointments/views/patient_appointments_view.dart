import 'package:curemate/core/extentions/date_time_format_extension.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/appointments/views/patient_appointment_details_view.dart';
import 'package:curemate/src/features/patient/shared/views/doctor_details_view.dart';
import 'package:curemate/src/shared/widgets/custom_centered_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../assets/app_assets.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../router/nav.dart';
import '../../../../shared/chat/providers/chatting_providers.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../shared/widgets/custom_drop_down_menu_widget.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../../appointments/providers/appointments_providers.dart';
import '../../../appointments/utils/appointment_utils.dart';
import '../../../appointments/views/appointment_booking_view.dart';
import '../../providers/patient_providers.dart';
import '../../../../../const/app_strings.dart';

final patientAppointmentsViewSearchQueryProvider = StateProvider<String>(
  (ref) => '',
);
final appointmentsDateFilterProvider = StateProvider<String>((ref) => 'All');
final appointmentsGroupByDoctorProvider = StateProvider<bool>((ref) => false);

class PatientAppointmentsView extends ConsumerWidget {
  const PatientAppointmentsView({super.key});

  Future<void> _cancelNotification(String appointmentId) async {
    final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.cancel(appointmentId.hashCode);
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Consumer(
            builder: (context, ref, _) {
              final filterOption = ref.watch(appointmentsFilterOptionProvider);
              final dateFilter = ref.watch(appointmentsDateFilterProvider);
              final isGroupedByDoctor = ref.watch(
                appointmentsGroupByDoctorProvider,
              );

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
                        ref
                            .read(appointmentsFilterOptionProvider.notifier)
                            .state = value;
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
                        ref
                            .read(appointmentsDateFilterProvider.notifier)
                            .state = value;
                        Navigator.pop(context);
                      },
                      backgroundColor: AppColors.gradientWhite,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CustomTextWidget(
                          text: 'Group by Doctor',
                          textStyle: TextStyle(
                            fontFamily: AppFonts.rubik,
                            fontSize: FontSizes(context).size16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                        const Spacer(),
                        Switch.adaptive(
                          value: isGroupedByDoctor,
                          onChanged: (value) {
                            ref
                                .read(
                                  appointmentsGroupByDoctorProvider.notifier,
                                )
                                .state = value;
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
                        ref
                            .read(appointmentsFilterOptionProvider.notifier)
                            .state = 'All';
                        ref
                            .read(appointmentsDateFilterProvider.notifier)
                            .state = 'All';
                        ref
                            .read(appointmentsGroupByDoctorProvider.notifier)
                            .state = false;
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

  String _getActiveFiltersText(
    String status,
    String date,
    bool isGroupedByDoctor,
  ) {
    List<String> activeFilters = [];
    if (status != 'All') activeFilters.add('Status: $status');
    if (date != 'All') activeFilters.add('Date: $date');
    if (isGroupedByDoctor) activeFilters.add('Grouped by Doctor');
    return activeFilters.join(' • ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentsProvider).value ?? [];
    final filterOption = ref.watch(appointmentsFilterOptionProvider);
    final dateFilter = ref.watch(appointmentsDateFilterProvider);
    final isGroupedByDoctor = ref.watch(appointmentsGroupByDoctorProvider);
    final searchQuery = ref.watch(patientAppointmentsViewSearchQueryProvider);

    final bool hasActiveFilters =
        filterOption != 'All' || dateFilter != 'All' || isGroupedByDoctor;

    final filteredAppointments = filterAndSortAppointments(
      appointments: appointments,
      filterOption: filterOption,
      dateFilter: dateFilter,
      groupByField: isGroupedByDoctor ? 'doctorUid' : null,
    );

    final searchedAppointments =
        searchQuery.isEmpty
            ? filteredAppointments
            : filteredAppointments.where((appointment) {
              return appointment.doctorName.toLowerCase().contains(
                    searchQuery,
                  ) ||
                  appointment.doctorCategory.toLowerCase().contains(
                    searchQuery,
                  ) ||
                  appointment.id.toLowerCase().contains(searchQuery) ||
                  appointment.status.toLowerCase().contains(searchQuery) ||
                  appointment.timeSlot.toLowerCase().contains(searchQuery) ||
                  appointment.date.toLowerCase().contains(searchQuery);
            }).toList();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.gradientGreen,
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
                  50.height,
                  if (hasActiveFilters) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
                          const Icon(
                            Icons.filter_list,
                            color: AppColors.gradientGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextWidget(
                              text: _getActiveFiltersText(
                                filterOption,
                                dateFilter,
                                isGroupedByDoctor,
                              ),
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
                              ref
                                  .read(
                                    appointmentsFilterOptionProvider.notifier,
                                  )
                                  .state = 'All';
                              ref
                                  .read(appointmentsDateFilterProvider.notifier)
                                  .state = 'All';
                              ref
                                  .read(
                                    appointmentsGroupByDoctorProvider.notifier,
                                  )
                                  .state = false;
                            },
                            child: const Icon(
                              Icons.close,
                              color: AppColors.gradientGreen,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  24.height,
                  if (searchedAppointments.isEmpty)
                    const Expanded(
                      child: CustomCenteredTextWidget(
                        text: 'No bookings Found',
                      ),
                    )
                  else
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(appointmentsProvider);
                        },
                        color: AppColors.gradientGreen,
                        child: ListView.builder(
                          itemCount: searchedAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = searchedAppointments[index];

                            final doctor = ref
                                .watch(doctorsProvider)
                                .value
                                ?.firstWhere(
                                  (doc) => doc.uid == appointment.doctorUid,
                                  orElse:
                                      () => Doctor(
                                        uid: appointment.doctorUid,
                                        fullName: 'Unknown Doctor',
                                        email: '',
                                        city: '',
                                        dob: '',
                                        gender:'',
                                        age: 0,
                                        phoneNumber: '',
                                        profileImageUrl: '',
                                        profileImagePublicId: '',
                                        userType: 'Doctor',
                                        latitude: 0.0,
                                        longitude: 0.0,
                                        createdAt: '',
                                        qualification: '',
                                        yearsOfExperience: '',
                                        category: '',
                                        hospital: '',
                                        averageRatings: 0.0,
                                        totalReviews: 0,
                                        totalPatientConsulted: 0,
                                        consultationFee: 0,
                                        profileViews: 0,
                                        viewedBy: {},
                                        availability: [],
                                      ),
                                );

                            Widget? header;
                            if (isGroupedByDoctor &&
                                (index == 0 ||
                                    filteredAppointments[index].doctorUid !=
                                        filteredAppointments[index - 1]
                                            .doctorUid)) {
                              header = Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 15,
                                  left: 70,
                                ),
                                child: CustomTextWidget(
                                  text: doctor!.fullName,
                                  textStyle: TextStyle(
                                    fontFamily: AppFonts.rubik,
                                    fontSize: FontSizes(context).size18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gradientGreen,
                                  ),
                                ),
                              );
                            }

                            final isPending = appointment.status == 'pending';
                            final isCancelled =
                                appointment.status == 'cancelled';
                            final isOnline =
                                ref
                                    .watch(formattedStatusProvider(doctor!.uid))
                                    .value ==
                                'Online';
                            return GestureDetector(
                              onTap: () {
                                AppNavigation.push(
                                  PatientAppointmentDetailsView(
                                    appointment: appointment,
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color:
                                      isCancelled
                                          ? Colors.grey[200]
                                          : AppColors.gradientWhite,
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
                                    GestureDetector(
                                      onTap: () {
                                        AppNavigation.push(
                                          DoctorProfileView(doctor: doctor),
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Stack(
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: SizedBox(
                                                  width: ScreenUtil.scaleWidth(
                                                    context,
                                                    60,
                                                  ),
                                                  height:
                                                      ScreenUtil.scaleHeight(
                                                        context,
                                                        60,
                                                      ),
                                                  child:
                                                      doctor!
                                                              .profileImageUrl
                                                              .isNotEmpty
                                                          ? Image.network(
                                                            doctor
                                                                .profileImageUrl,
                                                            fit: BoxFit.cover,
                                                          )
                                                          : Image.asset(
                                                            AppAssets
                                                                .defaultDoctorImg,
                                                            fit: BoxFit.cover,
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
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CustomTextWidget(
                                                  text: doctor.fullName,
                                                  textStyle: TextStyle(
                                                    fontFamily: AppFonts.rubik,
                                                    fontSize:
                                                        FontSizes(
                                                          context,
                                                        ).size18,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        isCancelled
                                                            ? Colors.grey
                                                            : AppColors.black,
                                                  ),
                                                ),
                                                4.height,
                                                CustomTextWidget(
                                                  text: doctor.category,
                                                  textStyle: TextStyle(
                                                    fontFamily: AppFonts.rubik,
                                                    fontSize:
                                                        FontSizes(
                                                          context,
                                                        ).size14,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                        isCancelled
                                                            ? Colors.grey
                                                            : AppColors
                                                                .subTextColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    12.height,
                                    CustomTextWidget(
                                      text: 'ID : ${appointment.id}',
                                      textStyle: TextStyle(
                                        fontFamily: AppFonts.rubik,
                                        fontSize: FontSizes(context).size14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            isCancelled
                                                ? Colors.grey
                                                : AppColors.subTextColor,
                                      ),
                                    ),
                                    4.height,
                                    CustomTextWidget(
                                      text:
                                          'Patient: ${appointment.patientName} (${appointment.patientType})',
                                      textStyle: TextStyle(
                                        fontFamily: AppFonts.rubik,
                                        fontSize: FontSizes(context).size14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            isCancelled
                                                ? Colors.grey
                                                : AppColors.subTextColor,
                                      ),
                                    ),
                                    4.height,
                                    CustomTextWidget(
                                      text:
                                          'Patient Gender: ${appointment.patientGender}',
                                      textStyle: TextStyle(
                                        fontFamily: AppFonts.rubik,
                                        fontSize: FontSizes(context).size14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            isCancelled
                                                ? Colors.grey
                                                : AppColors.subTextColor,
                                      ),
                                    ),
                                    4.height,
                                    CustomTextWidget(
                                      text:
                                          'Patient Age: ${appointment.patientAge}',
                                      textStyle: TextStyle(
                                        fontFamily: AppFonts.rubik,
                                        fontSize: FontSizes(context).size14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            isCancelled
                                                ? Colors.grey
                                                : AppColors.subTextColor,
                                      ),
                                    ),
                                    4.height,
                                    CustomTextWidget(
                                      text:
                                          'Booked by: ${appointment.bookerName}',
                                      textStyle: TextStyle(
                                        fontFamily: AppFonts.rubik,
                                        fontSize: FontSizes(context).size14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            isCancelled
                                                ? Colors.grey
                                                : AppColors.subTextColor,
                                      ),
                                    ),
                                    4.height,
                                    CustomTextWidget(
                                      text:
                                          'Created At: ${appointment.createdAt.formattedDateTime}',
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
                                        text:
                                            'Updated At: ${appointment.updatedAt!.formattedDateTime}',
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
                                      text:
                                          'Appointment Date: ${appointment.date.formattedDateMonthYear}',
                                      textStyle: TextStyle(
                                        fontFamily: AppFonts.rubik,
                                        fontSize: FontSizes(context).size14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            isCancelled
                                                ? Colors.grey
                                                : AppColors.subTextColor,
                                      ),
                                    ),
                                    4.height,
                                    CustomTextWidget(
                                      text:
                                          'Consultation Time: ${appointment.slotType} ${appointment.timeSlot}',
                                      textStyle: TextStyle(
                                        fontFamily: AppFonts.rubik,
                                        fontSize: FontSizes(context).size14,
                                        fontWeight: FontWeight.w400,
                                        color:
                                            isCancelled
                                                ? Colors.grey
                                                : AppColors.subTextColor,
                                      ),
                                    ),
                                    4.height,
                                    CustomTextWidget(
                                      text:
                                          'Status: ${appointment.status.capitalize()}',
                                      textStyle: TextStyle(
                                        fontFamily: AppFonts.rubik,
                                        fontSize: FontSizes(context).size14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.getStatusColor(
                                          appointment.status,
                                        ),
                                      ),
                                    ),
                                    if (appointment.patientNotes != null) ...[
                                      4.height,
                                      CustomTextWidget(
                                        text:
                                            'Notes: ${appointment.patientNotes}',
                                        textStyle: TextStyle(
                                          fontFamily: AppFonts.rubik,
                                          fontSize: FontSizes(context).size14,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              isCancelled
                                                  ? Colors.grey
                                                  : AppColors.subTextColor,
                                        ),
                                      ),
                                    ],
                                    if (appointment.reminderTime != null) ...[
                                      4.height,
                                      CustomTextWidget(
                                        text:
                                            'Reminder: ${appointment.reminderTime} before',
                                        textStyle: TextStyle(
                                          fontFamily: AppFonts.rubik,
                                          fontSize: FontSizes(context).size14,
                                          fontWeight: FontWeight.w400,
                                          color:
                                              isCancelled
                                                  ? Colors.grey
                                                  : AppColors.subTextColor,
                                        ),
                                      ),
                                    ],
                                    16.height,
                                    if (isPending)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          CustomButtonWidget(
                                            text: 'Edit',
                                            height: ScreenUtil.scaleHeight(
                                              context,
                                              40,
                                            ),
                                            width: ScreenUtil.scaleWidth(
                                              context,
                                              100,
                                            ),
                                            backgroundColor:
                                                AppColors.gradientGreen,
                                            fontFamily: AppFonts.rubik,
                                            fontSize: FontSizes(context).size14,
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.white,
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    bookingViewSelectedPatientLabelProvider
                                                        .notifier,
                                                  )
                                                  .state = appointment
                                                      .patientType;
                                              ref
                                                  .read(
                                                    bookingViewPatientNameProvider
                                                        .notifier,
                                                  )
                                                  .state = appointment
                                                      .patientName;
                                              ref
                                                  .read(
                                                    bookingViewPatientNumberProvider
                                                        .notifier,
                                                  )
                                                  .state = appointment
                                                      .patientNumber;
                                              AppNavigation.push(
                                                AppointmentBookingView(
                                                  doctor: doctor,
                                                  appointment: appointment,
                                                ),
                                              );
                                            },
                                          ),
                                          CustomButtonWidget(
                                            text: 'Cancel',
                                            height: ScreenUtil.scaleHeight(
                                              context,
                                              40,
                                            ),
                                            width: ScreenUtil.scaleWidth(
                                              context,
                                              100,
                                            ),
                                            backgroundColor: Colors.transparent,
                                            fontFamily: AppFonts.rubik,
                                            fontSize: FontSizes(context).size14,
                                            fontWeight: FontWeight.w500,
                                            textColor: Colors.red,
                                            border: const BorderSide(
                                              color: Colors.red,
                                            ),
                                            onPressed: () async {
                                              final isConnected = await ref.read(
                                                checkInternetConnectionProvider
                                                    .future,
                                              );
                                              if (!isConnected) {
                                                CustomSnackBarWidget.show(
                                                  context: context,
                                                  text:
                                                      'No Internet Connection',
                                                );
                                                return;
                                              }

                                              try {
                                                await ref
                                                    .read(
                                                      bookingRepositoryProvider,
                                                    )
                                                    .cancelBooking(
                                                      appointment.id,
                                                      DateTime.now()
                                                          .toIso8601String(),
                                                    );
                                                await _cancelNotification(
                                                  appointment.id,
                                                );

                                                CustomSnackBarWidget.show(
                                                  context: context,
                                                  text:
                                                      'Booking cancelled successfully',
                                                );
                                              } catch (e) {
                                                CustomSnackBarWidget.show(
                                                  context: context,
                                                  text:
                                                      'Failed to cancel booking: $e',
                                                );
                                              }
                                            },
                                          ),
                                        ],
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBarWidget(
              provider: patientAppointmentsViewSearchQueryProvider,
            ),
          ),
        ],
      ),
    );
  }
}
