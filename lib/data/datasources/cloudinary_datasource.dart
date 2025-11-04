import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryDataSource {
  static const String cloudName = 'dqeqxffbb';
  static const String uploadPreset = 'flutter_unsigned';

  Future<String?> uploadImage(File imageFile) async {
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final resData = await response.stream.bytesToString();
      final json = jsonDecode(resData);
      return json['secure_url'];
    } else {
      print('❌ Upload Cloudinary thất bại: ${response.statusCode}');
      return null;
    }
  }
}
