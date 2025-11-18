import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/string_utils.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateUserProfileUseCase implements UseCase<User, UpdateUserProfileParams> {
  final AuthRepository repository;

  UpdateUserProfileUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(UpdateUserProfileParams params) async {
    // Validate user ID
    if (StringUtils.isNullOrEmpty(params.userId)) {
      return const Left(ValidationFailure(
        message: 'ID người dùng không hợp lệ',
        code: 'invalid-user-id',
      ));
    }

    // Validate display name if provided
    if (params.displayName != null) {
      final displayNameValidation = Validators.validateDisplayName(params.displayName);
      if (displayNameValidation != null) {
        return Left(ValidationFailure(
          message: displayNameValidation,
          code: 'invalid-display-name',
        ));
      }
    }

    // Validate photo URL if provided
    if (params.photoUrl != null && StringUtils.isNotNullOrEmpty(params.photoUrl)) {
      if (!StringUtils.isValidUrl(params.photoUrl!)) {
        return const Left(ValidationFailure(
          message: 'URL ảnh đại diện không hợp lệ',
          code: 'invalid-photo-url',
        ));
      }
    }

    // Check if at least one field is being updated
    if (params.displayName == null && params.photoUrl == null) {
      return const Left(ValidationFailure(
        message: 'Vui lòng cung cấp ít nhất một trường để cập nhật',
        code: 'no-fields-to-update',
      ));
    }

    return await repository.updateUserProfile(
      userId: params.userId,
      displayName: params.displayName?.trim(),
      photoUrl: params.photoUrl?.trim(),
    );
  }
}

class UpdateUserProfileParams extends Equatable {
  final String userId;
  final String? displayName;
  final String? photoUrl;

  const UpdateUserProfileParams({
    required this.userId,
    this.displayName,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [userId, displayName, photoUrl];

  @override
  String toString() {
    return 'UpdateUserProfileParams(userId: $userId, displayName: $displayName, photoUrl: $photoUrl)';
  }
}