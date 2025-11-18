import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import '../constants/app_constants.dart';

class CloudinaryService {
  static CloudinaryService? _instance;
  late CloudinaryPublic _cloudinary;

  CloudinaryService._() {
    _cloudinary = CloudinaryPublic(
      AppConstants.cloudinaryCloudName,
      AppConstants.cloudinaryUploadPreset,
      cache: false,
    );
  }

  static CloudinaryService get instance {
    _instance ??= CloudinaryService._();
    return _instance!;
  }

  /// Upload single image to Cloudinary
  Future<String> uploadImage({
    required File imageFile,
    String? folder,
    String? publicId,
    Map<String, String>? tags,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          folder: folder ?? AppConstants.defaultImageFolder,
          publicId: publicId,
          tags: tags?.values.toList(),
        ),
      );

      return response.secureUrl;
    } catch (e) {
      throw CloudinaryException(
        message: 'Lỗi khi tải lên hình ảnh: ${e.toString()}',
        code: 'upload-failed',
      );
    }
  }

  /// Upload multiple images to Cloudinary
  Future<List<String>> uploadMultipleImages({
    required List<File> imageFiles,
    String? folder,
    Map<String, String>? tags,
    Function(int current, int total)? onProgress,
  }) async {
    try {
      final List<String> uploadedUrls = [];
      
      for (int i = 0; i < imageFiles.length; i++) {
        onProgress?.call(i + 1, imageFiles.length);
        
        final url = await uploadImage(
          imageFile: imageFiles[i],
          folder: folder,
          tags: tags,
        );
        
        uploadedUrls.add(url);
      }

      return uploadedUrls;
    } catch (e) {
      throw CloudinaryException(
        message: 'Lỗi khi tải lên nhiều hình ảnh: ${e.toString()}',
        code: 'multiple-upload-failed',
      );
    }
  }

  /// Upload restaurant images with specific folder structure
  Future<List<String>> uploadRestaurantImages({
    required List<File> imageFiles,
    required String restaurantId,
    Function(int current, int total)? onProgress,
  }) async {
    return uploadMultipleImages(
      imageFiles: imageFiles,
      folder: '${AppConstants.restaurantImagesFolder}/$restaurantId',
      tags: {'restaurant': restaurantId, 'type': 'restaurant'},
      onProgress: onProgress,
    );
  }

  /// Upload review images with specific folder structure
  Future<List<String>> uploadReviewImages({
    required List<File> imageFiles,
    required String restaurantId,
    required String userId,
    Function(int current, int total)? onProgress,
  }) async {
    return uploadMultipleImages(
      imageFiles: imageFiles,
      folder: '${AppConstants.reviewImagesFolder}/$restaurantId',
      tags: {
        'restaurant': restaurantId,
        'user': userId,
        'type': 'review',
      },
      onProgress: onProgress,
    );
  }

  /// Upload user profile image
  Future<String> uploadUserProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    return uploadImage(
      imageFile: imageFile,
      folder: AppConstants.userProfileImagesFolder,
      publicId: 'profile_$userId',
      tags: {'user': userId, 'type': 'profile'},
    );
  }

  /// Generate optimized image URL with transformations
  String getOptimizedImageUrl({
    required String publicId,
    int? width,
    int? height,
    String quality = 'auto',
    String format = 'auto',
    String crop = 'fill',
  }) {
    try {
      // Build transformation URL manually
      final baseUrl = 'https://res.cloudinary.com/${AppConstants.cloudinaryCloudName}/image/upload';
      final transformations = [
        if (width != null) 'w_$width',
        if (height != null) 'h_$height',
        'c_$crop',
        'q_$quality',
        'f_$format',
      ].join(',');
      
      return '$baseUrl/$transformations/$publicId';
    } catch (e) {
      // Return basic URL if transformation fails
      return 'https://res.cloudinary.com/${AppConstants.cloudinaryCloudName}/image/upload/$publicId';
    }
  }

  /// Generate thumbnail URL
  String getThumbnailUrl({
    required String publicId,
    int size = 150,
  }) {
    return getOptimizedImageUrl(
      publicId: publicId,
      width: size,
      height: size,
      crop: 'thumb',
    );
  }

  /// Delete image from Cloudinary
  /// Note: Deletion requires server-side implementation with API credentials
  Future<void> deleteImage({
    required String publicId,
  }) async {
    try {
      // Note: cloudinary_public doesn't support deletion
      // This would need to be implemented server-side with API credentials
      // For now, we'll just log the deletion request
      print('Delete image requested for publicId: $publicId');
      // TODO: Implement server-side deletion API
    } catch (e) {
      throw CloudinaryException(
        message: 'Lỗi khi xóa hình ảnh: ${e.toString()}',
        code: 'delete-failed',
      );
    }
  }

  /// Extract public ID from Cloudinary URL
  String? extractPublicIdFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      
      // Find the segment after 'upload' and before file extension
      final uploadIndex = pathSegments.indexOf('upload');
      if (uploadIndex != -1 && uploadIndex < pathSegments.length - 2) {
        final publicIdWithExtension = pathSegments.sublist(uploadIndex + 2).join('/');
        // Remove file extension
        final lastDotIndex = publicIdWithExtension.lastIndexOf('.');
        if (lastDotIndex != -1) {
          return publicIdWithExtension.substring(0, lastDotIndex);
        }
        return publicIdWithExtension;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }
}

class CloudinaryException implements Exception {
  final String message;
  final String code;

  const CloudinaryException({
    required this.message,
    required this.code,
  });

  @override
  String toString() => 'CloudinaryException: $message (Code: $code)';
}