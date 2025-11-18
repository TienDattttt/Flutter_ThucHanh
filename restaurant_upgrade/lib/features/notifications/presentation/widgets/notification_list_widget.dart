import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import 'notification_card.dart';

class NotificationListWidget extends StatefulWidget {
  final String userId;
  final ScrollController? scrollController;

  const NotificationListWidget({
    super.key,
    required this.userId,
    this.scrollController,
  });

  @override
  State<NotificationListWidget> createState() => _NotificationListWidgetState();
}

class _NotificationListWidgetState extends State<NotificationListWidget> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
  }

  @override
  void dispose() {
    if (widget.scrollController == null) {
      _scrollController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state is NotificationLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is NotificationError) {
          return _buildErrorWidget(context, state);
        }

        if (state is NotificationsLoaded) {
          return _buildLoadedNotifications(context, state);
        }

        if (state is NotificationActionLoading && state.currentNotifications != null) {
          return _buildLoadedNotifications(
            context, 
            NotificationsLoaded(notifications: state.currentNotifications!),
            showLoading: true,
          );
        }

        return _buildEmptyState(context);
      },
    );
  }

  Widget _buildErrorWidget(BuildContext context, NotificationError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Lỗi khi tải thông báo',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              state.message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton(
              onPressed: () {
                context.read<NotificationBloc>().add(RefreshNotifications(
                  userId: widget.userId,
                ));
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedNotifications(
    BuildContext context, 
    NotificationsLoaded state, {
    bool showLoading = false,
  }) {
    if (state.notifications.isEmpty) {
      return _buildEmptyState(context);
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            context.read<NotificationBloc>().add(RefreshNotifications(
              userId: widget.userId,
            ));
          },
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: state.notifications.length,
            separatorBuilder: (context, index) => const SizedBox(
              height: AppConstants.smallPadding,
            ),
            itemBuilder: (context, index) {
              final notification = state.notifications[index];
              return NotificationCard(
                notification: notification,
                onTap: () => _handleNotificationTap(notification.id),
                onMarkAsRead: notification.isRead 
                    ? null 
                    : () => _markAsRead(notification.id),
                onDelete: () => _deleteNotification(notification.id),
              );
            },
          ),
        ),
        
        // Loading overlay
        if (showLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Chưa có thông báo nào',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Các thông báo mới sẽ xuất hiện ở đây',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleNotificationTap(String notificationId) {
    context.read<NotificationBloc>().add(HandleNotificationTap(
      notificationId: notificationId,
    ));
  }

  void _markAsRead(String notificationId) {
    context.read<NotificationBloc>().add(MarkNotificationAsRead(
      notificationId: notificationId,
    ));
  }

  void _deleteNotification(String notificationId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa thông báo'),
        content: const Text('Bạn có chắc chắn muốn xóa thông báo này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationBloc>().add(DeleteNotification(
                notificationId: notificationId,
              ));
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}