import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../../core/utils/debug_print.dart';
import '../../../../shared/widgets/back_view_icon_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../appointments/providers/appointments_providers.dart';
import '../../../patient/providers/patient_providers.dart';
import '../../appointments/views/doctor_appointment_details_view.dart';

class AllRecentPatientsView extends ConsumerWidget {
  const AllRecentPatientsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackViewIconWidget(),
        title: CustomTextWidget(
          text: 'Recent Patients',
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
          final recentAppointments = appointments
              .where((app) => app.status == 'completed')
              .toList();

          if (recentAppointments.isEmpty) {
            return Center(
              child: CustomTextWidget(
                text: 'No recent patients',
                textStyle: TextStyle(
                  fontSize: FontSizes(context).size16,
                  fontFamily: AppFonts.rubik,
                  color: Colors.grey,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recentAppointments.length,
            itemBuilder: (context, index) {
              final appointment = recentAppointments[index];
              final patientAsync = ref.watch(
                patientDataByUidProvider(appointment.patientUid),
              );

              return patientAsync.when(
                data: (patient) {
                  final displayPatient = patient ?? Patient(
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
                            backgroundColor: AppColors.gradientGreen.withOpacity(0.1),
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
                          12.width,
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
                              // TODO: Implement chat functionality
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
    );
  }
} 