import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/favorites/widgets/favorite_view_patient_appointment_with_doctors_cards_list_widget.dart';
import 'package:curemate/src/features/patient/providers/patient_providers.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/lower_background_effects_widgets.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../home/cards/all_near_by_doctors_view_card.dart';
import '../../home/widgets/featured_doctors_list_widget.dart';
import '../../shared/doctors_searching/providers/doctors_searching_providers.dart';
import '../../shared/doctors_searching/widgets/doctors_list_widget.dart';

class PatientFavoriteDoctorsView extends ConsumerStatefulWidget {
  const PatientFavoriteDoctorsView({super.key});

  @override
  ConsumerState<PatientFavoriteDoctorsView> createState() =>
      _PatientFavoriteDoctorsViewState();
}

class _PatientFavoriteDoctorsViewState
    extends ConsumerState<PatientFavoriteDoctorsView> {
  @override
  Widget build(BuildContext context) {
    final currentPatientFavoriteDoctorList = ref.watch(
      filteredDoctorsByProvider(
        ProviderListParam(doctorListProvider: favoriteDoctorsProvider),
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
                  SearchBarWidget(provider: searchQueryProvider),
                  16.height,
                  DoctorsListWidget(
                    listOfDoctor: currentPatientFavoriteDoctorList,
                    doctorCardBuilder:
                        (doctor, isFavorite) => AllNearByDoctorsViewCard(
                          doctor: doctor,
                          isFavorite: isFavorite,
                        ),
                  ),
                  const FavoriteViewPatientAppointmentWithDoctorsCardsListWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
