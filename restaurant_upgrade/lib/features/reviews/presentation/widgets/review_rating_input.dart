import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class ReviewRatingInput extends StatefulWidget {
  final double initialRating;
  final ValueChanged<double> onRatingChanged;
  final bool enabled;
  final double size;

  const ReviewRatingInput({
    super.key,
    this.initialRating = 0.0,
    required this.onRatingChanged,
    this.enabled = true,
    this.size = 32.0,
  });

  @override
  State<ReviewRatingInput> createState() => _ReviewRatingInputState();
}

class _ReviewRatingInputState extends State<ReviewRatingInput> {
  late double _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đánh giá của bạn',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.smallPadding),
        
        // Star rating input
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final starValue = index + 1.0;
            return GestureDetector(
              onTap: widget.enabled ? () => _updateRating(starValue) : null,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: Icon(
                  _currentRating >= starValue
                      ? Icons.star
                      : _currentRating >= starValue - 0.5
                          ? Icons.star_half
                          : Icons.star_border,
                  size: widget.size,
                  color: _currentRating >= starValue - 0.5
                      ? Colors.amber
                      : Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
            );
          }),
        ),
        
        const SizedBox(height: AppConstants.smallPadding),
        
        // Rating text
        Text(
          _getRatingText(_currentRating),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _updateRating(double rating) {
    if (!widget.enabled) return;
    
    setState(() {
      _currentRating = rating;
    });
    widget.onRatingChanged(rating);
  }

  String _getRatingText(double rating) {
    if (rating == 0) return 'Chưa đánh giá';
    if (rating <= 1) return 'Rất tệ';
    if (rating <= 2) return 'Tệ';
    if (rating <= 3) return 'Trung bình';
    if (rating <= 4) return 'Tốt';
    return 'Xuất sắc';
  }
}