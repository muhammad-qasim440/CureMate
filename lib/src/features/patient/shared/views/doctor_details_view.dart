import 'package:cached_network_image/cached_network_image.dart';
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

import '../../../../../core/utils/flutter_cache_manager.dart';
import '../../../../router/nav.dart';
import '../../../../shared/chat/views/chat_screen.dart';
import '../../providers/patient_providers.dart';

class DoctorDetailsView extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailsView({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          doctor.fullName,
          style: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: AppColors.gradientGreen),
            onPressed: () {
                  AppNavigation.push( ChatScreen(
                    otherUserId: doctor.uid,
                    otherUserName: doctor.fullName,
                    isPatient: true,
                    fromDoctorDetails: true,
                  ),);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    child: CachedNetworkImage(
                      imageUrl: doctor.profileImageUrl.isNotEmpty == true
                          ? doctor.profileImageUrl
                          : '',
                      cacheManager: CustomCacheManager.instance,
                      placeholder: (context, url) => const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Text(
                        doctor.fullName.isNotEmpty == true ? doctor.fullName[0] : '?',
                        style: TextStyle(
                          fontSize: 40,
                          fontFamily: AppFonts.rubik,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      imageBuilder: (context, imageProvider) => CircleAvatar(
                        radius: 60,
                        backgroundImage: imageProvider,
                      ),
                    ),
                  ),
                ),
                16.height,
                Text(
                  doctor.fullName,
                  style: TextStyle(
                    fontSize: FontSizes(context).size22,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.rubik,
                  ),
                  textAlign: TextAlign.center,
                ),
                4.height,
                Text(
                  doctor.category.isNotEmpty == true ? doctor.category : 'General',
                  style: TextStyle(
                    fontSize: FontSizes(context).size16,
                    color: AppColors.subtextcolor,
                    fontFamily: AppFonts.rubik,
                  ),
                  textAlign: TextAlign.center,
                ),
                8.height,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    5,
                        (index) => Icon(
                      Icons.star,
                      size: 18,
                      color: index < ((doctor.averageRatings) / 2).round()
                          ? Colors.amber
                          : Colors.grey,
                    ),
                  ),
                ),
                24.height,
                _buildInfoCard(
                  context,
                  'Qualification',
                  doctor.qualification.isNotEmpty == true ? doctor.qualification : 'N/A',
                ),
                _buildInfoCard(
                  context,
                  'City',
                  doctor.city.isNotEmpty == true ? doctor.city : 'N/A',
                ),
                _buildInfoCard(
                  context,
                  'Consultation Fee',
                  'PKR ${doctor.consultationFee}',
                ),
                _buildInfoCard(
                  context,
                  'Years of Experience',
                  '${doctor.yearsOfExperience } years',
                ),
                _buildInfoCard(
                  context,
                  'Total Patients Consulted',
                  '${doctor.totalPatientConsulted }',
                ),
                _buildInfoCard(
                  context,
                  'Number of Reviews',
                  '${doctor.totalReviews }',
                ),
                32.height,
                // ElevatedButton.icon(
                //   onPressed: () {
                //
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(
                //           builder: (context) => ChatScreen(
                //             otherUserId: doctor.uid,
                //             otherUserName: doctor.fullName,
                //             isPatient: true,
                //           ),
                //         ),
                //       );
                //   },
                //   icon: const Icon(Icons.chat),
                //   label: const Text('Chat with Doctor'),
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: AppColors.gradientGreen,
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(
                //       horizontal: 24,
                //       vertical: 12,
                //     ),
                //     textStyle: TextStyle(
                //       fontSize: FontSizes(context).size16,
                //       fontFamily: AppFonts.rubik,
                //     ),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(12),
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: AppColors.gradientWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size16,
          ),
        ),
        subtitle: Text(
          value,
          style: TextStyle(
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size14,
            color: AppColors.subtextcolor,
          ),
        ),
      ),
    );
  }
}