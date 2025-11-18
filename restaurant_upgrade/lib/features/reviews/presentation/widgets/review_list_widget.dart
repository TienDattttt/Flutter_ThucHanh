import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/review.dart';
import '../bloc/review_bloc.dart';
import '../bloc/review_state.dart';
import '../bloc/review_event.dart';
import 'review_card.dart';
import 'review_order_selector.dart';

class ReviewListWidget extends StatefulWidget {
  final String restaurantId;
  final String? currentUserId;
  final ScrollController? scrollController;

  const ReviewListWidget({
    super.key,
    required this.restaurantId,
    this.currentUserId,
    this.scrollController,
  });

  @override
  State<ReviewListWidget> createState() => _ReviewListWidgetState();
}

class _ReviewListWidgetState extends State<ReviewListWidget> {
  late ScrollController _scrollController;
  String _currentOrderBy = AppConstants.orderByNewest;

  @override
  void initState() {
    super.initState();
    _scrollController = widget.scrollController ?? ScrollController();
    
    // Load reviews when widget is initialized
    context.read<ReviewBloc>().add(LoadReviews(
      restaurantId: widget.restaurantId,
      orderBy: _currentOrderBy,
    ));
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
    return BlocBuilder<ReviewBloc, ReviewState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with order selector
            _buildHeader(context, state),
            
            const SizedBox(height: AppConstants.defaultPadding),
            
            // Reviews list
            Expanded(
              child: _buildReviewsList(context, state),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ReviewState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Đánh giá',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ReviewOrderSelector(
            currentOrderBy: _currentOrderBy,
            onOrderChanged: (orderBy) {
              setState(() {
                _currentOrderBy = orderBy;
              });
              context.read<ReviewBloc>().add(ChangeReviewOrder(
                orderBy: orderBy,
              ));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsList(BuildContext context, ReviewState state) {
    if (state is ReviewLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is ReviewError) {
      return _buildErrorWidget(context, state);
    }

    if (state is ReviewsLoaded) {
      return _buildLoadedReviews(context, state);
    }

    if (state is ReviewActionLoading && state.currentReviews != null) {
      return _buildLoadedReviews(
        context, 
        ReviewsLoaded(reviews: state.currentReviews!),
        showLoading: true,
      );
    }

    return _buildEmptyState(context);
  }

  Widget _buildErrorWidget(BuildContext context, ReviewError state) {
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
              'Lỗi khi tải đánh giá',
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
                context.read<ReviewBloc>().add(RefreshReviews(
                  restaurantId: widget.restaurantId,
                  orderBy: _currentOrderBy,
                ));
              },
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedReviews(
    BuildContext context, 
    ReviewsLoaded state, {
    bool showLoading = false,
  }) {
    if (state.reviews.isEmpty) {
      return _buildEmptyState(context);
    }

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            context.read<ReviewBloc>().add(RefreshReviews(
              restaurantId: widget.restaurantId,
              orderBy: _currentOrderBy,
            ));
          },
          child: ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: state.reviews.length,
            separatorBuilder: (context, index) => const SizedBox(
              height: AppConstants.defaultPadding,
            ),
            itemBuilder: (context, index) {
              final review = state.reviews[index];
              return ReviewCard(
                review: review,
                currentUserId: widget.currentUserId,
                onMarkHelpful: widget.currentUserId != null
                    ? () => _markReviewAsHelpful(review)
                    : null,
                onUnmarkHelpful: widget.currentUserId != null
                    ? () => _unmarkReviewAsHelpful(review)
                    : null,
                onEdit: widget.currentUserId == review.userId
                    ? () => _editReview(review)
                    : null,
                onDelete: widget.currentUserId == review.userId
                    ? () => _deleteReview(review)
                    : null,
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
              Icons.rate_review_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Chưa có đánh giá nào',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              'Hãy là người đầu tiên đánh giá nhà hàng này!',
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

  void _markReviewAsHelpful(Review review) {
    if (widget.currentUserId != null) {
      context.read<ReviewBloc>().add(MarkReviewAsHelpful(
        reviewId: review.id,
        userId: widget.currentUserId!,
      ));
    }
  }

  void _unmarkReviewAsHelpful(Review review) {
    if (widget.currentUserId != null) {
      context.read<ReviewBloc>().add(UnmarkReviewAsHelpful(
        reviewId: review.id,
        userId: widget.currentUserId!,
      ));
    }
  }

  void _editReview(Review review) {
    // TODO: Navigate to edit review page
    // Navigator.of(context).push(
    //   MaterialPageRoute(
    //     builder: (context) => EditReviewPage(review: review),
    //   ),
    // );
  }

  void _deleteReview(Review review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa đánh giá'),
        content: const Text('Bạn có chắc chắn muốn xóa đánh giá này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<ReviewBloc>().add(DeleteReview(
                reviewId: review.id,
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