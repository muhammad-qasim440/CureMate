import 'dart:io';
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/drawer/widgets/patient_drawer_editable_personal_info_field_widget.dart';
import 'package:curemate/src/features/drawer/widgets/drawer_update_email_view_widget.dart';
import 'package:curemate/src/shared/providers/drop_down_provider/custom_drop_down_provider.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_centered_text_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import 'package:location/location.dart' as loc;
import '../../../../../const/font_sizes.dart';
import '../../../../const/app_strings.dart';
import '../../../shared/providers/profile_image_picker_provider/profile_image_picker_provider.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../patient/providers/patient_providers.dart';
import '../helpers/drawer_helpers.dart';
import '../providers/drawer_providers.dart';

final isUpdatingProfileProvider = StateProvider<bool>((ref) => false);
final hasChangesProvider = StateProvider<bool>((ref) => false);

class PatientDrawerProfileViewWidget extends ConsumerStatefulWidget {
  const PatientDrawerProfileViewWidget({super.key});

  @override
  ConsumerState<PatientDrawerProfileViewWidget> createState() =>
      _PatientDrawerProfileViewWidgetState();
}

class _PatientDrawerProfileViewWidgetState
    extends ConsumerState<PatientDrawerProfileViewWidget> {
  final DrawerHelpers drawerHelpers = DrawerHelpers();
  final Map<String, String> originalValues = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentSignInPatientDataProvider).value;
      if (user != null) {
        originalValues['name'] = user.fullName;
        originalValues['phone'] = user.phoneNumber;
        originalValues['city'] = user.city;
        originalValues['latitude'] = user.latitude.toString();
        originalValues['longitude'] = user.longitude.toString();
        originalValues['dob'] = user.dob;
        originalValues['age'] = user.age.toString();
        originalValues['gender'] = user.gender;

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
        if (ref.read(userUpdatedAgeProvider) == 0) {
          ref.read(userUpdatedAgeProvider.notifier).state = user.age;
        }
        if (ref.read(userUpdatedGenderProvider) == '') {
          ref.read(userUpdatedGenderProvider.notifier).state = user.gender;
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
        builder:
            (context) => UpdateEmailScreen(
              currentEmail: currentEmail,
              onUpdate: (newEmail, currentPassword, newPassword) async {
                await drawerHelpers.updateUserEmail(
                  context: context,
                  ref: ref,
                  newEmail: newEmail,
                  currentPassword: currentPassword,
                  newPassword: newPassword,
                  currentEmail: currentEmail,
                  isDoctor: false,
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
    final currentGender = ref.read(userUpdatedGenderProvider);
    final currentAge = ref.read(userUpdatedAgeProvider);
    final newProfileImage = ref.read(profileImagePickerProvider);

    final hasChanges =
        currentName != originalValues['name'] ||
        currentPhone != originalValues['phone'] ||
        currentCity != originalValues['city'] ||
        currentLatitude != originalValues['latitude'] ||
        currentLongitude != originalValues['longitude'] ||
        currentDob != originalValues['dob'] ||
        currentGender != originalValues['gender'] ||
        currentAge != int.tryParse(originalValues['age']!) ||
        newProfileImage.croppedImage != null;
    ref.read(hasChangesProvider.notifier).state = hasChanges;
  }

  void _saveChanges() async {
    await drawerHelpers.updatePatientProfile(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentSignInPatientDataProvider);
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
                                      'Update your profile to connect your doctor with\n better impression.',
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
                                                  )
                                                  as ImageProvider,
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
                                        onTap:
                                            isUpdating
                                                ? null
                                                : () {
                                                  drawerHelpers
                                                      .showImagePickerBottomSheet(
                                                        ref: ref,
                                                        context: context,
                                                        isProfileImagePicking:
                                                            true,
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
                            onEditPress:
                                isUpdating
                                    ? null
                                    : () =>
                                        _updateEmail(context, ref, user.email),
                          ),
                          EditablePersonalInfoField(
                            title: 'Name',
                            subtitleProvider: userUpdatedNameProvider,
                            isEditingProvider: isEditingNameProvider,
                            onChanged:
                                (value) =>
                                    ref
                                        .read(userUpdatedNameProvider.notifier)
                                        .state = value,
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
                            onChanged:
                                (value) =>
                                    ref
                                        .read(userUpdatedDOBProvider.notifier)
                                        .state = value,
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
                            title: 'Age',
                            subtitleProvider: userUpdatedAgeProvider,
                            isEditingProvider: isEditingAgeProvider,
                            onChanged:
                                (value) =>
                                    ref
                                        .read(userUpdatedAgeProvider.notifier)
                                        .state = int.tryParse(value)!,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your age';
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
                            title: 'Gender',
                            subtitleProvider: userUpdatedGenderProvider,
                            isEditingProvider: isEditingGenderProvider,
                            onChanged: (value) => ref
                                .read(userUpdatedGenderProvider.notifier)
                                .state = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your gender';
                              }
                              return null;
                            },
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
                            isDropdown: true,
                            dropdownItems: AppStrings.genders,
                            dropdownLabel: 'Gender',
                            dropdownValidatorText: 'Please select your gender',
                          ),

                          EditablePersonalInfoField(
                            title: 'Contact Number',
                            subtitleProvider: userUpdatedPhoneNumberProvider,
                            isEditingProvider: isEditingPhoneNumberProvider,
                            onChanged:
                                (value) =>
                                    ref
                                        .read(
                                          userUpdatedPhoneNumberProvider
                                              .notifier,
                                        )
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
                            onChanged:
                                (value) =>
                                    ref
                                        .read(userUpdatedCityProvider.notifier)
                                        .state = value,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your city';
                              }
                              return null;
                            },
                            isEnabled: !isUpdating,
                            onChangeDetected: () {
                              _checkForChanges(ref);
                            },
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
                                final latitude = double.tryParse(
                                  parts[0].trim(),
                                );
                                final longitude = double.tryParse(
                                  parts[1].trim(),
                                );
                                if (latitude != null && longitude != null) {
                                  ref
                                      .read(
                                        userUpdatedLatitudeProvider.notifier,
                                      )
                                      .state = latitude.toString();
                                  ref
                                      .read(
                                        userUpdatedLongitudeProvider.notifier,
                                      )
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
                              final longitude = double.tryParse(
                                parts[1].trim(),
                              );
                              if (latitude == null || longitude == null) {
                                return 'Coordinates must be valid numbers';
                              }
                              final isValidCoordinates =
                                  latitude.abs() <= 90 &&
                                  longitude.abs() <= 180;
                              if (!isValidCoordinates) {
                                return 'Invalid latitude or longitude';
                              }
                              return null;
                            },
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            suffixIcon: IconButton(
                              icon: const Icon(
                                Icons.location_on_rounded,
                                size: 20,
                              ),
                              onPressed: () async {
                                perm.PermissionStatus status =
                                    await perm.Permission.location.status;
                                if (status.isGranted) {
                                  final location = loc.Location();
                                  final locationData =
                                      await location.getLocation();
                                  ref
                                      .read(
                                        userUpdatedLatitudeProvider.notifier,
                                      )
                                      .state = locationData.latitude.toString();
                                  ref
                                      .read(
                                        userUpdatedLongitudeProvider.notifier,
                                      )
                                      .state = locationData.longitude
                                          .toString();
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
                                        .read(
                                          userUpdatedLatitudeProvider.notifier,
                                        )
                                        .state = locationData.latitude
                                            .toString();
                                    ref
                                        .read(
                                          userUpdatedLongitudeProvider.notifier,
                                        )
                                        .state = locationData.longitude
                                            .toString();
                                    ref
                                        .read(
                                          isEditingLocationProvider.notifier,
                                        )
                                        .state = false;
                                    _checkForChanges(ref);
                                  } else if (result.isPermanentlyDenied) {
                                    final opened = await perm.openAppSettings();
                                    if (opened) {
                                      Future.delayed(
                                        const Duration(seconds: 2),
                                        () async {
                                          final newStatus =
                                              await perm
                                                  .Permission
                                                  .location
                                                  .status;
                                          if (newStatus.isGranted) {
                                            final location = loc.Location();
                                            final locationData =
                                                await location.getLocation();
                                            ref
                                                .read(
                                                  userUpdatedLatitudeProvider
                                                      .notifier,
                                                )
                                                .state = locationData.latitude
                                                    .toString();
                                            ref
                                                .read(
                                                  userUpdatedLongitudeProvider
                                                      .notifier,
                                                )
                                                .state = locationData.longitude
                                                    .toString();
                                            ref
                                                .read(
                                                  isEditingLocationProvider
                                                      .notifier,
                                                )
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
                          30.height,

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              if (hasChanges ||
                                  profileImageState.croppedImage != null) ...[
                                CustomButtonWidget(
                                  text:
                                      isUpdating
                                          ? 'Updating...'
                                          : 'Save Changes',
                                  onPressed:
                                      isUpdating
                                          ? null
                                          : () {
                                            _saveChanges();
                                            ref
                                                .read(
                                                  hasChangesProvider.notifier,
                                                )
                                                .state = false;
                                          },
                                  backgroundColor: AppColors.gradientGreen,
                                  textColor: Colors.white,
                                  borderRadius: 8,
                                  isLoading: isUpdating,
                                  width: ScreenUtil.scaleWidth(context, 150),
                                ),
                                CustomButtonWidget(
                                  text: 'Discard Changes',
                                  onPressed:
                                      isUpdating
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
        loading:
            () => const Center(
              child: CircularProgressIndicator(color: AppColors.gradientGreen),
            ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class PersonalInfoCardsWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback? onEditPress;

  const PersonalInfoCardsWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.onEditPress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: ScreenUtil.scaleWidth(context, 320),
      height: ScreenUtil.scaleHeight(context, 60),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        shape: BoxShape.rectangle,
        color: AppColors.gradientWhite,
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: ScreenUtil.scaleWidth(context, 20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomTextWidget(
                    text: title,
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: FontSizes(context).size12,
                      color: AppColors.gradientGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  CustomTextWidget(
                    text: subtitle,
                    textStyle: TextStyle(
                      fontFamily: AppFonts.rubik,
                      fontSize: FontSizes(context).size16,
                      color: AppColors.subTextColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (onEditPress != null)
            IconButton(
              icon: const Icon(
                Icons.edit,
                color: AppColors.subTextColor,
                size: 20,
              ),
              onPressed: onEditPress,
            ),
        ],
      ),
    );
  }
}
