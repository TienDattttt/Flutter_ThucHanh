import 'package:flutter/material.dart';

class ReviewRatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final bool showRatingText;
  final int? reviewCount;

  const ReviewRatingDisplay({
    super.key,
    required this.rating,
    this.size = 16.0,
    this.showRatingText = false,
    this.reviewCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Star rating display
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starValue = index + 1.0;
            return Icon(
              rating >= starValue
                  ? Icons.star
                  : rating >= starValue - 0.5
                      ? Icons.star_half
                      : Icons.star_border,
              size: size,
              color: rating >= starValue - 0.5
                  ? Colors.amber
                  : Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
            );
          }),
        ),
        
        // Rating text and count
        if (showRatingText || reviewCount != null) ...[
          const SizedBox(width: 8),
          Text(
            _buildRatingText(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }

  String _buildRatingText() {
    final parts = <String>[];
    
    if (showRatingText) {
      parts.add(rating.toStringAsFixed(1));
    }
    
    if (reviewCount != null) {
      parts.add('($reviewCount đánh giá)');
    }
    
    return parts.join(' ');
  }
}