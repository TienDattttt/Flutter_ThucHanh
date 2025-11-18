import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class HandleNotificationUseCase implements UseCase<NotificationAction, HandleNotificationParams> {
  final NotificationRepository repository;

  HandleNotificationUseCase(this.repository);

  @override
  Future<Either<Failure, NotificationAction>> call(HandleNotificationParams params) async {
    try {
      // Mark notification as read if it's not already read
      if (!params.notification.isRead) {
        await repository.markNotificationAsRead(params.notification.id);
      }

      // Determine the action based on notification type and data
      final action = _determineNotificationAction(params.notification);

      return Right(action);
    } catch (e) {
      return Left(ServerFailure(
        message: 'Lỗi khi xử lý thông báo: ${e.toString()}',
        code: 'handle-notification-failed',
      ));
    }
  }

  NotificationAction _determineNotificationAction(Notification notification) {
    switch (notification.type) {
      case 'new_review':
        final restaurantId = notification.data['restaurantId'];
        if (restaurantId != null) {
          return NotificationAction.navigateToRestaurant(restaurantId);
        }
        break;

      case 'review_reply':
        final reviewId = notification.data['reviewId'];
        final restaurantId = notification.data['restaurantId'];
        if (reviewId != null && restaurantId != null) {
          return NotificationAction.navigateToReview(restaurantId, reviewId);
        }
        break;

      case 'restaurant_update':
        final restaurantId = notification.data['restaurantId'];
        if (restaurantId != null) {
          return NotificationAction.navigateToRestaurant(restaurantId);
        }
        break;

      case 'system_announcement':
        final url = notification.data['url'];
        if (url != null) {
          return NotificationAction.openUrl(url);
        }
        return NotificationAction.showDialog(
          title: notification.title,
          message: notification.body,
        );

      default:
        break;
    }

    // Default action - just show the notification content
    return NotificationAction.showDialog(
      title: notification.title,
      message: notification.body,
    );
  }
}

class HandleNotificationParams extends Equatable {
  final Notification notification;

  const HandleNotificationParams({
    required this.notification,
  });

  @override
  List<Object> get props => [notification];

  @override
  String toString() {
    return 'HandleNotificationParams(notification: ${notification.id})';
  }
}

/// Represents different actions that can be taken when handling a notification
abstract class NotificationAction extends Equatable {
  const NotificationAction();

  /// Navigate to restaurant detail page
  factory NotificationAction.navigateToRestaurant(String restaurantId) = 
      NavigateToRestaurantAction;

  /// Navigate to review detail
  factory NotificationAction.navigateToReview(String restaurantId, String reviewId) = 
      NavigateToReviewAction;

  /// Open external URL
  factory NotificationAction.openUrl(String url) = OpenUrlAction;

  /// Show dialog with message
  factory NotificationAction.showDialog({
    required String title,
    required String message,
  }) = ShowDialogAction;

  /// No action needed
  factory NotificationAction.none() = NoAction;
}

class NavigateToRestaurantAction extends NotificationAction {
  final String restaurantId;

  const NavigateToRestaurantAction(this.restaurantId);

  @override
  List<Object> get props => [restaurantId];
}

class NavigateToReviewAction extends NotificationAction {
  final String restaurantId;
  final String reviewId;

  const NavigateToReviewAction(this.restaurantId, this.reviewId);

  @override
  List<Object> get props => [restaurantId, reviewId];
}

class OpenUrlAction extends NotificationAction {
  final String url;

  const OpenUrlAction(this.url);

  @override
  List<Object> get props => [url];
}

class ShowDialogAction extends NotificationAction {
  final String title;
  final String message;

  const ShowDialogAction({
    required this.title,
    required this.message,
  });

  @override
  List<Object> get props => [title, message];
}

class NoAction extends NotificationAction {
  const NoAction();

  @override
  List<Object> get props => [];
}