import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_centered_text_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/app_strings.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../shared/widgets/custom_drop_down_menu_widget.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../shared/widgets/lower_background_effects_widgets.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../../bookings/providers/booking_providers.dart';
import '../../../patient/providers/patient_providers.dart';

class DoctorBookingsView extends ConsumerWidget {
  const DoctorBookingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentsProvider);
    final filterOption = ref.watch(appointmentsFilterOptionProvider);

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
          Padding(
            padding: EdgeInsets.only(right: ScreenUtil.scaleWidth(context, 5.0)),
            child: SizedBox(
              width: ScreenUtil.scaleWidth(context, 110),
              height: ScreenUtil.scaleHeight(context, 35),
              child: CustomDropdown(
                items: AppStrings.appointmentFilterOptions,
                label: '',
                onChanged: (value) {
                  ref.read(appointmentsFilterOptionProvider.notifier).state = value;
                },
                backgroundColor: AppColors.gradientWhite,
              ),
            ),
          ),
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
                  const SizedBox(height: 24),
                  Expanded(
                    child: appointmentsAsync.when(
                      data: (appointments) {
                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null) {
                          return const CustomCenteredTextWidget(
                            text: 'Please sign in to view bookings',
                          );
                        }
                        final filteredAppointments = appointments.where((app) {
                          if (app.doctorUid != user.uid) return false;
                          if (app.status == 'cancelled') return false;
                          if (filterOption == 'All') return true;
                          return app.status.toLowerCase() == filterOption.toLowerCase();
                        }).toList();


                        if (filteredAppointments.isEmpty) {
                          return const CustomCenteredTextWidget(
                            text: 'No Bookings Found',
                          );
                        }

                        return ListView.builder(
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = filteredAppointments[index];
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
                                canComplete = difference.inMinutes >= 30;
                              } catch (e) {
                                print('Error parsing date/time: $e');
                              }
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

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColors.gradientWhite,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                        AppColors.black.withOpacity(0.05),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(8),
                                            child: SizedBox(
                                              width: ScreenUtil.scaleWidth(
                                                  context, 60),
                                              height: ScreenUtil.scaleHeight(
                                                  context, 60),
                                              child: displayPatient
                                                  .profileImageUrl.isNotEmpty
                                                  ? Image.network(
                                                displayPatient
                                                    .profileImageUrl,
                                                fit: BoxFit.cover,
                                              )
                                                  : Image.asset(
                                                  'assets/default_patient.png'),
                                            ),
                                          ),
                                          12.width,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                CustomTextWidget(
                                                  text: displayPatient.fullName,
                                                  textStyle: TextStyle(
                                                    fontFamily: AppFonts.rubik,
                                                    fontSize:
                                                    FontSizes(context)
                                                        .size18,
                                                    fontWeight: FontWeight.w600,
                                                    color: AppColors.black,
                                                  ),
                                                ),
                                                4.height,
                                                CustomTextWidget(
                                                  text: appointment
                                                      .patientType ==
                                                      'My Self'
                                                      ? 'Patient: My Self'
                                                      : 'Patient: ${appointment.patientName}',
                                                  textStyle: TextStyle(
                                                    fontFamily: AppFonts.rubik,
                                                    fontSize:
                                                    FontSizes(context)
                                                        .size14,
                                                    fontWeight: FontWeight.w400,
                                                    color:
                                                    AppColors.subTextColor,
                                                  ),
                                                ),
                                                4.height,
                                                appointment.patientType !=
                                                    'My Self'
                                                    ? CustomTextWidget(
                                                  text:
                                                  'Relation with patient: ${appointment.patientType}',
                                                  textStyle: TextStyle(
                                                    fontFamily:
                                                    AppFonts.rubik,
                                                    fontSize:
                                                    FontSizes(context)
                                                        .size14,
                                                    fontWeight:
                                                    FontWeight.w400,
                                                    color: AppColors
                                                        .subTextColor,
                                                  ),
                                                )
                                                    : const SizedBox.shrink(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      12.height,
                                      CustomTextWidget(
                                        text:
                                        'Created At: ${appointment.createdAt.formattedDate}',
                                        textStyle: TextStyle(
                                          fontFamily: AppFonts.rubik,
                                          fontSize: FontSizes(context).size14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.subTextColor,
                                        ),
                                      ),
                                      4.height,
                                      CustomTextWidget(
                                        text:
                                        'Appointment Date: ${appointment.date}',
                                        textStyle: TextStyle(
                                          fontFamily: AppFonts.rubik,
                                          fontSize: FontSizes(context).size14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.subTextColor,
                                        ),
                                      ),
                                      4.height,
                                      CustomTextWidget(
                                        text:
                                        'Time: ${appointment.slotType} ${appointment.timeSlot}',
                                        textStyle: TextStyle(
                                          fontFamily: AppFonts.rubik,
                                          fontSize: FontSizes(context).size14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.subTextColor,
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
                                          color:
                                          _getStatusColor(appointment.status),
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
                                            color: AppColors.subTextColor,
                                          ),
                                        ),
                                      ],
                                      16.height,
                                      if (appointment.status == 'pending') ...[
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            CustomButtonWidget(
                                              text: 'Accept',
                                              height: ScreenUtil.scaleHeight(
                                                  context, 40),
                                              width: ScreenUtil.scaleWidth(
                                                  context, 100),
                                              backgroundColor:
                                              AppColors.gradientGreen,
                                              fontFamily: AppFonts.rubik,
                                              fontSize:
                                              FontSizes(context).size14,
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.white,
                                              onPressed: () async {
                                                final isConnected = await ref
                                                    .read(
                                                    checkInternetConnectionProvider
                                                        .future);
                                                if (!isConnected) {
                                                  CustomSnackBarWidget.show(
                                                    context: context,
                                                    text:
                                                    'No Internet Connection',
                                                  );
                                                  return;
                                                }

                                                final database = FirebaseDatabase
                                                    .instance
                                                    .ref();
                                                await database
                                                    .child('Appointments')
                                                    .child(appointment.id)
                                                    .update({
                                                  'status': 'accepted',
                                                });

                                                CustomSnackBarWidget.show(
                                                  context: context,
                                                  text:
                                                  'Booking accepted successfully',
                                                );
                                              },
                                            ),
                                            CustomButtonWidget(
                                              text: 'Reject',
                                              height: ScreenUtil.scaleHeight(
                                                  context, 40),
                                              width: ScreenUtil.scaleWidth(
                                                  context, 100),
                                              backgroundColor:
                                              Colors.transparent,
                                              fontFamily: AppFonts.rubik,
                                              fontSize:
                                              FontSizes(context).size14,
                                              fontWeight: FontWeight.w500,
                                              textColor: Colors.red,
                                              border: const BorderSide(
                                                  color: Colors.red),
                                              onPressed: () async {
                                                final isConnected = await ref
                                                    .read(
                                                    checkInternetConnectionProvider
                                                        .future);
                                                if (!isConnected) {
                                                  CustomSnackBarWidget.show(
                                                    context: context,
                                                    text:
                                                    'No Internet Connection',
                                                  );
                                                  return;
                                                }

                                                final database = FirebaseDatabase
                                                    .instance
                                                    .ref();
                                                await database
                                                    .child('Appointments')
                                                    .child(appointment.id)
                                                    .update({
                                                  'status': 'rejected',
                                                });

                                                CustomSnackBarWidget.show(
                                                  context: context,
                                                  text:
                                                  'Booking rejected successfully',
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                      if (appointment.status == 'accepted' &&
                                          canComplete) ...[
                                        8.height,
                                        CustomButtonWidget(
                                          text: 'Complete',
                                          height:
                                          ScreenUtil.scaleHeight(context, 40),
                                          width:
                                          ScreenUtil.scaleWidth(context, 100),
                                          backgroundColor: Colors.blue,
                                          fontFamily: AppFonts.rubik,
                                          fontSize: FontSizes(context).size14,
                                          fontWeight: FontWeight.w500,
                                          textColor: Colors.white,
                                          onPressed: () async {
                                            final isConnected = await ref.read(
                                                checkInternetConnectionProvider
                                                    .future);
                                            if (!isConnected) {
                                              CustomSnackBarWidget.show(
                                                context: context,
                                                text: 'No Internet Connection',
                                              );
                                              return;
                                            }

                                            final database =
                                            FirebaseDatabase.instance.ref();
                                            await database
                                                .child('Appointments')
                                                .child(appointment.id)
                                                .update({
                                              'status': 'completed',
                                            });

                                            CustomSnackBarWidget.show(
                                              context: context,
                                              text:
                                              'Appointment marked as completed',
                                            );
                                          },
                                        ),
                                      ],
                                    ],
                                  ),
                                );
                              },
                              loading: () =>
                              const SizedBox.shrink(),
                              error: (error, stack) {
                                print('Error loading patient data: $error');
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
                        print('Error loading appointments: $error');
                        return Center(child: Text('Error: $error'));
                      },
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return AppColors.gradientGreen;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'completed':
        return Colors.blue;
      default:
        return AppColors.subTextColor;
    }
  }
}