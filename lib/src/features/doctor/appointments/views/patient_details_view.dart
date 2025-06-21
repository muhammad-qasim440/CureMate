import 'package:cached_network_image/cached_network_image.dart';
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/src/features/patient/providers/patient_providers.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/utils/flutter_cache_manager.dart';
import '../../../../router/nav.dart';
import '../../../../shared/chat/views/chat_screen.dart';
import '../../../../shared/widgets/back_view_icon_widget.dart';

class PatientDetailsView extends ConsumerStatefulWidget {
  final Patient patient;

  const PatientDetailsView({super.key, required this.patient});
  @override
  ConsumerState<PatientDetailsView> createState() => _PatientDetailsViewState();
}

class _PatientDetailsViewState extends ConsumerState<PatientDetailsView>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: const BackViewIconWidget(),
                expandedHeight: 220,
                pinned: true,
                backgroundColor: AppColors.gradientGreen,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.gradientGreen,
                          AppColors.gradientGreen.withOpacity(0.5),
                          Colors.white,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  spreadRadius: 2,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: CachedNetworkImage(
                                imageUrl:
                                    widget.patient.profileImageUrl.isNotEmpty
                                        ? widget.patient.profileImageUrl
                                        : '',
                                cacheManager: CustomCacheManager.instance,
                                placeholder:
                                    (context, url) =>
                                        const CircularProgressIndicator(
                                          color: AppColors.gradientGreen,
                                        ),
                                errorWidget:
                                    (context, url, error) => Text(
                                      widget.patient.fullName.isNotEmpty
                                          ? widget.patient.fullName[0]
                                          : '?',
                                      style: TextStyle(
                                        fontSize: 40,
                                        fontFamily: AppFonts.rubik,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                imageBuilder:
                                    (context, imageProvider) => CircleAvatar(
                                      radius: 50,
                                      backgroundImage: imageProvider,
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.patient.fullName,
                            style: TextStyle(
                              fontSize: FontSizes(context).size26,
                              fontWeight: FontWeight.bold,
                              fontFamily: AppFonts.rubik,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.4),
                                  offset: const Offset(1, 1),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Patient',
                            style: TextStyle(
                              fontSize: FontSizes(context).size16,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: AppFonts.rubik,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildContactActions(),
                        _buildPatientInfo(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.person_outline,
                color: AppColors.gradientGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Patient Information',
                style: TextStyle(
                  fontSize: FontSizes(context).size20,
                  fontWeight: FontWeight.bold,
                  fontFamily: AppFonts.rubik,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Email', widget.patient.email),
          _buildInfoRow('Phone', widget.patient.phoneNumber),
          _buildInfoRow('City', widget.patient.city),
          _buildInfoRow('Date of Birth', widget.patient.dob),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontSize: FontSizes(context).size14,
                color: Colors.grey.shade600,
                fontFamily: AppFonts.rubik,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: FontSizes(context).size14,
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.rubik,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactActions() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.chat,
            label: 'Chat',
            color: Colors.blue,
            onTap: () {
              AppNavigation.push(
                ChatScreen(
                  otherUserId: widget.patient.uid,
                  otherUserName: widget.patient.fullName,
                  isPatient: false,
                  fromDoctorDetails: false,
                ),
              );
            },
          ),
          _buildActionButton(
            icon: Icons.phone,
            label: 'Call',
            color: AppColors.gradientGreen,
            onTap: () async {
              final Uri telUri = Uri(
                scheme: 'tel',
                path: widget.patient.phoneNumber,
              );
              if (await canLaunchUrl(telUri)) {
                await launchUrl(telUri);
              } else {
                if (mounted) {
                  CustomSnackBarWidget.show(
                    context: context,
                    text: 'Could not launch phone call',
                  );
                }
              }
            },
          ),
          _buildActionButton(
            icon: Icons.email,
            label: 'Email',
            color: Colors.red,
            onTap: () {
              final Uri emailUri = Uri(
                scheme: 'mailto',
                path: widget.patient.email,
              );
              launchUrl(emailUri);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: FontSizes(context).size12,
              color: Colors.grey.shade600,
              fontFamily: AppFonts.rubik,
            ),
          ),
        ],
      ),
    );
  }
}
