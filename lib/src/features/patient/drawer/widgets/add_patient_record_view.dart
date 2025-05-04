import 'dart:io';
import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/app.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../../core/utils/upload_profile_image_to_cloudinary.dart';
import '../../../../shared/providers/check_internet_connectivity_provider.dart';
import '../../../../shared/widgets/custom_appbar_header_widget.dart';
import '../../../../shared/widgets/custom_button_widget.dart';
import '../../../../shared/widgets/custom_snackbar_widget.dart';
import '../../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../../shared/widgets/custom_text_widget.dart';
import '../../../../theme/app_colors.dart';
import '../../../../utils/screen_utils.dart';
import '../../providers/patient_providers.dart';
import '../providers/drawer_providers.dart';

class AddPatientRecordView extends ConsumerStatefulWidget {
  const AddPatientRecordView({super.key});

  @override
  ConsumerState<AddPatientRecordView> createState() => _AddRecordScreenState();
}

class _AddRecordScreenState extends ConsumerState<AddPatientRecordView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dateController = TextEditingController();
  final _nameFocusNode = FocusNode();
  final _dateFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final patient = ref.read(currentSignInPatientDataProvider).value;
      if (patient != null) {
        ref.read(patientNameProvider.notifier).state = patient.fullName;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    _nameFocusNode.dispose();
    _dateFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);
    if (pickedFile != null) {
      ref
          .read(selectedImagesProvider.notifier)
          .update((state) => [...state, File(pickedFile.path)]);
      Navigator.pop(context);
    }
  }

  Future<void> _showImagePickerBottomSheet() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          20.height,
          Row(
            children: [
              10.width,
              CustomTextWidget(
                text: 'Add a record',
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
                color: AppColors.subtextcolor,
              ),
            ),
            onTap: () => _pickImage(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library, size: 15),
            title: CustomTextWidget(
              text: 'Upload from gallery',
              textStyle: TextStyle(
                fontSize: FontSizes(context).size16,
                fontFamily: AppFonts.rubikMedium,
                color: AppColors.subtextcolor,
              ),
            ),
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          10.height,
        ],
      ),
    );
  }

  Future<void> _uploadRecords() async {
    final isUploading = ref.read(isUploadingProvider);
    if (isUploading) return;

    ref.read(isUploadingProvider.notifier).state = true;

    final hasInternet = await ref.read(checkInternetConnectionProvider.future);
    if (!hasInternet) {
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

    if (user == null || images.isEmpty || !_formKey.currentState!.validate()) {
      CustomSnackBarWidget.show(
        context: context,
        text: 'Please ensure all fields are valid and images are selected.',
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

    final databaseRef = FirebaseDatabase.instance
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

  @override
  Widget build(BuildContext context) {
    final selectedImages = ref.watch(selectedImagesProvider);
    final recordType = ref.watch(recordTypeProvider);
    final recordDate = ref.watch(recordDateProvider);
    final patientName = ref.watch(patientNameProvider);
    final isEditingDate = ref.watch(isEditingDateProvider);
    final isEditingName = ref.watch(isEditingNameProvider);
    final isUploading = ref.watch(isUploadingProvider);
    ref.listen(patientNameProvider, (previous, next) {
      _nameController.text = next;
    });
    ref.listen(recordDateProvider, (previous, next) {
      _dateController.text = DateFormat(
        'dd MMM, yyyy',
      ).format(DateTime.parse(next));
    });
    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 15.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomAppBarHeaderWidget(title: 'Add Record',),
                        20.height,
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Container(
                                width: 80,
                                height: 105,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: AppColors.gradientDarkGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: InkWell(
                                  onTap: _showImagePickerBottomSheet,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Colors.green,
                                        size: 30,
                                      ),
                                      SizedBox(height: 8),
                                      CustomTextWidget(
                                        text: 'Add more\nimages',
                                        textAlignment: TextAlign.center,
                                        textStyle: TextStyle(
                                          color: Colors.green,
                                          fontSize: 14,
                                          fontFamily: AppFonts.rubik,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              ...selectedImages.map(
                                    (image) => Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 105,
                                      margin: const EdgeInsets.only(right: 10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          image: FileImage(image),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 12,
                                      child: CircleAvatar(
                                        maxRadius: 10,
                                        backgroundColor: AppColors.grey,
                                        child: InkWell(
                                          child: const Icon(
                                            Icons.close,
                                            size: 15,
                                            color: AppColors.gradientGreen,
                                          ),
                                          onTap: () {
                                            ref
                                                .read(selectedImagesProvider.notifier)
                                                .update(
                                                  (state) =>
                                                  state
                                                      .where((i) => i != image)
                                                      .toList(),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  140.height,
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 2,
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomTextWidget(
                                    text:'Record for',
                                    textStyle: TextStyle(
                                      fontSize: FontSizes(context).size16,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      _nameFocusNode.requestFocus();
                                      ref.read(isEditingNameProvider.notifier).state=true;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child:isEditingName?CustomTextFormFieldWidget(
                                contentPadding: const EdgeInsets.only(left:10),
                                focusNode: _nameFocusNode,
                                initialValue: patientName,
                                validator: (value) =>
                                value!.isEmpty ? 'Name is required' : null,
                                onFieldSubmitted: (_) => ref
                                    .read(isEditingNameProvider.notifier)
                                    .state = false,
                                onChanged:(value)=> ref.read(patientNameProvider.notifier).state=value,
                              ) :CustomTextWidget(
                                text: patientName,
                                textStyle: TextStyle(
                                  fontSize: FontSizes(context).size18,
                                  color: AppColors.gradientGreen.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Divider(height: 1,indent: 20,endIndent: 20,),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextWidget(
                                    text:'Type of record',
                                    textStyle: TextStyle(
                                      fontSize: FontSizes(context).size16,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      _buildRecordTypeOption(
                                        'Report',
                                        Icons.assessment_outlined,
                                        recordType == 'Report',
                                        Colors.blue.shade700,
                                      ),
                                      const SizedBox(width: 10),
                                      _buildRecordTypeOption(
                                        'Prescription',
                                        Icons.medical_services_outlined,
                                        recordType == 'Prescription',
                                        Colors.green,
                                      ),
                                      const SizedBox(width: 10),
                                      _buildRecordTypeOption(
                                        'Invoice',
                                        Icons.receipt_outlined,
                                        recordType == 'Invoice',
                                        Colors.grey.shade700,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1,indent: 20,endIndent: 20,),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomTextWidget(
                                    text:'Record created on',
                                    textStyle: TextStyle(
                                      fontSize:FontSizes(context).size16 ,
                                      fontFamily: AppFonts.rubik,
                                      color: AppColors.black,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit,
                                      color: Colors.grey,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      ref.read(isEditingDateProvider.notifier).state = true;
                                      _dateFocusNode.requestFocus();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: isEditingDate
                                  ? CustomTextFormFieldWidget(
                                controller: _dateController,
                                focusNode: _dateFocusNode,
                                initialValue:DateFormat('dd MMM, yyyy').format(DateTime.parse(recordDate)) ,
                                onChanged: (value) {
                                  try {
                                    final date = DateFormat(
                                      'dd MMM, yyyy',
                                    ).parse(value);
                                    ref
                                        .read(recordDateProvider.notifier)
                                        .state = date.toIso8601String();
                                  } catch (e) {}
                                },
                                onFieldSubmitted: (_) => ref
                                    .read(isEditingDateProvider.notifier)
                                    .state = false,
                                validator: (value) =>
                                value!.isEmpty ? 'Date is required' : null,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              )
                                  : CustomTextWidget(
                                text:DateFormat('dd MMM, yyyy').format(DateTime.parse(recordDate)),
                                textStyle:  TextStyle(
                                  fontSize: FontSizes(context).size18,
                                  fontFamily: AppFonts.rubik,
                                  color: AppColors.gradientGreen,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            30.height,
                            Center(
                              child: CustomButtonWidget(
                                width:ScreenUtil.scaleWidth(context,270),
                                height:ScreenUtil.scaleHeight(context,54),
                                text: isUploading ? 'Uploading...' : 'Upload record',
                                onPressed:
                                selectedImages.isEmpty || isUploading ? null : _uploadRecords,
                                backgroundColor: Colors.green,
                                textColor: Colors.white,
                                borderRadius: 6,
                                isEnabled: selectedImages.isNotEmpty && !isUploading,
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
        ],
      ),
    );
  }

  Widget _buildRecordTypeOption(String type, IconData icon, bool isSelected, Color color) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (mounted) {
            ref.read(recordTypeProvider.notifier).state = type;
          }
        },
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.gradientGreen : AppColors.grey,
              size: 28,
            ),
            const SizedBox(height: 8),
            CustomTextWidget(
              text:type,
              textStyle: TextStyle(
                fontSize: FontSizes(context).size13,
                fontFamily: AppFonts.rubik,
                color: isSelected ? AppColors.gradientGreen : AppColors.grey,
                fontWeight: isSelected ? FontWeight.w400 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}