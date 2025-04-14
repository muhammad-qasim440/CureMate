import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<String?> uploadImageToCloudinary(File imageFile) async {
  const uploadPreset = 'curemate_preset';
  final url = Uri.parse('https://api.cloudinary.com/v1_1/dqijptmo0/image/upload');

  var request = http.MultipartRequest('POST', url)
    ..fields['upload_preset'] = uploadPreset
    ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

  var response = await request.send();

  if (response.statusCode == 200) {
    final resStr = await response.stream.bytesToString();
    final resJson = json.decode(resStr);
    return resJson['secure_url'];
  } else {
    print('Cloudinary upload failed: ${response.statusCode}');
    return null;
  }
}
