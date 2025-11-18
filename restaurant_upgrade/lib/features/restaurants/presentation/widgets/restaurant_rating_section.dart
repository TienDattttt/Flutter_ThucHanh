import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantRatingSection extends StatelessWidget {
  final Restaurant restaurant;

  const RestaurantRatingSection({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Đánh giá',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppConstants.defaultPadding),

          if (restaurant.totalReviews > 0) ...[
            // Rating Summary
            Row(
              children: [
                // Average Rating
                Container(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
                  ),
                  child: Column(
                    children: [
                      Text(
                        restaurant.averageRating.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          return Icon(
                            Icons.star,
                            size: 16,
                            color: index < restaurant.averageRating.round()
                                ? Colors.amber
                                : Colors.grey[300],
                          );
                        }),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: AppConstants.defaultPadding),

                // Rating Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${restaurant.totalReviews} đánh giá',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppConstants.smallPadding),
                      
                      // Rating Distribution (placeholder)
                      ...List.generate(5, (index) {
                        final starCount = 5 - index;
                        // This is a placeholder - actual distribution would come from reviews
                        final percentage = _getPlaceholderPercentage(starCount, restaurant.averageRating);
                        
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Text(
                                '$starCount',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.star,
                                size: 12,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: AppConstants.smallPadding),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: Colors.grey[300],
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppConstants.smallPadding),
                              Text(
                                '${percentage.toInt()}%',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppConstants.defaultPadding),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to add review page
                    },
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Viết đánh giá'),
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to all reviews page
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('Xem tất cả'),
                  ),
                ),
              ],
            ),
          ] else ...[
            // No Reviews Yet
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.largePadding),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 48,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  Text(
                    'Chưa có đánh giá',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  Text(
                    'Hãy là người đầu tiên đánh giá nhà hàng này!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to add review page
                    },
                    icon: const Icon(Icons.rate_review),
                    label: const Text('Viết đánh giá đầu tiên'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Placeholder function to generate rating distribution
  // In real implementation, this would come from actual review data
  double _getPlaceholderPercentage(int starCount, double averageRating) {
    if (averageRating == 0) return 0;
    
    // Simple algorithm to generate realistic-looking distribution
    final diff = (starCount - averageRating).abs();
    if (diff < 0.5) return 40 + (10 * (1 - diff * 2));
    if (diff < 1.0) return 25 + (15 * (1 - diff));
    if (diff < 1.5) return 15 + (10 * (1 - (diff - 1) * 2));
    if (diff < 2.0) return 8 + (7 * (1 - (diff - 1.5) * 2));
    return 2 + (6 * (1 - (diff - 2) / 3));
  }
}