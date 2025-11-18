import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../core/services/fcm_service.dart';
import '../repositories/notification_repository.dart';

class SubscribeToRestaurantNotificationsUseCase implements UseCase<void, SubscribeToRestaurantNotificationsParams> {
  final NotificationRepository repository;
  final FCMService fcmService;

  SubscribeToRestaurantNotificationsUseCase({
    required this.repository,
    required this.fcmService,
  });

  @override
  Future<Either<Failure, void>> call(SubscribeToRestaurantNotificationsParams params) async {
    // Validate user ID
    if (StringUtils.isNullOrEmpty(params.userId)) {
      return const Left(ValidationFailure(
        message: 'ID người dùng không được để trống',
        code: 'invalid-user-id',
      ));
    }

    // Validate restaurant ID
    if (StringUtils.isNullOrEmpty(params.restaurantId)) {
      return const Left(ValidationFailure(
        message: 'ID nhà hàng không được để trống',
        code: 'invalid-restaurant-id',
      ));
    }

    try {
      // Subscribe to restaurant notifications in FCM
      await fcmService.subscribeToRestaurant(params.restaurantId);

      // Update subscription in backend
      final result = await repository.subscribeToRestaurant(
        userId: params.userId,
        restaurantId: params.restaurantId,
      );

      return result;
    } catch (e) {
      return Left(ServerFailure(
        message: 'Lỗi khi đăng ký thông báo nhà hàng: ${e.toString()}',
        code: 'subscribe-restaurant-failed',
      ));
    }
  }
}

class SubscribeToRestaurantNotificationsParams extends Equatable {
  final String userId;
  final String restaurantId;

  const SubscribeToRestaurantNotificationsParams({
    required this.userId,
    required this.restaurantId,
  });

  @override
  List<Object> get props => [userId, restaurantId];

  @override
  String toString() {
    return 'SubscribeToRestaurantNotificationsParams(userId: $userId, restaurantId: $restaurantId)';
  }
}