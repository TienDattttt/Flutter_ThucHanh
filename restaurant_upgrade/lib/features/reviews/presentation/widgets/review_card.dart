import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/review.dart';
import 'review_rating_display.dart';
import 'review_image_gallery.dart';

class ReviewCard extends StatelessWidget {
  final Review review;
  final String? currentUserId;
  final VoidCallback? onMarkHelpful;
  final VoidCallback? onUnmarkHelpful;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ReviewCard({
    super.key,
    required this.review,
    this.currentUserId,
    this.onMarkHelpful,
    this.onUnmarkHelpful,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrentUserReview = currentUserId == review.userId;
    final isMarkedHelpful = currentUserId != null && 
        review.helpfulUserIds.contains(currentUserId);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and rating
            _buildUserHeader(context),
            
            const SizedBox(height: AppConstants.smallPadding),
            
            // Review content
            _buildReviewContent(context),
            
            // Images if any
            if (review.imageUrls.isNotEmpty) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              _buildImageGallery(context),
            ],
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Actions and helpful count
            _buildActionsRow(context, isCurrentUserReview, isMarkedHelpful),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(BuildContext context) {
    return Row(
      children: [
        // User avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          backgroundImage: review.userPhotoUrl != null
              ? CachedNetworkImageProvider(review.userPhotoUrl!)
              : null,
          child: review.userPhotoUrl == null
              ? Text(
                  review.userDisplayName.isNotEmpty
                      ? review.userDisplayName[0].toUpperCase()
                      : '?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                )
              : null,
        ),
        
        const SizedBox(width: AppConstants.smallPadding),
        
        // User name and date
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                review.userDisplayName,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    AppDateUtils.formatRelativeTime(review.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (review.isEdited) ...[
                    const SizedBox(width: 4),
                    Text(
                      '• Đã chỉnh sửa',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        
        // Rating
        ReviewRatingDisplay(
          rating: review.rating.toDouble(),
          size: 16,
        ),
      ],
    );
  }

  Widget _buildReviewContent(BuildContext context) {
    return Text(
      review.comment,
      style: Theme.of(context).textTheme.bodyMedium,
    );
  }

  Widget _buildImageGallery(BuildContext context) {
    return ReviewImageGallery(
      imageUrls: review.imageUrls,
      maxHeight: 200,
    );
  }

  Widget _buildActionsRow(
    BuildContext context,
    bool isCurrentUserReview,
    bool isMarkedHelpful,
  ) {
    return Row(
      children: [
        // Helpful button
        if (!isCurrentUserReview && currentUserId != null)
          InkWell(
            onTap: isMarkedHelpful ? onUnmarkHelpful : onMarkHelpful,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.smallPadding,
                vertical: 4,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isMarkedHelpful ? Icons.thumb_up : Icons.thumb_up_outlined,
                    size: 16,
                    color: isMarkedHelpful
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Hữu ích',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isMarkedHelpful
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        
        // Helpful count
        if (review.helpfulCount > 0) ...[
          const SizedBox(width: AppConstants.smallPadding),
          Text(
            '${review.helpfulCount} người thấy hữu ích',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
        
        const Spacer(),
        
        // Edit and delete buttons for current user
        if (isCurrentUserReview) ...[
          InkWell(
            onTap: onEdit,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              child: Icon(
                Icons.edit_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.smallPadding),
          InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              child: Icon(
                Icons.delete_outlined,
                size: 18,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
        ],
      ],
    );
  }
}