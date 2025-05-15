import 'dart:io';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../../core/utils/upload_profile_image_to_cloudinary.dart';
import '../../../router/nav.dart';
import '../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../shared/providers/profile_image_picker_provider/profile_image_picker_provider.dart';
import '../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../doctor/providers/doctor_providers.dart';
import '../../patient/providers/patient_providers.dart';
import '../providers/drawer_providers.dart';
import '../widgets/patient_drawer_profile_view_widget.dart';
import '../widgets/patient_drawer_show_full_screen_image_widget.dart';
import '../widgets/drawer_update_email_view_widget.dart';

class DrawerHelpers {
  Future<void> clickORPickMultiImages({
    required WidgetRef ref,
    required StateProvider<List<File>> provider,
    required ImageSource source,
  }) async {if (source == ImageSource.camera) {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        ref
            .read(provider.notifier)
            .update((state) => [...state, File(pickedFile.path)]);
      }
    } else {final result = await FilePicker.platform.pickFiles(type: FileType.image, allowMultiple: true,);if (result != null && result.paths.isNotEmpty)
    {final files = result.paths.map((path) => File(path!)).toList();
      ref.read(provider.notifier).update((state) => [...state, ...files]);}}
  AppNavigation.pop();}
  Future<void> pickSingleImage(WidgetRef ref, BuildContext context, ImageSource source, StateProvider<File?> provider,) async {
    final file = await ImagePicker().pickImage(source: source);
    if (file != null) {
      ref.read(provider.notifier).state = File(file.path);
    }
    else {
      CustomSnackBarWidget.show(context: context, text: 'Please Pick Your Profile Image',);
    }
    AppNavigation.pop();
  }
  Future<void> uploadNewImages(WidgetRef ref, StateProvider<List<File>> provider, List<Map<String, String>> images, String recordId,) async {final newImagesToUpload = ref.read(provider);if (newImagesToUpload.isEmpty) return;List<Map<String, String>> imageDetails = [];
    for (var image in newImagesToUpload) {
      final result = await uploadImageToCloudinary(image);
      if (result != null) {
        imageDetails.add({
          'url': result['secure_url']!,
          'public_id': result['public_id']!,
        });
      }
    }

    if (imageDetails.isNotEmpty) {
      final updatedImages = [...images, ...imageDetails];
      await FirebaseDatabase.instance
          .ref()
          .child('Patients')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('MedicalRecords')
          .child(recordId)
          .update({'images': updatedImages});
    }

    ref.read(provider.notifier).state = [];
  }
  Future<void> deleteSelectedImages(
    WidgetRef ref,
    Set<int> selectedIndices,
    List<Map<String, String>> images,
    String recordId,
  ) async {final imagesToDelete = selectedIndices.map((index) => images[index]).toList();for (var image in imagesToDelete) {await deleteImageFromCloudinary(image['public_id']!);}final updatedImages = images.asMap().entries.where((entry) => !selectedIndices.contains(entry.key)).map((entry) => entry.value).toList();await FirebaseDatabase.instance.ref().child('Patients').child(FirebaseAuth.instance.currentUser!.uid).child('MedicalRecords').child(recordId).update({'images': updatedImages});}
  Future<void> deleteRecord(List<Map<String, String>> images, String recordId,) async {if (images.isNotEmpty) {for (var image in images) {await deleteImageFromCloudinary(image['public_id']!);}}await FirebaseDatabase.instance.ref().child('Patients').child(FirebaseAuth.instance.currentUser!.uid).child('MedicalRecords').child(recordId).remove();}
  Future<void> showImagePickerBottomSheet({required WidgetRef ref,
    required BuildContext context,
    StateProvider<List<File>>? multiImageProvider,
    StateProvider<File?>? singleImageProvider,
    bool isSingleImagePicking = false,
    bool isProfileImagePicking = false,
  }) async {
    final notifier = ref.read(profileImagePickerProvider.notifier);showModalBottomSheet(context: context, showDragHandle: true, builder:
          (context) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              20.height,
              Row(
                children: [
                  10.width,
                  CustomTextWidget(
                    text:
                        isProfileImagePicking
                            ? 'Select Image Source'
                            : 'Add more images',
                    textStyle: TextStyle(
                      fontSize: FontSizes(context).size22,
                      fontFamily: AppFonts.rubikMedium,
                      color: AppColors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, size: 15),
                title: CustomTextWidget(
                  text: 'Take a photo',
                  textStyle: TextStyle(
                    fontSize: FontSizes(context).size16,
                    fontFamily: AppFonts.rubik,
                    color: AppColors.subTextColor,
                  ),
                ),
                onTap: () async {
                  if (isSingleImagePicking) {
                    if (singleImageProvider != null) {
                      pickSingleImage(
                        ref,
                        context,
                        ImageSource.camera,
                        singleImageProvider,
                      );
                    }
                  } else if (isProfileImagePicking) {
                    AppNavigation.pop(context);
                    await notifier.pickImage(ref: ref, source: ImageSource.camera);
                  } else {
                    if (multiImageProvider != null) {
                      clickORPickMultiImages(
                        ref: ref,
                        source: ImageSource.camera,
                        provider: multiImageProvider,
                      );
                    }
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library, size: 15),
                title: CustomTextWidget(
                  text: 'Upload from gallery',
                  textStyle: TextStyle(
                    fontSize: FontSizes(context).size16,
                    fontFamily: AppFonts.rubikMedium,
                    color: AppColors.subTextColor,
                  ),
                ),
                onTap: () async {
                  if (isSingleImagePicking) {
                    if (singleImageProvider != null) {
                      pickSingleImage(
                        ref,
                        context,
                        ImageSource.gallery,
                        singleImageProvider,
                      );
                    }
                  }else if (isProfileImagePicking) {
                    AppNavigation.pop(context);

                   await notifier.pickImage(ref:ref,source: ImageSource.gallery);

                  }  else {
                    if (multiImageProvider != null) {
                      clickORPickMultiImages(
                        ref: ref,
                        source: ImageSource.gallery,
                        provider: multiImageProvider,
                      );
                    }
                  }
                },
              ),
              if (ref.read(profileImagePickerProvider).croppedImage != null)
                ListTile(
                  leading: const Icon(Icons.delete),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    notifier.reset(ref);
                  },
                ),
              10.height,
            ],
          ),
    );
  }
  void showFullScreenImage(
    WidgetRef ref,
    BuildContext context,
    int index,
    List<Map<String, String>> images,
  ) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) =>
                PatientDrawerShowFullScreenImageWidget(
                  images: List<String>.from(
                    images.map((img) => img['url'] ?? ''),
                  ),
                  initialIndex: index,
                  onDelete: () {
                    ref.read(selectedIndicesProvider.notifier).state = {};
                    ref.read(selectionModeProvider.notifier).state = false;
                  },
                ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = 0.0;
          const end = 1.0;
          const curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var opacityAnimation = animation.drive(tween);
          return FadeTransition(opacity: opacityAnimation, child: child);
        },
      ),
    );
  }
  Future<void> uploadRecords(
    WidgetRef ref,
    BuildContext context,
    GlobalKey<FormState> formKey,
  ) async {final isUploading = ref.read(isUploadingProvider);if (isUploading) return;ref.read(isUploadingProvider.notifier).state = true;final hasInternet = await ref.read(checkInternetConnectionProvider.future);if (!hasInternet) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'No internet connection. Please check your network.',
      );
      ref.read(isUploadingProvider.notifier).state = false;
      return;
    }
    final images = ref.read(selectedImagesProvider);
    final recordType = ref.read(recordTypeProvider);
    final recordDate = ref.read(recordDateProvider);
    final patientName = ref.read(patientNameProvider);
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || images.isEmpty || !formKey.currentState!.validate()) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'Please ensure all fields are valid and images are added.',
      );
      ref.read(isUploadingProvider.notifier).state = false;
      return;
    }

    List<Map<String, String>> imageDetails = [];
    for (var image in images) {
      final result = await uploadImageToCloudinary(image);
      if (result != null) {
        imageDetails.add({
          'url': result['secure_url']!,
          'public_id': result['public_id']!,
        });
      } else {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Failed to upload one or more images.',
        );
      }
    }

    if (imageDetails.isEmpty) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'No images were successfully uploaded.',
      );
      ref.read(isUploadingProvider.notifier).state = false;
      return;
    }

    final databaseRef =
        FirebaseDatabase.instance
            .ref()
            .child('Patients')
            .child(user.uid)
            .child('MedicalRecords')
            .push();
    await databaseRef.set({
      'patientName': patientName,
      'type': recordType,
      'images': imageDetails,
      'createdAt': recordDate,
    });

    ref.read(selectedImagesProvider.notifier).state = [];
    ref.read(recordTypeProvider.notifier).state = 'Prescription';
    ref.read(recordDateProvider.notifier).state =
        DateTime.now().toIso8601String();
    ref.read(isUploadingProvider.notifier).state = false;
    Navigator.pop(context);
  }
  Future<void> updatePatientProfile(BuildContext context, WidgetRef ref) async {
    final isUpdating = ref.read(isUpdatingProfileProvider);
    if (isUpdating) return;

    ref.read(isUpdatingProfileProvider.notifier).state = true;

    final hasInternet = await ref.read(checkInternetConnectionProvider.future);
    if (!hasInternet) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'No internet connection. Please check your network.',
      );
      ref.read(isUpdatingProfileProvider.notifier).state = false;
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'User not authenticated.',
      );
      ref.read(isUpdatingProfileProvider.notifier).state = false;
      return;
    }

    final userData = ref.read(currentSignInPatientDataProvider).value;
    if (userData == null) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'User data not available.',
      );
      ref.read(isUpdatingProfileProvider.notifier).state = false;
      return;
    }

    final currentName = ref.read(userUpdatedNameProvider);
    final currentPhone = ref.read(userUpdatedPhoneNumberProvider);
    final currentCity = ref.read(userUpdatedCityProvider);
    final currentLatitude = ref.read(userUpdatedLatitudeProvider);
    final currentLongitude = ref.read(userUpdatedLongitudeProvider);
    final currentDob = ref.read(userUpdatedDOBProvider);

    Map<String, dynamic> updatedData = {};
    if (currentName != userData.fullName) updatedData['fullName'] = currentName;
    if (currentPhone != userData.phoneNumber) updatedData['phoneNumber'] = currentPhone;
    if (currentCity != userData.city) updatedData['city'] = currentCity;
    if (currentLatitude != userData.latitude.toString()) updatedData['latitude'] = currentLatitude;
    if (currentLongitude != userData.longitude.toString()) updatedData['longitude'] = currentLongitude;
    if (currentDob != userData.dob) updatedData['dob'] = currentDob;

    final profileImageState = ref.read(profileImagePickerProvider);
    if (profileImageState.croppedImage != null) {
      if (userData.profileImagePublicId.isNotEmpty) {
        await deleteImageFromCloudinary(userData.profileImagePublicId);
      }
      final result = await uploadImageToCloudinary(
        File(profileImageState.croppedImage!.path),
      );
      if (result != null) {
        updatedData['profileImageUrl'] = result['secure_url'];
        updatedData['profileImagePublicId'] = result['public_id'];
      } else {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Failed to upload new profile image.',
        );
        clearChanges(ref);
        return;
      }
    }
    if (updatedData.isEmpty && profileImageState.croppedImage == null) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'No changes to save.',
      );
      clearChanges(ref);

      return;
    }
    await FirebaseDatabase.instance
        .ref()
        .child('Patients')
        .child(user.uid)
        .update(updatedData);

    Map<String, dynamic> userUpdates = {};
    if (updatedData.containsKey('fullName') && updatedData['fullName'] != null) {
      userUpdates['fullName'] = updatedData['fullName'];
    }

    if (updatedData.containsKey('profileImageUrl') && updatedData['profileImageUrl'] != null) {
      userUpdates['profileImageUrl'] = updatedData['profileImageUrl'];
    }

    if (userUpdates.isNotEmpty) {
      await FirebaseDatabase.instance.ref().child('Users').child(user.uid).update(userUpdates);
    }


    if (profileImageState.croppedImage != null) {
      ref.read(profileImagePickerProvider.notifier).reset(ref);
    }

    CustomSnackBarWidget.show(
      context: context,
      text: 'Profile updated successfully.',
    );
    clearChanges(ref);

  }
  Future<void> updateUserEmail({
    required BuildContext context,
    required WidgetRef ref,
    required String newEmail,
    required String currentPassword,
    required String newPassword,
    required String currentEmail,
    required bool isDoctor,
  }) async {
    final isUpdating = ref.read(isUpdatingProfileProvider);
    if (isUpdating) return;

    ref.read(isUpdatingProfileProvider.notifier).state = true;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'User not authenticated.',
      );
      ref.read(isUpdatingProfileProvider.notifier).state = false;
      return;
    }
    final hasInternet = await ref.read(checkInternetConnectionProvider.future);
    if (!hasInternet) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'No internet connection. Please check your network.',
      );
      ref.read(isUpdatingProfileProvider.notifier).state = false;
      return;
    }

    try {
      final credential = EmailAuthProvider.credential(
        email: currentEmail,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      await user.verifyBeforeUpdateEmail(newEmail);

      if (newPassword.isNotEmpty) {
        await user.updatePassword(newPassword);
      }

      if(isDoctor){
        await FirebaseDatabase.instance
            .ref()
            .child('Doctors')
            .child(user.uid)
            .update({'email': newEmail});
      }
      else{
        await FirebaseDatabase.instance
            .ref()
            .child('Patients')
            .child(user.uid)
            .update({'email': newEmail});
      }


      final userRef = FirebaseDatabase.instance.ref().child('Users').child(user.uid);
      final snapshot = await userRef.child('email').get();

      if (snapshot.exists && snapshot.value != newEmail) {
        await userRef.update({'email': newEmail});
      }

      CustomSnackBarWidget.show(
        context: context,
        text: 'Email and password updated successfully. Please verify your new email.',
      );
      ref.refresh(updateEmailProvider);

    } catch (e) {
      String errorMessage;
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'wrong-password':
            errorMessage = 'Incorrect current password.';
            break;
          case 'email-already-in-use':
            errorMessage = 'The new email is already in use.';
            break;
          case 'requires-recent-login':
            errorMessage = 'Please log in again to update your email or password.';
            break;
          default:
            errorMessage = 'Failed to update: ${e.message}';
        }
      } else {
        errorMessage = 'Failed to update: ${e.toString()}';
      }
      CustomSnackBarWidget.show(
        context: context,
        text: errorMessage,
      );
    } finally {
      ref.read(isUpdatingProfileProvider.notifier).state = false;
    }
  }
  Future<void> updateDoctorProfile(BuildContext context, WidgetRef ref) async {
    final isUpdating = ref.read(isUpdatingProfileProvider);
    if (isUpdating) return;

    ref.read(isUpdatingProfileProvider.notifier).state = true;

    final hasInternet = await ref.read(checkInternetConnectionProvider.future);
    if (!hasInternet) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'No internet connection. Please check your network.',
      );
      ref.read(isUpdatingProfileProvider.notifier).state = false;
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'User not authenticated.',
      );
      ref.read(isUpdatingProfileProvider.notifier).state = false;
      return;
    }

    final userData = ref.read(currentSignInDoctorDataProvider).value;
    if (userData == null) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'User data not available.',
      );
      ref.read(isUpdatingProfileProvider.notifier).state = false;
      return;
    }

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

    Map<String, dynamic> updatedData = {};
    if (currentName != userData.fullName) updatedData['fullName'] = currentName;
    if (currentPhone != userData.phoneNumber) updatedData['phoneNumber'] = currentPhone;
    if (currentCity != userData.city) updatedData['city'] = currentCity;
    if (currentLatitude != userData.latitude.toString()) updatedData['latitude'] = currentLatitude;
    if (currentLongitude != userData.longitude.toString()) updatedData['longitude'] = currentLongitude;
    if (currentDob != userData.dob) updatedData['dob'] = currentDob;
    if (currentQualification != userData.qualification) updatedData['qualification'] = currentQualification;
    if (currentYearsOfExperience != userData.yearsOfExperience) updatedData['yearsOfExperience'] = currentYearsOfExperience;
    if (currentCategory != userData.category) updatedData['category'] = currentCategory;
    if (currentHospital != userData.hospital) updatedData['hospital'] = currentHospital;
    if (currentConsultationFee != userData.consultationFee) updatedData['consultationFee'] = currentConsultationFee;

    final profileImageState = ref.read(profileImagePickerProvider);
    if (profileImageState.croppedImage != null) {
      if (userData.profileImagePublicId.isNotEmpty) {
        await deleteImageFromCloudinary(userData.profileImagePublicId);
      }
      final result = await uploadImageToCloudinary(
        File(profileImageState.croppedImage!.path),
      );
      if (result != null) {
        updatedData['profileImageUrl'] = result['secure_url'];
        updatedData['profileImagePublicId'] = result['public_id'];
      } else {
        CustomSnackBarWidget.show(
          context: context,
          text: 'Failed to upload new profile image.',
        );
        clearChanges(ref);
        return;
      }
    }

    if (updatedData.isEmpty && profileImageState.croppedImage == null) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'No changes to save.',
      );
      clearChanges(ref);
      return;
    }

    await FirebaseDatabase.instance
        .ref()
        .child('Doctors')
        .child(user.uid)
        .update(updatedData);

    Map<String, dynamic> userUpdates = {};
    if (updatedData.containsKey('fullName') && updatedData['fullName'] != null) {
      userUpdates['fullName'] = updatedData['fullName'];
    }
    if (updatedData.containsKey('profileImageUrl') && updatedData['profileImageUrl'] != null) {
      userUpdates['profileImageUrl'] = updatedData['profileImageUrl'];
    }

    if (userUpdates.isNotEmpty) {
      await FirebaseDatabase.instance
          .ref()
          .child('Users')
          .child(user.uid)
          .update(userUpdates);
    }

    if (profileImageState.croppedImage != null) {
      ref.read(profileImagePickerProvider.notifier).reset(ref);
    }

    CustomSnackBarWidget.show(
      context: context,
      text: 'Profile updated successfully.',
    );
    clearChanges(ref);
  }
  void clearChanges(WidgetRef ref) {
    final patient = ref.read(currentSignInPatientDataProvider).value;
    final doctor = ref.read(currentSignInDoctorDataProvider).value;

    if (patient != null) {
      ref.read(userUpdatedNameProvider.notifier).state = patient.fullName;
      ref.read(userUpdatedPhoneNumberProvider.notifier).state = patient.phoneNumber;
      ref.read(userUpdatedCityProvider.notifier).state = patient.city;
      ref.read(userUpdatedLatitudeProvider.notifier).state = patient.latitude.toString();
      ref.read(userUpdatedLongitudeProvider.notifier).state = patient.longitude.toString();
      ref.read(userUpdatedDOBProvider.notifier).state = patient.dob;
      ref.read(profileImagePickerProvider.notifier).reset(ref);
    } else if (doctor != null) {
      ref.read(userUpdatedNameProvider.notifier).state = doctor.fullName;
      ref.read(userUpdatedPhoneNumberProvider.notifier).state = doctor.phoneNumber;
      ref.read(userUpdatedCityProvider.notifier).state = doctor.city;
      ref.read(userUpdatedLatitudeProvider.notifier).state = doctor.latitude.toString();
      ref.read(userUpdatedLongitudeProvider.notifier).state = doctor.longitude.toString();
      ref.read(userUpdatedDOBProvider.notifier).state = doctor.dob;
      ref.read(userUpdatedQualificationProvider.notifier).state = doctor.qualification;
      ref.read(userUpdatedYearsOfExperienceProvider.notifier).state = doctor.yearsOfExperience;
      ref.read(userUpdatedCategoryProvider.notifier).state = doctor.category;
      ref.read(userUpdatedHospitalProvider.notifier).state = doctor.hospital;
      ref.read(userUpdatedConsultationFeeProvider.notifier).state = doctor.consultationFee;
      ref.read(profileImagePickerProvider.notifier).reset(ref);
    }

    ref.read(hasChangesProvider.notifier).state = false;
    ref.read(isUpdatingProfileProvider.notifier).state = false;
  }
}
