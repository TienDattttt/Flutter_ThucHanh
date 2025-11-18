import 'package:equatable/equatable.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String userId;
  final int? limit;

  const LoadNotifications({
    required this.userId,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, limit];
}

class RefreshNotifications extends NotificationEvent {
  final String userId;
  final int? limit;

  const RefreshNotifications({
    required this.userId,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, limit];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsRead({
    required this.notificationId,
  });

  @override
  List<Object> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationEvent {
  final String userId;

  const MarkAllNotificationsAsRead({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

class DeleteNotification extends NotificationEvent {
  final String notificationId;

  const DeleteNotification({
    required this.notificationId,
  });

  @override
  List<Object> get props => [notificationId];
}

class HandleNotificationTap extends NotificationEvent {
  final String notificationId;

  const HandleNotificationTap({
    required this.notificationId,
  });

  @override
  List<Object> get props => [notificationId];
}

class InitializeNotifications extends NotificationEvent {
  final String userId;

  const InitializeNotifications({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}

class SubscribeToRestaurantNotifications extends NotificationEvent {
  final String userId;
  final String restaurantId;

  const SubscribeToRestaurantNotifications({
    required this.userId,
    required this.restaurantId,
  });

  @override
  List<Object> get props => [userId, restaurantId];
}

class UnsubscribeFromRestaurantNotifications extends NotificationEvent {
  final String userId;
  final String restaurantId;

  const UnsubscribeFromRestaurantNotifications({
    required this.userId,
    required this.restaurantId,
  });

  @override
  List<Object> get props => [userId, restaurantId];
}