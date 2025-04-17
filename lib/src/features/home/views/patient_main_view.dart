import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/const/font_sizes.dart';
import 'package:curemate/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_snackbar_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../shared/widgets/app_exit_bottom_sheet/exit_app_bottom_sheet.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../theme/app_colors.dart';
import '../../patient/providers/patient_providers.dart';
import '../../patient/views/rate_doctor/views/star_rating.dart';
import '../../signin/providers/auth-provider.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class PatientMainView extends ConsumerWidget {
  final List<Widget> _screens = const [
    PatientHomeView(),
    DummyScreen(title: 'Favorites'),
    DummyScreen(title: 'Messages'),
    DummyScreen(title: 'Profile'),
  ];

  const PatientMainView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);
    return WillPopScope(
      onWillPop: () async {
        if (selectedIndex != 0) {
          ref.read(bottomNavIndexProvider.notifier).state = 0;
          return false;
        }
        ExitAppBottomSheet(
          exit: () async {
            await SystemNavigator.pop();
          },
        ).show(context);
        return false;
      },
      child: Scaffold(
        body: _screens[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap:
              (index) =>
                  ref.read(bottomNavIndexProvider.notifier).state = index,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: _buildSelectedIcon(Icons.home),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite),
              activeIcon: _buildSelectedIcon(Icons.favorite),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: _buildSelectedIcon(Icons.menu_book_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.chat),
              activeIcon: _buildSelectedIcon(Icons.chat),
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(
        color: AppColors.gradientGreen,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.white),
    );
  }
}

