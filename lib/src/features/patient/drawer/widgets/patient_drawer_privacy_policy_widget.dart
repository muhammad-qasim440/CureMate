import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../const/app_strings.dart';
import '../../../../shared/widgets/custom_appbar_header_widget.dart';
import '../../../../shared/widgets/lower_background_effects_widgets.dart';
import '../../../../theme/app_colors.dart';


class PrivacyPolicyScreen extends ConsumerStatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  ConsumerState<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends ConsumerState<PrivacyPolicyScreen> {
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
                  const CustomAppBarHeaderWidget(title: 'Privacy Policy'),
                  34.height,
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: CustomTextWidget(
                              text:'Cure Mate Privacy Policy',
                              applyShadow: true,
                              applySkew: true,
                              applyGradient: true,
                              textStyle: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gradientGreen,
                              ),
                            ),
                          ),
                          10.height,
                          const Center(
                            child: Text(
                              'Last Updated: May 12, 2025',
                              style: TextStyle(
                                fontSize: 16,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          20.height,
                          const Text(
                            'At Cure Mate, we are committed to protecting your privacy and ensuring the security of your personal information. This Privacy Policy explains how we collect, use, disclose, and safeguard your data when you use our app. By using Cure Mate, you agree to the practices described in this policy.',
                            style: TextStyle(fontSize: 16),
                          ),
                          20.height,
                          const Text(
                            '1. Information We Collect',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          10.height,
                          _buildBulletPoint(
                            'Personal Information: Name, email address, phone number, and any other details you provide when creating a profile or contacting us.',
                          ),
                          _buildBulletPoint(
                            'Usage Data: Information about your interactions with the app, such as search queries for doctors, features used, and time spent.',
                          ),
                          _buildBulletPoint(
                            'Device Information: Device type, operating system, IP address, and unique device identifiers.',
                          ),
                          _buildBulletPoint(
                            'Location Data: If enabled, we may collect your location to provide location-based services or suggest nearby doctors.',
                          ),
                          20.height,
                          const Text(
                            '2. How We Use Your Information',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          10.height,
                          _buildBulletPoint(
                            'Provide and enhance our services, such as doctor search, appointment scheduling, and personalized recommendations.',
                          ),
                          _buildBulletPoint(
                            'Communicate with you, including sending updates, notifications, or responding to inquiries.',
                          ),
                          _buildBulletPoint(
                            'Analyze app usage to improve functionality and user experience.',
                          ),
                          _buildBulletPoint(
                            'Ensure the security of the app and prevent unauthorized access or fraudulent activity.',
                          ),
                          _buildBulletPoint(
                            'Comply with legal obligations.',
                          ),
                          20.height,
                          const Text(
                            '3. How We Share Your Information',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          10.height,
                          _buildBulletPoint(
                            'Service Providers: Third parties that assist us in operating the app, such as cloud hosting or analytics providers, under strict confidentiality agreements.',
                          ),
                          _buildBulletPoint(
                            'Legal Requirements: If required by law, we may disclose your information to comply with legal processes or protect our rights.',
                          ),
                          _buildBulletPoint(
                            'With Your Consent: We may share your information for other purposes if you provide explicit consent.',
                          ),
                          20.height,
                          const Text(
                            '4. Data Security',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          10.height,
                          const Text(
                            'We implement reasonable security measures, including encryption and secure servers, to protect your data. However, no method of transmission over the internet is 100% secure, and we cannot guarantee absolute security.',
                            style: TextStyle(fontSize: 16),
                          ),
                          20.height,
                          const Text(
                            '5. Your Choices and Rights',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          10.height,
                          _buildBulletPoint(
                            'Access and Update: You can access or update your personal information through your profile settings.',
                          ),
                          _buildBulletPoint(
                            'Delete: You may request the deletion of your data by contacting us at ${AppStrings.feedbackEmail}.',
                          ),
                          _buildBulletPoint(
                            'Opt-Out: You can opt out of promotional communications by following the unsubscribe instructions in those messages.',
                          ),
                          _buildBulletPoint(
                            'Location Settings: You can disable location access through your device settings.',
                          ),
                          20.height,
                          const Text(
                            '6. Third-Party Links',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          10.height,
                          const Text(
                            'Cure Mate may contain links to third-party websites or services (e.g., for doctor data or analytics). We are not responsible for the privacy practices of these external sites and encourage you to review their policies.',
                            style: TextStyle(fontSize: 16),
                          ),
                          20.height,
                          const Text(
                            '7. Changes to This Policy',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          10.height,
                          const Text(
                            'We may update this Privacy Policy from time to time. We will notify you of significant changes by posting a notice in the app or sending an email. Your continued use of Cure Mate after such changes constitutes acceptance of the updated policy.',
                            style: TextStyle(fontSize: 16),
                          ),
                          20.height,
                          const Text(
                            '8. Contact Us',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          10.height,
                          _buildBulletPoint(
                            'Email:${AppStrings.feedbackEmail}',
                          ),
                          _buildBulletPoint(
                            'Address: Bahauddin Zakariya University, Multan, Pakistan',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0, right: 8.0),
            child: Icon(
              Icons.circle,
              color: Colors.green,
              size: 10,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}