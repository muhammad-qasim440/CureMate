import 'dart:convert';

import 'package:curemate/core/utils/debug_print.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../../router/nav.dart';
import '../../patient/providers/patient_providers.dart';
import '../model/diagnosis_model.dart';
import '../providers/disease_diagnosis_providers.dart';
import '../widgets/all_recommended_doctor_widget_based_on_diagnonsis.dart';

class DiagnosisView extends ConsumerStatefulWidget {
  const DiagnosisView({super.key});

  @override
  ConsumerState<DiagnosisView> createState() => _DiagnosisViewState();
}

class _DiagnosisViewState extends ConsumerState<DiagnosisView> {
  final TextEditingController _symptomsController = TextEditingController();
  final TextEditingController _apiUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // _loadApiUrl();
  }

  // Future<void> _loadApiUrl() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final savedUrl = prefs.getString('api_url') ?? ref.read(apiUrlProvider);
  //   _apiUrlController.text = savedUrl;
  //   ref.read(apiUrlProvider.notifier).state = savedUrl;
  // }
  //
  // Future<void> _saveApiUrl(String url) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   await prefs.setString('api_url', url);
  //   ref.read(apiUrlProvider.notifier).state = url;
  // }

  Future<void> _diagnoseSymptoms() async {
    final symptoms = _symptomsController.text
        .split(',')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();

    if (symptoms.isEmpty) {
      ref.read(diagnosisProvider.notifier).state =
          AsyncValue.error('Please enter at least one symptom', StackTrace.current);
      return;
    }

    ref.read(diagnosisProvider.notifier).state = const AsyncValue.loading();

    try {
      final response = await http.post(
        Uri.parse(ref.read(apiUrlProvider)),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'symptoms': symptoms}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final diagnoses = (data['diagnoses'] as List<dynamic>)
            .map((item) => Diagnosis.fromJson(item as Map<String, dynamic>))
            .toList();
        ref.read(diagnosisProvider.notifier).state = AsyncValue.data(diagnoses);
      } else {
        ref.read(diagnosisProvider.notifier).state = AsyncValue.error(
            jsonDecode(response.body)['error'] ?? 'Unknown error', StackTrace.current);
      }
    } catch (e) {
      logDebug('Failed to connect to the server: $e');
      ref.read(diagnosisProvider.notifier).state =
          AsyncValue.error('Failed to connect to the server: $e', StackTrace.current);
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnosesAsync = ref.watch(diagnosisProvider);
    final doctorsAsync = ref.watch(doctorsProvider);

    // Group diagnoses by doctor_type
    final groupedDiagnoses = <String, List<Diagnosis>>{};
    diagnosesAsync.whenData((diagnoses) {
      for (var diagnosis in diagnoses) {
        groupedDiagnoses.putIfAbsent(diagnosis.doctorType, () => []).add(diagnosis);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text('Health Check'),
        backgroundColor: const Color(0xFF4A90E2),
        elevation: 0,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Check Your Symptoms',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Enter symptoms (comma-separated) to get diagnoses and doctor recommendations.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(height: 20),
                // API URL input
                // Container(
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(12),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.1),
                //         blurRadius: 8,
                //         offset: const Offset(0, 2),
                //       ),
                //     ],
                //   ),
                //   child: TextField(
                //     controller: _apiUrlController,
                //     decoration: const InputDecoration(
                //       labelText: 'API URL',
                //       hintText: 'e.g., https://5d9a-39-48-35-158.ngrok-free.app/diagnose',
                //       labelStyle: TextStyle(color: Color(0xFF666666)),
                //       hintStyle: TextStyle(color: Color(0xFF999999)),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.all(Radius.circular(12)),
                //         borderSide: BorderSide.none,
                //       ),
                //       contentPadding: EdgeInsets.all(16),
                //     ),
                //     style: const TextStyle(
                //       fontSize: 14,
                //       color: Color(0xFF333333),
                //     ),
                //     onChanged: _saveApiUrl,
                //   ),
                // ),
                // const SizedBox(height: 16),
                // Symptoms input
                Container(
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
                  child: TextField(
                    controller: _symptomsController,
                    decoration: const InputDecoration(
                      labelText: 'Symptoms',
                      hintText: 'e.g., fever, cough, sore throat',
                      labelStyle: TextStyle(color: Color(0xFF666666)),
                      hintStyle: TextStyle(color: Color(0xFF999999)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.all(16),
                    ),
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Diagnose button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _diagnoseSymptoms,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90E2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      shadowColor: Colors.black.withOpacity(0.2),
                    ),
                    child: const Text(
                      'Diagnose Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Diagnoses and doctors
                diagnosesAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                    ),
                  ),
                  error: (error, _) => Container(
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
                    child: Text(
                      'Error: $error',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  data: (diagnoses) {
                    if (diagnoses.isEmpty) {
                      return Container(
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
                        child: const Text(
                          'No diagnoses found. Try different symptoms.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                          ),
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: groupedDiagnoses.entries.map((entry) {
                        final doctorType = entry.key;
                        final diagnoses = entry.value;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Diagnoses card
                            Container(
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
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Diagnosis Results',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...diagnoses.map((diagnosis) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                diagnosis.diagnosis.toUpperCase(),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF333333),
                                                ),
                                              ),
                                              Text(
                                                'Confidence: ${(diagnosis.confidence * 100).toStringAsFixed(2)}%',
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Color(0xFF666666),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.info_outline,
                                          color: Color(0xFF4A90E2),
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            // Doctors
                            doctorsAsync.when(
                              loading: () => const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4A90E2)),
                                ),
                              ),
                              error: (error, _) => Container(
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
                                child: Text(
                                  'Error loading doctors: $error',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              data: (doctors) {
                                final matchingDoctors = doctors
                                    .where((doctor) => doctor.category == doctorType)
                                    .toList()
                                  ..sort((a, b) => b.averageRatings.compareTo(a.averageRatings));
                                final topDoctors = matchingDoctors.take(6).toList();
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8, bottom: 8),
                                      child: Text(
                                        'Top $doctorType',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF333333),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 200,
                                      child: topDoctors.isEmpty
                                          ? Container(
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
                                        child: const Center(
                                          child: Text(
                                            'No doctors found for this specialty.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF333333),
                                            ),
                                          ),
                                        ),
                                      )
                                          : ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: topDoctors.length,
                                        itemBuilder: (context, index) {
                                          final doctor = topDoctors[index];
                                          return Container(
                                            width: 180,
                                            margin: const EdgeInsets.only(right: 12),
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
                                            child: Padding(
                                              padding: const EdgeInsets.all(12),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 30,
                                                    backgroundImage: doctor.profileImageUrl.isNotEmpty
                                                        ? NetworkImage(doctor.profileImageUrl)
                                                        : null,
                                                    child: doctor.profileImageUrl.isEmpty
                                                        ? const Icon(
                                                      Icons.person,
                                                      size: 30,
                                                      color: Color(0xFF666666),
                                                    )
                                                        : null,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    doctor.fullName,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight: FontWeight.w600,
                                                      color: Color(0xFF333333),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    doctor.hospital,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF666666),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    'Rating: ${doctor.averageRatings.toStringAsFixed(1)}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF666666),
                                                    ),
                                                  ),
                                                  Text(
                                                    'Fee: ${doctor.consultationFee}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF666666),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    // if (matchingDoctors.length > 6)
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            AppNavigation.push(
                                                AllDoctorsScreen(doctorType: doctorType,)
                                            );

                                          },
                                          child: const Text(
                                            'See All',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF4A90E2),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _apiUrlController.dispose();
    super.dispose();
  }
}