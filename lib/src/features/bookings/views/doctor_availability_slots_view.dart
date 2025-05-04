import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/custom_appbar_header_widget.dart';
import '../../../shared/widgets/lower_background_effects_widgets.dart';
import '../../patient/providers/patient_providers.dart';
import '../card/availability_slots_view_doctor_card.dart';

class DoctorAvailabilitySlotsView extends ConsumerStatefulWidget {
  final Doctor doctor;
  const DoctorAvailabilitySlotsView({super.key,required this.doctor});

  @override
  ConsumerState<DoctorAvailabilitySlotsView> createState() => _DoctorAvailabilitySlotsViewState();
}

class _DoctorAvailabilitySlotsViewState extends ConsumerState<DoctorAvailabilitySlotsView> {
  @override
  Widget build(BuildContext context) {
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
                  const CustomAppBarHeaderWidget(title: 'Available On'),
                  34.height,
                  AvailabilitySlotsViewDoctorCard(doctor: widget.doctor),
                  20.height,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
