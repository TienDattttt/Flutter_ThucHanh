import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/string_utils.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class MarkReviewAsHelpfulUseCase implements UseCase<Review, MarkReviewAsHelpfulParams> {
  final ReviewRepository repository;

  MarkReviewAsHelpfulUseCase(this.repository);

  @override
  Future<Either<Failure, Review>> call(MarkReviewAsHelpfulParams params) async {
    // Validate review ID
    if (StringUtils.isNullOrEmpty(params.reviewId)) {
      return const Left(ValidationFailure(
        message: 'ID đánh giá không được để trống',
        code: 'invalid-review-id',
      ));
    }

    // Validate user ID
    if (StringUtils.isNullOrEmpty(params.userId)) {
      return const Left(ValidationFailure(
        message: 'ID người dùng không được để trống',
        code: 'invalid-user-id',
      ));
    }

    return await repository.markReviewAsHelpful(
      reviewId: params.reviewId,
      userId: params.userId,
    );
  }
}

class MarkReviewAsHelpfulParams extends Equatable {
  final String reviewId;
  final String userId;

  const MarkReviewAsHelpfulParams({
    required this.reviewId,
    required this.userId,
  });

  @override
  List<Object> get props => [reviewId, userId];

  @override
  String toString() {
    return 'MarkReviewAsHelpfulParams(reviewId: $reviewId, userId: $userId)';
  }
}