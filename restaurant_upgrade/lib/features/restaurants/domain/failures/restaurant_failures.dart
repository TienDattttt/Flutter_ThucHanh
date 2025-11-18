import '../../../../core/error/failures.dart';

/// Specific restaurant failures
class RestaurantNotFoundFailure extends ServerFailure {
  const RestaurantNotFoundFailure()
      : super(
          message: 'Không tìm thấy nhà hàng',
          code: 'restaurant-not-found',
        );
}

class RestaurantAlreadyExistsFailure extends ServerFailure {
  const RestaurantAlreadyExistsFailure()
      : super(
          message: 'Nhà hàng đã tồn tại',
          code: 'restaurant-already-exists',
        );
}

class RestaurantAccessDeniedFailure extends ServerFailure {
  const RestaurantAccessDeniedFailure()
      : super(
          message: 'Không có quyền truy cập nhà hàng này',
          code: 'restaurant-access-denied',
        );
}

class RestaurantInactiveFailure extends ServerFailure {
  const RestaurantInactiveFailure()
      : super(
          message: 'Nhà hàng không còn hoạt động',
          code: 'restaurant-inactive',
        );
}

class RestaurantCreationFailure extends ServerFailure {
  const RestaurantCreationFailure()
      : super(
          message: 'Không thể tạo nhà hàng',
          code: 'restaurant-creation-failed',
        );
}

class RestaurantUpdateFailure extends ServerFailure {
  const RestaurantUpdateFailure()
      : super(
          message: 'Không thể cập nhật thông tin nhà hàng',
          code: 'restaurant-update-failed',
        );
}

class RestaurantDeletionFailure extends ServerFailure {
  const RestaurantDeletionFailure()
      : super(
          message: 'Không thể xóa nhà hàng',
          code: 'restaurant-deletion-failed',
        );
}

class InvalidLocationFailure extends ValidationFailure {
  const InvalidLocationFailure()
      : super(
          message: 'Vị trí không hợp lệ',
          code: 'invalid-location',
        );
}

class InvalidCategoryFailure extends ValidationFailure {
  const InvalidCategoryFailure()
      : super(
          message: 'Danh mục không hợp lệ',
          code: 'invalid-category',
        );
}

class RestaurantImageUploadFailure extends StorageFailure {
  const RestaurantImageUploadFailure()
      : super(
          message: 'Không thể tải lên hình ảnh nhà hàng',
          code: 'restaurant-image-upload-failed',
        );
}

class RestaurantImageDeleteFailure extends StorageFailure {
  const RestaurantImageDeleteFailure()
      : super(
          message: 'Không thể xóa hình ảnh nhà hàng',
          code: 'restaurant-image-delete-failed',
        );
}

class RestaurantSearchFailure extends ServerFailure {
  const RestaurantSearchFailure()
      : super(
          message: 'Lỗi khi tìm kiếm nhà hàng',
          code: 'restaurant-search-failed',
        );
}

class RestaurantLocationSearchFailure extends ServerFailure {
  const RestaurantLocationSearchFailure()
      : super(
          message: 'Lỗi khi tìm kiếm nhà hàng theo vị trí',
          code: 'restaurant-location-search-failed',
        );
}

class RestaurantCategoryLoadFailure extends ServerFailure {
  const RestaurantCategoryLoadFailure()
      : super(
          message: 'Không thể tải danh sách danh mục',
          code: 'restaurant-category-load-failed',
        );
}

class RestaurantRatingUpdateFailure extends ServerFailure {
  const RestaurantRatingUpdateFailure()
      : super(
          message: 'Không thể cập nhật đánh giá nhà hàng',
          code: 'restaurant-rating-update-failed',
        );
}

class RestaurantOwnershipFailure extends ServerFailure {
  const RestaurantOwnershipFailure()
      : super(
          message: 'Bạn không phải là chủ sở hữu của nhà hàng này',
          code: 'restaurant-ownership-failed',
        );
}

class RestaurantValidationFailure extends ValidationFailure {
  const RestaurantValidationFailure({
    required super.message,
    required super.code,
  });
}

class RestaurantDuplicateNameFailure extends ValidationFailure {
  const RestaurantDuplicateNameFailure()
      : super(
          message: 'Tên nhà hàng đã tồn tại trong khu vực này',
          code: 'restaurant-duplicate-name',
        );
}

class RestaurantInvalidCoordinatesFailure extends ValidationFailure {
  const RestaurantInvalidCoordinatesFailure()
      : super(
          message: 'Tọa độ địa lý không hợp lệ',
          code: 'restaurant-invalid-coordinates',
        );
}

class RestaurantTooManyImagesFailure extends ValidationFailure {
  const RestaurantTooManyImagesFailure()
      : super(
          message: 'Số lượng hình ảnh vượt quá giới hạn cho phép',
          code: 'restaurant-too-many-images',
        );
}

class RestaurantInvalidWebsiteFailure extends ValidationFailure {
  const RestaurantInvalidWebsiteFailure()
      : super(
          message: 'Website không hợp lệ',
          code: 'restaurant-invalid-website',
        );
}

class RestaurantInvalidPhoneFailure extends ValidationFailure {
  const RestaurantInvalidPhoneFailure()
      : super(
          message: 'Số điện thoại không hợp lệ',
          code: 'restaurant-invalid-phone',
        );
}