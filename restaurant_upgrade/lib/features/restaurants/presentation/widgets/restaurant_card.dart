import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/location_utils.dart';
import '../../domain/entities/restaurant.dart';

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;
  final bool showDistance;
  final double? userLatitude;
  final double? userLongitude;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
    this.showDistance = false,
    this.userLatitude,
    this.userLongitude,
  });

  @override
  Widget build(BuildContext context) {
    String? distanceText;
    if (showDistance && userLatitude != null && userLongitude != null) {
      final distance = LocationUtils.calculateDistance(
        userLatitude!,
        userLongitude!,
        restaurant.latitude,
        restaurant.longitude,
      );
      distanceText = LocationUtils.formatDistance(distance);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.cardBorderRadius),
                topRight: Radius.circular(AppConstants.cardBorderRadius),
              ),
              child: restaurant.imageUrls.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: restaurant.imageUrls.first,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.restaurant,
                          size: 64,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.restaurant,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
            ),

            // Restaurant Info
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and Distance
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          restaurant.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (distanceText != null) ...[
                        const SizedBox(width: AppConstants.smallPadding),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.smallPadding,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            distanceText,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding),

                  // Rating and Reviews
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.averageRating > 0
                            ? restaurant.averageRating.toStringAsFixed(1)
                            : 'Chưa có đánh giá',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        '(${restaurant.totalReviews} đánh giá)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding),

                  // Address
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding),

                  // Categories
                  if (restaurant.categories.isNotEmpty)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: restaurant.categories.take(3).map((category) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.smallPadding,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}