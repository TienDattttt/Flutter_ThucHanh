import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class CloudinaryHelper {
  static const String cloudName = 'YOUR_CLOUD_NAME';
  static const String uploadPreset = 'YOUR_UPLOAD_PRESET';

  static Future<String?> uploadImage(File imageFile) async {
    final url =
    Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    final mimeTypeData = lookupMimeType(imageFile.path)?.split('/') ?? ['image', 'jpeg'];

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
        contentType: MediaType(mimeTypeData[0], mimeTypeData[1]),
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Cloudinary upload failed: ${response.body}');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    return data['secure_url'] as String?;
  }
}
