import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/string_utils.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class UnmarkReviewAsHelpfulUseCase implements UseCase<Review, UnmarkReviewAsHelpfulParams> {
  final ReviewRepository repository;

  UnmarkReviewAsHelpfulUseCase(this.repository);

  @override
  Future<Either<Failure, Review>> call(UnmarkReviewAsHelpfulParams params) async {
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

    return await repository.unmarkReviewAsHelpful(
      reviewId: params.reviewId,
      userId: params.userId,
    );
  }
}

class UnmarkReviewAsHelpfulParams extends Equatable {
  final String reviewId;
  final String userId;

  const UnmarkReviewAsHelpfulParams({
    required this.reviewId,
    required this.userId,
  });

  @override
  List<Object> get props => [reviewId, userId];

  @override
  String toString() {
    return 'UnmarkReviewAsHelpfulParams(reviewId: $reviewId, userId: $userId)';
  }
}