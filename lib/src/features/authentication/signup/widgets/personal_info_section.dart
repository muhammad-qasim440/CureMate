import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_strings.dart';
import '../../../../shared/providers/drop_down_provider/custom_drop_down_provider.dart';
import 'common_personal_details_widget.dart';
import 'doctor_details_widget.dart';

class PersonalInfoSection extends ConsumerWidget {
  const PersonalInfoSection({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final dropDownState = ref.watch(
      customDropDownProvider(AppStrings.userTypes),
    );
    final userType = dropDownState.selected;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CommonPersonalDetailsWidget(),
        23.height,
        if (userType == 'Doctor') ...[
         const DoctorDetailsWidget(),
        ],
      ],
    );
  }
}
