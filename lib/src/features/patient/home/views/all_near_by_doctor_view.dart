import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/home/cards/all_near_by_doctors_view_card.dart';
import 'package:curemate/src/features/patient/providers/patient_providers.dart';
import 'package:curemate/src/features/patient/shared/doctors_searching/providers/doctors_searching_providers.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:curemate/src/shared/widgets/custom_drop_down_menu_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_strings.dart';
import '../../../../shared/widgets/lower_background_effects_widgets.dart';
import '../../../../shared/widgets/search_bar_widget.dart';
import '../../shared/doctors_searching/widgets/doctors_list_widget.dart';

class AllNearByDoctorsView extends ConsumerStatefulWidget {
  const AllNearByDoctorsView({super.key});

  @override
  ConsumerState<AllNearByDoctorsView> createState() => _AllNearByDoctorsViewState();
}

class _AllNearByDoctorsViewState extends ConsumerState<AllNearByDoctorsView> {
  @override
  Widget build(BuildContext context) {
    final nearbyDoctorsList = ref.watch(
        filteredDoctorsByProvider(ProviderListParam(doctorListProvider: nearByDoctorsProvider)));
    return  Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomAppBarHeaderWidget(title: 'Nearby Doctors',isAllNearByDoctorsView: true,),
                  34.height,
                  SearchBarWidget(provider: searchQueryProvider,),
                  16.height,
                  DoctorsListWidget(
                    listOfDoctor: nearbyDoctorsList,
                    doctorCardBuilder:
                        (doctor, isFavorite) => AllNearByDoctorsViewCard(
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