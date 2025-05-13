// DoctorAvailabilityDialog
import 'package:flutter/material.dart';

import '../../../../const/app_fonts.dart';
import '../../../theme/app_colors.dart';
import '../../patient/providers/patient_providers.dart';

class DoctorAvailabilityDialog {
  static void show(BuildContext context, Doctor doctor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text(
            'Doctor Availability',
            style: TextStyle(
              fontFamily: AppFonts.rubik,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: doctor.availability.map((avail) {
                final day = avail['day'] as String;
                List<String> slots = [];
                if (avail['isFullDay'] == true) {
                  slots.add(
                    '${avail['startTime']} - ${avail['endTime']} (Full Day)',
                  );
                } else {
                  if (avail['morning']?['isAvailable'] == true) {
                    slots.add(
                      'Morning: ${avail['morning']['startTime']} - ${avail['morning']['endTime']}',
                    );
                  }
                  if (avail['afternoon']?['isAvailable'] == true) {
                    slots.add(
                      'Afternoon: ${avail['afternoon']['startTime']} - ${avail['afternoon']['endTime']}',
                    );
                  }
                  if (avail['evening']?['isAvailable'] == true) {
                    slots.add(
                      'Evening: ${avail['evening']['startTime']} - ${avail['evening']['endTime']}',
                    );
                  }
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        day,
                        style: const TextStyle(
                          fontFamily: AppFonts.rubik,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        ),
                      ),
                      ...slots.map(
                            (slot) => Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(
                            slot,
                            style: const TextStyle(
                              fontFamily: AppFonts.rubik,
                              fontSize: 14,
                              color: AppColors.subTextColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontFamily: AppFonts.rubik,
                  fontSize: 14,
                  color: AppColors.gradientGreen,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}