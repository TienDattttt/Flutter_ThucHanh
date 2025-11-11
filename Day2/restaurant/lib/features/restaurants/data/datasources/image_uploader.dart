import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ✅ Class tiện ích upload ảnh lên Cloudinary (unsigned)
class ImageUploader {
  final String cloudName;
  final String uploadPreset; // unsigned preset

  ImageUploader({
    required this.cloudName,
    required this.uploadPreset,
  });

  /// Hàm upload ảnh, trả về link [secure_url]
  Future<String> uploadImage(File file) async {
    // URL endpoint Cloudinary
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');

    // multipart form-data request
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    try {
      final response = await request.send();
      final body = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(body) as Map<String, dynamic>;
        return data['secure_url'] as String; // ✅ link ảnh thật
      } else {
        final msg = json.decode(body);
        throw Exception('Upload thất bại: ${response.statusCode} - ${msg['error']?['message'] ?? body}');
      }
    } catch (e) {
      throw Exception('❌ Lỗi upload Cloudinary: $e');
    }
  }

  /// ✅ Factory tiện lợi: đọc trực tiếp từ file .env
  factory ImageUploader.fromEnv() {
    return ImageUploader(
      cloudName: dotenv.env['CLOUD_NAME'] ?? '',
      uploadPreset: dotenv.env['UPLOAD_PRESET'] ?? '',
    );
  }
}
