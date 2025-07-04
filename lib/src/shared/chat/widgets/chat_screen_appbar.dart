
import 'package:curemate/src/router/nav.dart';
import 'package:curemate/src/shared/providers/check_internet_connectivity_provider.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../const/app_fonts.dart';
import '../../../../core/utils/flutter_cache_manager.dart';
import '../../../features/patient/views/patient_main_view.dart';
import '../../widgets/back_view_icon_widget.dart';
import '../providers/chatting_providers.dart';

class ChatScreenAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String otherUserId;
  final String otherUserName;
  final bool fromDoctorDetails;
  final bool isPatient;

  const ChatScreenAppBar({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    required this.fromDoctorDetails,
    required this.isPatient,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherUserProfile = ref.watch(otherUserProfileProvider(otherUserId));
    final status = ref.watch(formattedStatusProvider(otherUserId));
    final isInternet = ref.watch(checkInternetConnectionProvider).value ?? false;

    return AppBar(
      backgroundColor: AppColors.gradientGreen,
      leading: BackViewIconWidget(
        onPressed: () {
          if (fromDoctorDetails && isPatient) {
            ref.read(patientBottomNavIndexProvider.notifier).state = 3;
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else {
            AppNavigation.pop();
          }
        },
      ),
      title: Row(
        children: [
          otherUserProfile.when(
            data: (profile) => CircleAvatar(
              radius: 20,
              child: CachedNetworkImage(
                imageUrl: profile['profileImageUrl']?.isNotEmpty == true
                    ? profile['profileImageUrl']
                    : '',
                cacheManager: CustomCacheManager.instance,
                placeholder: (context, url) => const CircularProgressIndicator(color: AppColors.gradientGreen,),
                errorWidget: (context, url, error) => Text(
                  otherUserName.isNotEmpty ? otherUserName[0] : '?',
                  style: const TextStyle(
                    fontSize: 20,
                    fontFamily: AppFonts.rubik,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                imageBuilder: (context, imageProvider) => CircleAvatar(
                  radius: 20,
                  backgroundImage: imageProvider,
                ),
              ),
            ),
            loading: () => const CircleAvatar(child: CircularProgressIndicator(color: AppColors.gradientGreen,)),
            error: (error, _) => CircleAvatar(
              child: Text(
                otherUserName.isNotEmpty ? otherUserName[0] : '?',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                otherUserName.isNotEmpty ? otherUserName : 'Unknown User',
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: AppFonts.rubik,
                  fontWeight: FontWeight.w600,
                ),
              ),
              status.when(
                data: (data) =>
                    Text(
                      ! isInternet?'waiting for network conn...': data,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.gradientWhite,
                    fontFamily: AppFonts.rubik,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                loading: () => const Text('...'),
                error: (error, _) => const Text('Offline'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}



