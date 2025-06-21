import 'package:flutter/material.dart';
import '../../../../const/app_fonts.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../model/diagnosis_model.dart';

class DiagnosisResultsWidget extends StatelessWidget {
  final List<Diagnosis> diagnoses;
  final String doctorType;

  const DiagnosisResultsWidget({
    super.key,
    required this.diagnoses,
    required this.doctorType,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.gradientWhite,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextWidget(
                text: 'Possible Diseases',
                textStyle: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black,
                ),
              ),

              const SizedBox(height: 16),
              ...diagnoses.map((diagnosis) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomTextWidget(
                                text: diagnosis.diagnosis.toUpperCase(),
                                textStyle: TextStyle(
                                  fontFamily: AppFonts.rubik,
                                  fontSize: FontSizes(context).size15,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.black,
                                ),
                              ),
                              CustomTextWidget(
                                text: 'Confidence: ${(diagnosis.confidence * 100).toStringAsFixed(2)}%',
                                textStyle: TextStyle(
                                  fontFamily: AppFonts.rubik,
                                  fontSize: FontSizes(context).size13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
              CustomTextWidget(
                text: 'Consult to: $doctorType for proper evaluation.',
                textStyle: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.subTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 