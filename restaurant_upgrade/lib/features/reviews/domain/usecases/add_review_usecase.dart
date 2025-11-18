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

class AddReviewUseCase implements UseCase<Review, AddReviewParams> {
  final ReviewRepository repository;

  AddReviewUseCase(this.repository);

  @override
  Future<Either<Failure, Review>> call(AddReviewParams params) async {
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

    // Validate user display name
    final displayNameValidation = Validators.validateDisplayName(params.userDisplayName);
    if (displayNameValidation != null) {
      return Left(ValidationFailure(
        message: displayNameValidation,
        code: 'invalid-user-display-name',
      ));
    }

    // Validate rating
    final ratingValidation = Validators.validateRating(params.rating);
    if (ratingValidation != null) {
      return Left(ValidationFailure(
        message: ratingValidation,
        code: 'invalid-rating',
      ));
    }

    // Validate comment
    final commentValidation = Validators.validateReviewComment(params.comment);
    if (commentValidation != null) {
      return Left(ValidationFailure(
        message: commentValidation,
        code: 'invalid-comment',
      ));
    }

    // Validate images
    if (params.images != null) {
      if (params.images!.length > AppConstants.maxImagesPerReview) {
        return Left(ValidationFailure(
          message: 'Không được thêm quá ${AppConstants.maxImagesPerReview} hình ảnh',
          code: 'too-many-images',
        ));
      }

      // Validate each image
      for (final image in params.images!) {
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

    return await repository.addReview(
      restaurantId: params.restaurantId,
      userId: params.userId,
      userDisplayName: params.userDisplayName.trim(),
      userPhotoUrl: params.userPhotoUrl?.trim(),
      rating: params.rating,
      comment: params.comment.trim(),
      images: params.images,
    );
  }
}

class AddReviewParams extends Equatable {
  final String restaurantId;
  final String userId;
  final String userDisplayName;
  final String? userPhotoUrl;
  final int rating;
  final String comment;
  final List<File>? images;

  const AddReviewParams({
    required this.restaurantId,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    this.images,
  });

  @override
  List<Object?> get props => [
    restaurantId,
    userId,
    userDisplayName,
    userPhotoUrl,
    rating,
    comment,
    images,
  ];

  @override
  String toString() {
    return 'AddReviewParams(restaurantId: $restaurantId, userId: $userId, userDisplayName: $userDisplayName, userPhotoUrl: $userPhotoUrl, rating: $rating, comment: $comment, images: ${images?.length ?? 0} images)';
  }
}