// Patient Home View
class PatientHomeView extends ConsumerWidget {
  const PatientHomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        const LowerBackgroundEffectsWidgets(),
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              220.height,
              SpecialityIconsList(),
              NearbyDoctorsList(),
              PopularDoctorsList(),
              FeaturedDoctorsList(),
            ],
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Column(
            children: [
              const UserProfileHeader(),
              Transform.translate(
                offset: const Offset(0, -40),
                child: const SearchBarWidget(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UserProfileHeader extends ConsumerWidget {
  const UserProfileHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patientAsync = ref.watch(currentPatientProvider);

    return Container(
      height: ScreenUtil.scaleHeight(context, 156),
      width: ScreenUtil.scaleWidth(context, 375),
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: AppColors.backgroundLinearGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                patientAsync.when(
                  data:
                      (patient) => CustomTextWidget(
                        text:
                            patient != null
                                ? 'Hi ${patient.fullName}!'
                                : 'Hi Guest!',
                        textStyle: TextStyle(
                          fontSize: FontSizes(context).size20,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFonts.rubik,
                        ),
                      ),
                  loading: () => const CircularProgressIndicator(),
                  error:
                      (error, stack) => CustomTextWidget(
                        text: 'Error loading user',
                        textStyle: TextStyle(
                          fontSize: FontSizes(context).size20,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppFonts.rubik,
                          color: Colors.red,
                        ),
                      ),
                ),
                6.height,
                CustomTextWidget(
                  text: 'Find Your Doctor',
                  textStyle: TextStyle(
                    fontSize: FontSizes(context).size26,
                    color: AppColors.gradientWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Positioned(
              top: ScreenUtil.scaleHeight(context, 6),
              right: ScreenUtil.scaleWidth(context, 15),
              child: patientAsync.when(
                data:
                    (patient) => CircleAvatar(
                      radius: 25,
                      backgroundImage:
                          patient != null && patient.profileImageUrl.isNotEmpty
                              ? NetworkImage(patient.profileImageUrl)
                              : null,
                      child:
                          patient == null || patient.profileImageUrl.isEmpty
                              ? Icon(
                                Icons.person,
                                size: 30,
                                color: Colors.grey.shade600,
                              )
                              : null,
                    ),
                loading: () => const CircularProgressIndicator(),
                error:
                    (error, stack) => CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(
                        Icons.error,
                        size: 30,
                        color: Colors.grey.shade600,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: ScreenUtil.scaleWidth(context, 335),
          height: ScreenUtil.scaleHeight(context, 54),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const Icon(Icons.search, color: AppColors.subtextcolor, size: 20),
              5.width,
              CustomTextWidget(
                text: 'Search...',
                textStyle: TextStyle(
                  fontSize: FontSizes(context).size15,
                  fontWeight: FontWeight.w400,
                  fontFamily: AppFonts.rubik,
                  color: AppColors.subtextcolor,
                ),
              ),
              const Spacer(),
              const Icon(Icons.close, color: AppColors.subtextcolor, size: 20),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class SpecialityIconsList extends StatelessWidget {
  final List<Map<String, dynamic>> specialities = [
    {
      'icon': Icons.local_hospital,
      'label': 'General',
      'gradient': [Colors.orange, Colors.deepOrange],
    },
    {
      'icon': Icons.favorite,
      'label': 'Cardiology',
      'gradient': [Colors.redAccent, Colors.red],
    },
    {
      'icon': Icons.remove_red_eye,
      'label': 'Eye',
      'gradient': [Colors.lightBlueAccent, Colors.blue],
    },
    {
      'icon': Icons.masks,
      'label': 'Dental',
      'gradient': [Colors.lightGreen, Colors.green],
    },
    {
      'icon': Icons.child_care,
      'label': 'Pediatrics',
      'gradient': [Colors.purpleAccent, Colors.purple],
    },
    {
      'icon': Icons.psychology,
      'label': 'Psychiatry',
      'gradient': [Colors.tealAccent, Colors.teal],
    },
    {
      'icon': Icons.accessibility_new,
      'label': 'Orthopedics',
      'gradient': [Colors.indigoAccent, Colors.indigo],
    },
    {
      'icon': Icons.woman,
      'label': 'Gynecology',
      'gradient': [Colors.pinkAccent, Colors.pink],
    },
    {
      'icon': Icons.bubble_chart,
      'label': 'Neurology',
      'gradient': [Colors.deepPurpleAccent, Colors.deepPurple],
    },
    {
      'icon': Icons.spa,
      'label': 'Dermatology',
      'gradient': [Colors.brown.shade200, Colors.brown],
    },
  ];

  SpecialityIconsList({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: ScreenUtil.scaleHeight(context, 130),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: specialities.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {},
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                children: [
                  Container(
                    width: ScreenUtil.scaleWidth(context, 70),
                    height: ScreenUtil.scaleHeight(context, 75),
                    padding: const EdgeInsets.all(12),
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

// Doctor Card Widget (Reusable for all doctor lists)
class DoctorCard extends StatelessWidget {
  final Doctor doctor;

  const DoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Tapped on ${doctor.fullName}',
        );
      },
      child: Container(
        width: ScreenUtil.scaleWidth(context, 190),
        height: ScreenUtil.scaleHeight(context, 264),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.gradientWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: ScreenUtil.scaleWidth(context, 190),
              height: ScreenUtil.scaleHeight(context, 180),
              decoration: BoxDecoration(
                image:
                    doctor.profileImageUrl.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(doctor.profileImageUrl),
                          fit: BoxFit.cover,
                        )
                        : null,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child:
                  doctor.profileImageUrl.isEmpty
                      ? Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey.shade600,
                        ),
                      )
                      : null,
            ),
            5.height,
            CustomTextWidget(
              text: doctor.fullName,
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size15,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextWidget(
                  text:
                      doctor.category.isNotEmpty ? doctor.category : 'General',
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size12,
                    color: AppColors.subtextcolor,
                  ),
                ),
                15.width,
                CustomTextWidget(
                  text:
                      '${doctor.latitude != 0 ? (doctor.latitude - 30.2246769).abs().toStringAsFixed(1) : 'N/A'} km',
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size14,
                    color: AppColors.gradientGreen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Nearby Doctors List Widget
class NearbyDoctorsList extends ConsumerWidget {
  const NearbyDoctorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nearby Doctors',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size18,
                ),
              ),
              const Text('See all', style: TextStyle(color: Colors.teal)),
            ],
          ),
          16.height,
          SizedBox(
            height: ScreenUtil.scaleHeight(context, 225),
            child: doctorsAsync.when(
              data:
                  (doctors) =>
                      doctors.isEmpty
                          ? const Center(child: Text('No doctors available'))
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: doctors.length,
                            itemBuilder: (context, index) {
                              return DoctorCard(doctor: doctors[index]);
                            },
                          ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );
  }
}

class PopularDoctorCard extends StatelessWidget {
  final Doctor doctor;

  const PopularDoctorCard({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Tapped on ${doctor.fullName}',
        );
      },
      child: Container(
        width: ScreenUtil.scaleWidth(context, 190),
        height: ScreenUtil.scaleHeight(context, 264),
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppColors.gradientWhite,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: ScreenUtil.scaleWidth(context, 160),
              height: ScreenUtil.scaleHeight(context, 140),
              decoration: BoxDecoration(
                image:
                    doctor.profileImageUrl.isNotEmpty
                        ? DecorationImage(
                          image: NetworkImage(doctor.profileImageUrl),
                          fit: BoxFit.cover,
                        )
                        : null,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child:
                  doctor.profileImageUrl.isEmpty
                      ? Center(
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey.shade600,
                        ),
                      )
                      : null,
            ),
            8.height,
            CustomTextWidget(
              text: doctor.fullName,
              textAlignment: TextAlign.center,
              textStyle: TextStyle(
                fontWeight: FontWeight.w500,
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size15,
              ),
            ),
            4.height,
            CustomTextWidget(
              text: doctor.category.isNotEmpty ? doctor.category : 'General',
              textAlignment: TextAlign.center,
              textStyle: TextStyle(
                fontWeight: FontWeight.w400,
                fontFamily: AppFonts.rubik,
                fontSize: FontSizes(context).size12,
                color: AppColors.subtextcolor,
              ),
            ),
            4.height,
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star,
                  size: 16,
                  color:
                      index < (doctor.averageRatings / 2).round()
                          ? Colors.amber
                          : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PopularDoctorsList extends ConsumerWidget {
  const PopularDoctorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Doctors',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size18,
                ),
              ),
              const Text('See all', style: TextStyle(color: Colors.teal)),
            ],
          ),
          16.height,
          SizedBox(
            height: ScreenUtil.scaleHeight(context, 220),
            child: doctorsAsync.when(
              data: (doctors) {
                final sortedDoctors =
                    doctors
                        .where((doctor) => doctor.averageRatings > 0)
                        .toList()
                      ..sort(
                        (a, b) => b.averageRatings.compareTo(a.averageRatings),
                      );
                return sortedDoctors.isEmpty
                    ? const Center(child: Text('No popular doctors available'))
                    : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount:
                          sortedDoctors.length > 2
                              ? 2
                              : sortedDoctors
                                  .length, // Limit to 2 as per screenshot
                      itemBuilder: (context, index) {
                        return PopularDoctorCard(doctor: sortedDoctors[index]);
                      },
                    );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Text(
                      error.toString().contains('permission_denied')
                          ? 'Permission denied. Please sign in as a patient.'
                          : 'Error loading doctors: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeaturedDoctorCard extends ConsumerWidget {
  final Doctor doctor;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const FeaturedDoctorCard({
    super.key,
    required this.doctor,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        _showRatingDialog(context, ref);
        CustomSnackBarWidget.show(
          context: context,
          text: 'Tapped on ${doctor.fullName}',
        );
      },
      child: Stack(
        children: [
          Container(
            width: ScreenUtil.scaleWidth(context, 140),
            height: ScreenUtil.scaleHeight(context, 180),
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: ScreenUtil.scaleWidth(context, 100),
                  height: ScreenUtil.scaleHeight(context, 100),
                  margin: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image:
                        doctor.profileImageUrl.isNotEmpty
                            ? DecorationImage(
                              image: NetworkImage(doctor.profileImageUrl),
                              fit: BoxFit.cover,
                            )
                            : null,
                  ),
                  child:
                      doctor.profileImageUrl.isEmpty
                          ? Center(
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey.shade600,
                            ),
                          )
                          : null,
                ),
                8.height,
                CustomTextWidget(
                  text: doctor.fullName,
                  textAlignment: TextAlign.center,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size14,
                  ),
                ),
                4.height,
                CustomTextWidget(
                  text:
                      '\$${doctor.yearsOfExperience != null ? (int.parse(doctor.yearsOfExperience) * 10).toStringAsFixed(2) : 'N/A'}/hour',
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size14,
                    color: AppColors.gradientGreen,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: ScreenUtil.scaleWidth(context, 4),
            left: ScreenUtil.scaleWidth(context, 4),
            child: GestureDetector(
              onTap: onFavoriteToggle,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : const Color(0xFF6B46C1), // Purple for not favorited
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            top: ScreenUtil.scaleWidth(context, 8),
            right: ScreenUtil.scaleWidth(context, 20),
            child: Row(
              children: [
                const Icon(
                  Icons.star,
                  size: 16,
                  color: Colors.amber,
                ),
                4.width,
                CustomTextWidget(
                  text: (doctor.averageRatings / 5).toStringAsFixed(1),
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontFamily: AppFonts.rubik,
                    fontSize: FontSizes(context).size12,
                    color: AppColors.subtextcolor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRatingDialog(BuildContext context, WidgetRef ref) {
    double rating = 0.0; // Rating out of 5, will convert to 10
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${doctor.fullName}',textAlign: TextAlign.center,),
        contentPadding: EdgeInsets.all(10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide your rating (out of 5 stars)',textAlign: TextAlign.center),
            16.height,
            StarRating(
              rating: rating,
              onRatingChanged: (newRating) => rating = newRating,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (rating > 0) {
                _submitRating(context,ref, rating * 2);
                Navigator.pop(context);
              } else {
                CustomSnackBarWidget.show(context: context, text: 'Please select a rating');
              }
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _submitRating(BuildContext context, WidgetRef ref, double rating) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBarWidget.show(context: context, text: 'Please sign in to rate');
      return;
    }

    // Check if the user is a patient
    final database = FirebaseDatabase.instance.ref();
    final userTypeSnapshot = await database.child('Patients').child(user.uid).child('userType').get();
    if (!userTypeSnapshot.exists || userTypeSnapshot.value != 'Patient') {
      CustomSnackBarWidget.show(context: context, text: 'Only patients can submit ratings');
      return;
    }

    final ratingRef = database.child('Doctors').child(doctor.uid).child('ratings').child(user.uid);

    try {
      await ratingRef.set({
        'rating': rating, // Rating out of 10
        'timestamp': DateTime.now().toIso8601String(),
      });
      CustomSnackBarWidget.show(context: context, text: 'Rating submitted successfully');
    } catch (e) {
      String errorMessage = 'Error submitting rating: $e';
      if (e.toString().contains('PERMISSION_DENIED')) {
        errorMessage = 'Permission denied. Ensure you are a patient and signed in.';
      }
      CustomSnackBarWidget.show(context: context, text: errorMessage);
    }
  }
}

class FeaturedDoctorsList extends ConsumerWidget {
  const FeaturedDoctorsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctorsAsync = ref.watch(doctorsProvider);
    final favoriteUidsAsync = ref.watch(favoriteDoctorUidsProvider);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Doctors',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontFamily: AppFonts.rubik,
                  fontSize: FontSizes(context).size18,
                  color: AppColors.black,
                ),
              ),
              const Text('See all', style: TextStyle(color: Colors.teal)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: ScreenUtil.scaleHeight(context, 180),
            child: doctorsAsync.when(
              data:
                  (doctors) => favoriteUidsAsync.when(
                    data: (favoriteUids) {
                      final shuffledDoctors =
                          doctors.toList()..shuffle(); // Shuffle all doctors
                      return shuffledDoctors.isEmpty
                          ? const Center(child: Text('No doctors available'))
                          : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount:
                                shuffledDoctors.length > 3
                                    ? 3
                                    : shuffledDoctors
                                        .length, // Limit to 3 as per screenshot
                            itemBuilder: (context, index) {
                              final doctor = shuffledDoctors[index];
                              final isFavorite = favoriteUids.contains(
                                doctor.uid,
                              );
                              return FeaturedDoctorCard(
                                doctor: doctor,
                                isFavorite: isFavorite,
                                onFavoriteToggle:
                                    () => _toggleFavorite(
                                      context,
                                      ref,
                                      doctor.uid,
                                    ),
                              );
                            },
                          );
                    },
                    loading:
                        () => const Center(child: CircularProgressIndicator()),
                    error:
                        (error, stack) => Center(
                          child: Text(
                            'Error loading favorites: $error',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                  ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error:
                  (error, stack) => Center(
                    child: Text(
                      error.toString().contains('permission_denied')
                          ? 'Permission denied. Please sign in as a patient.'
                          : 'Error loading doctors: $error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    String doctorUid,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final database = FirebaseDatabase.instance.ref();
    final favoritesRef = database
        .child('Patients')
        .child(user.uid)
        .child('favorites')
        .child(doctorUid);

    try {
      final snapshot = await favoritesRef.get();
      if (snapshot.exists) {
        await favoritesRef.remove();
      } else {
        await favoritesRef.set(true);
      }
    } catch (e) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'Error toggling favorite: $e',
      );
    }
  }
}

class DummyScreen extends ConsumerWidget {
  final String title;

  const DummyScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$title screen', style: TextStyle(fontSize: 20)),
          const SizedBox(height: 20),
          CustomButtonWidget(
            text: 'logout',
            height: ScreenUtil.scaleHeight(context, 45),
            backgroundColor: AppColors.btnBgColor,
            fontFamily: AppFonts.rubik,
            fontSize: FontSizes(context).size18,
            fontWeight: FontWeight.w900,
            textColor: AppColors.gradientWhite,
            width: ScreenUtil.scaleWidth(context, 320),
            onPressed: () async {
              final isNetworkAvailable = ref.read(
                checkInternetConnectionProvider,
              );
              final isConnected =
                  await isNetworkAvailable.whenData((value) => value).value ??
                  false;

              if (!isConnected) {
                CustomSnackBarWidget.show(
                  context: context,
                  backgroundColor: AppColors.gradientGreen,
                  text: "No Internet Connection",
                );
                return;
              }
              try {
                await ref.read(authProvider).logout(context);

              } catch (e) {
                CustomSnackBarWidget.show(context: context, text: "$e");
              }
            },
          ),
        ],
      ),
    );
  }
}
