import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/doctor/doctor_main_view.dart';
import 'package:curemate/src/features/drawer/views/doctor_drawer_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../../core/utils/debug_print.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../appointments/models/appointment_model.dart';
import '../../../appointments/providers/appointments_providers.dart';
import '../../../../utils/screen_utils.dart';
import '../../../doctor/providers/doctor_providers.dart';
import '../../../patient/providers/patient_providers.dart';
import '../../appointments/views/doctor_appointment_details_view.dart';
import 'all_today_appointments_view.dart';
import 'all_recent_patients_view.dart';

class DoctorHomeView extends ConsumerWidget {
  const DoctorHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final doctorAsync = ref.watch(currentSignInDoctorDataProvider);

    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          RefreshIndicator(
            color: AppColors.gradientGreen,
            onRefresh: () async {
              ref.refresh(appointmentsProvider);
              ref.refresh(currentSignInDoctorDataProvider);
            },
            child: Column(
              children: [
                _buildHeader(context, ref, appointmentsAsync, doctorAsync),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildQuickActions(context, ref),
                          const SizedBox(height: 20),
                          _buildNotifications(context, ref, appointmentsAsync),
                          const SizedBox(height: 20),
                          _buildTodayAppointments(
                            context,
                            appointmentsAsync,
                            ref,
                          ),
                          const SizedBox(height: 20),
                          _buildRecentPatients(context, ref, appointmentsAsync),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AppointmentModel>> appointmentsAsync,
    AsyncValue<Doctor?> doctorAsync,
  ) {
    return Container(
      height: ScreenUtil.scaleHeight(context, 200),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.gradientGreen,
            AppColors.gradientGreen.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextWidget(
                        text: 'Welcome back,',
                        textStyle: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: FontSizes(context).size16,
                          fontFamily: AppFonts.rubik,
                        ),
                      ),
                      const SizedBox(height: 4),
                      doctorAsync.when(
                        data:
                            (doctor) => CustomTextWidget(
                              text: doctor?.fullName ?? 'Doctor',
                              textStyle: TextStyle(
                                color: Colors.white,
                                fontSize: FontSizes(context).size24,
                                fontFamily: AppFonts.rubik,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        loading:
                            () => const CircularProgressIndicator(
                              color: Colors.white,
                            ),
                        error: (_, __) => const Text('Error loading profile'),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      AppNavigation.push(const DoctorDrawerView());
                    },
                    child: doctorAsync.when(
                      data:
                          (doctor) => Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  doctor?.profileImageUrl != null &&
                                          doctor!.profileImageUrl.isNotEmpty
                                      ? NetworkImage(doctor.profileImageUrl)
                                      : null,
                              child:
                                  doctor?.profileImageUrl == null ||
                                          doctor!.profileImageUrl.isEmpty
                                      ? const Icon(
                                        Icons.person,
                                        size: 35,
                                        color: AppColors.gradientGreen,
                                      )
                                      : null,
                            ),
                          ),
                      loading:
                          () => const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                      error:
                          (_, __) =>
                              const Icon(Icons.error, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              appointmentsAsync.when(
                data: (appointments) {
                  final todayAppointments =
                      appointments.where((app) {
                        return app.date ==
                            DateFormat('yyyy-MM-dd').format(DateTime.now());
                      }).length;

                  return GestureDetector(
                    onTap: () {
                      ref.read(doctorBottomNavIndexProvider.notifier).state = 1;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          CustomTextWidget(
                            text: '$todayAppointments appointments today',
                            textStyle: TextStyle(
                              color: Colors.white,
                              fontSize: FontSizes(context).size16,
                              fontFamily: AppFonts.rubik,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                loading:
                    () => const CircularProgressIndicator(color: Colors.white),
                error:
                    (_, __) => const Text(
                      'Error loading appointments',
                      style: TextStyle(color: Colors.white),
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextWidget(
          text: 'Quick Actions',
          textStyle: TextStyle(
            fontSize: FontSizes(context).size18,
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                context,
                'View Bookings',
                Icons.calendar_today,
                AppColors.gradientGreen,
                () => ref.read(doctorBottomNavIndexProvider.notifier).state = 1,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionCard(
                context,
                'Chat with Patients',
                Icons.chat_bubble_outline,
                Colors.blue,
                () => ref.read(doctorBottomNavIndexProvider.notifier).state = 2,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: FontSizes(context).size14,
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotifications(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AppointmentModel>> appointmentsAsync,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(doctorBottomNavIndexProvider.notifier).state = 1;
        ref.read(appointmentsFilterOptionProvider.notifier).state = 'Pending';
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            text: 'Important Updates',
            textStyle: TextStyle(
              fontSize: FontSizes(context).size18,
              fontFamily: AppFonts.rubik,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.gradientGreen,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppColors.black,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                appointmentsAsync.when(
                  data: (appointments) {
                    final pendingAppointments =
                        appointments
                            .where(
                              (appointments) =>
                                  appointments.status == 'pending',
                            )
                            .length;
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomTextWidget(
                            text: '$pendingAppointments Pending Appointments',
                            textStyle: TextStyle(
                              fontSize: FontSizes(context).size16,
                              fontFamily: AppFonts.rubik,
                              fontWeight: FontWeight.w500,
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You have pending appointments that need review',
                            style: TextStyle(
                              fontSize: FontSizes(context).size14,
                              fontFamily: AppFonts.rubik,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error:
                      (error, stack) => CustomTextWidget(
                        text: 'Unable to fetch pending appointments $error ',
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayAppointments(
    BuildContext context,
    AsyncValue<List<AppointmentModel>> appointmentsAsync,
    WidgetRef ref,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomTextWidget(
              text: 'Today\'s Appointments',
              textStyle: TextStyle(
                fontSize: FontSizes(context).size18,
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            CustomButtonWidget(
              text: 'See All',
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size12,
              textColor: AppColors.textColor,
              onPressed: () {
                AppNavigation.push(const AllTodayAppointmentsView());
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        appointmentsAsync.when(
          data: (appointments) {
            final todayAppointments =
                appointments
                    .where((app) {
                      return app.date ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now());
                    })
                    .take(4)
                    .toList();

            if (todayAppointments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomTextWidget(
                    text: 'No appointments scheduled for today',
                    textStyle: TextStyle(
                      fontSize: FontSizes(context).size16,
                      fontFamily: AppFonts.rubik,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: AppColors.gradientWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Headers Row
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        10.width,
                        CustomTextWidget(
                          text: 'Time',
                          textStyle: TextStyle(
                            fontSize: FontSizes(context).size12,
                            fontFamily: AppFonts.rubik,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gradientGreen,

                          ),
                        ),
                        const SizedBox(width: 20),
                        CustomTextWidget(
                          text: 'Patient Name',
                          textStyle: TextStyle(
                            fontSize: FontSizes(context).size12,
                            fontFamily: AppFonts.rubik,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gradientGreen,

                          ),
                        ),
                        const SizedBox(width: 20),

                        CustomTextWidget(
                          text: 'Status',
                          textStyle: TextStyle(
                            fontSize: FontSizes(context).size12,
                            fontFamily: AppFonts.rubik,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gradientGreen,

                          ),
                        ),
                        const SizedBox(width: 20),

                        CustomTextWidget(
                          text: 'Booked By',
                          textStyle: TextStyle(
                            fontSize: FontSizes(context).size12,
                            fontFamily: AppFonts.rubik,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gradientGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Appointments List
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment = todayAppointments[index];
                      return GestureDetector(
                        onTap: () async {
                          final patientAsync = await ref.read(
                            patientDataByUidProvider(appointment.patientUid).future,
                          );
                          if (patientAsync != null) {
                            AppNavigation.push(
                              DoctorAppointmentDetailsView(
                                appointment: appointment,
                                patient: patientAsync,
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Center(
                                child: Text(
                                  appointment.timeSlot,
                                  style: TextStyle(
                                    color: _getStatusColor(appointment.status),
                                    fontSize: FontSizes(context).size11,
                                    fontFamily: AppFonts.rubik,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              CustomTextWidget(
                                text: appointment.patientName,
                                textStyle: TextStyle(
                                  fontSize: FontSizes(context).size11,
                                  fontFamily: AppFonts.rubik,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 20),
                              CustomTextWidget(
                                text: appointment.status.toUpperCase(),
                                textStyle: TextStyle(
                                  fontSize: FontSizes(context).size11,
                                  fontFamily: AppFonts.rubik,
                                  color: _getStatusColor(appointment.status),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 20),
                              CustomTextWidget(
                                text: appointment.bookerName.toUpperCase(),
                                textStyle: TextStyle(
                                  fontSize: FontSizes(context).size11,
                                  fontFamily: AppFonts.rubik,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Error loading appointments'),
        ),
      ],
    );
  }

  Widget _buildRecentPatients(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<AppointmentModel>> appointmentsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomTextWidget(
              text: 'Recent Patients',
              textStyle: TextStyle(
                fontSize: FontSizes(context).size18,
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            CustomButtonWidget(
              text: 'See All',
              fontFamily: AppFonts.rubik,
              fontSize: FontSizes(context).size12,
              textColor: AppColors.textColor,
              onPressed: () {
                AppNavigation.push(const AllRecentPatientsView());
              },
            ),
          ],
        ),
        10.height,
        appointmentsAsync.when(
          data: (appointments) {
            final recentAppointments =
                appointments
                    .where((app) => app.status == 'completed')
                    .take(3)
                    .toList();

            if (recentAppointments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CustomTextWidget(
                    text: 'No recent patients',
                    textStyle: TextStyle(
                      fontSize: FontSizes(context).size16,
                      fontFamily: AppFonts.rubik,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentAppointments.length,
              itemBuilder: (context, index) {
                final appointment = recentAppointments[index];
                final patientAsync = ref.watch(
                  patientDataByUidProvider(appointment.patientUid),
                );

                return patientAsync.when(
                  data: (patient) {
                    final displayPatient =
                        patient ??
                        Patient(
                          uid: appointment.patientUid,
                          fullName: 'Unknown Patient',
                          email: '',
                          city: '',
                          dob: '',
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

                    return GestureDetector(
                      onTap: () {
                        AppNavigation.push(
                          DoctorAppointmentDetailsView(
                            appointment: appointment,
                            patient: displayPatient,
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: AppColors.gradientGreen
                                  .withOpacity(0.1),
                              child: Text(
                                appointment.patientName[0],
                                style: TextStyle(
                                  color: AppColors.gradientGreen,
                                  fontSize: FontSizes(context).size18,
                                  fontFamily: AppFonts.rubik,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    appointment.patientName,
                                    style: TextStyle(
                                      fontSize: FontSizes(context).size16,
                                      fontFamily: AppFonts.rubik,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Last visit: ${appointment.date}',
                                    style: TextStyle(
                                      fontSize: FontSizes(context).size14,
                                      fontFamily: AppFonts.rubik,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chat_bubble_outline),
                              color: AppColors.gradientGreen,
                              onPressed: () {
                                ref
                                    .read(doctorBottomNavIndexProvider.notifier)
                                    .state = 2;
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (error, stack) {
                    logDebug('Error loading patient data: $error');
                    return Center(child: Text('Error loading patient: $error'));
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Text('Error loading recent patients'),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return AppColors.gradientGreen;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }
}
