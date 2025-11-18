import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/constants/app_constants.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetUserNotificationsUseCase implements UseCase<Stream<List<Notification>>, GetUserNotificationsParams> {
  final NotificationRepository repository;

  GetUserNotificationsUseCase(this.repository);

  @override
  Future<Either<Failure, Stream<List<Notification>>>> call(GetUserNotificationsParams params) async {
    // Validate user ID
    if (StringUtils.isNullOrEmpty(params.userId)) {
      return const Left(ValidationFailure(
        message: 'ID người dùng không được để trống',
        code: 'invalid-user-id',
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

    try {
      final notificationsStream = repository.getUserNotifications(
        userId: params.userId,
        limit: params.limit ?? AppConstants.notificationPageSize,
      );

      // Convert Stream<Either<Failure, List<Notification>>> to Either<Failure, Stream<List<Notification>>>
      return Right(notificationsStream.map((either) {
        return either.fold(
          (failure) => throw Exception(failure.message),
          (notifications) => notifications,
        );
      }));
    } catch (e) {
      return Left(ServerFailure(
        message: 'Lỗi khi tải danh sách thông báo: ${e.toString()}',
        code: 'get-notifications-failed',
      ));
    }
  }
}

class GetUserNotificationsParams extends Equatable {
  final String userId;
  final int? limit;

  const GetUserNotificationsParams({
    required this.userId,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, limit];

  @override
  String toString() {
    return 'GetUserNotificationsParams(userId: $userId, limit: $limit)';
  }
}