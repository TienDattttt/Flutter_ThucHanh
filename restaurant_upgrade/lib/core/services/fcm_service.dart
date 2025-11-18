import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/app_constants.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = 
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  bool _isInitialized = false;

  /// Initialize FCM service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      print('FCM Token: $_fcmToken');

      // Set up message handlers
      _setupMessageHandlers();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        print('FCM Token refreshed: $token');
        // TODO: Update token on server
      });

      _isInitialized = true;
    } catch (e) {
      print('Error initializing FCM: $e');
    }
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isIOS) {
      // Request iOS permissions
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('iOS notification permission status: ${settings.authorizationStatus}');
    } else if (Platform.isAndroid) {
      // Request Android permissions
      final status = await Permission.notification.request();
      print('Android notification permission status: $status');
    }
  }

  /// Initialize local notifications
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      await _createNotificationChannel();
    }
  }

  /// Create notification channel for Android
  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'restaurant_reviews',
      'Restaurant Reviews',
      description: 'Notifications for restaurant reviews and updates',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Set up message handlers
  void _setupMessageHandlers() {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle app launch from terminated state
    _handleAppLaunchFromNotification();
  }

  /// Handle foreground messages
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Received foreground message: ${message.messageId}');

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  /// Handle message opened app
  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    print('Message opened app: ${message.messageId}');
    await _handleNotificationNavigation(message);
  }

  /// Handle app launch from notification
  Future<void> _handleAppLaunchFromNotification() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      print('App launched from notification: ${initialMessage.messageId}');
      await _handleNotificationNavigation(initialMessage);
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      'restaurant_reviews',
      'Restaurant Reviews',
      channelDescription: 'Notifications for restaurant reviews and updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: _encodeNotificationPayload(message),
    );
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      final message = _decodeNotificationPayload(response.payload!);
      _handleNotificationNavigation(message);
    }
  }

  /// Handle notification navigation
  Future<void> _handleNotificationNavigation(RemoteMessage message) async {
    final data = message.data;
    final type = data['type'];

    switch (type) {
      case 'new_review':
        final restaurantId = data['restaurantId'];
        if (restaurantId != null) {
          // TODO: Navigate to restaurant detail page
          print('Navigate to restaurant: $restaurantId');
        }
        break;
      case 'review_reply':
        final reviewId = data['reviewId'];
        if (reviewId != null) {
          // TODO: Navigate to review detail
          print('Navigate to review: $reviewId');
        }
        break;
      default:
        print('Unknown notification type: $type');
    }
  }

  /// Encode notification payload
  String _encodeNotificationPayload(RemoteMessage message) {
    // Simple encoding - in production, use proper JSON encoding
    return '${message.messageId}|${message.data.entries.map((e) => '${e.key}:${e.value}').join(',')}';
  }

  /// Decode notification payload
  RemoteMessage _decodeNotificationPayload(String payload) {
    // Simple decoding - in production, use proper JSON decoding
    final parts = payload.split('|');
    final messageId = parts[0];
    final dataString = parts.length > 1 ? parts[1] : '';
    
    final data = <String, dynamic>{};
    if (dataString.isNotEmpty) {
      for (final pair in dataString.split(',')) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          data[keyValue[0]] = keyValue[1];
        }
      }
    }

    return RemoteMessage(
      messageId: messageId,
      data: data,
    );
  }

  /// Get FCM token
  String? get fcmToken => _fcmToken;

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic $topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic $topic: $e');
    }
  }

  /// Subscribe to restaurant notifications
  Future<void> subscribeToRestaurant(String restaurantId) async {
    await subscribeToTopic('${AppConstants.restaurantTopicPrefix}$restaurantId');
  }

  /// Unsubscribe from restaurant notifications
  Future<void> unsubscribeFromRestaurant(String restaurantId) async {
    await unsubscribeFromTopic('${AppConstants.restaurantTopicPrefix}$restaurantId');
  }

  /// Subscribe to all users notifications
  Future<void> subscribeToAllUsers() async {
    await subscribeToTopic(AppConstants.allUsersTopicPrefix);
  }

  /// Unsubscribe from all users notifications
  Future<void> unsubscribeFromAllUsers() async {
    await unsubscribeFromTopic(AppConstants.allUsersTopicPrefix);
  }

  /// Clear all notifications
  Future<void> clearAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Get notification settings
  Future<NotificationSettings> getNotificationSettings() async {
    return await _firebaseMessaging.getNotificationSettings();
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
  // Handle background message processing here
}