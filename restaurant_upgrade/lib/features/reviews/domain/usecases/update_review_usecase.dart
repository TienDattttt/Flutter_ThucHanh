import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/review.dart';
import '../repositories/review_repository.dart';

class UpdateReviewUseCase implements UseCase<Review, UpdateReviewParams> {
  final ReviewRepository repository;

  UpdateReviewUseCase(this.repository);

  @override
  Future<Either<Failure, Review>> call(UpdateReviewParams params) async {
    // Validate review ID
    if (StringUtils.isNullOrEmpty(params.reviewId)) {
      return const Left(ValidationFailure(
        message: 'ID đánh giá không được để trống',
        code: 'invalid-review-id',
      ));
    }

    // Validate rating if provided
    if (params.rating != null) {
      final ratingValidation = Validators.validateRating(params.rating);
      if (ratingValidation != null) {
        return Left(ValidationFailure(
          message: ratingValidation,
          code: 'invalid-rating',
        ));
      }
    }

    // Validate comment if provided
    if (params.comment != null) {
      final commentValidation = Validators.validateReviewComment(params.comment);
      if (commentValidation != null) {
        return Left(ValidationFailure(
          message: commentValidation,
          code: 'invalid-comment',
        ));
      }
    }

    // Check if at least one field is being updated
    if (params.rating == null && 
        params.comment == null && 
        (params.newImages == null || params.newImages!.isEmpty) &&
        (params.imagesToDelete == null || params.imagesToDelete!.isEmpty)) {
      return const Left(ValidationFailure(
        message: 'Vui lòng cung cấp ít nhất một trường để cập nhật',
        code: 'no-fields-to-update',
      ));
    }

    // Validate new images
    if (params.newImages != null && params.newImages!.isNotEmpty) {
      if (params.newImages!.length > AppConstants.maxImagesPerReview) {
        return Left(ValidationFailure(
          message: 'Không được thêm quá ${AppConstants.maxImagesPerReview} hình ảnh',
          code: 'too-many-images',
        ));
      }

      // Validate each new image
      for (final image in params.newImages!) {
        if (!await image.exists()) {
          return const Left(ValidationFailure(
            message: 'File hình ảnh không tồn tại',
            code: 'image-file-not-exists',
          ));
        }

        if (!ImageUtils.isValidImageFormat(image.path)) {
          return const Left(ValidationFailure(
            message: 'Định dạng hình ảnh không được hỗ trợ',
            code: 'invalid-image-format',
          ));
        }

        // Check file size
        final fileSize = await image.length();
        if (fileSize > AppConstants.maxImageSizeMB * 1024 * 1024) {
          return Left(ValidationFailure(
            message: 'Kích thước hình ảnh không được vượt quá ${AppConstants.maxImageSizeMB}MB',
            code: 'image-too-large',
          ));
        }
      }
    }

    // Validate images to delete
    if (params.imagesToDelete != null) {
      for (final imageUrl in params.imagesToDelete!) {
        if (!StringUtils.isValidUrl(imageUrl)) {
          return const Left(ValidationFailure(
            message: 'URL hình ảnh không hợp lệ',
            code: 'invalid-image-url',
          ));
        }
      }
    }

    return await repository.updateReview(
      reviewId: params.reviewId,
      rating: params.rating,
      comment: params.comment?.trim(),
      newImages: params.newImages,
      imagesToDelete: params.imagesToDelete,
    );
  }
}

class UpdateReviewParams extends Equatable {
  final String reviewId;
  final int? rating;
  final String? comment;
  final List<File>? newImages;
  final List<String>? imagesToDelete;

  const UpdateReviewParams({
    required this.reviewId,
    this.rating,
    this.comment,
    this.newImages,
    this.imagesToDelete,
  });

  @override
  List<Object?> get props => [
    reviewId,
    rating,
    comment,
    newImages,
    imagesToDelete,
  ];

  @override
  String toString() {
    return 'UpdateReviewParams(reviewId: $reviewId, rating: $rating, comment: $comment, newImages: ${newImages?.length ?? 0} images, imagesToDelete: ${imagesToDelete?.length ?? 0} images)';
  }
}