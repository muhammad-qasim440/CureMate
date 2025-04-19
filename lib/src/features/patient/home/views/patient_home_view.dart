import 'package:curemate/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/lower_background_effects_widgets.dart';
import '../widgets/doctor_search_bar_widget.dart';
import '../widgets/doctors_speciality_icons_list_widget.dart';
import '../widgets/featured_doctors_list_widget.dart';
import '../widgets/near_by_doctors_list_widget.dart';
import '../widgets/popular_doctors_list_widget.dart';
import '../widgets/user_profile_header_widget.dart';

class PatientHomeView extends ConsumerWidget {
  const PatientHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        const LowerBackgroundEffectsWidgets(),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              220.height,
              DoctorsSpecialityIconsListWidget(),
              const NearbyDoctorsListWidget(),
              const PopularDoctorsListWidget(),
              const FeaturedDoctorsListWidget(),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              UserProfileHeaderWidget(),
              Transform.translate(
                offset: const Offset(0, -40),
                child: const DoctorSearchBarWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
