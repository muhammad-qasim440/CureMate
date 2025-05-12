import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/home/views/all_near_by_doctor_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';
import '../cards/near_by_doctors_card.dart';

class NearbyDoctorsListWidget extends ConsumerWidget {
  const NearbyDoctorsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(nearByDoctorsProvider);
    final logedInPatientProvider =
        ref.watch(currentSignInPatientDataProvider).value;
    late Patient patient;
    if (logedInPatientProvider != null) {
      patient = logedInPatientProvider;
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                text: 'Nearby Doctors',
                textStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size18,
                ),
              ),
              4.width,
              CustomButtonWidget(
                text: 'See all',
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size15,
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                textColor: AppColors.gradientGreen,
                onPressed: (){
                  AppNavigation.push(const AllNearByDoctorsView(isFromFeatured: false,isFromPopular: false,));
                },
              ),
            ],
          ),
          16.height,
          SizedBox(
            height: ScreenUtil.scaleHeight(context, 225),
            child: doctorsAsync.when(
              data:
                  (doctors) =>
                      doctors.isEmpty
                          ? const Center(child: Text('No doctors available'))
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: doctors.length > 4 ? 4 : doctors.length,
                            itemBuilder: (context, index) {
                              return NearByDoctorsCard(
                                doctor: doctors[index],
                                patient: patient,
                              );
                            },
                          ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
