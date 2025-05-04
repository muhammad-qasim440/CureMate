import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../theme/app_colors.dart';
import '../../providers/profile_image_picker_provider/profile_image_picker_provider.dart';

class ProfileImagePickerWidget extends ConsumerWidget {
  final double size;
  final VoidCallback? onTap;

  const ProfileImagePickerWidget({
    super.key,
    this.size = 50.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageState = ref.watch(profileImagePickerProvider);

    return GestureDetector(
      onTap: onTap ?? () => _showImageSourceOptions(context, ref),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade200,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: imageState.isProcessing
                ?  const Center(child: CircularProgressIndicator(color: AppColors.gradientGreen,))
                : imageState.croppedImage != null
                ? Image.file(
              File(imageState.croppedImage!.path),
              fit: BoxFit.cover,
              width: size,
              height: size,
            )
                : Center(
              child: Icon(
                Icons.add_a_photo_outlined,
                size: size * 0.5,
                color: Colors.grey.shade400,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showImageSourceOptions(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(profileImagePickerProvider.notifier);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  notifier.pickImage(ref:ref,source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  notifier.pickImage(ref:ref,source: ImageSource.camera);
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
            ],
          ),
        );
      },
    );
  }
}