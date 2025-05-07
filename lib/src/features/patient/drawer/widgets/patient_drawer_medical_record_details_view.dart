import 'package:curemate/core/extentions/widget_extension.dart';
import 'package:curemate/src/features/patient/drawer/helpers/drawer_helpers.dart';
import 'package:curemate/src/shared/widgets/custom_appbar_header_widget.dart';
import 'package:curemate/src/shared/widgets/custom_button_widget.dart';
import 'package:curemate/src/shared/widgets/custom_text_widget.dart';
import 'package:curemate/src/shared/widgets/lower_background_effects_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curemate/const/app_fonts.dart';
import 'package:curemate/src/theme/app_colors.dart';
import '../providers/drawer_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PatientDrawerMedicalRecordDetailsView extends ConsumerWidget {
  final Map<String, dynamic> record;
  final String recordId;

  const PatientDrawerMedicalRecordDetailsView({
    super.key,
    required this.record,
    required this.recordId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final drawerHelpers = DrawerHelpers();
    final medicalRecordsAsync = ref.watch(medicalRecordsProvider);
    final newImages = ref.watch(newImagesProvider);
    final selectionMode = ref.watch(selectionModeProvider);
    final selectedIndices = ref.watch(selectedIndicesProvider);
    final isUploading = ref.watch(isUploadingProvider);
    final isDeleting = ref.watch(isDeletingProvider);

    final images = medicalRecordsAsync.when(
      data: (records) {
        final currentRecord = records.firstWhere(
          (r) => r['id'].toString() == recordId,
          orElse: () => record,
        );
        return List<Map<String, String>>.from(currentRecord['images'] ?? []);
      },
      loading: () => List<Map<String, String>>.from(record['images'] ?? []),
      error:
          (error, stack) =>
              List<Map<String, String>>.from(record['images'] ?? []),
    );

    return Scaffold(
      floatingActionButton:
          selectionMode && selectedIndices.isNotEmpty || newImages.isNotEmpty
              ? null
              : FloatingActionButton(
                onPressed: () {
                  drawerHelpers.showImagePickerBottomSheet(
                    ref: ref,
                    context: context,
                    multiImageProvider: newImagesProvider,
                  );
                },
                backgroundColor: AppColors.gradientGreen,
                child: const Icon(Icons.add, color: Colors.white),
              ),
      body: Stack(
        children: [
          const LowerBackgroundEffectsWidgets(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 15.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CustomAppBarHeaderWidget(title: 'Record Details'),
                      135.width,
                      if (selectionMode || newImages.isNotEmpty)
                        InkWell(
                          child: const Icon(
                            Icons.close,
                            color: AppColors.gradientGreen,
                          ),
                          onTap: () {
                            if (newImages.isNotEmpty) {
                              ref.read(newImagesProvider.notifier).state = [];
                              return;
                            }
                            ref.read(selectedIndicesProvider.notifier).state =
                                {};
                            ref.read(selectionModeProvider.notifier).state =
                                false;
                          },
                        ),
                    ],
                  ),
                  20.height,
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.75,
                          ),
                      itemCount: images.length + newImages.length,
                      itemBuilder: (context, index) {
                        if (index < images.length) {
                          final image = images[index];
                          return GestureDetector(
                            onTap:
                                selectionMode
                                    ? () {
                                      final currentIndices = ref.read(
                                        selectedIndicesProvider,
                                      );
                                      if (currentIndices.contains(index)) {
                                        ref
                                            .read(
                                              selectedIndicesProvider.notifier,
                                            )
                                            .update(
                                              (state) =>
                                                  {...state}..remove(index),
                                            );
                                      } else {
                                        ref
                                            .read(
                                              selectedIndicesProvider.notifier,
                                            )
                                            .update(
                                              (state) => {...state, index},
                                            );
                                      }
                                    }
                                    : () {
                                      drawerHelpers.showFullScreenImage(
                                        ref,
                                        context,
                                        index,
                                        images,
                                      );
                                    },
                            onLongPress: () {
                              if (!selectionMode) {
                                ref.read(selectionModeProvider.notifier).state =
                                    true;
                                ref
                                    .read(selectedIndicesProvider.notifier)
                                    .update((state) => {...state, index});
                              }
                            },
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: image['url']!,
                                  fit: BoxFit.cover,
                                  placeholder:
                                      (context, url) => Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.gradientGreen,
                                          ),
                                        ),
                                      ),
                                  errorWidget:
                                      (context, url, error) => Container(
                                        decoration: BoxDecoration(
                                          color: Colors.grey[200],
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                            ),
                                            8.height,
                                            GestureDetector(
                                              onTap: () {
                                                ref.refresh(
                                                  medicalRecordsProvider,
                                                );
                                              },
                                              child: const CustomTextWidget(
                                                text: 'Retry',
                                                textStyle: TextStyle(
                                                  color:
                                                      AppColors.gradientGreen,
                                                  fontSize: 14,
                                                  fontFamily: AppFonts.rubik,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  imageBuilder:
                                      (context, imageProvider) => Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                ),
                                if (selectedIndices.contains(index))
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black26,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check_circle,
                                        color: AppColors.gradientWhite,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        } else {
                          final newImageIndex = index - images.length;
                          return Stack(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    image: FileImage(newImages[newImageIndex]),
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
                                          .read(newImagesProvider.notifier)
                                          .update(
                                            (state) =>
                                                state
                                                    .where(
                                                      (i) =>
                                                          i !=
                                                          newImages[newImageIndex],
                                                    )
                                                    .toList(),
                                          );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                      },
                    ),
                  ),
                  if (selectionMode && selectedIndices.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomButtonWidget(
                        text:
                            isDeleting
                                ? 'Deleting...'
                                : 'Delete Selected (${selectedIndices.length})',
                        onPressed:
                            isDeleting
                                ? null
                                : () async {
                                  ref.read(isDeletingProvider.notifier).state =
                                      true;
                                  await drawerHelpers.deleteSelectedImages(
                                    ref,
                                    selectedIndices,
                                    images,
                                    recordId,
                                  );
                                  ref
                                      .read(selectedIndicesProvider.notifier)
                                      .state = {};
                                  ref
                                      .read(selectionModeProvider.notifier)
                                      .state = false;
                                  ref.read(isDeletingProvider.notifier).state =
                                      false;
                                },
                        backgroundColor: AppColors.gradientGreen,
                        textColor: Colors.white,
                        borderRadius: 8,
                      ),
                    ),
                  if (newImages.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: CustomButtonWidget(
                        text:
                            isUploading
                                ? 'Uploading...'
                                : 'Upload New Images (${newImages.length})',
                        onPressed:
                            isUploading
                                ? null
                                : () async {
                                  ref.read(isUploadingProvider.notifier).state =
                                      true;
                                  await drawerHelpers.uploadNewImages(
                                    ref,
                                    newImagesProvider,
                                    images,
                                    recordId,
                                  );
                                  ref.read(isUploadingProvider.notifier).state =
                                      false;
                                },
                        backgroundColor: AppColors.gradientGreen,
                        textColor: Colors.white,
                        borderRadius: 8,
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
}
