import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/get_user_notifications_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import '../../domain/usecases/initialize_notifications_usecase.dart';
import '../../domain/usecases/handle_notification_usecase.dart';
import '../../domain/usecases/subscribe_to_restaurant_notifications_usecase.dart';
import '../../domain/usecases/unsubscribe_from_restaurant_notifications_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetUserNotificationsUseCase getUserNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final InitializeNotificationsUseCase initializeNotificationsUseCase;
  final HandleNotificationUseCase handleNotificationUseCase;
  final SubscribeToRestaurantNotificationsUseCase subscribeToRestaurantNotificationsUseCase;
  final UnsubscribeFromRestaurantNotificationsUseCase unsubscribeFromRestaurantNotificationsUseCase;

  StreamSubscription<List<Notification>>? _notificationsSubscription;
  String? _currentUserId;

  NotificationBloc({
    required this.getUserNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.initializeNotificationsUseCase,
    required this.handleNotificationUseCase,
    required this.subscribeToRestaurantNotificationsUseCase,
    required this.unsubscribeFromRestaurantNotificationsUseCase,
  }) : super(const NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<HandleNotificationTap>(_onHandleNotificationTap);
    on<InitializeNotifications>(_onInitializeNotifications);
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadNotifications(LoadNotifications event, Emitter<NotificationState> emit) async {
    if (_currentUserId != event.userId) {
      emit(const NotificationLoading());
    }

    _currentUserId = event.userId;

    final result = await getUserNotificationsUseCase(GetUserNotificationsParams(
      userId: event.userId,
      limit: event.limit,
    ));

    result.fold(
      (failure) => emit(NotificationError(
        message: failure.message,
        code: failure.code,
      )),
      (notificationsStream) {
        _notificationsSubscription?.cancel();
        _notificationsSubscription = notificationsStream.listen(
          (notifications) {
            if (!isClosed) {
              final unreadCount = notifications.where((n) => !n.isRead).length;
              emit(NotificationsLoaded(
                notifications: notifications,
                unreadCount: unreadCount,
                hasReachedMax: notifications.length < (event.limit ?? AppConstants.notificationPageSize),
              ));
            }
          },
          onError: (error) {
            if (!isClosed) {
              emit(NotificationError(
                message: error.toString(),
                code: 'stream-error',
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _onRefreshNotifications(RefreshNotifications event, Emitter<NotificationState> emit) async {
    final result = await getUserNotificationsUseCase(GetUserNotificationsParams(
      userId: event.userId,
      limit: event.limit,
    ));

    result.fold(
      (failure) => emit(NotificationError(
        message: failure.message,
        code: failure.code,
      )),
      (notificationsStream) {
        _notificationsSubscription?.cancel();
        _notificationsSubscription = notificationsStream.listen(
          (notifications) {
            if (!isClosed) {
              final unreadCount = notifications.where((n) => !n.isRead).length;
              emit(NotificationsLoaded(
                notifications: notifications,
                unreadCount: unreadCount,
                hasReachedMax: notifications.length < (event.limit ?? AppConstants.notificationPageSize),
              ));
            }
          },
          onError: (error) {
            if (!isClosed) {
              emit(NotificationError(
                message: error.toString(),
                code: 'stream-error',
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _onMarkNotificationAsRead(MarkNotificationAsRead event, Emitter<NotificationState> emit) async {
    final result = await markNotificationAsReadUseCase(MarkNotificationAsReadParams(
      notificationId: event.notificationId,
    ));

    result.fold(
      (failure) => emit(NotificationActionError(
        message: failure.message,
        action: 'mark_read',
        code: failure.code,
      )),
      (_) {
        // The stream will automatically update with the new state
      },
    );
  }

  Future<void> _onMarkAllNotificationsAsRead(MarkAllNotificationsAsRead event, Emitter<NotificationState> emit) async {
    emit(const NotificationActionLoading(action: 'mark_all_read'));

    // TODO: Implement mark all as read use case
    emit(const NotificationActionSuccess(
      message: 'Đã đánh dấu tất cả thông báo là đã đọc',
      action: 'mark_all_read',
    ));
  }

  Future<void> _onDeleteNotification(DeleteNotification event, Emitter<NotificationState> emit) async {
    // TODO: Implement delete notification use case
    emit(const NotificationActionSuccess(
      message: 'Đã xóa thông báo',
      action: 'delete',
    ));
  }

  Future<void> _onHandleNotificationTap(HandleNotificationTap event, Emitter<NotificationState> emit) async {
    // TODO: Get notification by ID and handle tap
    // For now, just mark as read
    add(MarkNotificationAsRead(notificationId: event.notificationId));
  }

  Future<void> _onInitializeNotifications(InitializeNotifications event, Emitter<NotificationState> emit) async {
    final result = await initializeNotificationsUseCase(InitializeNotificationsParams(
      userId: event.userId,
    ));

    result.fold(
      (failure) => emit(NotificationError(
        message: failure.message,
        code: failure.code,
      )),
      (_) => emit(NotificationInitialized(userId: event.userId)),
    );
  }
}