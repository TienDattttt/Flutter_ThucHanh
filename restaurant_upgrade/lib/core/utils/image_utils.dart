import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../constants/app_constants.dart';

class ImageUtils {
  /// Check if the file has a valid image format
  static bool isValidImageFormat(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    return AppConstants.supportedImageFormats.contains(extension);
  }

  /// Compress image to reduce file size
  static Future<File> compressImage(File imageFile, {int quality = 85}) async {
    try {
      // Read the image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw Exception('Không thể đọc file hình ảnh');
      }

      // Resize if image is too large
      img.Image resizedImage = image;
      if (image.width > AppConstants.maxImageWidth || 
          image.height > AppConstants.maxImageHeight) {
        resizedImage = img.copyResize(
          image,
          width: image.width > AppConstants.maxImageWidth 
              ? AppConstants.maxImageWidth 
              : null,
          height: image.height > AppConstants.maxImageHeight 
              ? AppConstants.maxImageHeight 
              : null,
        );
      }

      // Compress the image
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);
      
      // Write to a new file
      final compressedFile = File('${imageFile.path}_compressed.jpg');
      await compressedFile.writeAsBytes(compressedBytes);
      
      return compressedFile;
    } catch (e) {
      throw Exception('Lỗi khi nén hình ảnh: ${e.toString()}');
    }
  }

  /// Get image dimensions
  static Future<Map<String, int>?> getImageDimensions(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      return {
        'width': image.width,
        'height': image.height,
      };
    } catch (e) {
      return null;
    }
  }

  /// Check if image needs compression
  static Future<bool> needsCompression(File imageFile) async {
    try {
      final fileSize = await imageFile.length();
      final dimensions = await getImageDimensions(imageFile);
      
      if (dimensions == null) return false;
      
      return fileSize > AppConstants.maxImageSizeMB * 1024 * 1024 ||
             dimensions['width']! > AppConstants.maxImageWidth ||
             dimensions['height']! > AppConstants.maxImageHeight;
    } catch (e) {
      return false;
    }
  }

  /// Generate thumbnail from image
  static Future<Uint8List?> generateThumbnail(
    File imageFile, {
    int width = 150,
    int height = 150,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) return null;
      
      final thumbnail = img.copyResize(
        image,
        width: width,
        height: height,
        interpolation: img.Interpolation.average,
      );
      
      return Uint8List.fromList(img.encodeJpg(thumbnail, quality: 80));
    } catch (e) {
      return null;
    }
  }

  /// Validate image file
  static Future<String?> validateImageFile(File imageFile) async {
    try {
      // Check if file exists
      if (!await imageFile.exists()) {
        return 'File hình ảnh không tồn tại';
      }

      // Check file format
      if (!isValidImageFormat(imageFile.path)) {
        return 'Định dạng hình ảnh không được hỗ trợ';
      }

      // Check file size
      final fileSize = await imageFile.length();
      if (fileSize > AppConstants.maxImageSizeMB * 1024 * 1024) {
        return 'Kích thước hình ảnh không được vượt quá ${AppConstants.maxImageSizeMB}MB';
      }

      // Check if it's a valid image
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) {
        return 'File không phải là hình ảnh hợp lệ';
      }

      return null; // No validation errors
    } catch (e) {
      return 'Lỗi khi kiểm tra hình ảnh: ${e.toString()}';
    }
  }

  /// Get file size in MB
  static Future<double> getFileSizeInMB(File file) async {
    try {
      final bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      return 0.0;
    }
  }

  /// Create a placeholder image
  static Uint8List createPlaceholderImage({
    int width = 300,
    int height = 200,
    String text = 'No Image',
  }) {
    final image = img.Image(width: width, height: height);
    img.fill(image, color: img.ColorRgb8(240, 240, 240));
    
    // Add text (simple implementation)
    // Note: For better text rendering, consider using a canvas library
    
    return Uint8List.fromList(img.encodeJpg(image));
  }

  /// Generate image file name
  static String generateImageFileName(String prefix, String extension) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return '${prefix}_$timestamp.$extension';
  }
}