import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/location_utils.dart';
import '../../../../core/utils/string_utils.dart';

import '../entities/restaurant.dart';
import '../repositories/restaurant_repository.dart';

class AddRestaurantUseCase implements UseCase<Restaurant, AddRestaurantParams> {
  final RestaurantRepository repository;

  AddRestaurantUseCase(this.repository);

  @override
  Future<Either<Failure, Restaurant>> call(AddRestaurantParams params) async {
    // Validate restaurant name
    final nameValidation = Validators.validateRestaurantName(params.name);
    if (nameValidation != null) {
      return Left(ValidationFailure(
        message: nameValidation,
        code: 'invalid-restaurant-name',
      ));
    }

    // Validate description
    if (StringUtils.isNullOrEmpty(params.description)) {
      return const Left(ValidationFailure(
        message: 'Mô tả nhà hàng không được để trống',
        code: 'invalid-description',
      ));
    }

    if (params.description.length < 10) {
      return const Left(ValidationFailure(
        message: 'Mô tả nhà hàng phải có ít nhất 10 ký tự',
        code: 'description-too-short',
      ));
    }

    if (params.description.length > 1000) {
      return const Left(ValidationFailure(
        message: 'Mô tả nhà hàng không được vượt quá 1000 ký tự',
        code: 'description-too-long',
      ));
    }

    // Validate address
    final addressValidation = Validators.validateAddress(params.address);
    if (addressValidation != null) {
      return Left(ValidationFailure(
        message: addressValidation,
        code: 'invalid-address',
      ));
    }

    // Validate phone number if provided
    if (params.phoneNumber != null) {
      final phoneValidation = Validators.validatePhoneNumber(params.phoneNumber);
      if (phoneValidation != null) {
        return Left(ValidationFailure(
          message: phoneValidation,
          code: 'invalid-phone-number',
        ));
      }
    }

    // Validate website if provided
    if (params.website != null) {
      final websiteValidation = Validators.validateWebsite(params.website);
      if (websiteValidation != null) {
        return Left(ValidationFailure(
          message: websiteValidation,
          code: 'invalid-website',
        ));
      }
    }

    // Validate coordinates
    if (!LocationUtils.isValidCoordinates(params.latitude, params.longitude)) {
      return const Left(ValidationFailure(
        message: 'Tọa độ địa lý không hợp lệ',
        code: 'invalid-coordinates',
      ));
    }

    // Validate categories
    if (params.categories.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Vui lòng chọn ít nhất một danh mục',
        code: 'no-categories',
      ));
    }

    if (params.categories.length > 5) {
      return const Left(ValidationFailure(
        message: 'Không được chọn quá 5 danh mục',
        code: 'too-many-categories',
      ));
    }

    // Validate image URLs
    if (params.imageUrls.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Vui lòng thêm ít nhất một hình ảnh',
        code: 'no-images',
      ));
    }

    if (params.imageUrls.length > 10) {
      return const Left(ValidationFailure(
        message: 'Không được thêm quá 10 hình ảnh',
        code: 'too-many-images',
      ));
    }

    // Validate image URLs format
    for (final imageUrl in params.imageUrls) {
      if (!StringUtils.isValidUrl(imageUrl)) {
        return const Left(ValidationFailure(
          message: 'URL hình ảnh không hợp lệ',
          code: 'invalid-image-url',
        ));
      }
    }

    return await repository.addRestaurant(
      name: params.name.trim(),
      description: params.description.trim(),
      address: params.address.trim(),
      phoneNumber: params.phoneNumber?.trim(),
      website: params.website?.trim(),
      imageUrls: params.imageUrls,
      latitude: params.latitude,
      longitude: params.longitude,
      categories: params.categories,
      ownerId: params.ownerId,
    );
  }
}

class AddRestaurantParams extends Equatable {
  final String name;
  final String description;
  final String address;
  final String? phoneNumber;
  final String? website;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final List<String> categories;
  final String? ownerId;

  const AddRestaurantParams({
    required this.name,
    required this.description,
    required this.address,
    this.phoneNumber,
    this.website,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.categories,
    this.ownerId,
  });

  @override
  List<Object?> get props => [
    name,
    description,
    address,
    phoneNumber,
    website,
    imageUrls,
    latitude,
    longitude,
    categories,
    ownerId,
  ];

  @override
  String toString() {
    return 'AddRestaurantParams(name: $name, description: $description, address: $address, phoneNumber: $phoneNumber, website: $website, imageUrls: $imageUrls, latitude: $latitude, longitude: $longitude, categories: $categories, ownerId: $ownerId)';
  }
}