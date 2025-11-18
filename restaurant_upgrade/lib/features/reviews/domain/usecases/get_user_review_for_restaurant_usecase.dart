import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/string_utils.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetUserReviewForRestaurantUseCase implements UseCase<Review?, GetUserReviewForRestaurantParams> {
  final ReviewRepository repository;

  GetUserReviewForRestaurantUseCase(this.repository);

  @override
  Future<Either<Failure, Review?>> call(GetUserReviewForRestaurantParams params) async {
    // Validate restaurant ID
    if (StringUtils.isNullOrEmpty(params.restaurantId)) {
      return const Left(ValidationFailure(
        message: 'ID nhà hàng không được để trống',
        code: 'invalid-restaurant-id',
      ));
    }

    // Validate user ID
    if (StringUtils.isNullOrEmpty(params.userId)) {
      return const Left(ValidationFailure(
        message: 'ID người dùng không được để trống',
        code: 'invalid-user-id',
      ));
    }

    return await repository.getUserReviewForRestaurant(
      restaurantId: params.restaurantId,
      userId: params.userId,
    );
  }
}

class GetUserReviewForRestaurantParams extends Equatable {
  final String restaurantId;
  final String userId;

  const GetUserReviewForRestaurantParams({
    required this.restaurantId,
    required this.userId,
  });

  @override
  List<Object> get props => [restaurantId, userId];

  @override
  String toString() {
    return 'GetUserReviewForRestaurantParams(restaurantId: $restaurantId, userId: $userId)';
  }
}