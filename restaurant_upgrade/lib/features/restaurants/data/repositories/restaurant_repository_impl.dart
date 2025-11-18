import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../domain/entities/restaurant.dart';
import '../../domain/repositories/restaurant_repository.dart';
import '../datasources/restaurant_remote_data_source.dart';
import '../datasources/restaurant_local_data_source.dart';
import '../models/restaurant_model.dart';

class RestaurantRepositoryImpl implements RestaurantRepository {
  final RestaurantRemoteDataSource remoteDataSource;
  final RestaurantLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  RestaurantRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Stream<Either<Failure, List<Restaurant>>> getRestaurants({
    String? category,
    double? minRating,
    String? searchQuery,
    int? limit,
  }) async* {
    if (await networkInfo.isConnected) {
      try {
        yield* remoteDataSource.getRestaurants(
          category: category,
          minRating: minRating,
          searchQuery: searchQuery,
          limit: limit,
        ).map((restaurantModels) async {
          // Cache the restaurants if no filters are applied (base data)
          if (category == null && minRating == null && searchQuery == null) {
            try {
              await localDataSource.cacheRestaurants(restaurantModels);
            } catch (e) {
              // Continue even if caching fails
            }
          }

          final restaurants = restaurantModels
              .map((model) => model.toEntity())
              .toList();
          return Right<Failure, List<Restaurant>>(restaurants);
        }).asyncMap((futureResult) async => await futureResult)
        .handleError((error) {
          if (error is ServerException) {
            return Left<Failure, List<Restaurant>>(
              ServerFailure(message: error.message, code: error.code),
            );
          }
          return Left<Failure, List<Restaurant>>(
            ErrorMapper.mapGenericException(error as Exception),
          );
        });
      } catch (e) {
        yield Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      // Try to get cached data when offline
      try {
        if (await localDataSource.hasRestaurantsCache()) {
          final cachedRestaurants = await localDataSource.getCachedRestaurants();
          var restaurants = cachedRestaurants.map((model) => model.toEntity()).toList();

          // Apply client-side filtering for cached data
          if (category != null) {
            restaurants = restaurants.where((r) => r.categories.contains(category)).toList();
          }
          if (minRating != null) {
            restaurants = restaurants.where((r) => r.averageRating >= minRating).toList();
          }
          if (searchQuery != null) {
            final query = searchQuery.toLowerCase();
            restaurants = restaurants.where((r) => 
              r.name.toLowerCase().contains(query) ||
              r.description.toLowerCase().contains(query) ||
              r.address.toLowerCase().contains(query)
            ).toList();
          }
          if (limit != null && restaurants.length > limit) {
            restaurants = restaurants.take(limit).toList();
          }

          yield Right(restaurants);
        } else {
          yield const Left(NetworkFailure(
            message: 'Không có kết nối internet và không có dữ liệu offline',
            code: 'no-internet-no-cache',
          ));
        }
      } catch (e) {
        yield const Left(NetworkFailure(
          message: 'Không có kết nối internet',
          code: 'no-internet',
        ));
      }
    }
  }

  @override
  Future<Either<Failure, Restaurant>> getRestaurantById(String restaurantId) async {
    if (await networkInfo.isConnected) {
      try {
        final restaurantModel = await remoteDataSource.getRestaurantById(restaurantId);
        
        // Cache the restaurant
        try {
          await localDataSource.cacheRestaurant(restaurantModel);
        } catch (e) {
          // Continue even if caching fails
        }
        
        return Right(restaurantModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      // Try to get cached restaurant when offline
      try {
        final cachedRestaurant = await localDataSource.getCachedRestaurant(restaurantId);
        return Right(cachedRestaurant.toEntity());
      } on CacheException {
        return const Left(NetworkFailure(
          message: 'Không có kết nối internet và không có dữ liệu offline',
          code: 'no-internet-no-cache',
        ));
      } catch (e) {
        return const Left(NetworkFailure(
          message: 'Không có kết nối internet',
          code: 'no-internet',
        ));
      }
    }
  }

  @override
  Stream<Either<Failure, List<Restaurant>>> getRestaurantsNearLocation({
    required double latitude,
    required double longitude,
    required double radiusInKm,
    String? category,
    double? minRating,
    int? limit,
  }) async* {
    if (await networkInfo.isConnected) {
      try {
        yield* remoteDataSource.getRestaurantsNearLocation(
          latitude: latitude,
          longitude: longitude,
          radiusInKm: radiusInKm,
          category: category,
          minRating: minRating,
          limit: limit,
        ).map((restaurantModels) {
          final restaurants = restaurantModels
              .map((model) => model.toEntity())
              .toList();
          return Right<Failure, List<Restaurant>>(restaurants);
        }).handleError((error) {
          if (error is ServerException) {
            return Left<Failure, List<Restaurant>>(
              ServerFailure(message: error.message, code: error.code),
            );
          }
          return Left<Failure, List<Restaurant>>(
            ErrorMapper.mapGenericException(error as Exception),
          );
        });
      } catch (e) {
        yield Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      yield const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
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
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final restaurantModel = RestaurantModel.create(
          name: name,
          description: description,
          address: address,
          phoneNumber: phoneNumber,
          website: website,
          imageUrls: imageUrls,
          latitude: latitude,
          longitude: longitude,
          categories: categories,
          ownerId: ownerId,
        );

        final addedRestaurant = await remoteDataSource.addRestaurant(restaurantModel);
        return Right(addedRestaurant.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
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
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // First get the current restaurant
        final currentRestaurant = await remoteDataSource.getRestaurantById(restaurantId);
        
        // Update with new values
        final updatedRestaurant = currentRestaurant.copyWith(
          name: name,
          description: description,
          address: address,
          phoneNumber: phoneNumber,
          website: website,
          imageUrls: imageUrls,
          latitude: latitude,
          longitude: longitude,
          categories: categories,
          isActive: isActive,
          updatedAt: DateTime.now(),
        );

        final result = await remoteDataSource.updateRestaurant(updatedRestaurant);
        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteRestaurant(String restaurantId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteRestaurant(restaurantId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateRestaurantRating({
    required String restaurantId,
    required double averageRating,
    required int totalReviews,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateRestaurantRating(
          restaurantId: restaurantId,
          averageRating: averageRating,
          totalReviews: totalReviews,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getRestaurantCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final categories = await remoteDataSource.getRestaurantCategories();
        
        // Cache the categories
        try {
          await localDataSource.cacheRestaurantCategories(categories);
        } catch (e) {
          // Continue even if caching fails
        }
        
        return Right(categories);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      // Try to get cached categories when offline
      try {
        if (await localDataSource.hasCategoriesCache()) {
          final cachedCategories = await localDataSource.getCachedRestaurantCategories();
          return Right(cachedCategories);
        } else {
          return const Left(NetworkFailure(
            message: 'Không có kết nối internet và không có dữ liệu offline',
            code: 'no-internet-no-cache',
          ));
        }
      } catch (e) {
        return const Left(NetworkFailure(
          message: 'Không có kết nối internet',
          code: 'no-internet',
        ));
      }
    }
  }
}