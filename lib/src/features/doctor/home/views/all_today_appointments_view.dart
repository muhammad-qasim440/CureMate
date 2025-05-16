import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/back_view_icon_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../../appointments/providers/appointments_providers.dart';
import '../../appointments/views/doctor_appointment_details_view.dart';

class AllTodayAppointmentsView extends ConsumerWidget {
  const AllTodayAppointmentsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackViewIconWidget(),
        title: CustomTextWidget(
          text: 'Today\'s Appointments',
          textStyle: TextStyle(
            fontSize: FontSizes(context).size18,
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.gradientGreen,
        foregroundColor: Colors.white,
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          final todayAppointments = appointments
              .where((app) => app.date == DateFormat('yyyy-MM-dd').format(DateTime.now()))
              .toList();

          if (todayAppointments.isEmpty) {
            return Center(
              child: CustomTextWidget(
                text: 'No appointments scheduled for today',
                textStyle: TextStyle(
                  fontSize: FontSizes(context).size16,
                  fontFamily: AppFonts.rubik,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.gradientWhite,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    // Time Column (15%)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.15,
                      child: CustomTextWidget(
                        text: 'Time',
                        textStyle: TextStyle(
                          fontSize: FontSizes(context).size12,
                          fontFamily: AppFonts.rubik,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gradientGreen,
                        ),
                      ),
                    ),
                    // Patient Name Column (30%)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.30,
                      child: CustomTextWidget(
                        text: 'Patient Name',
                        textStyle: TextStyle(
                          fontSize: FontSizes(context).size12,
                          fontFamily: AppFonts.rubik,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gradientGreen,
                        ),
                      ),
                    ),
                    // Status Column (25%)
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.25,
                      child: CustomTextWidget(
                        text: 'Status',
                        textStyle: TextStyle(
                          fontSize: FontSizes(context).size12,
                          fontFamily: AppFonts.rubik,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gradientGreen,
                        ),
                      ),
                    ),
                    // Booked By Column (30%)
                    Expanded(
                      child: CustomTextWidget(
                        text: 'Booked By',
                        textStyle: TextStyle(
                          fontSize: FontSizes(context).size12,
                          fontFamily: AppFonts.rubik,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gradientGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Appointments List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
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
                          color: Colors.white,
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Time Column (15%)
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.15,
                              child: Text(
                                appointment.timeSlot,
                                style: TextStyle(
                                  color: _getStatusColor(appointment.status),
                                  fontSize: FontSizes(context).size11,
                                  fontFamily: AppFonts.rubik,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: ScreenUtil.wp(context, 0.28),
                              child: CustomTextWidget(
                                textAlignment: TextAlign.center,

                                text: appointment.patientName,
                                textStyle: TextStyle(
                                  fontSize: FontSizes(context).size11,
                                  fontFamily: AppFonts.rubik,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Status Column (25%)
                            SizedBox(
                              width: ScreenUtil.wp(context, 0.25),
                              child: CustomTextWidget(
                                text: appointment.status.toUpperCase(),
                                textStyle: TextStyle(
                                  fontSize: FontSizes(context).size11,
                                  fontFamily: AppFonts.rubik,
                                  color: _getStatusColor(appointment.status),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            // Booked By Column (30%)
                            Expanded(
                              child: CustomTextWidget(
                                textAlignment: TextAlign.center,
                                text: appointment.bookerName.toUpperCase(),
                                textStyle: TextStyle(
                                  fontSize: FontSizes(context).size11,
                                  fontFamily: AppFonts.rubik,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Text('Error loading appointments'),
      ),
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