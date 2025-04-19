import 'package:curemate/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_header_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/lower_background_effects_widgets.dart';
import '../widgets/doctors_list_widget.dart';
import '../widgets/search_bar_widget.dart';

class DoctorsSearchingView extends ConsumerStatefulWidget {
  const DoctorsSearchingView({super.key});

  @override
  ConsumerState<DoctorsSearchingView> createState() => _SearchDoctorsViewState();
}

class _SearchDoctorsViewState extends ConsumerState<DoctorsSearchingView> {
  @override
  Widget build(BuildContext context) {
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
                  const CustomHeaderWidget(title: 'Find Doctors',),
                  34.height,
                  const SearchBarWidget(),
                  16.height,
                  const DoctorsListWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}