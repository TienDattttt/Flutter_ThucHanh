import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/notification.dart' as app_notification;

class NotificationCard extends StatelessWidget {
  final app_notification.Notification notification;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: notification.isRead ? 1 : 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
            color: notification.isRead 
                ? null 
                : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon, title and actions
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notification icon
                  _buildNotificationIcon(context),
                  
                  const SizedBox(width: AppConstants.smallPadding),
                  
                  // Title and content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: notification.isRead 
                                ? FontWeight.normal 
                                : FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.body,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Actions menu
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'mark_read':
                          onMarkAsRead?.call();
                          break;
                        case 'delete':
                          onDelete?.call();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      if (!notification.isRead && onMarkAsRead != null)
                        const PopupMenuItem(
                          value: 'mark_read',
                          child: Row(
                            children: [
                              Icon(Icons.mark_email_read),
                              SizedBox(width: 8),
                              Text('Đánh dấu đã đọc'),
                            ],
                          ),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete),
                              SizedBox(width: 8),
                              Text('Xóa'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              
              // Image if available
              if (notification.imageUrl != null) ...[
                const SizedBox(height: AppConstants.smallPadding),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  child: CachedNetworkImage(
                    imageUrl: notification.imageUrl!,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 120,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 120,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: const Center(
                        child: Icon(Icons.error_outline),
                      ),
                    ),
                  ),
                ),
              ],
              
              // Footer with timestamp
              const SizedBox(height: AppConstants.smallPadding),
              Row(
                children: [
                  Text(
                    AppDateUtils.formatRelativeTime(notification.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  if (!notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case 'new_review':
        iconData = Icons.rate_review;
        iconColor = Colors.green;
        break;
      case 'review_reply':
        iconData = Icons.reply;
        iconColor = Colors.blue;
        break;
      case 'restaurant_update':
        iconData = Icons.restaurant;
        iconColor = Colors.orange;
        break;
      case 'system_announcement':
        iconData = Icons.announcement;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Theme.of(context).colorScheme.primary;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 20,
        color: iconColor,
      ),
    );
  }
}