import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/location_utils.dart';
import '../models/restaurant_model.dart';

abstract class RestaurantRemoteDataSource {
  /// Get all restaurants with optional filtering
  Stream<List<RestaurantModel>> getRestaurants({
    String? category,
    double? minRating,
    String? searchQuery,
    int? limit,
  });

  /// Get restaurant by ID
  Future<RestaurantModel> getRestaurantById(String restaurantId);

  /// Get restaurants near a location
  Stream<List<RestaurantModel>> getRestaurantsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    String? category,
    double? minRating,
    int? limit,
  });

  /// Add new restaurant
  Future<RestaurantModel> addRestaurant(RestaurantModel restaurant);

  /// Update restaurant information
  Future<RestaurantModel> updateRestaurant(RestaurantModel restaurant);

  /// Delete restaurant
  Future<void> deleteRestaurant(String restaurantId);

  /// Update restaurant rating
  Future<void> updateRestaurantRating({
    required String restaurantId,
    required double averageRating,
    required int totalReviews,
  });

  /// Get restaurant categories
  Future<List<String>> getRestaurantCategories();

  /// Search restaurants by name
  Stream<List<RestaurantModel>> searchRestaurants({
    required String query,
    String? category,
    double? minRating,
    int? limit,
  });
}

class RestaurantRemoteDataSourceImpl implements RestaurantRemoteDataSource {
  final FirebaseFirestore firestore;

  RestaurantRemoteDataSourceImpl({
    required this.firestore,
  });

