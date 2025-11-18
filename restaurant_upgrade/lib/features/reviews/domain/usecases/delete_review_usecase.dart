import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/string_utils.dart';
import '../repositories/review_repository.dart';

class DeleteReviewUseCase implements UseCase<void, DeleteReviewParams> {
  final ReviewRepository repository;

  DeleteReviewUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteReviewParams params) async {
    // Validate review ID
    if (StringUtils.isNullOrEmpty(params.reviewId)) {
      return const Left(ValidationFailure(
        message: 'ID đánh giá không được để trống',
        code: 'invalid-review-id',
      ));
    }

    return await repository.deleteReview(params.reviewId);
  }
}

class DeleteReviewParams extends Equatable {
  final String reviewId;

  const DeleteReviewParams({
    required this.reviewId,
  });

  @override
  List<Object> get props => [reviewId];

  @override
  String toString() {
    return 'DeleteReviewParams(reviewId: $reviewId)';
  }
}