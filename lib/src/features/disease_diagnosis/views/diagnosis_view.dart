import 'dart:convert';

import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/core/utils/debug_print.dart';
import 'package:curemate/src/features/drawer/providers/change_password_providers.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/back_view_icon_widget.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../../const/app_strings.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_centered_text_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../model/diagnosis_model.dart';
import '../providers/disease_diagnosis_providers.dart';
import '../widgets/diagnosis_results_widget.dart';
import '../widgets/recommended_doctors_widget.dart';
import '../widgets/symptoms_input_widget.dart';
import '../../patient/providers/patient_providers.dart';

final isLoadingProvider=StateProvider<bool>((ref)=>false);
final hasSearchedProvider=StateProvider.autoDispose<bool>((ref)=>false);
class DiagnosisView extends ConsumerStatefulWidget {
  const DiagnosisView({super.key});

  @override
  ConsumerState<DiagnosisView> createState() => _DiagnosisViewState();
}

class _DiagnosisViewState extends ConsumerState<DiagnosisView> {
  final TextEditingController _symptomsController = TextEditingController();

  Future<void> diagnoseSymptoms(WidgetRef ref, String api) async {
    final isLoading = ref.read(isLoadingProvider);
    if (isLoading) return;

    FocusScope.of(context).unfocus();

    ref.read(isLoadingProvider.notifier).state = true;
    final hasInternetConnection = await ref.read(checkInternetConnectionProvider.future);
    if (!hasInternetConnection) {
      if (context.mounted) {
        CustomSnackBarWidget.show(
          context: context,
          text: AppStrings.noInternetInSnackBar,
        );
      }
      ref.read(isLoadingProvider.notifier).state = false;
      return;
    }

    final symptoms = _symptomsController.text
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();

    if (symptoms.isEmpty) {
      ref.read(diagnosisProvider.notifier).state = AsyncValue.error(
        'Please enter at least one symptom',
        StackTrace.current,
      );
      ref.read(isLoadingProvider.notifier).state = false;
      return;
    }
    if (api.isEmpty|| api=='') {
      ref.read(diagnosisProvider.notifier).state = AsyncValue.error(
        'please check you local host and ngrok api link ',
        StackTrace.current,
      );
      ref.read(isLoadingProvider.notifier).state = false;
      return;
    }
    logDebug('Symptoms $symptoms');
    try {
      final response = await http.post(
        Uri.parse('$api/diagnose'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'symptoms': symptoms}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final diagnoses = (data['diagnoses'] as List<dynamic>)
            .map((item) => Diagnosis.fromJson(item as Map<String, dynamic>))
            .toList();
        ref.read(diagnosisProvider.notifier).state = AsyncValue.data(diagnoses);
        ref.read(hasSearchedProvider.notifier).state = true;
        _symptomsController.clear();
      } else {
        ref.read(diagnosisProvider.notifier).state = AsyncValue.error(
          jsonDecode(response.body)['error'] ?? 'Unknown error',
          StackTrace.current,
        );
      }
    } catch (e) {
      logDebug('Failed to connect to the server: $e');
      if (!mounted) return;
      ref.read(diagnosisProvider.notifier).state = AsyncValue.error(
        'Failed to connect to the server. Please try again later.',
        StackTrace.current,
      );
    } finally {
      if (mounted) {
        ref.read(isLoadingProvider.notifier).state = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnosesAsync = ref.watch(diagnosisProvider);
    final doctorsAsync = ref.watch(doctorsProvider);
    final isLoading=ref.watch(isLoadingProvider);
    final hasSearched=ref.watch(hasSearchedProvider);
    final api=ref.watch(ngrokApiProvider).when(data: (data){ return data;}, error: (e,stack){return '';}, loading: (){return '';});
    final groupedDiagnoses = <String, List<Diagnosis>>{};
    diagnosesAsync.whenData((diagnoses) {
      for (var diagnosis in diagnoses) {
        groupedDiagnoses
            .putIfAbsent(diagnosis.doctorType, () => [])
            .add(diagnosis);
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.gradientGreen,
        leading: BackViewIconWidget(onPressed: (){
          ref.invalidate(diagnosisProvider);
          AppNavigation.pop(context);
        },),
        titleSpacing: 0,
        leadingWidth: 60,
        title: CustomTextWidget(
          text: 'Disease Diagnose System',
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size18,
            fontWeight: FontWeight.w700,
            color: AppColors.gradientWhite,
          ),
        ),
      ),
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!hasSearched) ...[
                              5.height,
                              Center(
                                child: CustomTextWidget(
                                  text: 'Welcome to Disease Diagnose System',
                                  textStyle: TextStyle(
                                    fontFamily: AppFonts.rubik,
                                    fontSize: FontSizes(context).size18,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              CustomTextWidget(
                                textAlignment: TextAlign.center,
                                text:
                                    'Enter your symptoms (with , separated) below to get potential health conditions and recommended specialists. Please note that this is not a substitute for professional medical advice.',
                                textStyle: TextStyle(
                                  fontFamily: AppFonts.rubik,
                                  fontSize: FontSizes(context).size12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.subTextColor,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            diagnosesAsync.when(
                              loading:
                                  () => const Center(
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.btnBgColor,
                                      ),
                                    ),
                                  ),
                              error:
                                  (error, _) => Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: CustomCenteredTextWidget(
                                      text: 'Error: $error',
                                      textStyle: TextStyle(
                                          fontFamily: AppFonts.rubik,
                                          fontSize: FontSizes(context).size14,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.red,
                                      ),
                                    ),
                                  ),
                              data: (diagnoses) {
                                if (diagnoses.isEmpty && hasSearched) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
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
                                    child: CustomCenteredTextWidget(
                                      text:
                                          'No health conditions found for the given symptoms. Please try with different symptoms or consult a healthcare professional.',
                                      textStyle: TextStyle(
                                        fontFamily: AppFonts.rubik,
                                        fontSize: FontSizes(context).size14,
                                        fontWeight: FontWeight.w400,
                                        color: AppColors.textColor,
                                      ),
                                    ),
                                  );
                                }
                                return Column(
                                  children: [
                                    Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.info_outline),
                                          10.width,
                                          CustomTextWidget(
                                            text: 'Important',
                                            textStyle: TextStyle(
                                              fontFamily: AppFonts.rubik,
                                              fontSize: FontSizes(context).size20,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    10.height,
                                    Center(
                                      child: CustomTextWidget(
                                        textAlignment: TextAlign.center,
                                        text: 'These results are based on the symptoms you provided and are not a definitive diagnosis. Please consult with a healthcare professional for proper evaluation and treatment.',
                                        textStyle: TextStyle(
                                          fontFamily: AppFonts.rubik,
                                          fontSize: FontSizes(context).size12,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.red,
                                        ),
                                      ),
                                    ),
                                    10.height,
                                    Column(
                                      children: groupedDiagnoses.entries.map((entry) {
                                            final doctorType = entry.key;
                                            final diagnoses = entry.value;
                                            return Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                DiagnosisResultsWidget(
                                                  diagnoses: diagnoses,
                                                  doctorType: doctorType,
                                                ),
                                                doctorsAsync.when(
                                                  loading:
                                                      () => const Center(
                                                        child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(
                                                                AppColors
                                                                    .btnBgColor,
                                                              ),
                                                        ),
                                                      ),
                                                  error:
                                                      (error, _) => Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: AppColors.black
                                                                  .withOpacity(0.1),
                                                              blurRadius: 8,
                                                              offset: const Offset(
                                                                0,
                                                                2,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        padding:
                                                            const EdgeInsets.all(
                                                              16,
                                                            ),
                                                        child: CustomCenteredTextWidget(
                                                          text:
                                                              'Error loading doctors: $error',
                                                          textStyle:
                                                              TextStyle(
                                                                fontFamily: AppFonts.rubik,
                                                                fontSize: FontSizes(context).size14,
                                                                fontWeight: FontWeight.w400,
                                                                color:AppColors.red,
                                                              ),
                                                        ),
                                                      ),
                                                  data: (doctors) {
                                                    final matchingDoctors = doctors.where((doctor) =>
                                                                  doctor.category ==
                                                                  doctorType,).toList()..sort((a, b) => b.averageRatings.compareTo(a.averageRatings,),);
                                                    final topDoctors =
                                                        matchingDoctors
                                                            .take(6)
                                                            .toList();
                                                    return RecommendedDoctorsWidget(
                                                      doctorType: doctorType,
                                                      doctors: topDoctors,
                                                    );
                                                  },
                                                ),
                                                const SizedBox(height: 16),
                                              ],
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SymptomsInputWidget(
                controller: _symptomsController,
                onSubmit:(){diagnoseSymptoms(ref,api);},
                isLoading: isLoading,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }
}
