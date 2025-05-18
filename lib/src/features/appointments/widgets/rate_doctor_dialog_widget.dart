import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../models/appointment_model.dart';
import '../providers/rate_doctor_on_completed_appointment_provider.dart';
import 'custom_star_rating_widget.dart';

class RateDoctorDialog extends ConsumerWidget {
  final AppointmentModel appointment;

  const RateDoctorDialog({super.key, required this.appointment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(rateDoctorOnCompletedAppointmentProvider);
    final controller = TextEditingController(text: state.review);

    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextWidget(
                  text: 'Rate Your Experience',
                  textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gradientGreen,
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextWidget(
                  textAlignment: TextAlign.center,
                  text:
                      'How was your experience with ${appointment.doctorName}?',
                  textStyle: TextStyle(
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size14,
                    color: AppColors.subTextColor,
                  ),
                ),
                const SizedBox(height: 20),
                CustomStarRating(
                  rating: state.rating,
                  size: 40,
                  onRatingUpdate: (rating) {
                    ref
                        .read(rateDoctorOnCompletedAppointmentProvider.notifier)
                        .updateRating(rating);
                  },
                ),
                const SizedBox(height: 20),
                CustomTextFormFieldWidget(
                  controller: controller,
                  labelStyle: const TextStyle(color: AppColors.subTextColor,fontFamily: AppFonts.rubik,),
                  label: 'Write a review (optional)',
                  maxLines: 3,
                  onChanged: (text) {
                    ref
                        .read(rateDoctorOnCompletedAppointmentProvider.notifier)
                        .updateReview(text);
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: CustomButtonWidget(
                        onPressed: () => Navigator.pop(context),
                        text: 'Cancel',
                        backgroundColor: Colors.grey[200]!,
                        textColor: AppColors.subTextColor,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: CustomButtonWidget(
                        onPressed:
                            state.isSubmitting
                                ? null
                                : () async {
                                  if (state.rating == 0) {
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Please provide a rating',
                                    );
                                    return;
                                  }

                                  final success = await ref
                                      .read(
                                        rateDoctorOnCompletedAppointmentProvider
                                            .notifier,
                                      )
                                      .submitRating(appointment);
                                  if (success && context.mounted) {
                                    Navigator.of(context).pop(true);
                                  } else if (!success && context.mounted) {
                                    CustomSnackBarWidget.show(
                                      context: context,
                                      text: 'Error submitting rating',
                                    );
                                  }
                                },
                        text: state.isSubmitting ? 'Submitting...' : 'Submit',
                        backgroundColor: AppColors.gradientGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
