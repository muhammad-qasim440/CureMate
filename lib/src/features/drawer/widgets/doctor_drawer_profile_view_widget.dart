import 'dart:io';
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/doctor/providers/doctor_providers.dart';
import 'package:curemate/src/features/drawer/widgets/patient_drawer_editable_personal_info_field_widget.dart';
import 'package:curemate/src/features/drawer/widgets/patient_drawer_profile_view_widget.dart';
import 'package:curemate/src/features/drawer/widgets/drawer_update_email_view_widget.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_centered_text_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:location/location.dart' as loc;
import '../../../../../const/app_strings.dart';
import '../../../../../const/font_sizes.dart';
import '../../../shared/providers/profile_image_picker_provider/profile_image_picker_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../helpers/drawer_helpers.dart';
import '../providers/drawer_providers.dart';

final isUpdatingProfileProvider = StateProvider<bool>((ref) => false);
final hasChangesProvider = StateProvider<bool>((ref) => false);

class DoctorDrawerProfileViewWidget extends ConsumerStatefulWidget {
  const DoctorDrawerProfileViewWidget({super.key});

  @override
  ConsumerState<DoctorDrawerProfileViewWidget> createState() =>
      _DoctorDrawerProfileViewWidgetState();
}

class _DoctorDrawerProfileViewWidgetState
    extends ConsumerState<DoctorDrawerProfileViewWidget> {
  final DrawerHelpers drawerHelpers = DrawerHelpers();
  final Map<String, String> originalValues = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentSignInDoctorDataProvider).value;
      if (user != null) {
        originalValues['name'] = user.fullName;
        originalValues['phone'] = user.phoneNumber;
        originalValues['city'] = user.city;
        originalValues['latitude'] = user.latitude.toString();
        originalValues['longitude'] = user.longitude.toString();
        originalValues['dob'] = user.dob;
        originalValues['qualification'] = user.qualification;
        originalValues['yearsOfExperience'] = user.yearsOfExperience;
        originalValues['category'] = user.category;
        originalValues['hospital'] = user.hospital;
        originalValues['consultationFee'] = user.consultationFee.toString();

        if (ref.read(userUpdatedNameProvider) == '') {
          ref.read(userUpdatedNameProvider.notifier).state = user.fullName;
        }
        if (ref.read(userUpdatedPhoneNumberProvider) == '') {
          ref.read(userUpdatedPhoneNumberProvider.notifier).state =
              user.phoneNumber;
        }
        if (ref.read(userUpdatedCityProvider) == '') {
          ref.read(userUpdatedCityProvider.notifier).state = user.city;
        }
        if (ref.read(userUpdatedLatitudeProvider) == '') {
          ref.read(userUpdatedLatitudeProvider.notifier).state =
              user.latitude.toString();
        }
        if (ref.read(userUpdatedLongitudeProvider) == '') {
          ref.read(userUpdatedLongitudeProvider.notifier).state =
              user.longitude.toString();
        }
        if (ref.read(userUpdatedDOBProvider) == '') {
          ref.read(userUpdatedDOBProvider.notifier).state = user.dob;
        }
        if (ref.read(userUpdatedQualificationProvider) == '') {
          ref.read(userUpdatedQualificationProvider.notifier).state =
              user.qualification;
        }
        if (ref.read(userUpdatedYearsOfExperienceProvider) == '') {
          ref.read(userUpdatedYearsOfExperienceProvider.notifier).state =
              user.yearsOfExperience;
        }
        if (ref.read(userUpdatedCategoryProvider) == '') {
          ref.read(userUpdatedCategoryProvider.notifier).state = user.category;
        }
        if (ref.read(userUpdatedHospitalProvider) == '') {
          ref.read(userUpdatedHospitalProvider.notifier).state = user.hospital;
        }
        if (ref.read(userUpdatedConsultationFeeProvider) == 0) {
          ref.read(userUpdatedConsultationFeeProvider.notifier).state =
              user.consultationFee;
        }
      }
      ref.read(isUpdatingProfileProvider.notifier).state = false;
      ref.read(hasChangesProvider.notifier).state = false;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _updateEmail(
      BuildContext context,
      WidgetRef ref,
      String currentEmail,
      ) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateEmailScreen(
          currentEmail: currentEmail,
          onUpdate: (newEmail, currentPassword, newPassword) async {
            await drawerHelpers.updateUserEmail(
              context: context,
              ref: ref,
              newEmail: newEmail,
              currentPassword: currentPassword,
              newPassword: newPassword,
              currentEmail: currentEmail,
              isDoctor: true,
            );
          },
        ),
      ),
    );
  }

  void _checkForChanges(WidgetRef ref) {
    final currentName = ref.read(userUpdatedNameProvider);
    final currentPhone = ref.read(userUpdatedPhoneNumberProvider);
    final currentCity = ref.read(userUpdatedCityProvider);
    final currentLatitude = ref.read(userUpdatedLatitudeProvider);
    final currentLongitude = ref.read(userUpdatedLongitudeProvider);
    final currentDob = ref.read(userUpdatedDOBProvider);
    final currentQualification = ref.read(userUpdatedQualificationProvider);
    final currentYearsOfExperience = ref.read(userUpdatedYearsOfExperienceProvider);
    final currentCategory = ref.read(userUpdatedCategoryProvider);
    final currentHospital = ref.read(userUpdatedHospitalProvider);
    final currentConsultationFee = ref.read(userUpdatedConsultationFeeProvider);
    final newProfileImage = ref.read(profileImagePickerProvider);

    final hasChanges =
        currentName != originalValues['name'] ||
            currentPhone != originalValues['phone'] ||
            currentCity != originalValues['city'] ||
            currentLatitude != originalValues['latitude'] ||
            currentLongitude != originalValues['longitude'] ||
            currentDob != originalValues['dob'] ||
            currentQualification != originalValues['qualification'] ||
            currentYearsOfExperience != originalValues['yearsOfExperience'] ||
            currentCategory != originalValues['category'] ||
            currentHospital != originalValues['hospital'] ||
            currentConsultationFee.toString() != originalValues['consultationFee'] ||
            newProfileImage.croppedImage != null;

    ref.read(hasChangesProvider.notifier).state = hasChanges;
  }

  void _saveChanges() async {
    await drawerHelpers.updateDoctorProfile(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentSignInDoctorDataProvider);
    final isUpdating = ref.watch(isUpdatingProfileProvider);
    final hasChanges = ref.watch(hasChangesProvider);
    final profileImageState = ref.watch(profileImagePickerProvider);

    return Scaffold(
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const CustomCenteredTextWidget(text: 'Please Sign In');
          }

          return Stack(
            children: [
              const LowerBackgroundEffectsWidgets(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Green Header
                  Container(
                    width: ScreenUtil.scaleWidth(context, 375),
                    height: ScreenUtil.scaleHeight(context, 357),
                    decoration: const BoxDecoration(
                      color: AppColors.gradientGreen,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: ScreenUtil.scaleHeight(context, 16),
                              left: ScreenUtil.scaleWidth(context, 20),
                            ),
                            child: CustomAppBarHeaderWidget(
                              title: 'Profile',
                              textStyle: TextStyle(
                                color: AppColors.gradientWhite,
                                fontSize: FontSizes(context).size18,
                                fontFamily: AppFonts.rubik,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          34.height,
                          Center(
                            child: Column(
                              children: [
                                CustomTextWidget(
                                  text: 'Set up your profile',
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontFamily: AppFonts.rubik,
                                    fontSize: FontSizes(context).size18,
                                    color: AppColors.black,
                                  ),
                                ),
                                10.height,
                                CustomTextWidget(
                                  text:
                                  'Update your profile to connect your patients with\n better impression.',
                                  textAlignment: TextAlign.center,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w200,
                                    fontFamily: AppFonts.rubik,
                                    fontSize: FontSizes(context).size14,
                                    color: AppColors.gradientWhite,
                                  ),
                                ),
                                22.height,
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    CircleAvatar(
                                      radius: 65,
                                      backgroundImage:
                                      profileImageState.croppedImage != null
                                          ? FileImage(
                                        File(
                                          profileImageState
                                              .croppedImage!
                                              .path,
                                        ),
                                      )
                                          : NetworkImage(
                                        user.profileImageUrl,
                                      ) as ImageProvider,
                                    ),
                                    Positioned(
                                      bottom: ScreenUtil.scaleHeight(
                                        context,
                                        20,
                                      ),
                                      right: ScreenUtil.scaleWidth(
                                        context,
                                        -15,
                                      ),
                                      child: GestureDetector(
                                        onTap: isUpdating
                                            ? null
                                            : () {
                                          drawerHelpers
                                              .showImagePickerBottomSheet(
                                            ref: ref,
                                            context: context,
                                            isProfileImagePicking: true,
                                          );
                                        },
                                        child: CircleAvatar(
                                          radius: 20,
                                          backgroundColor: AppColors.grey
                                              .withOpacity(0.5),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            size: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Personal Info Section
                  25.height,
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: ScreenUtil.scaleWidth(context, 20),
                    ),
                    child: CustomTextWidget(
                      text: 'Personal Information',
                      textStyle: TextStyle(
                        fontSize: FontSizes(context).size18,
                        fontFamily: AppFonts.rubik,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  12.height,

                  // Scrollable Section with Editable Fields
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: ScreenUtil.scaleWidth(context, 20),
                      ),
                      child: Column(
                        children: [
                          PersonalInfoCardsWidget(
                            title: 'Email',
                            subtitle: user.email,
                            onEditPress: isUpdating
                                ? null
                                : () => _updateEmail(context, ref, user.email),
                          ),
                          EditablePersonalInfoField(
                            title: 'Name',
                            subtitleProvider: userUpdatedNameProvider,
                            isEditingProvider: isEditingNameProvider,
                            onChanged: (value) =>
                            ref.read(userUpdatedNameProvider.notifier).state =
                                value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              return null;
                            },
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
                          ),
                          EditablePersonalInfoField(
                            title: 'Date of Birth',
                            subtitleProvider: userUpdatedDOBProvider,
                            isEditingProvider: isEditingDOBProvider,
                            onChanged: (value) =>
                            ref.read(userUpdatedDOBProvider.notifier).state =
                                value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your date of birth';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.datetime,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today, size: 20),
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime.now(),
                                );
                                if (picked != null) {
                                  final formattedDate =
                                      "${picked.day}/${picked.month}/${picked.year}";
                                  ref
                                      .read(userUpdatedDOBProvider.notifier)
                                      .state = formattedDate;
                                  ref
                                      .read(isEditingDOBProvider.notifier)
                                      .state = false;
                                  _checkForChanges(ref);
                                }
                              },
                            ),
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
                          ),
                          EditablePersonalInfoField(
                            title: 'Contact Number',
                            subtitleProvider: userUpdatedPhoneNumberProvider,
                            isEditingProvider: isEditingPhoneNumberProvider,
                            onChanged: (value) => ref
                                .read(userUpdatedPhoneNumberProvider.notifier)
                                .state = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your phone number';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.phone,
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
                          ),
                          EditablePersonalInfoField(
                            title: 'City',
                            subtitleProvider: userUpdatedCityProvider,
                            isEditingProvider: isEditingCityProvider,
                            onChanged: (value) =>
                            ref.read(userUpdatedCityProvider.notifier).state =
                                value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your city';
                              }
                              return null;
                            },
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
                            isDropdown: true,
                            dropdownItems: AppStrings.cities,
                            dropdownLabel: 'City',
                            dropdownValidatorText: 'Please select your city',
                          ),
                          EditablePersonalInfoField(
                            title: 'Location',
                            subtitleProvider: StateProvider<String>(
                                  (ref) =>
                              '${ref.watch(userUpdatedLatitudeProvider)} - ${ref.watch(userUpdatedLongitudeProvider)}',
                            ),
                            isEditingProvider: isEditingLocationProvider,
                            onChanged: (value) {
                              final parts = value.split(' - ');
                              if (parts.length == 2) {
                                final latitude = double.tryParse(parts[0].trim());
                                final longitude =
                                double.tryParse(parts[1].trim());
                                if (latitude != null && longitude != null) {
                                  ref
                                      .read(userUpdatedLatitudeProvider.notifier)
                                      .state = latitude.toString();
                                  ref
                                      .read(userUpdatedLongitudeProvider.notifier)
                                      .state = longitude.toString();
                                  _checkForChanges(ref);
                                }
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your location';
                              }
                              final parts = value.split(' - ');
                              if (parts.length != 2) {
                                return 'Enter coordinates in format: latitude - longitude';
                              }
                              final latitude = double.tryParse(parts[0].trim());
                              final longitude = double.tryParse(parts[1].trim());
                              if (latitude == null || longitude == null) {
                                return 'Coordinates must be valid numbers';
                              }
                              final isValidCoordinates =
                                  latitude.abs() <= 90 && longitude.abs() <= 180;
                              if (!isValidCoordinates) {
                                return 'Invalid latitude or longitude';
                              }
                              return null;
                            },
                            keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.location_on_rounded, size: 20),
                              onPressed: () async {
                                perm.PermissionStatus status =
                                await perm.Permission.location.status;
                                if (status.isGranted) {
                                  final location = loc.Location();
                                  final locationData = await location.getLocation();
                                  ref
                                      .read(userUpdatedLatitudeProvider.notifier)
                                      .state = locationData.latitude.toString();
                                  ref
                                      .read(userUpdatedLongitudeProvider.notifier)
                                      .state = locationData.longitude.toString();
                                  ref
                                      .read(isEditingLocationProvider.notifier)
                                      .state = false;
                                  _checkForChanges(ref);
                                } else if (status.isDenied ||
                                    status.isRestricted ||
                                    status.isLimited) {
                                  perm.PermissionStatus result =
                                  await perm.Permission.location.request();
                                  if (result.isGranted) {
                                    final location = loc.Location();
                                    final locationData =
                                    await location.getLocation();
                                    ref
                                        .read(userUpdatedLatitudeProvider.notifier)
                                        .state = locationData.latitude.toString();
                                    ref
                                        .read(
                                        userUpdatedLongitudeProvider.notifier)
                                        .state = locationData.longitude.toString();
                                    ref
                                        .read(isEditingLocationProvider.notifier)
                                        .state = false;
                                    _checkForChanges(ref);
                                  } else if (result.isPermanentlyDenied) {
                                    final opened = await perm.openAppSettings();
                                    if (opened) {
                                      Future.delayed(
                                        const Duration(seconds: 2),
                                            () async {
                                          final newStatus = await perm
                                              .Permission.location.status;
                                          if (newStatus.isGranted) {
                                            final location = loc.Location();
                                            final locationData =
                                            await location.getLocation();
                                            ref
                                                .read(userUpdatedLatitudeProvider
                                                .notifier)
                                                .state = locationData.latitude
                                                .toString();
                                            ref
                                                .read(
                                                userUpdatedLongitudeProvider
                                                    .notifier)
                                                .state = locationData.longitude
                                                .toString();
                                            ref
                                                .read(isEditingLocationProvider
                                                .notifier)
                                                .state = false;
                                            _checkForChanges(ref);
                                          }
                                        },
                                      );
                                    }
                                  }
                                }
                              },
                            ),
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
                          ),
                          EditablePersonalInfoField(
                            title: 'Qualification',
                            subtitleProvider: userUpdatedQualificationProvider,
                            isEditingProvider: isEditingQualificationProvider,
                            onChanged: (value) => ref
                                .read(userUpdatedQualificationProvider.notifier)
                                .state = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your qualification';
                              }
                              return null;
                            },
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
                          ),
                          EditablePersonalInfoField(
                            title: 'Years of Experience',
                            subtitleProvider: userUpdatedYearsOfExperienceProvider,
                            isEditingProvider: isEditingYearsOfExperienceProvider,
                            onChanged: (value) => ref
                                .read(userUpdatedYearsOfExperienceProvider.notifier)
                                .state = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter years of experience';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
                          ),
                          EditablePersonalInfoField(
                            title: 'Category',
                            subtitleProvider: userUpdatedCategoryProvider,
                            isEditingProvider: isEditingCategoryProvider,
                            onChanged: (value) => ref
                                .read(userUpdatedCategoryProvider.notifier)
                                .state = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your category';
                              }
                              return null;
                            },
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
                            isDropdown: true,
                            dropdownItems: AppStrings.docCategories,
                            dropdownLabel: 'Category',
                            dropdownValidatorText: 'Please select your category',
                          ),
                          EditablePersonalInfoField(
                            title: 'Hospital/Clinic',
                            subtitleProvider: userUpdatedHospitalProvider,
                            isEditingProvider: isEditingHospitalProvider,
                            onChanged: (value) => ref
                                .read(userUpdatedHospitalProvider.notifier)
                                .state = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your hospital or clinic name';
                              }
                              return null;
                            },
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
                          ),
                          EditablePersonalInfoField(
                            title: 'Consultation Fee',
                            subtitleProvider: StateProvider<String>(
                                  (ref) =>
                                  ref.watch(userUpdatedConsultationFeeProvider).toString(),
                            ),
                            isEditingProvider: isEditingConsultationFeeProvider,
                            onChanged: (value) {
                              final fee = int.tryParse(value);
                              if (fee != null) {
                                ref
                                    .read(userUpdatedConsultationFeeProvider.notifier)
                                    .state = fee;
                              }
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your consultation fee';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
                          ),

                          30.height,

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (hasChanges || profileImageState.croppedImage != null) ...[
                                CustomButtonWidget(
                                  text: isUpdating ? 'Updating...' : 'Save Changes',
                                  onPressed: isUpdating ? null : () {
                                    _saveChanges();
                                    ref.read(hasChangesProvider.notifier).state=false;
                                  },
                                  backgroundColor: AppColors.gradientGreen,
                                  textColor: Colors.white,
                                  borderRadius: 8,
                                  isLoading: isUpdating,
                                  width: ScreenUtil.scaleWidth(context, 150),
                                ),
                                CustomButtonWidget(
                                  text: 'Discard Changes',
                                  onPressed: isUpdating
                                      ? null
                                      : () {
                                    drawerHelpers.clearChanges(ref);
                                  },
                                  backgroundColor: AppColors.subTextColor,
                                  textColor: Colors.white,
                                  borderRadius: 8,
                                  width: ScreenUtil.scaleWidth(context, 150),
                                ),
                              ],
                            ],
                          ),
                          20.height,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gradientGreen),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}