import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/restaurant.dart';

abstract class RestaurantRepository {
  /// Get all restaurants with optional filtering
  Stream<Either<Failure, List<Restaurant>>> getRestaurants({
    String? category,
    double? minRating,
    String? searchQuery,
    int? limit,
  });

  /// Get restaurant by ID
  Future<Either<Failure, Restaurant>> getRestaurantById(String restaurantId);

  /// Get restaurants near a location
  Stream<Either<Failure, List<Restaurant>>> getRestaurantsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    String? category,
    double? minRating,
    int? limit,
  });

  /// Add new restaurant (admin functionality)
  Future<Either<Failure, Restaurant>> addRestaurant({
    required String name,
    required String description,
    required String address,
    String? phoneNumber,
    String? website,
    required List<String> imageUrls,
    required double latitude,
    required double longitude,
    required List<String> categories,
    String? ownerId,
  });

  /// Update restaurant information
  Future<Either<Failure, Restaurant>> updateRestaurant({
    required String restaurantId,
    String? name,
    String? description,
    String? address,
    String? phoneNumber,
    String? website,
    List<String>? imageUrls,
    double? latitude,
    double? longitude,
    List<String>? categories,
    bool? isActive,
  });

  /// Delete restaurant
  Future<Either<Failure, void>> deleteRestaurant(String restaurantId);

  /// Update restaurant rating (called by Cloud Function)
  Future<Either<Failure, void>> updateRestaurantRating({
    required String restaurantId,
    required double averageRating,
    required int totalReviews,
  });

  /// Get restaurant categories
  Future<Either<Failure, List<String>>> getRestaurantCategories();
}