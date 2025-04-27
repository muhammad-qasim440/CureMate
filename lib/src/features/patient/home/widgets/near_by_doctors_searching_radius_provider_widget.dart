import 'package:curemate/const/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../theme/app_colors.dart';

final radiusProvider = StateProvider<int>((ref) => 0);

class RadiusSelector extends ConsumerWidget {
  const RadiusSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(radiusProvider);

    // Add an "All" option to the list
    final radiusOptions = [0, ...AppStrings.doctorSearchingAreaRadius];

    return PopupMenuButton<int>(
      offset: Offset(0, 40),
      onSelected: (value) {
        ref.read(radiusProvider.notifier).state = value;
      },
      itemBuilder: (context) {
        return radiusOptions
            .map(
              (radius) => PopupMenuItem(
            value: radius,
            child: Row(
              children: [
                Text(radius == 0 ? 'All' : '$radius km'),
              ],
            ),
          ),
        )
            .toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.gradientGreen,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Text(
              selected == 0 ? 'All' : '$selected km',
              style: const TextStyle(
                fontFamily: AppFonts.rubik,
                fontWeight: FontWeight.w500,
                color: AppColors.gradientWhite,
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }
}
