import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/notification.dart';

abstract class NotificationRepository {
  /// Initialize Firebase Messaging
  Future<Either<Failure, void>> initializeMessaging();

  /// Get FCM token for the device
  Future<Either<Failure, String?>> getFCMToken();

  /// Subscribe to a topic
  Future<Either<Failure, void>> subscribeToTopic(String topic);

  /// Unsubscribe from a topic
  Future<Either<Failure, void>> unsubscribeFromTopic(String topic);

  /// Get notifications for a user
  Stream<Either<Failure, List<Notification>>> getUserNotifications({
    required String userId,
    int? limit,
  });

  /// Mark notification as read
  Future<Either<Failure, void>> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read for a user
  Future<Either<Failure, void>> markAllNotificationsAsRead(String userId);

  /// Delete a notification
  Future<Either<Failure, void>> deleteNotification(String notificationId);

  /// Get unread notification count
  Future<Either<Failure, int>> getUnreadNotificationCount(String userId);

  /// Handle foreground message
  Stream<Map<String, dynamic>> get onForegroundMessage;

  /// Handle background message tap
  Stream<Map<String, dynamic>> get onMessageOpenedApp;

  /// Handle notification when app is terminated
  Future<Map<String, dynamic>?> getInitialMessage();

  /// Send notification to specific user (admin functionality)
  Future<Either<Failure, void>> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  });

  /// Send notification to topic (admin functionality)
  Future<Either<Failure, void>> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  });

  /// Register FCM token
  Future<Either<Failure, void>> registerFCMToken({
    required String userId,
    required String token,
  });

  /// Unregister FCM token
  Future<Either<Failure, void>> unregisterFCMToken({
    required String userId,
    required String token,
  });

  /// Subscribe to restaurant notifications
  Future<Either<Failure, void>> subscribeToRestaurant({
    required String userId,
    required String restaurantId,
  });

  /// Unsubscribe from restaurant notifications
  Future<Either<Failure, void>> unsubscribeFromRestaurant({
    required String userId,
    required String restaurantId,
  });

  /// Get notification settings
  Future<Either<Failure, Map<String, bool>>> getNotificationSettings(String userId);

  /// Update notification settings
  Future<Either<Failure, void>> updateNotificationSettings({
    required String userId,
    required Map<String, bool> settings,
  });
}