import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class ReviewOrderSelector extends StatelessWidget {
  final String currentOrderBy;
  final ValueChanged<String> onOrderChanged;

  const ReviewOrderSelector({
    super.key,
    required this.currentOrderBy,
    required this.onOrderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      initialValue: currentOrderBy,
      onSelected: onOrderChanged,
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sort,
            size: 18,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            _getOrderDisplayName(currentOrderBy),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: AppConstants.orderByNewest,
          child: Row(
            children: [
              Icon(
                Icons.access_time,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              const Text('Mới nhất'),
            ],
          ),
        ),
        PopupMenuItem(
          value: AppConstants.orderByOldest,
          child: Row(
            children: [
              Icon(
                Icons.history,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              const Text('Cũ nhất'),
            ],
          ),
        ),
        PopupMenuItem(
          value: AppConstants.orderByRatingDesc,
          child: Row(
            children: [
              Icon(
                Icons.star,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              const Text('Đánh giá cao nhất'),
            ],
          ),
        ),
        PopupMenuItem(
          value: AppConstants.orderByRatingAsc,
          child: Row(
            children: [
              Icon(
                Icons.star_border,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              const Text('Đánh giá thấp nhất'),
            ],
          ),
        ),
        PopupMenuItem(
          value: AppConstants.orderByHelpful,
          child: Row(
            children: [
              Icon(
                Icons.thumb_up,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              const Text('Hữu ích nhất'),
            ],
          ),
        ),
      ],
    );
  }

  String _getOrderDisplayName(String orderBy) {
    switch (orderBy) {
      case AppConstants.orderByNewest:
        return 'Mới nhất';
      case AppConstants.orderByOldest:
        return 'Cũ nhất';
      case AppConstants.orderByRatingDesc:
        return 'Đánh giá cao';
      case AppConstants.orderByRatingAsc:
        return 'Đánh giá thấp';
      case AppConstants.orderByHelpful:
        return 'Hữu ích';
      default:
        return 'Mới nhất';
    }
  }
}