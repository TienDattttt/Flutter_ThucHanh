import '../../../../core/error/failures.dart';

/// Specific review failures
class ReviewNotFoundFailure extends ServerFailure {
  const ReviewNotFoundFailure()
      : super(
          message: 'Không tìm thấy đánh giá',
          code: 'review-not-found',
        );
}

class ReviewAlreadyExistsFailure extends ServerFailure {
  const ReviewAlreadyExistsFailure()
      : super(
          message: 'Bạn đã đánh giá nhà hàng này rồi',
          code: 'review-already-exists',
        );
}

class ReviewAccessDeniedFailure extends ServerFailure {
  const ReviewAccessDeniedFailure()
      : super(
          message: 'Không có quyền truy cập đánh giá này',
          code: 'review-access-denied',
        );
}

class ReviewCreationFailure extends ServerFailure {
  const ReviewCreationFailure()
      : super(
          message: 'Không thể tạo đánh giá',
          code: 'review-creation-failed',
        );
}

class ReviewUpdateFailure extends ServerFailure {
  const ReviewUpdateFailure()
      : super(
          message: 'Không thể cập nhật đánh giá',
          code: 'review-update-failed',
        );
}

class ReviewDeletionFailure extends ServerFailure {
  const ReviewDeletionFailure()
      : super(
          message: 'Không thể xóa đánh giá',
          code: 'review-deletion-failed',
        );
}

class ReviewImageUploadFailure extends StorageFailure {
  const ReviewImageUploadFailure()
      : super(
          message: 'Không thể tải lên hình ảnh đánh giá',
          code: 'review-image-upload-failed',
        );
}

class ReviewImageDeleteFailure extends StorageFailure {
  const ReviewImageDeleteFailure()
      : super(
          message: 'Không thể xóa hình ảnh đánh giá',
          code: 'review-image-delete-failed',
        );
}

class ReviewValidationFailure extends ValidationFailure {
  const ReviewValidationFailure({
    required super.message,
    required super.code,
  });
}

class ReviewInvalidRatingFailure extends ValidationFailure {
  const ReviewInvalidRatingFailure()
      : super(
          message: 'Đánh giá phải từ 1 đến 5 sao',
          code: 'review-invalid-rating',
        );
}

class ReviewInvalidCommentFailure extends ValidationFailure {
  const ReviewInvalidCommentFailure()
      : super(
          message: 'Nội dung đánh giá không hợp lệ',
          code: 'review-invalid-comment',
        );
}

class ReviewCommentTooShortFailure extends ValidationFailure {
  const ReviewCommentTooShortFailure()
      : super(
          message: 'Nội dung đánh giá quá ngắn',
          code: 'review-comment-too-short',
        );
}

class ReviewCommentTooLongFailure extends ValidationFailure {
  const ReviewCommentTooLongFailure()
      : super(
          message: 'Nội dung đánh giá quá dài',
          code: 'review-comment-too-long',
        );
}

class ReviewTooManyImagesFailure extends ValidationFailure {
  const ReviewTooManyImagesFailure()
      : super(
          message: 'Số lượng hình ảnh vượt quá giới hạn cho phép',
          code: 'review-too-many-images',
        );
}

class ReviewImageTooLargeFailure extends ValidationFailure {
  const ReviewImageTooLargeFailure()
      : super(
          message: 'Kích thước hình ảnh quá lớn',
          code: 'review-image-too-large',
        );
}

class ReviewInvalidImageFormatFailure extends ValidationFailure {
  const ReviewInvalidImageFormatFailure()
      : super(
          message: 'Định dạng hình ảnh không được hỗ trợ',
          code: 'review-invalid-image-format',
        );
}

class ReviewHelpfulMarkFailure extends ServerFailure {
  const ReviewHelpfulMarkFailure()
      : super(
          message: 'Không thể đánh dấu đánh giá hữu ích',
          code: 'review-helpful-mark-failed',
        );
}

class ReviewHelpfulUnmarkFailure extends ServerFailure {
  const ReviewHelpfulUnmarkFailure()
      : super(
          message: 'Không thể bỏ đánh dấu đánh giá hữu ích',
          code: 'review-helpful-unmark-failed',
        );
}

class ReviewSelfHelpfulFailure extends ValidationFailure {
  const ReviewSelfHelpfulFailure()
      : super(
          message: 'Không thể đánh dấu đánh giá của chính mình là hữu ích',
          code: 'review-self-helpful-failed',
        );
}

class ReviewEditTimeExpiredFailure extends ValidationFailure {
  const ReviewEditTimeExpiredFailure()
      : super(
          message: 'Thời gian chỉnh sửa đánh giá đã hết hạn',
          code: 'review-edit-time-expired',
        );
}

class ReviewDuplicateHelpfulFailure extends ValidationFailure {
  const ReviewDuplicateHelpfulFailure()
      : super(
          message: 'Bạn đã đánh dấu đánh giá này là hữu ích rồi',
          code: 'review-duplicate-helpful',
        );
}

class ReviewNotHelpfulFailure extends ValidationFailure {
  const ReviewNotHelpfulFailure()
      : super(
          message: 'Bạn chưa đánh dấu đánh giá này là hữu ích',
          code: 'review-not-helpful',
        );
}

class ReviewRestaurantNotFoundFailure extends ValidationFailure {
  const ReviewRestaurantNotFoundFailure()
      : super(
          message: 'Không tìm thấy nhà hàng để đánh giá',
          code: 'review-restaurant-not-found',
        );
}

class ReviewUserNotAuthenticatedFailure extends AuthFailure {
  const ReviewUserNotAuthenticatedFailure()
      : super(
          message: 'Bạn cần đăng nhập để đánh giá',
          code: 'review-user-not-authenticated',
        );
}

class ReviewLoadFailure extends ServerFailure {
  const ReviewLoadFailure()
      : super(
          message: 'Không thể tải danh sách đánh giá',
          code: 'review-load-failed',
        );
}

class ReviewImageCompressionFailure extends StorageFailure {
  const ReviewImageCompressionFailure()
      : super(
          message: 'Không thể nén hình ảnh',
          code: 'review-image-compression-failed',
        );
}