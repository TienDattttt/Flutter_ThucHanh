import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class GetRestaurantsUseCase implements UseCase<Stream<List<Restaurant>>, GetRestaurantsParams> {
  final RestaurantRepository repository;

  GetRestaurantsUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<List<Restaurant>>>> call(GetRestaurantsParams params) async {
    // Validate parameters
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

    if (params.minRating != null && 
        (params.minRating! < AppConstants.minRating || 
         params.minRating! > AppConstants.maxRating)) {
      return Left(ValidationFailure(
        message: 'Đánh giá tối thiểu phải từ ${AppConstants.minRating} đến ${AppConstants.maxRating}',
        code: 'invalid-min-rating',
      ));
    }

    try {
      final restaurantsStream = repository.getRestaurants(
        category: params.category,
        minRating: params.minRating,
        searchQuery: params.searchQuery,
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
        message: 'Lỗi khi tải danh sách nhà hàng: ${e.toString()}',
        code: 'get-restaurants-failed',
      ));
    }
  }
}

class GetRestaurantsParams extends Equatable {
  final String? category;
  final double? minRating;
  final String? searchQuery;
  final int? limit;

  const GetRestaurantsParams({
    this.category,
    this.minRating,
    this.searchQuery,
    this.limit,
  });

  @override
  List<Object?> get props => [category, minRating, searchQuery, limit];

  @override
  String toString() {
    return 'GetRestaurantsParams(category: $category, minRating: $minRating, searchQuery: $searchQuery, limit: $limit)';
  }
}