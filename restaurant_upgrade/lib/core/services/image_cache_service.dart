import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../constants/app_constants.dart';
import '../utils/image_utils.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  late final CacheManager _cacheManager;
  bool _isInitialized = false;

  /// Initialize image cache service
  Future<void> initialize() async {
    if (_isInitialized) return;

    _cacheManager = CacheManager(
      Config(
        'restaurant_images',
        stalePeriod: Duration(days: AppConstants.imageCacheMaxAge),
        maxNrOfCacheObjects: 1000,
        repo: JsonCacheInfoRepository(databaseName: 'restaurant_images'),
        fileService: HttpFileService(),
      ),
    );

    _isInitialized = true;
    print('Image cache service initialized');
  }

  /// Get cache manager instance
  CacheManager get cacheManager => _cacheManager;

  /// Preload images for better performance
  Future<void> preloadImages(List<String> imageUrls) async {
    if (!_isInitialized) await initialize();

    final futures = imageUrls.map((url) async {
      try {
        await _cacheManager.downloadFile(url);
      } catch (e) {
        print('Error preloading image $url: $e');
      }
    });

    await Future.wait(futures);
    print('Preloaded ${imageUrls.length} images');
  }

  /// Get cached image file
  Future<File?> getCachedImageFile(String url) async {
    if (!_isInitialized) await initialize();

    try {
      final fileInfo = await _cacheManager.getFileFromCache(url);
      return fileInfo?.file;
    } catch (e) {
      print('Error getting cached image file: $e');
      return null;
    }
  }

  /// Cache image from URL
  Future<File?> cacheImageFromUrl(String url) async {
    if (!_isInitialized) await initialize();

    try {
      final file = await _cacheManager.getSingleFile(url);
      return file;
    } catch (e) {
      print('Error caching image from URL: $e');
      return null;
    }
  }

  /// Generate and cache thumbnail
  Future<File?> generateAndCacheThumbnail(
    String originalUrl, {
    int width = AppConstants.thumbnailSize,
    int height = AppConstants.thumbnailSize,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final thumbnailKey = '${originalUrl}_thumb_${width}x$height';
      
      // Check if thumbnail already exists in cache
      final existingThumbnail = await _cacheManager.getFileFromCache(thumbnailKey);
      if (existingThumbnail != null) {
        return existingThumbnail.file;
      }

      // Get original image
      final originalFile = await _cacheManager.getSingleFile(originalUrl);

      // Generate thumbnail
      final thumbnailBytes = await ImageUtils.generateThumbnail(
        originalFile,
        width: width,
        height: height,
      );

      if (thumbnailBytes == null) return null;

      // Cache thumbnail
      final thumbnailFile = await _cacheManager.putFile(
        thumbnailKey,
        thumbnailBytes,
        maxAge: Duration(days: AppConstants.imageCacheMaxAge),
      );

      return thumbnailFile;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  /// Compress and cache image
  Future<File?> compressAndCacheImage(
    File originalFile, {
    int quality = AppConstants.imageQuality,
  }) async {
    if (!_isInitialized) await initialize();

    try {
      final compressedKey = '${originalFile.path}_compressed_$quality';
      
      // Check if compressed version already exists
      final existingCompressed = await _cacheManager.getFileFromCache(compressedKey);
      if (existingCompressed != null) {
        return existingCompressed.file;
      }

      // Compress image
      final compressedFile = await ImageUtils.compressImage(
        originalFile,
        quality: quality,
      );

      // Cache compressed image
      final compressedBytes = await compressedFile.readAsBytes();
      final cachedFile = await _cacheManager.putFile(
        compressedKey,
        compressedBytes,
        maxAge: Duration(days: AppConstants.imageCacheMaxAge),
      );

      return cachedFile;
    } catch (e) {
      print('Error compressing and caching image: $e');
      return null;
    }
  }

  /// Clear image cache
  Future<void> clearCache() async {
    if (!_isInitialized) await initialize();

    try {
      await _cacheManager.emptyCache();
      print('Image cache cleared');
    } catch (e) {
      print('Error clearing image cache: $e');
    }
  }

  /// Get cache size
  Future<int> getCacheSize() async {
    if (!_isInitialized) await initialize();

    try {
      // This is a simplified implementation
      // In a real app, you might want to implement proper cache size calculation
      return 0;
    } catch (e) {
      print('Error getting cache size: $e');
      return 0;
    }
  }

  /// Remove expired cache files
  Future<void> cleanupExpiredCache() async {
    if (!_isInitialized) await initialize();

    try {
      // This is handled automatically by CacheManager
      print('Expired cache files cleaned up');
    } catch (e) {
      print('Error cleaning up expired cache: $e');
    }
  }

  /// Preload restaurant images
  Future<void> preloadRestaurantImages(List<String> imageUrls) async {
    await preloadImages(imageUrls);
    
    // Also generate thumbnails for better performance
    final thumbnailFutures = imageUrls.map((url) async {
      try {
        await generateAndCacheThumbnail(url);
      } catch (e) {
        print('Error generating thumbnail for $url: $e');
      }
    });
    
    await Future.wait(thumbnailFutures);
  }



  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStatistics() async {
    if (!_isInitialized) await initialize();

    try {
      final cacheSize = await getCacheSize();
      
      return {
        'totalFiles': 0,
        'totalSize': cacheSize,
        'totalSizeMB': (cacheSize / (1024 * 1024)).toStringAsFixed(2),
        'maxAge': AppConstants.imageCacheMaxAge,
        'maxObjects': 1000,
      };
    } catch (e) {
      print('Error getting cache statistics: $e');
      return {};
    }
  }
}