import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/location_utils.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantsNearLocationUseCase implements UseCase<Stream<List<Restaurant>>, GetRestaurantsNearLocationParams> {
  final RestaurantRepository repository;

  GetRestaurantsNearLocationUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<List<Restaurant>>>> call(GetRestaurantsNearLocationParams params) async {
    // Validate coordinates
    if (!LocationUtils.isValidCoordinates(params.latitude, params.longitude)) {
      return const Left(ValidationFailure(
        message: 'Tọa độ không hợp lệ',
        code: 'invalid-coordinates',
      ));
    }

    // Validate radius
    if (params.radiusInKm <= 0) {
      return const Left(ValidationFailure(
        message: 'Bán kính tìm kiếm phải lớn hơn 0',
        code: 'invalid-radius',
      ));
    }

    if (params.radiusInKm > AppConstants.maxSearchRadius) {
      return Left(ValidationFailure(
        message: 'Bán kính tìm kiếm không được vượt quá ${AppConstants.maxSearchRadius}km',
        code: 'radius-too-large',
      ));
    }

    // Validate limit
    if (params.limit != null && params.limit! <= 0) {
      return const Left(ValidationFailure(
        message: 'Số lượng giới hạn phải lớn hơn 0',
        code: 'invalid-limit',
      ));
    }

    if (params.limit != null && params.limit! > AppConstants.maxPageSize) {
      return Left(ValidationFailure(
        message: 'Số lượng giới hạn không được vượt quá ${AppConstants.maxPageSize}',
        code: 'limit-too-large',
      ));
    }

    // Validate minimum rating
    if (params.minRating != null && 
        (params.minRating! < AppConstants.minRating || 
         params.minRating! > AppConstants.maxRating)) {
      return Left(ValidationFailure(
        message: 'Đánh giá tối thiểu phải từ ${AppConstants.minRating} đến ${AppConstants.maxRating}',
        code: 'invalid-min-rating',
      ));
    }

    try {
      final restaurantsStream = repository.getRestaurantsNearLocation(
        latitude: params.latitude,
        longitude: params.longitude,
        radiusInKm: params.radiusInKm,
        category: params.category,
        minRating: params.minRating,
        limit: params.limit ?? AppConstants.restaurantListPageSize,
      );

      // Convert Stream<Either<Failure, List<Restaurant>>> to Either<Failure, Stream<List<Restaurant>>>
      return Right(restaurantsStream.map((either) {
        return either.fold(
          (failure) => throw Exception(failure.message),
          (restaurants) => restaurants,
        );
      }));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Lỗi khi tìm kiếm nhà hàng theo vị trí: ${e.toString()}',
        code: 'get-restaurants-near-location-failed',
      ));
    }
  }
}

class GetRestaurantsNearLocationParams extends Equatable {
  final double latitude;
  final double longitude;
  final double radiusInKm;
  final String? category;
  final double? minRating;
  final int? limit;

  const GetRestaurantsNearLocationParams({
    required this.latitude,
    required this.longitude,
    required this.radiusInKm,
    this.category,
    this.minRating,
    this.limit,
  });

  @override
  List<Object?> get props => [
    latitude,
    longitude,
    radiusInKm,
    category,
    minRating,
    limit,
  ];

  @override
  String toString() {
    return 'GetRestaurantsNearLocationParams(latitude: $latitude, longitude: $longitude, radiusInKm: $radiusInKm, category: $category, minRating: $minRating, limit: $limit)';
  }
}