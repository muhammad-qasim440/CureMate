import 'dart:io';
import 'package:curemate/core/utils/debug_print.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, String>?> uploadImageToCloudinary(File imageFile) async {
  const uploadPreset = 'curemate_preset';
  final url = Uri.parse('https://api.cloudinary.com/v1_1/dqijptmo0/image/upload');

  var request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  var response = await request.send();

  if (response.statusCode == 200) {
    final resStr = await response.stream.bytesToString();
    final resJson = json.decode(resStr);

    return {
      'secure_url': resJson['secure_url'],
      'public_id': resJson['public_id'],
    };
  } else {
    print('Cloudinary upload failed: ${response.statusCode}');
    return null;
  }
}

Future<void> deleteImageFromCloudinary(String publicId) async {
  final url = Uri.parse('https://api.cloudinary.com/v1_1/dqijptmo0/image/destroy');

  var request = http.MultipartRequest('POST', url)
    ..fields['public_id'] = publicId
    ..fields['upload_preset'] = 'curemate_preset';

  var response = await request.send();

  if (response.statusCode == 200) {
    print('Image deleted successfully');
  } else {
    print('Failed to delete image: ${response.statusCode}');
  }
}

Future<Map<String, String>?> updateImage(File newImageFile, String oldImagePublicId) async {
  await deleteImageFromCloudinary(oldImagePublicId);
  final uploadResult = await uploadImageToCloudinary(newImageFile);
  if (uploadResult != null) {
    logDebug('New image uploaded: ${uploadResult['secure_url']}');
    return uploadResult;
  } else {
    logDebug('Failed to upload the new image');
    return null;
  }
}

// Future<void> _updateDoctorProfileImage(BuildContext context, WidgetRef ref) async {
//   final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//   if (pickedFile != null) {
//     final doctorData = ref.read(currentDoctorDataProvider).value; // Assuming a provider for doctor data
//     if (doctorData != null) {
//       final result = await uploadImageToCloudinary(File(pickedFile.path));
//       if (result != null) {
//         if (doctorData.profileImagePublicId.isNotEmpty) {
//           await deleteImageFromCloudinary(doctorData.profileImagePublicId);
//         }
//         await FirebaseDatabase.instance
//             .ref()
//             .child('Doctors')
//             .child(FirebaseAuth.instance.currentUser!.uid)
//             .update({
//           'profileImageUrl': result['secure_url'],
//           'profileImagePublicId': result['public_id'],
//         });
//       }
//     }
//   }
// }
//
// Future<void> _deleteDoctorProfileImage(BuildContext context, WidgetRef ref) async {
//   final doctorData = ref.read(currentDoctorDataProvider).value;
//   if (doctorData != null && doctorData.profileImagePublicId.isNotEmpty) {
//     await deleteImageFromCloudinary(doctorData.profileImagePublicId);
//     await FirebaseDatabase.instance
//         .ref()
//         .child('Doctors')
//         .child(FirebaseAuth.instance.currentUser!.uid)
//         .update({
//       'profileImageUrl': '',
//       'profileImagePublicId': '',
//     });
//   }
// }