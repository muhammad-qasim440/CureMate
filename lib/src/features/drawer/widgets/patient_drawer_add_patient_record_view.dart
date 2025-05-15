import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../shared/widgets/custom_alert_dialog_widget.dart';
import '../../../shared/widgets/custom_appbar_header_widget.dart';
import '../../../shared/widgets/custom_button_widget.dart';
import '../../../shared/widgets/custom_text_form_field_widget.dart';
import '../../../shared/widgets/custom_text_widget.dart';
import '../../../theme/app_colors.dart';
import '../../../utils/screen_utils.dart';
import '../../patient/providers/patient_providers.dart';
import '../helpers/drawer_helpers.dart';
import '../providers/drawer_providers.dart';

class PatientDrawerAddPatientRecordView extends ConsumerStatefulWidget {
  const PatientDrawerAddPatientRecordView({super.key});

  @override
  ConsumerState<PatientDrawerAddPatientRecordView> createState() => _PatientDrawerAddPatientRecordViewState();
}

class _PatientDrawerAddPatientRecordViewState extends ConsumerState<PatientDrawerAddPatientRecordView> {
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(ref.read(recordDateProvider)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDate = DateFormat('dd MMM, yyyy').format(picked);
      _dateController.text = formattedDate;
      ref.read(recordDateProvider.notifier).state = picked.toIso8601String();
      ref.read(isEditingDateProvider.notifier).state = false;
    }
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
    final drawerHelpers = DrawerHelpers();

    ref.listen(patientNameProvider, (previous, next) {
      _nameController.text = next;
    });
    ref.listen(recordDateProvider, (previous, next) {
      _dateController.text = DateFormat('dd MMM, yyyy').format(DateTime.parse(next));
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
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CustomAppBarHeaderWidget(title: 'Add Record'),
                            150.width,
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => const CustomInfoDialogWidget(
                                    title: 'Record Upload Information',
                                    message: 'You can only upload images of prescriptions or medical reports etc.\n\nPDFs, videos, or other file types are not supported.',
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.info,
                                color: AppColors.gradientGreen,
                              ),
                            ),
                          ],
                        ),
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
                                  onTap: () {
                                    drawerHelpers.showImagePickerBottomSheet(
                                      ref:ref,
                                      context:context,
                                      multiImageProvider: selectedImagesProvider,
                                    );
                                  },
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
                                            ref.read(selectedImagesProvider.notifier).update(
                                                  (state) => state.where((i) => i != image).toList(),
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
                                    text: 'Record for',
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
                                      ref.read(isEditingNameProvider.notifier).state = true;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: isEditingName
                                  ? CustomTextFormFieldWidget(
                                contentPadding: const EdgeInsets.only(left: 10),
                                focusNode: _nameFocusNode,
                                initialValue: patientName,
                                validator: (value) => value!.isEmpty ? 'Name is required' : null,
                                onFieldSubmitted: (_) => ref.read(isEditingNameProvider.notifier).state = false,
                                onChanged: (value) => ref.read(patientNameProvider.notifier).state = value,
                              )
                                  : CustomTextWidget(
                                text: patientName,
                                textStyle: TextStyle(
                                  fontSize: FontSizes(context).size18,
                                  color: AppColors.gradientGreen.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Divider(height: 1, indent: 20, endIndent: 20),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CustomTextWidget(
                                    text: 'Type of record',
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
                            const Divider(height: 1, indent: 20, endIndent: 20),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  CustomTextWidget(
                                    text: 'Record created on',
                                    textStyle: TextStyle(
                                      fontSize: FontSizes(context).size16,
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
                                      _selectDate(context); // Open date picker immediately
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
                                readOnly: true,
                                onTap: () => _selectDate(context),
                                validator: (value) => value!.isEmpty ? 'Date is required' : null,
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black,
                                ),
                              )
                                  : CustomTextWidget(
                                text: DateFormat('dd MMM, yyyy').format(DateTime.parse(recordDate)),
                                textStyle: TextStyle(
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
                                width: ScreenUtil.scaleWidth(context, 270),
                                height: ScreenUtil.scaleHeight(context, 54),
                                text: isUploading ? 'Uploading...' : 'Upload record',
                                onPressed: isUploading
                                    ? null
                                    : () {
                                  drawerHelpers.uploadRecords(ref, context, _formKey);
                                },
                                backgroundColor: selectedImages.isEmpty ? AppColors.subTextColor : AppColors.gradientGreen,
                                textColor: selectedImages.isEmpty ? AppColors.black : AppColors.gradientWhite,
                                borderRadius: 6,
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

  Widget _buildRecordTypeOption(
      String type,
      IconData icon,
      bool isSelected,
      Color color,
      ) {
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
              text: type,
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