  @override
  Stream<List<RestaurantModel>> getRestaurants({
    String? category,
    double? minRating,
    String? searchQuery,
    int? limit,
  }) {
    try {
      print('🔍 RestaurantRemoteDataSource: Getting restaurants with filters:');
      print('   Category: $category');
      print('   MinRating: $minRating');
      print('   SearchQuery: $searchQuery');
      print('   Limit: $limit');
      
      Query query = firestore
          .collection(AppConstants.restaurantsCollection)
          .where('isActive', isEqualTo: true);
      
      print('📊 RestaurantRemoteDataSource: Base query created');

      // Apply category filter
      if (category != null && category.isNotEmpty) {
        query = query.where('categories', arrayContains: category);
      }

      // Apply minimum rating filter
      if (minRating != null && minRating > 0) {
        query = query.where('averageRating', isGreaterThanOrEqualTo: minRating);
      }

      // Apply search query filter (basic text search)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        // Firestore doesn't support full-text search, so we'll use array-contains for categories
        // and client-side filtering for name/description
        query = query.orderBy('name');
      } else {
        // Temporary: Use simple ordering to avoid index requirement
        // TODO: Re-enable after creating composite indexes
        // query = query.orderBy('averageRating', descending: true);
        query = query.orderBy('name');
      }

      // Apply limit
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        print('📄 RestaurantRemoteDataSource: Received ${snapshot.docs.length} documents from Firestore');
        
        var restaurants = snapshot.docs
            .map((doc) {
              try {
                return RestaurantModel.fromFirestore(doc);
              } catch (e) {
                print('❌ Error parsing document ${doc.id}: $e');
                return null;
              }
            })
            .where((restaurant) => restaurant != null)
            .cast<RestaurantModel>()
            .toList();

        print('✅ RestaurantRemoteDataSource: Successfully parsed ${restaurants.length} restaurants');

        // Client-side search filtering if search query is provided
        if (searchQuery != null && searchQuery.isNotEmpty) {
          final searchLower = searchQuery.toLowerCase();
          restaurants = restaurants.where((restaurant) {
            return restaurant.name.toLowerCase().contains(searchLower) ||
                restaurant.description.toLowerCase().contains(searchLower) ||
                restaurant.address.toLowerCase().contains(searchLower) ||
                restaurant.categories.any((cat) => 
                    cat.toLowerCase().contains(searchLower));
          }).toList();
          print('🔍 RestaurantRemoteDataSource: After search filter: ${restaurants.length} restaurants');
        }

        print('🏪 RestaurantRemoteDataSource: Returning ${restaurants.length} restaurants');
        return restaurants;
      });
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi tải danh sách nhà hàng: ${e.toString()}',
        code: 'get-restaurants-failed',
      );
    }
  }

  @override
  Future<RestaurantModel> getRestaurantById(String restaurantId) async {
    try {
      final doc = await firestore
          .collection(AppConstants.restaurantsCollection)
          .doc(restaurantId)
          .get();

      if (!doc.exists) {
        throw const ServerException(
          message: 'Không tìm thấy nhà hàng',
          code: 'restaurant-not-found',
        );
      }

      return RestaurantModel.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Lỗi khi tải thông tin nhà hàng: ${e.toString()}',
        code: 'get-restaurant-failed',
      );
    }
  }

  @override
  Stream<List<RestaurantModel>> getRestaurantsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    String? category,
    double? minRating,
    int? limit,
  }) {
    try {
      // Calculate bounding box for the search area
      final boundingBox = LocationUtils.getBoundingBox(
        latitude,
        longitude,
        radiusInKm,
      );

      Query query = firestore
          .collection(AppConstants.restaurantsCollection)
          .where('isActive', isEqualTo: true)
          .where('latitude', isGreaterThanOrEqualTo: boundingBox[0])
          .where('latitude', isLessThanOrEqualTo: boundingBox[2]);

      // Apply category filter
      if (category != null && category.isNotEmpty) {
        query = query.where('categories', arrayContains: category);
      }

      // Apply minimum rating filter
      if (minRating != null && minRating > 0) {
        query = query.where('averageRating', isGreaterThanOrEqualTo: minRating);
      }

      return query.snapshots().map((snapshot) {
        var restaurants = snapshot.docs
            .map((doc) => RestaurantModel.fromFirestore(doc))
            .where((restaurant) {
              // Additional longitude filtering (Firestore limitation)
              if (restaurant.longitude < boundingBox[1] || 
                  restaurant.longitude > boundingBox[3]) {
                return false;
              }

              // Calculate actual distance and filter by radius
              final distance = LocationUtils.calculateDistance(
                latitude,
                longitude,
                restaurant.latitude,
                restaurant.longitude,
              );
              return distance <= radiusInKm;
            })
            .toList();

        // Sort by distance (closest first)
        restaurants.sort((a, b) {
          final distanceA = LocationUtils.calculateDistance(
            latitude, longitude, a.latitude, a.longitude);
          final distanceB = LocationUtils.calculateDistance(
            latitude, longitude, b.latitude, b.longitude);
          return distanceA.compareTo(distanceB);
        });

        // Apply limit
        if (limit != null && limit > 0 && restaurants.length > limit) {
          restaurants = restaurants.take(limit).toList();
        }

        return restaurants;
      });
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi tìm kiếm nhà hàng theo vị trí: ${e.toString()}',
        code: 'get-restaurants-near-location-failed',
      );
    }
  }

  @override
  Future<RestaurantModel> addRestaurant(RestaurantModel restaurant) async {
    try {
      final docRef = await firestore
          .collection(AppConstants.restaurantsCollection)
          .add(restaurant.toFirestore());

      final doc = await docRef.get();
      return RestaurantModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi thêm nhà hàng: ${e.toString()}',
        code: 'add-restaurant-failed',
      );
    }
  }

  @override
  Future<RestaurantModel> updateRestaurant(RestaurantModel restaurant) async {
    try {
      await firestore
          .collection(AppConstants.restaurantsCollection)
          .doc(restaurant.id)
          .update({
        ...restaurant.toFirestore(),
        'updatedAt': Timestamp.now(),
      });

      final doc = await firestore
          .collection(AppConstants.restaurantsCollection)
          .doc(restaurant.id)
          .get();

      return RestaurantModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi cập nhật nhà hàng: ${e.toString()}',
        code: 'update-restaurant-failed',
      );
    }
  }

  @override
  Future<void> deleteRestaurant(String restaurantId) async {
    try {
      await firestore
          .collection(AppConstants.restaurantsCollection)
          .doc(restaurantId)
          .delete();
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi xóa nhà hàng: ${e.toString()}',
        code: 'delete-restaurant-failed',
      );
    }
  }

  @override
  Future<void> updateRestaurantRating({
    required String restaurantId,
    required double averageRating,
    required int totalReviews,
  }) async {
    try {
      await firestore
          .collection(AppConstants.restaurantsCollection)
          .doc(restaurantId)
          .update({
        'averageRating': averageRating,
        'totalReviews': totalReviews,
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi cập nhật đánh giá nhà hàng: ${e.toString()}',
        code: 'update-restaurant-rating-failed',
      );
    }
  }

  @override
  Future<List<String>> getRestaurantCategories() async {
    try {
      // Try to get categories from a dedicated collection first
      final categoriesSnapshot = await firestore
          .collection(AppConstants.categoriesCollection)
          .orderBy('name')
          .get();

      if (categoriesSnapshot.docs.isNotEmpty) {
        return categoriesSnapshot.docs
            .map((doc) => doc.data()['name'] as String)
            .toList();
      }

      // Fallback to default categories
      return AppConstants.defaultCategories;
    } catch (e) {
      // Return default categories if there's an error
      return AppConstants.defaultCategories;
    }
  }

  @override
  Stream<List<RestaurantModel>> searchRestaurants({
    required String query,
    String? category,
    double? minRating,
    int? limit,
  }) {
    try {
      // Use the general getRestaurants method with search query
      return getRestaurants(
        category: category,
        minRating: minRating,
        searchQuery: query,
        limit: limit,
      );
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi tìm kiếm nhà hàng: ${e.toString()}',
        code: 'search-restaurants-failed',
      );
    }
  }
}