import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../injection_container.dart' as di;
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_list_widget.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<NotificationBloc>()
        ..add(const LoadNotifications(userId: 'current_user_id')), // TODO: Get actual user ID
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Thông báo'),
          actions: [
            BlocBuilder<NotificationBloc, NotificationState>(
              builder: (context, state) {
                if (state is NotificationsLoaded && state.notifications.isNotEmpty) {
                  return PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_all_read':
                          context.read<NotificationBloc>().add(
                            const MarkAllNotificationsAsRead(userId: 'current_user_id'),
                          );
                          break;
                        case 'clear_all':
                          _showClearAllDialog(context);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'mark_all_read',
                        child: Row(
                          children: [
                            Icon(Icons.mark_email_read),
                            SizedBox(width: 8),
                            Text('Đánh dấu tất cả đã đọc'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'clear_all',
                        child: Row(
                          children: [
                            Icon(Icons.clear_all),
                            SizedBox(width: 8),
                            Text('Xóa tất cả'),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.notifications_off, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'Thông báo đang được phát triển',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                'Vui lòng tạo Firestore indexes trước',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ), // TODO: Fix Firestore index and get actual user ID
      ),
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Xóa tất cả thông báo'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // TODO: Implement clear all notifications
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Xóa tất cả'),
          ),
        ],
      ),
    );
  }
}