import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/shared/doctors_searching/card/doctor_searching_view_doctor_card.dart';
import 'package:curemate/src/features/patient/shared/doctors_searching/providers/doctors_searching_providers.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/lower_background_effects_widgets.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../providers/patient_providers.dart';
import '../../shared/doctors_searching/widgets/doctors_list_widget.dart';
class PatientDrawerMyDoctorsView extends ConsumerStatefulWidget {
  const PatientDrawerMyDoctorsView({super.key});

  @override
  ConsumerState<PatientDrawerMyDoctorsView> createState() =>
      _PatientDrawerMyDoctorsViewState();
}

class _PatientDrawerMyDoctorsViewState extends ConsumerState<PatientDrawerMyDoctorsView> {
  @override
  Widget build(BuildContext context) {
    final filteredDoctors = ref.watch(
      filteredDoctorsByProvider(
        ProviderListParam(doctorListProvider: doctorsProvider),
      ),
    );
    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomAppBarHeaderWidget(title: 'My Doctors'),
                  34.height,
                  SearchBarWidget(provider: searchQueryProvider),
                  16.height,
                  DoctorsListWidget(
                    listOfDoctor: filteredDoctors,
                    doctorCardBuilder:
                        (doctor, isFavorite) => DoctorSearchingViewDoctorCard(
                      doctor: doctor,
                      isFavorite: isFavorite,
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
}
