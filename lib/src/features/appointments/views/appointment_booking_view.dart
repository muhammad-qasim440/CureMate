import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/core/utils/debug_print.dart';
import 'package:curemate/src/features/appointments/views/select_time_view.dart';
import 'package:curemate/src/shared/widgets/custom_drop_down_menu_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/app_strings.dart';
import '../../../../const/font_sizes.dart';
import '../../../router/nav.dart';
import '../../../shared/providers/drop_down_provider/custom_drop_down_provider.dart';
import '../../../shared/widgets/custom_appbar_header_widget.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../patient/providers/patient_providers.dart';
import '../card/doctor_appointment_booking_view_card.dart';
import '../models/appointment_model.dart';
import '../providers/appointments_providers.dart';
import '../utils/appointment_utils.dart';

// Provider for age as string to sync with TextFormField
final bookingViewPatientAgeStringProvider = StateProvider<String>((ref) {
  final age = ref.watch(bookingViewPatientAgeProvider);
  return age.toString();
});

class AppointmentBookingView extends ConsumerStatefulWidget {
  final Doctor doctor;
  final AppointmentModel? appointment;

  const AppointmentBookingView({
    super.key,
    required this.doctor,
    this.appointment,
  });

  @override
  ConsumerState<AppointmentBookingView> createState() =>
      _AppointmentBookingViewState();
}

