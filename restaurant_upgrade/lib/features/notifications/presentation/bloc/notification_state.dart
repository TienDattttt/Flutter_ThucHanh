import 'package:equatable/equatable.dart';
import '../../domain/entities/notification.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationsLoaded extends NotificationState {
  final List<Notification> notifications;
  final int unreadCount;
  final bool hasReachedMax;

  const NotificationsLoaded({
    required this.notifications,
    this.unreadCount = 0,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, hasReachedMax];

  NotificationsLoaded copyWith({
    List<Notification>? notifications,
    int? unreadCount,
    bool? hasReachedMax,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class NotificationError extends NotificationState {
  final String message;
  final String? code;

  const NotificationError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class NotificationActionLoading extends NotificationState {
  final String action;
  final List<Notification>? currentNotifications;

  const NotificationActionLoading({
    required this.action,
    this.currentNotifications,
  });

  @override
  List<Object?> get props => [action, currentNotifications];
}

class NotificationActionSuccess extends NotificationState {
  final String message;
  final String action;
  final List<Notification>? notifications;

  const NotificationActionSuccess({
    required this.message,
    required this.action,
    this.notifications,
  });

  @override
  List<Object?> get props => [message, action, notifications];
}

class NotificationActionError extends NotificationState {
  final String message;
  final String action;
  final String? code;
  final List<Notification>? currentNotifications;

  const NotificationActionError({
    required this.message,
    required this.action,
    this.code,
    this.currentNotifications,
  });

  @override
  List<Object?> get props => [message, action, code, currentNotifications];
}

class NotificationInitialized extends NotificationState {
  final String userId;

  const NotificationInitialized({
    required this.userId,
  });

  @override
  List<Object> get props => [userId];
}