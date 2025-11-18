import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/services/fcm_service.dart';
import '../repositories/notification_repository.dart';

class InitializeNotificationsUseCase implements UseCase<void, InitializeNotificationsParams> {
  final NotificationRepository repository;
  final FCMService fcmService;

  InitializeNotificationsUseCase({
    required this.repository,
    required this.fcmService,
  });

  @override
  Future<Either<Failure, void>> call(InitializeNotificationsParams params) async {
    // Validate user ID
    if (StringUtils.isNullOrEmpty(params.userId)) {
      return const Left(ValidationFailure(
        message: 'ID người dùng không được để trống',
        code: 'invalid-user-id',
      ));
    }

    try {
      // Initialize FCM service if not already initialized
      await fcmService.initialize();

      // Get FCM token
      final fcmToken = fcmService.fcmToken;
      if (fcmToken == null) {
        return const Left(ServerFailure(
          message: 'Không thể lấy FCM token',
          code: 'fcm-token-unavailable',
        ));
      }

      // Register FCM token with backend
      final registerResult = await repository.registerFCMToken(
        userId: params.userId,
        token: fcmToken,
      );

      if (registerResult.isLeft()) {
        return registerResult;
      }

      // Subscribe to general notifications
      await fcmService.subscribeToAllUsers();

      // Subscribe to user-specific notifications
      await fcmService.subscribeToTopic('${params.userId}_notifications');

      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Lỗi khi khởi tạo thông báo: ${e.toString()}',
        code: 'initialize-notifications-failed',
      ));
    }
  }
}

class InitializeNotificationsParams extends Equatable {
  final String userId;

  const InitializeNotificationsParams({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];

  @override
  String toString() {
    return 'InitializeNotificationsParams(userId: $userId)';
  }
}