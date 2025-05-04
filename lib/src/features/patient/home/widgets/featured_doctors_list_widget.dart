import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/shared/helpers/add_or_remove_doctor_into_favorite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../router/nav.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';
import '../cards/featured_doctor_card.dart';
import '../views/all_near_by_doctor_view.dart';

class FeaturedDoctorsListWidget extends ConsumerWidget {
  const FeaturedDoctorsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final favoriteUidsAsync = ref.watch(favoriteDoctorUidsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomTextWidget(
                text: 'Featured Doctors',
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
                  AppNavigation.push(const AllNearByDoctorsView(isFromFeatured: true,isFromPopular: false,));
                },
              ),
            ],
          ),
          16.height,
          SizedBox(
            height: ScreenUtil.scaleHeight(context, 180),
            child: doctorsAsync.when(
              data:
                  (doctors) => favoriteUidsAsync.when(
                    data: (favoriteUids) {
                      final shuffledDoctors =
                          doctors.toList()..shuffle(); // Shuffle all doctors
                      return shuffledDoctors.isEmpty
                          ? const Center(child: Text('No doctors available'))
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                shuffledDoctors.length > 6
                                    ? 6
                                    : shuffledDoctors
                                        .length, // Limit to 3 as per screenshot
                            itemBuilder: (context, index) {
                              final doctor = shuffledDoctors[index];
                              final isFavorite = favoriteUids.contains(
                                doctor.uid,
                              );
                              return FeaturedDoctorCard(
                                doctor: doctor,
                                isFavorite: isFavorite,
                                onFavoriteToggle: () {
                                  AddORRemoveDoctorIntoFavorite.toggleFavorite(
                                    context,
                                    ref,
                                    doctor.uid,
                                  );
                                },
                              );
                            },
                          );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stack) => Center(
                          child: Text(
                            'Error loading favorites: $error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Text(
                      error.toString().contains('permission_denied')
                          ? 'Permission denied. Please sign in as a patient.'
                          : 'Error loading doctors: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
