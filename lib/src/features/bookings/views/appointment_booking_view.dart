// appointment_booking_view.dart
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/bookings/card/doctor_booking_view_card.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../router/nav.dart';
import '../../../shared/widgets/custom_appbar_header_widget.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../patient/providers/patient_providers.dart';
import 'select_time_view.dart';

class AppointmentBookingView extends ConsumerStatefulWidget {
  final Doctor doctor;
  final bool isFavorite;

  const AppointmentBookingView({super.key, required this.doctor,required this.isFavorite});

  @override
  ConsumerState<AppointmentBookingView> createState() => _AppointmentBookingViewState();
}

class _AppointmentBookingViewState extends ConsumerState<AppointmentBookingView> {
  String selectedPatientOption = 'My Self';
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();

  @override
  void dispose() {
    patientNameController.dispose();
    contactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patient = ref.watch(currentSignInPatientDataProvider).value;

    // if (patient != null) {
    //   patientNameController.text = patient.fullName;
    //   contactNumberController.text = patient.phoneNumber;
    // }

    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: Column(
                    children: [
                      const CustomAppBarHeaderWidget(title: 'Appointment'),
                      35.height,
                      DoctorAppointmentBookingViewCard(doctor: widget.doctor, isFavorite: widget.isFavorite)
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
                        const CustomTextWidget(
                          text: 'Appointment For',
                          textStyle: TextStyle(
                            fontFamily: AppFonts.rubik,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                        23.height,
                        CustomTextFormFieldWidget(
                          label: 'Patient Name',
                          hintText: 'Enter patient name',
                          controller: patientNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the patient name';
                            }
                            return null;
                          },
                        ),
                        23.height,
                        CustomTextFormFieldWidget(
                          label: 'Contact Number',
                          hintText: 'Enter contact number',
                          controller: contactNumberController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter the contact number';
                            }
                            return null;
                          },
                        ),
                        24.height,
                        const CustomTextWidget(
                          text: 'Who is this patient?',
                          textStyle: TextStyle(
                            fontFamily: AppFonts.rubik,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                        16.height,
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildPatientOption('My Self', Icons.person),
                              5.width,
                              _buildPatientOption('My Child', Icons.child_care),
                              5.width,
                              _buildPatientOption('My Mother', Icons.woman_2_rounded),
                              5.width,
                              _buildPatientOption('My Father', Icons.man),
                              5.width,
                              _buildPatientOption('My Wife', Icons.woman),
                              5.width,
                              _buildPatientOption('Other', Icons.help_outline),
                              3.width,
                            ],
                          ),
                        ),
                        24.height,
                      ],
                    ),
                  ),
                ),
              ),
              CustomButtonWidget(
                text: 'Next',
                height: ScreenUtil.scaleHeight(context, 50),
                width: ScreenUtil.scaleWidth(context, 295),
                backgroundColor: AppColors.gradientGreen,
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size16,
                fontWeight: FontWeight.w500,
                textColor: Colors.white,
                onPressed: () {
                  if (patientNameController.text.isEmpty || contactNumberController.text.isEmpty) {
                    CustomSnackBarWidget.show(
                      context: context,
                      text: 'Please fill all fields',
                    );
                    return;
                  }
                  AppNavigation.push(
                    SelectTimeView(
                      doctor: widget.doctor,
                      patientName: patientNameController.text,
                      contactNumber: contactNumberController.text,
                    ),
                  );
                },
              ),
              120.height,
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientOption(String label, IconData icon) {
    final isSelected = selectedPatientOption == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPatientOption = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gradientGreen.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.gradientGreen : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.gradientGreen : AppColors.subtextcolor),
            8.width,
            CustomTextWidget(
              text: label,
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size14,
                fontWeight: FontWeight.w400,
                color: isSelected ? AppColors.gradientGreen : AppColors.subtextcolor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}