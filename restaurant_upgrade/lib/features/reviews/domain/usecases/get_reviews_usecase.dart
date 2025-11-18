import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class GetReviewsUseCase implements UseCase<Stream<List<Review>>, GetReviewsParams> {
  final ReviewRepository repository;

  GetReviewsUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<List<Review>>>> call(GetReviewsParams params) async {
    // Validate restaurant ID
    if (StringUtils.isNullOrEmpty(params.restaurantId)) {
      return const Left(ValidationFailure(
        message: 'ID nhà hàng không được để trống',
        code: 'invalid-restaurant-id',
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

    // Validate order by
    const validOrderBy = ['newest', 'oldest', 'rating_desc', 'rating_asc', 'helpful'];
    if (params.orderBy != null && !validOrderBy.contains(params.orderBy)) {
      return const Left(ValidationFailure(
        message: 'Kiểu sắp xếp không hợp lệ',
        code: 'invalid-order-by',
      ));
    }

    try {
      final reviewsStream = repository.getReviewsForRestaurant(
        restaurantId: params.restaurantId,
        limit: params.limit ?? AppConstants.reviewListPageSize,
        orderBy: params.orderBy,
      );

      // Convert Stream<Either<Failure, List<Review>>> to Either<Failure, Stream<List<Review>>>
      return Right(reviewsStream.map((either) {
        return either.fold(
          (failure) => throw Exception(failure.message),
          (reviews) => reviews,
        );
      }));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Lỗi khi tải danh sách đánh giá: ${e.toString()}',
        code: 'get-reviews-failed',
      ));
    }
  }
}

class GetReviewsParams extends Equatable {
  final String restaurantId;
  final int? limit;
  final String? orderBy;

  const GetReviewsParams({
    required this.restaurantId,
    this.limit,
    this.orderBy,
  });

  @override
  List<Object?> get props => [restaurantId, limit, orderBy];

  @override
  String toString() {
    return 'GetReviewsParams(restaurantId: $restaurantId, limit: $limit, orderBy: $orderBy)';
  }
}