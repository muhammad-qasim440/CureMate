import 'package:cached_network_image/cached_network_image.dart';
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/src/shared/repository/doctor_repository.dart';
import 'package:curemate/src/shared/widgets/back_view_icon_widget.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/theme/app_colors.dart';
import 'package:curemate/src/utils/app_utils.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/utils/flutter_cache_manager.dart';
import '../../../../router/nav.dart';
import '../../../../shared/chat/views/chat_screen.dart';
import '../../../appointments/views/appointment_booking_view.dart';
import '../../providers/patient_providers.dart';
import '../helpers/add_or_remove_doctor_into_favorite.dart';

class DoctorProfileView extends ConsumerStatefulWidget {
  final Doctor doctor;

  const DoctorProfileView({super.key, required this.doctor});
  @override
  ConsumerState<DoctorProfileView> createState() => _DoctorProfileViewState();
}

class _DoctorProfileViewState extends ConsumerState<DoctorProfileView>
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final doctorRepository = DoctorRepository();
      doctorRepository.incrementProfileView(widget.doctor.uid).catchError((e) {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Failed to update profile view: $e',
        );
      });
    });
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  void _openMapsWithDirections() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${widget.doctor.latitude},${widget.doctor.longitude}&travelmode=driving',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      CustomSnackBarWidget.show(
        context: context,
        text: 'Could not launch maps',
      );
    }
  }

  String _formatAvailability() {
    final availability = widget.doctor.availability;
    if (availability.isEmpty) {
      return 'Not specified';
    }

    List<String> schedules = [];

    for (var schedule in availability) {
      if (schedule['isFullDay'] == true) {
        schedules.add(
          '${schedule['day']}: ${schedule['startTime']} - ${schedule['endTime']}',
        );
      } else {
        String daySchedule = '${schedule['day']}: ';
        List<String> timeSlots = [];

        if (schedule['morning'] != null &&
            schedule['morning']['isAvailable'] == true) {
          timeSlots.add(
            '${schedule['morning']['startTime']} - ${schedule['morning']['endTime']}',
          );
        }

        if (schedule['afternoon'] != null &&
            schedule['afternoon']['isAvailable'] == true) {
          timeSlots.add(
            '${schedule['afternoon']['startTime']} - ${schedule['afternoon']['endTime']}',
          );
        }

        if (schedule['evening'] != null &&
            schedule['evening']['isAvailable'] == true) {
          timeSlots.add(
            '${schedule['evening']['startTime']} - ${schedule['evening']['endTime']}',
          );
        }

        if (timeSlots.isNotEmpty) {
          daySchedule += timeSlots.join(', ');
          schedules.add(daySchedule);
        }
      }
    }

    return schedules.isNotEmpty ? schedules.join('\n') : 'Not specified';
  }

  @override
  Widget build(BuildContext context) {
    final favoriteDocids = ref.watch(favoriteDoctorUidsProvider).value ?? [];
    final isFavorite = favoriteDocids.contains(widget.doctor.uid);

    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          CustomScrollView(
            slivers: [
              SliverAppBar(
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
                                    widget.doctor.profileImageUrl.isNotEmpty ==
                                            true
                                        ? widget.doctor.profileImageUrl
                                        : '',
                                cacheManager: CustomCacheManager.instance,
                                placeholder:
                                    (context, url) =>
                                        const CircularProgressIndicator(
                                          color: AppColors.gradientGreen,
                                        ),
                                errorWidget:
                                    (context, url, error) => Text(
                                      widget.doctor.fullName.isNotEmpty == true
                                          ? widget.doctor.fullName[0]
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
                            widget.doctor.fullName,
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
                            'Specialist ${widget.doctor.category}',
                            style: TextStyle(
                              fontSize: FontSizes(context).size16,
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: AppFonts.rubik,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ...List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star,
                                  size: 18,
                                  color:
                                      index <
                                              ((widget.doctor.averageRatings) /
                                                      2)
                                                  .round()
                                          ? Colors.amber
                                          : Colors.black,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'PKR ${widget.doctor.consultationFee}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: FontSizes(context).size16,
                                  fontFamily: AppFonts.rubik,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                leading: const BackViewIconWidget(),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      AddORRemoveDoctorIntoFavorite.toggleFavorite(
                        context,
                        ref,
                        widget.doctor.uid,
                      );
                    },
                  ),
                ],
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
                        _buildStatistics(),
                        _buildAvailabilitySection(),
                        _buildMapSection(),
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: CustomButtonWidget(
          text: 'Book Now',
          backgroundColor: AppColors.gradientGreen,
          width: double.infinity,
          height: ScreenUtil.scaleHeight(context, 54),
          fontFamily: AppFonts.rubik,
          fontWeight: FontWeight.w600,
          fontSize: FontSizes(context).size16,
          textColor: Colors.white,
          onPressed: () {
            AppNavigation.push(AppointmentBookingView(doctor: widget.doctor));
          },
        ),
      ),
    );
  }

  Widget _buildStatistics() {
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
          _buildStatItem(
            widget.doctor.yearsOfExperience,
            'Years Exp',
            Icons.work,
          ),
          _buildStatItem(
            '${widget.doctor.totalPatientConsulted}',
            'Patients',
            Icons.people,
          ),
          _buildStatItem(
            '${widget.doctor.profileViews}',
            'Views',
            Icons.visibility,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.gradientGreen),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: FontSizes(context).size18,
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.rubik,
                color: AppColors.gradientGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: FontSizes(context).size14,
            color: Colors.grey.shade600,
            fontFamily: AppFonts.rubik,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
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
                Icons.calendar_today,
                color: AppColors.gradientGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Availability',
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
          Text(
            _formatAvailability(),
            style: TextStyle(
              fontSize: FontSizes(context).size16,
              color: Colors.black87,
              fontFamily: AppFonts.rubik,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Qualification', widget.doctor.qualification),
          _buildInfoRow('City', widget.doctor.city),
          _buildInfoRow('Hospital', widget.doctor.hospital),
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

  Widget _buildMapSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: AppColors.gradientGreen,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Location',
                  style: TextStyle(
                    fontSize: FontSizes(context).size20,
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.rubik,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 250,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(
                        widget.doctor.latitude,
                        widget.doctor.longitude,
                      ),
                      initialZoom: 10.0,
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.none,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.app',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(
                              widget.doctor.latitude,
                              widget.doctor.longitude,
                            ),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                      const Positioned(
                        bottom: 8,
                        right: 8,
                        child: Text(
                          '© OpenStreetMap contributors',
                          style: TextStyle(fontSize: 10, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: _openMapsWithDirections,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gradientGreen,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.directions,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Get Directions',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: AppFonts.rubik,
                                fontSize: FontSizes(context).size14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildContactActions() {
    final currentUser = ref
        .watch(currentSignInPatientDataProvider)
        .when<Patient?>(
          data: (data) => data,
          error: (err, stack) => null,
          loading: () => null,
        );
    final isPhoneCallsAllowedByDoctor = ref.watch(
      isPhoneCallsAllowedByUserProvider(widget.doctor.uid),
    );
    final isPhoneCallsAllowedByCurrentUser = ref.watch(
      isPhoneCallsAllowedByUserProvider(currentUser?.uid ?? ''),
    );

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
                Icons.contact_phone,
                color: AppColors.gradientGreen,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Contact Doctor',
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.call,
                label: 'Call',
                color: Colors.green,
                onTap: () {
                  if (currentUser == null) {
                    CustomSnackBarWidget.show(
                      context: context,
                      text: 'Please log in to make a call.',
                    );
                    return;
                  }

                  isPhoneCallsAllowedByDoctor.when(
                    data: (doctorAllowed) {
                      isPhoneCallsAllowedByCurrentUser.when(
                        data: (userAllowed) {
                          if (doctorAllowed && userAllowed) {
                            AppUtils.openPhone(widget.doctor.phoneNumber);
                          } else if (!doctorAllowed && !userAllowed) {
                            CustomSnackBarWidget.show(
                              context: context,
                              text:
                                  'Both you and the doctor have disabled phone calls.',
                            );
                          } else if (!doctorAllowed) {
                            CustomSnackBarWidget.show(
                              context: context,
                              text: 'The doctor has disabled phone calls.',
                            );
                          } else {
                            CustomSnackBarWidget.show(
                              context: context,
                              text:
                                  'You have disabled phone calls in your settings.',
                            );
                          }
                        },
                        loading:
                            () => CustomSnackBarWidget.show(
                              context: context,
                              text: 'Checking call permissions...',
                            ),
                        error:
                            (e, _) => CustomSnackBarWidget.show(
                              context: context,
                              text: 'Error checking your call permissions.',
                            ),
                      );
                    },
                    loading:
                        () => CustomSnackBarWidget.show(
                          context: context,
                          text: 'Checking call permissions...',
                        ),
                    error:
                        (e, _) => CustomSnackBarWidget.show(
                          context: context,
                          text: 'Error checking doctor call permissions.',
                        ),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.chat,
                label: 'Chat',
                color: Colors.blue,
                onTap: () {
                  AppNavigation.push(
                    ChatScreen(
                      otherUserId: widget.doctor.uid,
                      otherUserName: widget.doctor.fullName,
                      isPatient: true,
                      fromDoctorDetails: true,
                    ),
                  );
                },
              ),
              _buildActionButton(
                icon: Icons.email,
                label: 'Email',
                color: Colors.red,
                onTap: () {
                  final Uri emailUri = Uri(
                    scheme: 'mailto',
                    path: widget.doctor.email,
                  );
                  launchUrl(emailUri);
                },
              ),
            ],
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
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: FontSizes(context).size14,
              fontFamily: AppFonts.rubik,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
