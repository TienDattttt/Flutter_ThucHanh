import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  /// Get user notifications
  Stream<List<NotificationModel>> getUserNotifications({
    required String userId,
    int? limit,
  });

  /// Mark notification as read
  Future<void> markNotificationAsRead(String notificationId);

  /// Mark all notifications as read for user
  Future<void> markAllNotificationsAsRead(String userId);

  /// Delete notification
  Future<void> deleteNotification(String notificationId);

  /// Get unread notification count
  Future<int> getUnreadNotificationCount(String userId);

  /// Register FCM token
  Future<void> registerFCMToken({
    required String userId,
    required String token,
  });

  /// Unregister FCM token
  Future<void> unregisterFCMToken({
    required String userId,
    required String token,
  });

  /// Subscribe to restaurant notifications
  Future<void> subscribeToRestaurant({
    required String userId,
    required String restaurantId,
  });

  /// Unsubscribe from restaurant notifications
  Future<void> unsubscribeFromRestaurant({
    required String userId,
    required String restaurantId,
  });

  /// Get notification settings for user
  Future<Map<String, bool>> getNotificationSettings(String userId);

  /// Update notification settings
  Future<void> updateNotificationSettings({
    required String userId,
    required Map<String, bool> settings,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseMessaging firebaseMessaging;

  NotificationRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseMessaging,
  });

  @override
  Stream<List<NotificationModel>> getUserNotifications({
    required String userId,
    int? limit,
  }) {
    try {
      Query query = firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi tải thông báo: ${e.toString()}',
        code: 'get-notifications-failed',
      );
    }
  }

  @override
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .update({
        'isRead': true,
        'readAt': Timestamp.now(),
      });
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi đánh dấu thông báo đã đọc: ${e.toString()}',
        code: 'mark-notification-read-failed',
      );
    }
  }

  @override
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      final batch = firestore.batch();
      final notifications = await firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': Timestamp.now(),
        });
      }

      await batch.commit();
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi đánh dấu tất cả thông báo đã đọc: ${e.toString()}',
        code: 'mark-all-notifications-read-failed',
      );
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await firestore
          .collection(AppConstants.notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi xóa thông báo: ${e.toString()}',
        code: 'delete-notification-failed',
      );
    }
  }

  @override
  Future<int> getUnreadNotificationCount(String userId) async {
    try {
      final snapshot = await firestore
          .collection(AppConstants.notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi đếm thông báo chưa đọc: ${e.toString()}',
        code: 'get-unread-count-failed',
      );
    }
  }

  @override
  Future<void> registerFCMToken({
    required String userId,
    required String token,
  }) async {
    try {
      // Get current user document
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw const ServerException(
          message: 'Người dùng không tồn tại',
          code: 'user-not-found',
        );
      }

      final userData = userDoc.data()!;
      final currentTokens = List<String>.from(userData['fcmTokens'] ?? []);

      // Add token if not already present
      if (!currentTokens.contains(token)) {
        currentTokens.add(token);
        
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .update({'fcmTokens': currentTokens});
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Lỗi khi đăng ký FCM token: ${e.toString()}',
        code: 'register-fcm-token-failed',
      );
    }
  }

  @override
  Future<void> unregisterFCMToken({
    required String userId,
    required String token,
  }) async {
    try {
      // Get current user document
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw const ServerException(
          message: 'Người dùng không tồn tại',
          code: 'user-not-found',
        );
      }

      final userData = userDoc.data()!;
      final currentTokens = List<String>.from(userData['fcmTokens'] ?? []);

      // Remove token if present
      if (currentTokens.contains(token)) {
        currentTokens.remove(token);
        
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .update({'fcmTokens': currentTokens});
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Lỗi khi hủy đăng ký FCM token: ${e.toString()}',
        code: 'unregister-fcm-token-failed',
      );
    }
  }

  @override
  Future<void> subscribeToRestaurant({
    required String userId,
    required String restaurantId,
  }) async {
    try {
      // Get user's FCM tokens
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw const ServerException(
          message: 'Người dùng không tồn tại',
          code: 'user-not-found',
        );
      }

      final userData = userDoc.data()!;
      final fcmTokens = List<String>.from(userData['fcmTokens'] ?? []);

      if (fcmTokens.isNotEmpty) {
        // Subscribe tokens to restaurant topic
        final topic = '${AppConstants.restaurantTopicPrefix}$restaurantId';
        await firebaseMessaging.subscribeToTopic(topic);
      }

      // Update user's subscribed restaurants
      final subscribedRestaurants = List<String>.from(
          userData['subscribedRestaurants'] ?? []);
      
      if (!subscribedRestaurants.contains(restaurantId)) {
        subscribedRestaurants.add(restaurantId);
        
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .update({'subscribedRestaurants': subscribedRestaurants});
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Lỗi khi đăng ký thông báo nhà hàng: ${e.toString()}',
        code: 'subscribe-restaurant-failed',
      );
    }
  }

  @override
  Future<void> unsubscribeFromRestaurant({
    required String userId,
    required String restaurantId,
  }) async {
    try {
      // Get user's FCM tokens
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw const ServerException(
          message: 'Người dùng không tồn tại',
          code: 'user-not-found',
        );
      }

      final userData = userDoc.data()!;
      final fcmTokens = List<String>.from(userData['fcmTokens'] ?? []);

      if (fcmTokens.isNotEmpty) {
        // Unsubscribe tokens from restaurant topic
        final topic = '${AppConstants.restaurantTopicPrefix}$restaurantId';
        await firebaseMessaging.unsubscribeFromTopic(topic);
      }

      // Update user's subscribed restaurants
      final subscribedRestaurants = List<String>.from(
          userData['subscribedRestaurants'] ?? []);
      
      if (subscribedRestaurants.contains(restaurantId)) {
        subscribedRestaurants.remove(restaurantId);
        
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(userId)
            .update({'subscribedRestaurants': subscribedRestaurants});
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Lỗi khi hủy đăng ký thông báo nhà hàng: ${e.toString()}',
        code: 'unsubscribe-restaurant-failed',
      );
    }
  }

  @override
  Future<Map<String, bool>> getNotificationSettings(String userId) async {
    try {
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        throw const ServerException(
          message: 'Người dùng không tồn tại',
          code: 'user-not-found',
        );
      }

      final userData = userDoc.data()!;
      final settings = Map<String, bool>.from(
          userData['notificationSettings'] ?? {});

      // Return default settings if none exist
      return {
        'newReviews': settings['newReviews'] ?? true,
        'reviewReplies': settings['reviewReplies'] ?? true,
        'restaurantUpdates': settings['restaurantUpdates'] ?? true,
        'systemAnnouncements': settings['systemAnnouncements'] ?? true,
        ...settings,
      };
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Lỗi khi tải cài đặt thông báo: ${e.toString()}',
        code: 'get-notification-settings-failed',
      );
    }
  }

  @override
  Future<void> updateNotificationSettings({
    required String userId,
    required Map<String, bool> settings,
  }) async {
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'notificationSettings': settings});
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi cập nhật cài đặt thông báo: ${e.toString()}',
        code: 'update-notification-settings-failed',
      );
    }
  }
}