import 'package:flutter/material.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/core/extentions/widget_extension.dart';

import '../../../../const/font_sizes.dart';

class AboutUsWidget extends StatelessWidget {
  const AboutUsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 15.0,
                  ),
                  child: CustomAppBarHeaderWidget(
                    title: 'About CureMate',
                  ),
                ),

                24.height,
                const Center(
                  child: CustomTextWidget(
                    text: 'Welcome to CureMate',
                    applyShadow: true,
                    textStyle: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: AppFonts.rubik,
                      color: AppColors.gradientGreen,
                    ),
                  ),
                ),
                10.height,
                 Center(
                  child: CustomTextWidget(
                    text: 'A Smart Health Solution',
                    textStyle: TextStyle(
                      fontSize: FontSizes(context).size14,
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                      fontFamily: AppFonts.rubikMedium,
                    ),
                  ),
                ),
                 Expanded(
                   child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildSection(
                          context,
                          'Our Mission',
                          'CureMate is designed to bridge the gap between patients and healthcare providers through an innovative digital platform. We aim to make healthcare more accessible, efficient, and user-friendly for everyone.',
                        ),
                        _buildSection(
                          context,
                          'Key Features',
                          '• Smart Doctor Search & Filtering\n'
                              '• Real-time Chat with Doctors\n'
                              '• Easy Appointment Scheduling\n'
                              '• Digital Medical Records Management\n'
                              '• Favorite Doctors List\n'
                              '• Comprehensive Patient Profiles\n'
                              '• Real-time Appointment Status Tracking',
                        ),
                        _buildSection(
                          context,
                          'For Patients',
                          '• Find and connect with qualified healthcare professionals\n'
                              '• Book and manage appointments seamlessly\n'
                              '• Store and access medical records securely\n'
                              '• Receive appointment reminders and notifications\n'
                              '• Provide feedback and rate services\n'
                              '• Customize communication preferences',
                        ),
                        _buildSection(
                          context,
                          'For Doctors',
                          '• Manage patient appointments efficiently\n'
                              '• Communicate with patients securely\n'
                              '• Set availability and consultation hours\n'
                              '• Track patient interactions and progress\n'
                              '• Build professional reputation through ratings',
                        ),
                        _buildSection(
                          context,
                          'Privacy & Security',
                          'We prioritize the security and confidentiality of your medical information. Our platform implements industry-standard security measures and follows strict privacy policies to protect your personal and medical data.',
                        ),
                        24.height,
                        Center(
                          child: CustomTextWidget(
                            text: 'Version 1.0.0',
                            textStyle: TextStyle(
                              color: AppColors.textColor,
                              fontSize: FontSizes(context).size14,
                              fontFamily: AppFonts.rubik,
                            ),
                          ),
                        ),
                        24.height,
                      ],
                    ),
                   ),
                 ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context,String title, String content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomTextWidget(
            text: title,
            textStyle: TextStyle(
              fontSize: FontSizes(context).size18,
              fontWeight: FontWeight.bold,
              color: AppColors.gradientGreen,
              fontFamily: AppFonts.rubikMedium,
            ),
          ),
          8.height,
          CustomTextWidget(
            text: content,
            textAlignment: TextAlign.start,
            textStyle:  TextStyle(
              fontSize: FontSizes(context).size14,
              fontFamily: AppFonts.rubik,
            ),
          ),
        ],
      ),
    );
  }
}