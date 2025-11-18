import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';


class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Stream<Either<Failure, List<Notification>>> getUserNotifications({
    required String userId,
    int? limit,
  }) async* {
    if (await networkInfo.isConnected) {
      try {
        yield* remoteDataSource.getUserNotifications(
          userId: userId,
          limit: limit,
        ).map((notificationModels) {
          final notifications = notificationModels
              .map((model) => model.toEntity())
              .toList();
          return Right<Failure, List<Notification>>(notifications);
        }).handleError((error) {
          if (error is ServerException) {
            return Left<Failure, List<Notification>>(
              ServerFailure(message: error.message, code: error.code),
            );
          }
          return Left<Failure, List<Notification>>(
            ErrorMapper.mapGenericException(error as Exception),
          );
        });
      } catch (e) {
        yield Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      yield const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markNotificationAsRead(notificationId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> markAllNotificationsAsRead(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.markAllNotificationsAsRead(userId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(String notificationId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteNotification(notificationId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadNotificationCount(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final count = await remoteDataSource.getUnreadNotificationCount(userId);
        return Right(count);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> registerFCMToken({
    required String userId,
    required String token,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.registerFCMToken(
          userId: userId,
          token: token,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> unregisterFCMToken({
    required String userId,
    required String token,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.unregisterFCMToken(
          userId: userId,
          token: token,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> subscribeToRestaurant({
    required String userId,
    required String restaurantId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.subscribeToRestaurant(
          userId: userId,
          restaurantId: restaurantId,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> unsubscribeFromRestaurant({
    required String userId,
    required String restaurantId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.unsubscribeFromRestaurant(
          userId: userId,
          restaurantId: restaurantId,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, Map<String, bool>>> getNotificationSettings(String userId) async {
    if (await networkInfo.isConnected) {
      try {
        final settings = await remoteDataSource.getNotificationSettings(userId);
        return Right(settings);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> updateNotificationSettings({
    required String userId,
    required Map<String, bool> settings,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.updateNotificationSettings(
          userId: userId,
          settings: settings,
        );
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  // Missing methods from NotificationRepository interface
  @override
  Future<Either<Failure, void>> initializeMessaging() async {
    // TODO: Implement
    return const Right(null);
  }

  @override
  Future<Either<Failure, String?>> getFCMToken() async {
    // TODO: Implement
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> subscribeToTopic(String topic) async {
    // TODO: Implement
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic) async {
    // TODO: Implement
    return const Right(null);
  }

  @override
  Stream<Map<String, dynamic>> get onForegroundMessage => const Stream.empty();

  @override
  Stream<Map<String, dynamic>> get onMessageOpenedApp => const Stream.empty();

  @override
  Future<Map<String, dynamic>?> getInitialMessage() async {
    // TODO: Implement
    return null;
  }

  @override
  Future<Either<Failure, void>> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    // TODO: Implement
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    // TODO: Implement
    return const Right(null);
  }
}