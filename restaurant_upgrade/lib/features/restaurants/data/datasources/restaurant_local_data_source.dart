import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/exceptions.dart';
import '../models/restaurant_model.dart';

abstract class RestaurantLocalDataSource {
  /// Cache restaurants list
  Future<void> cacheRestaurants(List<RestaurantModel> restaurants);

  /// Get cached restaurants
  Future<List<RestaurantModel>> getCachedRestaurants();

  /// Cache single restaurant
  Future<void> cacheRestaurant(RestaurantModel restaurant);

  /// Get cached restaurant by ID
  Future<RestaurantModel> getCachedRestaurant(String restaurantId);

  /// Cache restaurant categories
  Future<void> cacheRestaurantCategories(List<String> categories);

  /// Get cached restaurant categories
  Future<List<String>> getCachedRestaurantCategories();

  /// Clear all cached data
  Future<void> clearCache();

  /// Check if restaurants are cached
  Future<bool> hasRestaurantsCache();

  /// Check if categories are cached
  Future<bool> hasCategoriesCache();
}

class RestaurantLocalDataSourceImpl implements RestaurantLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _restaurantsKey = 'CACHED_RESTAURANTS';
  static const String _restaurantPrefix = 'CACHED_RESTAURANT_';
  static const String _categoriesKey = 'CACHED_CATEGORIES';
  static const String _lastCacheTimeKey = 'RESTAURANTS_CACHE_TIME';
  static const int _cacheValidityHours = 24; // Cache valid for 24 hours

  RestaurantLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheRestaurants(List<RestaurantModel> restaurants) async {
    try {
      final restaurantsJson = restaurants
          .map((restaurant) => restaurant.toJson())
          .toList();
      
      await sharedPreferences.setString(
        _restaurantsKey,
        json.encode(restaurantsJson),
      );
      
      // Cache timestamp
      await sharedPreferences.setInt(
        _lastCacheTimeKey,
        DateTime.now().millisecondsSinceEpoch,
      );

      // Cache individual restaurants for quick access
      for (final restaurant in restaurants) {
        await cacheRestaurant(restaurant);
      }
    } catch (e) {
      throw CacheException(
        message: 'Lỗi khi lưu cache danh sách nhà hàng: ${e.toString()}',
        code: 'cache-restaurants-failed',
      );
    }
  }

  @override
  Future<List<RestaurantModel>> getCachedRestaurants() async {
    try {
      // Check if cache is still valid
      if (!await _isCacheValid()) {
        throw const CacheException(
          message: 'Cache đã hết hạn',
          code: 'cache-expired',
        );
      }

      final restaurantsString = sharedPreferences.getString(_restaurantsKey);
      if (restaurantsString == null) {
        throw const CacheException(
          message: 'Không tìm thấy cache danh sách nhà hàng',
          code: 'no-cached-restaurants',
        );
      }

      final restaurantsJson = json.decode(restaurantsString) as List;
      return restaurantsJson
          .map((json) => RestaurantModel.fromJson(json))
          .toList();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Lỗi khi đọc cache danh sách nhà hàng: ${e.toString()}',
        code: 'get-cached-restaurants-failed',
      );
    }
  }

  @override
  Future<void> cacheRestaurant(RestaurantModel restaurant) async {
    try {
      await sharedPreferences.setString(
        '$_restaurantPrefix${restaurant.id}',
        json.encode(restaurant.toJson()),
      );
    } catch (e) {
      throw CacheException(
        message: 'Lỗi khi lưu cache nhà hàng: ${e.toString()}',
        code: 'cache-restaurant-failed',
      );
    }
  }

  @override
  Future<RestaurantModel> getCachedRestaurant(String restaurantId) async {
    try {
      final restaurantString = sharedPreferences.getString(
        '$_restaurantPrefix$restaurantId',
      );
      
      if (restaurantString == null) {
        throw const CacheException(
          message: 'Không tìm thấy cache nhà hàng',
          code: 'no-cached-restaurant',
        );
      }

      final restaurantJson = json.decode(restaurantString);
      return RestaurantModel.fromJson(restaurantJson);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Lỗi khi đọc cache nhà hàng: ${e.toString()}',
        code: 'get-cached-restaurant-failed',
      );
    }
  }

  @override
  Future<void> cacheRestaurantCategories(List<String> categories) async {
    try {
      await sharedPreferences.setString(
        _categoriesKey,
        json.encode(categories),
      );
    } catch (e) {
      throw CacheException(
        message: 'Lỗi khi lưu cache danh mục: ${e.toString()}',
        code: 'cache-categories-failed',
      );
    }
  }

  @override
  Future<List<String>> getCachedRestaurantCategories() async {
    try {
      final categoriesString = sharedPreferences.getString(_categoriesKey);
      if (categoriesString == null) {
        throw const CacheException(
          message: 'Không tìm thấy cache danh mục',
          code: 'no-cached-categories',
        );
      }

      final categoriesJson = json.decode(categoriesString) as List;
      return categoriesJson.cast<String>();
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Lỗi khi đọc cache danh mục: ${e.toString()}',
        code: 'get-cached-categories-failed',
      );
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      // Remove restaurants cache
      await sharedPreferences.remove(_restaurantsKey);
      await sharedPreferences.remove(_lastCacheTimeKey);
      await sharedPreferences.remove(_categoriesKey);

      // Remove individual restaurant caches
      final keys = sharedPreferences.getKeys();
      for (final key in keys) {
        if (key.startsWith(_restaurantPrefix)) {
          await sharedPreferences.remove(key);
        }
      }
    } catch (e) {
      throw CacheException(
        message: 'Lỗi khi xóa cache: ${e.toString()}',
        code: 'clear-cache-failed',
      );
    }
  }

  @override
  Future<bool> hasRestaurantsCache() async {
    try {
      return sharedPreferences.containsKey(_restaurantsKey) && 
             await _isCacheValid();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> hasCategoriesCache() async {
    try {
      return sharedPreferences.containsKey(_categoriesKey);
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isCacheValid() async {
    final cacheTime = sharedPreferences.getInt(_lastCacheTimeKey);
    if (cacheTime == null) return false;

    final cacheDateTime = DateTime.fromMillisecondsSinceEpoch(cacheTime);
    final now = DateTime.now();
    final difference = now.difference(cacheDateTime);

    return difference.inHours < _cacheValidityHours;
  }
}