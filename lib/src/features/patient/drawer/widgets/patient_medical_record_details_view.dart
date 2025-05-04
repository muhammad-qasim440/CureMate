import 'dart:io';

import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:curemate/src/utils/screen_utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../const/app_fonts.dart';
import '../../../../../const/font_sizes.dart';
import '../../../../../core/utils/upload_profile_image_to_cloudinary.dart';
import '../../../../theme/app_colors.dart';
import '../providers/drawer_providers.dart';
import 'package:curemate/src/router/nav.dart';

// Providers for state management
final selectedIndicesProvider = StateProvider<Set<int>>((ref) => {});
final selectionModeProvider = StateProvider<bool>((ref) => false);
final newImagesProvider = StateProvider<List<File>>((ref) => []);

class MedicalRecordDetailView extends ConsumerWidget {
  final Map<String, dynamic> record;
  final String recordId;

  const MedicalRecordDetailView({super.key, required this.record, required this.recordId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the medicalRecordsProvider to get real-time updates
    final medicalRecordsAsync = ref.watch(medicalRecordsProvider);
    final newImages = ref.watch(newImagesProvider);
    final selectionMode = ref.watch(selectionModeProvider);
    final selectedIndices = ref.watch(selectedIndicesProvider);

    // Extract the current record based on recordId from the provider
    final images = medicalRecordsAsync.when(
      data: (records) {
        final currentRecord = records.firstWhere(
              (r) => r['id'].toString() == recordId,
          orElse: () => record,
        );
        return List<Map<String, String>>.from(currentRecord['images'] ?? []);
      },
      loading: () => List<Map<String, String>>.from(record['images'] ?? []),
      error: (error, stack) => List<Map<String, String>>.from(record['images'] ?? []),
    );

    Future<void> _pickImage(ImageSource source) async {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile != null) {
        ref.read(newImagesProvider.notifier).update((state) => [...state, File(pickedFile.path)]);
        Navigator.pop(context);
      }
    }

    Future<void> _showImagePickerBottomSheet() async {
      showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (context) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.height,
            Row(
              children: [
                10.width,
                CustomTextWidget(
                  text: 'Add more images',
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

    Future<void> _uploadNewImages() async {
      final newImagesToUpload = ref.read(newImagesProvider);
      if (newImagesToUpload.isEmpty) return;

      List<Map<String, String>> imageDetails = [];
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

      ref.read(newImagesProvider.notifier).state = [];
    }

    Future<void> _deleteSelectedImages() async {
      final imagesToDelete = selectedIndices.map((index) => images[index]).toList();
      for (var image in imagesToDelete) {
        await deleteImageFromCloudinary(image['public_id']!);
      }

      final updatedImages = images
          .asMap()
          .entries
          .where((entry) => !selectedIndices.contains(entry.key))
          .map((entry) => entry.value)
          .toList();

      await FirebaseDatabase.instance
          .ref()
          .child('Patients')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('MedicalRecords')
          .child(recordId)
          .update({'images': updatedImages});

      ref.read(selectedIndicesProvider.notifier).state = {};
      ref.read(selectionModeProvider.notifier).state = false;
    }

    Future<void> _deleteRecord() async {
      for (var image in images) {
        await deleteImageFromCloudinary(image['public_id']!);
      }

      await FirebaseDatabase.instance
          .ref()
          .child('Patients')
          .child(FirebaseAuth.instance.currentUser!.uid)
          .child('MedicalRecords')
          .child(recordId)
          .remove();

      AppNavigation.pop(context);
    }

    void _showFullScreenImage(int index) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => FullScreenImageView(
            images: List<String>.from(images.map((img) => img['url'] ?? '')),
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
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var opacityAnimation = animation.drive(tween);
            return FadeTransition(opacity: opacityAnimation, child: child);
          },
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CustomAppBarHeaderWidget(
                        title: 'Record Details',
                      ),
                      100.width,
                      if (selectionMode)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: () {
                            ref.read(selectedIndicesProvider.notifier).state = {};
                            ref.read(selectionModeProvider.notifier).state = false;
                          },
                        ),
                    ],
                  ),
                  20.height,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Existing images from Firebase
                        ...images.asMap().entries.map((entry) {
                          final index = entry.key;
                          final image = entry.value;
                          return GestureDetector(
                            onTap: selectionMode
                                ? () {
                              final currentIndices = ref.read(selectedIndicesProvider);
                              if (currentIndices.contains(index)) {
                                ref.read(selectedIndicesProvider.notifier).update(
                                        (state) => {...state}..remove(index));
                              } else {
                                ref.read(selectedIndicesProvider.notifier).update(
                                        (state) => {...state, index});
                              }
                            }
                                : () => _showFullScreenImage(index),
                            onLongPress: () {
                              if (!selectionMode) {
                                ref.read(selectionModeProvider.notifier).state = true;
                                ref.read(selectedIndicesProvider.notifier).update(
                                        (state) => {...state, index});
                              }
                            },
                            child: Stack(
                              children: [
                                Container(
                                  width: 80,
                                  height: 105,
                                  margin: const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      image['url']!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                ),
                                if (selectedIndices.contains(index))
                                  Container(
                                    width: 80,
                                    height: 105,
                                    color: Colors.black26,
                                    child: const Center(
                                      child: Icon(Icons.check_circle, color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),
                        // Newly picked images (not yet uploaded)
                        ...newImages.asMap().entries.map((entry) {
                          final index = entry.key + images.length;
                          return Stack(
                            children: [
                              Container(
                                width: 80,
                                height: 105,
                                margin: const EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(entry.value),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }),
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
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (selectionMode && selectedIndices.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomButtonWidget(
                        text: 'Delete Selected (${selectedIndices.length})',
                        onPressed: _deleteSelectedImages,
                        backgroundColor: AppColors.gradientGreen,
                        textColor: Colors.white,
                        borderRadius: 8,
                      ),
                    ),
                  if (newImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomButtonWidget(
                        text: 'Upload New Images (${newImages.length})',
                        onPressed: _uploadNewImages,
                        backgroundColor: AppColors.gradientGreen,
                        textColor: Colors.white,
                        borderRadius: 8,
                      ),
                    ),
                  // Padding(
                  //   padding: const EdgeInsets.all(16.0),
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.end,
                  //     children: [
                  //       CustomButtonWidget(
                  //         text: 'Delete Record',
                  //         onPressed: _deleteRecord,
                  //         backgroundColor: AppColors.gradientBlue,
                  //         textColor: Colors.white,
                  //         borderRadius: 8,
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageView extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final VoidCallback onDelete;

  const FullScreenImageView({super.key, required this.images, required this.initialIndex, required this.onDelete});

  @override
  State<FullScreenImageView> createState() => _FullScreenImageViewState();
}

class _FullScreenImageViewState extends State<FullScreenImageView> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.velocity.pixelsPerSecond.dx > 0 && _currentIndex > 0) {
                setState(() => _currentIndex--);
              } else if (details.velocity.pixelsPerSecond.dx < 0 && _currentIndex < widget.images.length - 1) {
                setState(() => _currentIndex++);
              }
            },
            child: Center(
              child: Image.network(
                widget.images[_currentIndex],
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            top: ScreenUtil.scaleHeight(context, 40),
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                widget.onDelete();
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}