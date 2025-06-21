import 'package:curemate/src/features/patient/shared/doctors_searching/providers/doctors_searching_providers.dart';
import 'package:curemate/src/features/patient/shared/doctors_searching/views/search_doctors_view.dart';
import 'package:curemate/src/router/nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';

class DoctorsSpecialityIconsListWidget extends ConsumerWidget {
  final List<Map<String, dynamic>> specialities = [
    {
      'icon': Icons.local_hospital,
      'label': 'General',
      'gradient': [Colors.orange, Colors.deepOrange],
    },
    {
      'icon': Icons.favorite,
      'label': 'Cardiologist',
      'gradient': [Colors.redAccent, Colors.red],
    },
    {
      'icon': Icons.remove_red_eye,
      'label': 'Ophthalmologist',
      'gradient': [Colors.lightBlueAccent, Colors.blue],
    },
    {
      'icon': Icons.masks,
      'label': 'Dentist',
      'gradient': [Colors.lightGreen, Colors.green],
    },
    {
      'icon': Icons.child_care,
      'label': 'Pediatrician',
      'gradient': [Colors.purpleAccent, Colors.purple],
    },
    {
      'icon': Icons.psychology,
      'label': 'Psychiatrist',
      'gradient': [Colors.tealAccent, Colors.teal],
    },
    {
      'icon': Icons.accessibility_new,
      'label': 'Orthopedic Surgeon',
      'gradient': [Colors.indigoAccent, Colors.indigo],
    },
    {
      'icon': Icons.woman,
      'label': 'Gynecologist',
      'gradient': [Colors.pinkAccent, Colors.pink],
    },
    {
      'icon': Icons.bubble_chart,
      'label': 'Neurologist',
      'gradient': [Colors.deepPurpleAccent, Colors.deepPurple],
    },
    {
      'icon': Icons.spa,
      'label': 'Dermatologist',
      'gradient': [Colors.brown.shade200, Colors.brown],
    },
    {
      'icon': Icons.all_inclusive,
      'label': 'All',
      'gradient': [Colors.black12, Colors.white],
    },
  ];


  DoctorsSpecialityIconsListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: ScreenUtil.scaleHeight(context, 130),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: specialities.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              final selectedLabel = specialities[index]['label'];

              if (selectedLabel == 'All') {
                ref.read(searchQueryProvider.notifier).state = '';
              } else {
                ref.read(searchQueryProvider.notifier).state = selectedLabel;
              }
              AppNavigation.push(const DoctorsSearchingView());
            },

            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: ScreenUtil.scaleWidth(context, 70),
                    height: ScreenUtil.scaleHeight(context, 75),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: specialities[index]['gradient'],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      specialities[index]['icon'],
                      color: AppColors.gradientWhite,
                      size: 35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  CustomTextWidget(
                    text: specialities[index]['label'],
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.rubik,
                      fontSize: FontSizes(context).size13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
