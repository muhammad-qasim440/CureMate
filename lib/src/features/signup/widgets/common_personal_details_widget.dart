import 'package:curemate/extentions/widget_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart' as perm;
import '../../../../const/app_fonts.dart';
import '../../../../const/app_strings.dart';
import '../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_drop_down_menu_widget.dart';
import '../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../theme/app_colors.dart';
import '../providers/signup_form_provider.dart';

class CommonPersonalDetailsWidget extends ConsumerStatefulWidget {
  const CommonPersonalDetailsWidget({super.key});

  @override
  ConsumerState<CommonPersonalDetailsWidget> createState() => _CommonPersonalDetailsWidgetState();
}

class _CommonPersonalDetailsWidgetState extends ConsumerState<CommonPersonalDetailsWidget> {
  final FocusNode nameFocus = FocusNode();
  final FocusNode phoneFocus = FocusNode();
  final FocusNode dobFocus = FocusNode();
  final FocusNode locationFocus = FocusNode();
  final dateOfBirthController = TextEditingController();
  final locationController = TextEditingController();
  final Location _location=Location();

  @override
  void dispose() {
    nameFocus.dispose();
    phoneFocus.dispose();
    dobFocus.dispose();
    locationFocus.dispose();
    dateOfBirthController.dispose();
    locationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomTextFormFieldWidget(
          label: 'Full Name',
          hintText: 'Enter your full name',
          focusNode: nameFocus,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
          onChanged:
              (value) => ref.read(fullNameProvider.notifier).state = value,
          keyboardType: TextInputType.name,
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w400,
            fontSize: FontSizes(context).size14,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: AppFonts.rubik,
            color: AppColors.subtextcolor,
          ),
        ),
        23.height,
        // Phone Number
        CustomTextFormFieldWidget(
          label: 'Phone Number',
          hintText: '03XXXXXXXXX',
          focusNode: phoneFocus,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a phone number';
            } else if(value.length<11){
              return 'Phone number should be of 11 digits';
            }
            return null;
          },
          onChanged:
              (value) => ref.read(phoneNumberProvider.notifier).state = value,
          keyboardType: TextInputType.phone,
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w400,
            fontSize: FontSizes(context).size14,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: AppFonts.rubik,
            color: AppColors.subtextcolor,
          ),
        ),
        23.height,
        // Date of Birth
        CustomTextFormFieldWidget(
          controller: dateOfBirthController,
          label: 'Date of Birth',
          hintText: 'DD/MM/YYYY',
          focusNode: dobFocus,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your date of birth';
            }
            return null;
          },
          onChanged: (value){
            ref.read(dateOfBirthProvider.notifier).state=value;
          },
          keyboardType: TextInputType.datetime,
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w400,
            fontSize: FontSizes(context).size14,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: AppFonts.rubik,
            color: AppColors.subtextcolor,
          ),
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
                final formattedDate = "${picked.day}/${picked.month}/${picked.year}";
                ref.read(dateOfBirthProvider.notifier).state = formattedDate;
                dateOfBirthController.text = formattedDate;
              }
            },
          ),
        ),
        23.height,
        // city
        const CustomDropdown(
          items: AppStrings.cities,
          label: 'City',
          validatorText: 'please select your city',
        ),
        23.height,
        CustomTextFormFieldWidget(
          controller: locationController,
          label: 'Location',
          hintText: 'your location(latitude,longitude',
          focusNode: locationFocus,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your location';
            }
            return null;
          },
          keyboardType: TextInputType.streetAddress,
          textStyle: TextStyle(
            fontFamily: AppFonts.rubik,
            fontWeight: FontWeight.w400,
            fontSize: FontSizes(context).size14,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: AppColors.grey),
          ),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
            fontFamily: AppFonts.rubik,
            color: AppColors.subtextcolor,
          ),
          onChanged: (value)=>locationController.text=value,
          suffixIcon: IconButton(
            icon: const Icon(Icons.location_on_rounded, size: 20),
            onPressed: () async {
              perm.PermissionStatus status = await perm.Permission.location.status;

              if (status.isGranted) {
                final locationData = await _location.getLocation();
                locationController.text = '${locationData.latitude} - ${locationData.longitude}';
                ref.read(locationLatitudeProvider.notifier).state = locationData.latitude!;
                ref.read(locationLongitudeProvider.notifier).state = locationData.longitude!;
              } else if (status.isDenied || status.isRestricted || status.isLimited) {
                perm.PermissionStatus result = await perm.Permission.location.request();

                if (result.isGranted) {
                  final locationData = await _location.getLocation();
                  locationController.text = '${locationData.latitude} - ${locationData.longitude}';
                  ref.read(locationLatitudeProvider.notifier).state = locationData.latitude!;
                  ref.read(locationLongitudeProvider.notifier).state = locationData.longitude!;
                } else if (result.isPermanentlyDenied) {
                  final opened = await perm.openAppSettings();
                  if (opened) {
                    Future.delayed(const Duration(seconds: 2), () async {
                      final newStatus = await perm.Permission.location.status;
                      if (newStatus.isGranted) {
                        final locationData = await _location.getLocation();
                        locationController.text = '${locationData.latitude} - ${locationData.longitude}';
                        ref.read(locationLatitudeProvider.notifier).state = locationData.latitude!;
                        ref.read(locationLongitudeProvider.notifier).state = locationData.longitude!;
                      }
                    });
                  }
                }
              }
            },


          ),
        ),

      ],
    );
  }
}