class _AppointmentBookingViewState
    extends ConsumerState<AppointmentBookingView> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    if (widget.appointment != null) {
      // Edit mode: Prefill with appointment data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bookingViewPatientNameProvider.notifier).state =
            widget.appointment!.patientName;
        ref.read(bookingViewPatientNumberProvider.notifier).state =
            widget.appointment!.patientNumber;
        ref.read(customDropDownProvider(AppStrings.genders).notifier).setSelected(
            widget.appointment!.patientGender);
        ref.read(bookingViewPatientAgeProvider.notifier).state =
            widget.appointment!.patientAge;
        ref.read(bookingViewPatientNoteProvider.notifier).state =
            widget.appointment!.patientNotes ?? '';
        ref.read(bookingViewSelectedPatientLabelProvider.notifier).state =
            widget.appointment!.patientType;
        debugPrint('Edit mode: Prefilled appointment data');
      });
    } else {
      // New appointment: Set default to "My Self" and prefill user data
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(bookingViewSelectedPatientLabelProvider.notifier).state =
        'My Self';
        final currentUserAsync = ref.read(currentSignInPatientDataProvider);
        if (currentUserAsync is AsyncData && currentUserAsync.value != null) {
          prefillPatientData(ref: ref, currentUser: currentUserAsync.value!);
        }
        debugPrint('New appointment: Set default to My Self and prefilled data');
      });
    }
  }

  @override
  void dispose() {
    nameFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.appointment != null;
    final selectedLabel = ref.watch(bookingViewSelectedPatientLabelProvider);
    final currentUserAsync = ref.watch(currentSignInPatientDataProvider);

    // Sync age string provider with int provider
    ref.listen(bookingViewPatientAgeStringProvider, (previous, next) {
      final age = int.tryParse(next);
      if (age != null && age != ref.read(bookingViewPatientAgeProvider)) {
        ref.read(bookingViewPatientAgeProvider.notifier).state = age;
        debugPrint('Updated age provider: $age');
      }
    });

    ref.listen(bookingViewPatientAgeProvider, (previous, next) {
      final stringValue = ref.read(bookingViewPatientAgeStringProvider);
      if (stringValue != next.toString()) {
        ref.read(bookingViewPatientAgeStringProvider.notifier).state =
            next.toString();
        debugPrint('Synced age string provider: ${next.toString()}');
      }
    });

    // Handle clearing data when patient label changes
    ref.listen(bookingViewSelectedPatientLabelProvider, (previous, next) {
      if (!isEditing && previous != next) {
        if (next == 'My Self' &&
            currentUserAsync is AsyncData &&
            currentUserAsync.value != null) {
          prefillPatientData(ref: ref, currentUser: currentUserAsync.value!);
        } else {
          clearPatientData(ref: ref);
        }
      }
    });

    return Scaffold(
      body: Form(
        key: _formKey,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            const LowerBackgroundEffectsWidgets(),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: SafeArea(
                    child: Column(
                      children: [
                        CustomAppBarHeaderWidget(
                          title: isEditing ? 'Edit Appointment' : 'Appointment',
                        ),
                        35.height,
                        DoctorAppointmentBookingViewCard(doctor: widget.doctor),
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
                            focusNode: nameFocusNode,
                            hintText: 'Enter patient name',
                            provider: bookingViewPatientNameProvider,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the patient name';
                              }
                              return null;
                            },
                          ),
                          23.height,
                          CustomDropdown(
                            items: AppStrings.genders,
                            label: 'Gender',
                            validatorText: 'Please select Gender',
                            initialValue: isEditing
                                ? widget.appointment?.patientGender
                                : null,
                          ),
                          23.height,
                          CustomTextFormFieldWidget(
                            label: 'Age',
                            hintText: '23 (number)',
                            provider: bookingViewPatientAgeStringProvider,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter patient age';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              if (value.length > 3) {
                                return 'Please enter a valid age number';
                              }
                              return null;
                            },
                          ),
                          23.height,
                          CustomTextFormFieldWidget(
                            label: 'Contact Number',
                            hintText: '03*********',
                            provider: bookingViewPatientNumberProvider,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the contact number';
                              } else if (!RegExp(r'^\d+$').hasMatch(value)) {
                                return 'Contact number must contain only digits';
                              } else if (!value.startsWith('0') ||
                                  !value.startsWith('3', 1)) {
                                return 'Number should start from 03*********';
                              } else if (value.length != 11) {
                                return 'Contact number should be exactly 11 digits';
                              }
                              return null;
                            },
                          ),
                          23.height,
                          CustomTextFormFieldWidget(
                            label: 'Note (optional)',
                            hintText: 'Enter your note (optional)',
                            provider: bookingViewPatientNoteProvider,
                            initialValue:
                            isEditing ? widget.appointment?.patientNotes : null,
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
                                _buildPatientOption(
                                    'My Mother', Icons.woman_2_rounded),
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
                          Center(
                            child: CustomButtonWidget(
                              text: isEditing ? 'Next' : 'Next',
                              height: ScreenUtil.scaleHeight(context, 50),
                              width: ScreenUtil.scaleWidth(context, 295),
                              backgroundColor: AppColors.gradientGreen,
                              fontFamily: AppFonts.rubik,
                              fontSize: FontSizes(context).size16,
                              fontWeight: FontWeight.w500,
                              textColor: Colors.white,
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                if (!_formKey.currentState!.validate()) return;
                                if (ref
                                    .read(bookingViewPatientNameProvider)
                                    .isEmpty ||
                                    ref
                                        .read(bookingViewPatientNumberProvider)
                                        .isEmpty ||
                                    ref
                                        .read(customDropDownProvider(
                                        AppStrings.genders))
                                        .selected
                                        .isEmpty ||
                                    ref
                                        .read(bookingViewPatientAgeProvider)
                                        .toString()
                                        .isEmpty) {
                                  CustomSnackBarWidget.show(
                                    context: context,
                                    text:
                                    'Please enter patient name, contact number, gender and age',
                                  );
                                  return;
                                }
                                AppNavigation.push(
                                  SelectTimeView(
                                    doctor: widget.doctor,
                                    appointment: widget.appointment,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                40.height,

              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientOption(String label, IconData icon) {
    final isSelected =
        ref.watch(bookingViewSelectedPatientLabelProvider) == label;
    return GestureDetector(
      onTap: () {
        ref.read(bookingViewSelectedPatientLabelProvider.notifier).state = label;
        nameFocusNode.requestFocus();
        debugPrint('Selected label: $label');
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gradientGreen.withOpacity(0.1)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.gradientGreen : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.gradientGreen : AppColors.subTextColor,
            ),
            8.width,
            CustomTextWidget(
              text: label,
              textStyle: TextStyle(
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size14,
                fontWeight: FontWeight.w400,
                color: isSelected
                    ? AppColors.gradientGreen
                    : AppColors.subTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}