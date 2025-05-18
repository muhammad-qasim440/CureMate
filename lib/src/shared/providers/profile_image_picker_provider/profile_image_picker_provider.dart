import 'dart:io';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

import '../../../../core/utils/debug_print.dart';
import '../../../features/authentication/signup/providers/signup_form_provider.dart';

class ProfileImageState {
  final XFile? originalImage;
  final XFile? croppedImage;
  final bool isProcessing;
  final String? errorMessage;

  ProfileImageState({
    this.originalImage,
    this.croppedImage,
    this.isProcessing = false,
    this.errorMessage,
  });

  ProfileImageState copyWith({
    XFile? originalImage,
    XFile? croppedImage,
    bool? isProcessing,
    String? errorMessage,
  }) {
    return ProfileImageState(
      originalImage: originalImage ?? this.originalImage,
      croppedImage: croppedImage ?? this.croppedImage,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ProfileImagePickerNotifier extends StateNotifier<ProfileImageState> {
  ProfileImagePickerNotifier() : super(ProfileImageState());

  final ImagePicker _picker = ImagePicker();

  Future<void> pickImage({required WidgetRef ref,ImageSource source = ImageSource.gallery}) async {
    state = state.copyWith(isProcessing: true, errorMessage: null);

    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 90,
      );

      if (image == null) {
        state = state.copyWith(isProcessing: false);
        return;
      }

      state = state.copyWith(originalImage: image);
      final croppedImage = await _processProfileImage(image);

      if (croppedImage != null) {
        state = state.copyWith(croppedImage: croppedImage, isProcessing: false);
        ref.read(userProfileProvider.notifier).state = croppedImage;
      } else {
        /// If face detection fails, just center crop the image
        final centeredCrop = await _createCenteredSquareCrop(image);
        state = state.copyWith(croppedImage: centeredCrop, isProcessing: false);
        ref.read(userProfileProvider.notifier).state = centeredCrop;
      }
    } catch (e) {
      state = state.copyWith(
          isProcessing: false,
          errorMessage: "Error processing image: ${e.toString()}"
      );
    }
  }

  /// Fallback method if face detection fails
  Future<XFile> _createCenteredSquareCrop(XFile image) async {
    final bytes = await image.readAsBytes();
    final original = img.decodeImage(bytes)!;

    final imgWidth = original.width;
    final imgHeight = original.height;

    /// Create a square crop from the center
    final size = min(imgWidth, imgHeight);
    final x = (imgWidth - size) ~/ 2;
    final y = (imgHeight - size) ~/ 2;

    final cropped = img.copyCrop(
      original,
      x: x,
      y: y,
      width: size,
      height: size,
    );

    /// Resize to standard profile picture size
    final resized = img.copyResize(cropped, width: 500, height: 500);

    final dir = await getTemporaryDirectory();
    final path = join(dir.path, 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
    final file = File(path)..writeAsBytesSync(img.encodeJpg(resized, quality: 90));

    return XFile(file.path);
  }

  Future<XFile?> _processProfileImage(XFile image) async {
    try {
      /// 1.  Use FaceDetector to find the face
      final inputImage = InputImage.fromFilePath(image.path);
      final faceDetector = FaceDetector(
        options: FaceDetectorOptions(
          performanceMode: FaceDetectorMode.accurate,
          enableLandmarks: true,
        ),
      );

      final faces = await faceDetector.processImage(inputImage);
      await faceDetector.close();

      if (faces.isEmpty) return null;

      /// Sort faces by size (largest first) if there are multiple
      if (faces.length > 1) {
        faces.sort((a, b) =>
            (b.boundingBox.width * b.boundingBox.height)
                .compareTo(a.boundingBox.width * a.boundingBox.height));
      }

      final Face mainFace = faces.first;
      final faceBox = mainFace.boundingBox;

      /// 2. Load and process the image
      final bytes = await image.readAsBytes();
      final original = img.decodeImage(bytes);
      if (original == null) return null;

      final imgWidth = original.width;
      final imgHeight = original.height;

      /// 3. Calculate proper square dimensions for profile picture
      /// We want to ensure the face is properly centered and there's enough
      /// space around it for a professional-looking profile picture

      /// Get the face center point
      double faceCenterX = faceBox.left + (faceBox.width / 2);
      double faceCenterY = faceBox.top + (faceBox.height / 2);

      /// Calculate proper square size using face width/height as reference
      /// A good profile picture shows the face plus some margin around it
      double squareSize = max(faceBox.width, faceBox.height) * 2.2;

      /// Ensure we don't exceed image dimensions
      squareSize = min(squareSize, min(imgWidth, imgHeight).toDouble());

      /// Calculate top-left point of our square crop
      double left = faceCenterX - (squareSize / 2);
      double top = faceCenterY - (squareSize / 2);

      /// Adjust if the crop extends beyond image boundaries
      if (left < 0) left = 0;
      if (top < 0) top = 0;
      if (left + squareSize > imgWidth) left = imgWidth - squareSize;
      if (top + squareSize > imgHeight) top = imgHeight - squareSize;

      /// 4. Perform the crop
      final cropped = img.copyCrop(
        original,
        x: left.toInt(),
        y: top.toInt(),
        width: squareSize.toInt(),
        height: squareSize.toInt(),
      );

      /// 5. Resize to standard profile picture size
      final resized = img.copyResize(cropped, width: 500, height: 500);

      /// 6. Save the result
      final dir = await getTemporaryDirectory();
      final path = join(dir.path, 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg');
      final file = File(path)..writeAsBytesSync(img.encodeJpg(resized, quality: 90));
      return XFile(file.path);
    } catch (e) {
      logDebug("Error in face processing: $e");
      return null;
    }
  }

  void reset(dynamic ref) {
    state = ProfileImageState();
    ref.read(userProfileProvider.notifier).state=null;
  }
}

final profileImagePickerProvider = StateNotifierProvider<ProfileImagePickerNotifier, ProfileImageState>(
      (ref) => ProfileImagePickerNotifier(),
);