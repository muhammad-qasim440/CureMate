import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/shared/helpers/add_or_remove_doctor_into_favorite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../const/app_fonts.dart';
import '../../../../../../const/font_sizes.dart';
import '../../../../assets/app_assets.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../patient/providers/patient_providers.dart';

class AvailabilitySlotsViewDoctorCard extends ConsumerStatefulWidget {
  final Doctor doctor;

  const AvailabilitySlotsViewDoctorCard({
    super.key,
    required this.doctor,
  });

  @override
  ConsumerState<AvailabilitySlotsViewDoctorCard> createState() => _AvailabilitySlotsViewDoctorCardState();
}

class _AvailabilitySlotsViewDoctorCardState extends ConsumerState<AvailabilitySlotsViewDoctorCard> {
  @override
  Widget build(BuildContext context) {
    final favoriteDoctroIdAsync=ref.watch(favoriteDoctorUidsProvider).value??[];
    final isFavorite = favoriteDoctroIdAsync.contains(widget.doctor.uid,);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.gradientWhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: ScreenUtil.scaleWidth(context, 92),
                    height: ScreenUtil.scaleHeight(context, 92),
                    child: widget.doctor.profileImageUrl.isNotEmpty
                        ? Image.network(
                      widget.doctor.profileImageUrl,
                      fit: BoxFit.cover,
                    )
                        : Image.asset(
                      AppAssets.defaultDoctorImg,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                12.width,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      10.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: CustomTextWidget(
                              text: widget.doctor.fullName,
                              textStyle: TextStyle(
                                fontFamily: AppFonts.rubik,
                                fontSize: FontSizes(context).size18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.black,
                              ),
                            ),
                          ),
                          4.width,
                          InkWell(
                            onTap: () {
                              AddORRemoveDoctorIntoFavorite.toggleFavorite(
                                context,
                                ref,
                                widget.doctor.uid,
                              );
                            },
                            child: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: isFavorite ? Colors.red : Colors.grey[400],
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      4.width,
                      CustomTextWidget(
                        text: widget.doctor.hospital,
                        textAlignment: TextAlign.center,
                        textStyle: TextStyle(
                          fontFamily: AppFonts.rubik,
                          fontSize: FontSizes(context).size14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gradientGreen,
                        ),
                      ),
                      5.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          5,
                              (index) => Icon(
                            Icons.star,
                            size: 16,
                            color: index < (widget.doctor.averageRatings / 2).round()
                                ? Colors.amber
                                : Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
