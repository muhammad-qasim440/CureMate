
import 'package:image_picker/image_picker.dart';

Future<XFile?> pickProfileImage() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.gallery);
  if (pickedFile != null) {
    return XFile(pickedFile.path);
  }
  return null;
}
