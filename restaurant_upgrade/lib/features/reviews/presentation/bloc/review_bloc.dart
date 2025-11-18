import 'dart:async';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_reviews_usecase.dart';
import '../../domain/usecases/add_review_usecase.dart';
import '../../domain/usecases/update_review_usecase.dart';
import '../../domain/usecases/delete_review_usecase.dart';
import '../../domain/usecases/mark_review_as_helpful_usecase.dart';
import '../../domain/usecases/unmark_review_as_helpful_usecase.dart';
import '../../domain/usecases/get_user_review_for_restaurant_usecase.dart';
import 'review_event.dart';
import 'review_state.dart';

class ReviewBloc extends Bloc<ReviewEvent, ReviewState> {
  final GetReviewsUseCase getReviewsUseCase;
  final AddReviewUseCase addReviewUseCase;
  final UpdateReviewUseCase updateReviewUseCase;
  final DeleteReviewUseCase deleteReviewUseCase;
  final MarkReviewAsHelpfulUseCase markReviewAsHelpfulUseCase;
  final UnmarkReviewAsHelpfulUseCase unmarkReviewAsHelpfulUseCase;
  final GetUserReviewForRestaurantUseCase getUserReviewForRestaurantUseCase;

  StreamSubscription<List<Review>>? _reviewsSubscription;
  String? _currentRestaurantId;
  String? _currentOrderBy;

  ReviewBloc({
    required this.getReviewsUseCase,
    required this.addReviewUseCase,
    required this.updateReviewUseCase,
    required this.deleteReviewUseCase,
    required this.markReviewAsHelpfulUseCase,
    required this.unmarkReviewAsHelpfulUseCase,
    required this.getUserReviewForRestaurantUseCase,
  }) : super(const ReviewInitial()) {
    on<LoadReviews>(_onLoadReviews);
    on<RefreshReviews>(_onRefreshReviews);
    on<AddReview>(_onAddReview);
    on<UpdateReview>(_onUpdateReview);
    on<DeleteReview>(_onDeleteReview);
    on<MarkReviewAsHelpful>(_onMarkReviewAsHelpful);
    on<UnmarkReviewAsHelpful>(_onUnmarkReviewAsHelpful);
    on<GetUserReviewForRestaurant>(_onGetUserReviewForRestaurant);
    on<ChangeReviewOrder>(_onChangeReviewOrder);
    on<SelectImages>(_onSelectImages);
    on<RemoveSelectedImage>(_onRemoveSelectedImage);
    on<ClearSelectedImages>(_onClearSelectedImages);
    on<ResetReviewForm>(_onResetReviewForm);
  }

  @override
  Future<void> close() {
    _reviewsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadReviews(LoadReviews event, Emitter<ReviewState> emit) async {
    if (_currentRestaurantId != event.restaurantId || 
        _currentOrderBy != event.orderBy) {
      emit(const ReviewLoading());
    }

    _currentRestaurantId = event.restaurantId;
    _currentOrderBy = event.orderBy;

    final result = await getReviewsUseCase(GetReviewsParams(
      restaurantId: event.restaurantId,
      limit: event.limit,
      orderBy: event.orderBy,
    ));

    result.fold(
      (failure) => emit(ReviewError(
        message: failure.message,
        code: failure.code,
      )),
      (reviewsStream) {
        _reviewsSubscription?.cancel();
        _reviewsSubscription = reviewsStream.listen(
          (reviews) {
            if (!isClosed) {
              emit(ReviewsLoaded(
                reviews: reviews,
                currentOrderBy: event.orderBy,
                hasReachedMax: reviews.length < (event.limit ?? AppConstants.reviewListPageSize),
              ));
            }
          },
          onError: (error) {
            if (!isClosed) {
              emit(ReviewError(
                message: error.toString(),
                code: 'stream-error',
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _onRefreshReviews(RefreshReviews event, Emitter<ReviewState> emit) async {
    // Keep current state while refreshing
    final currentState = state;
    
    final result = await getReviewsUseCase(GetReviewsParams(
      restaurantId: event.restaurantId,
      limit: event.limit,
      orderBy: event.orderBy,
    ));

    result.fold(
      (failure) => emit(ReviewError(
        message: failure.message,
        code: failure.code,
      )),
      (reviewsStream) {
        _reviewsSubscription?.cancel();
        _reviewsSubscription = reviewsStream.listen(
          (reviews) {
            if (!isClosed) {
              emit(ReviewsLoaded(
                reviews: reviews,
                currentOrderBy: event.orderBy,
                hasReachedMax: reviews.length < (event.limit ?? AppConstants.reviewListPageSize),
              ));
            }
          },
          onError: (error) {
            if (!isClosed) {
              emit(ReviewError(
                message: error.toString(),
                code: 'stream-error',
              ));
            }
          },
        );
      },
    );
  }

  Future<void> _onAddReview(AddReview event, Emitter<ReviewState> emit) async {
    final currentReviews = _getCurrentReviews();
    
    emit(ReviewActionLoading(
      action: 'add',
      currentReviews: currentReviews,
    ));

    final result = await addReviewUseCase(AddReviewParams(
      restaurantId: event.restaurantId,
      userId: event.userId,
      userDisplayName: event.userDisplayName,
      userPhotoUrl: event.userPhotoUrl,
      rating: event.rating,
      comment: event.comment,
      images: event.images,
    ));

    result.fold(
      (failure) => emit(ReviewActionError(
        message: failure.message,
        action: 'add',
        code: failure.code,
        currentReviews: currentReviews,
      )),
      (review) => emit(const ReviewActionSuccess(
        message: AppConstants.reviewAddedMessage,
        action: 'add',
      )),
    );
  }

  Future<void> _onUpdateReview(UpdateReview event, Emitter<ReviewState> emit) async {
    final currentReviews = _getCurrentReviews();
    
    emit(ReviewActionLoading(
      action: 'update',
      currentReviews: currentReviews,
    ));

    final result = await updateReviewUseCase(UpdateReviewParams(
      reviewId: event.reviewId,
      rating: event.rating,
      comment: event.comment,
      newImages: event.newImages,
      imagesToDelete: event.imagesToDelete,
    ));

    result.fold(
      (failure) => emit(ReviewActionError(
        message: failure.message,
        action: 'update',
        code: failure.code,
        currentReviews: currentReviews,
      )),
      (review) => emit(const ReviewActionSuccess(
        message: AppConstants.reviewUpdatedMessage,
        action: 'update',
      )),
    );
  }

  Future<void> _onDeleteReview(DeleteReview event, Emitter<ReviewState> emit) async {
    final currentReviews = _getCurrentReviews();
    
    emit(ReviewActionLoading(
      action: 'delete',
      currentReviews: currentReviews,
    ));

    final result = await deleteReviewUseCase(DeleteReviewParams(
      reviewId: event.reviewId,
    ));

    result.fold(
      (failure) => emit(ReviewActionError(
        message: failure.message,
        action: 'delete',
        code: failure.code,
        currentReviews: currentReviews,
      )),
      (_) => emit(const ReviewActionSuccess(
        message: AppConstants.reviewDeletedMessage,
        action: 'delete',
      )),
    );
  }

  Future<void> _onMarkReviewAsHelpful(MarkReviewAsHelpful event, Emitter<ReviewState> emit) async {
    final result = await markReviewAsHelpfulUseCase(MarkReviewAsHelpfulParams(
      reviewId: event.reviewId,
      userId: event.userId,
    ));

    result.fold(
      (failure) => emit(ReviewActionError(
        message: failure.message,
        action: 'mark_helpful',
        code: failure.code,
      )),
      (review) {
        // Update the review in current state if available
        if (state is ReviewsLoaded) {
          final currentState = state as ReviewsLoaded;
          final updatedReviews = currentState.reviews.map((r) {
            return r.id == review.id ? review : r;
          }).toList();
          
          emit(currentState.copyWith(reviews: updatedReviews));
        }
      },
    );
  }

  Future<void> _onUnmarkReviewAsHelpful(UnmarkReviewAsHelpful event, Emitter<ReviewState> emit) async {
    final result = await unmarkReviewAsHelpfulUseCase(UnmarkReviewAsHelpfulParams(
      reviewId: event.reviewId,
      userId: event.userId,
    ));

    result.fold(
      (failure) => emit(ReviewActionError(
        message: failure.message,
        action: 'unmark_helpful',
        code: failure.code,
      )),
      (review) {
        // Update the review in current state if available
        if (state is ReviewsLoaded) {
          final currentState = state as ReviewsLoaded;
          final updatedReviews = currentState.reviews.map((r) {
            return r.id == review.id ? review : r;
          }).toList();
          
          emit(currentState.copyWith(reviews: updatedReviews));
        }
      },
    );
  }

  Future<void> _onGetUserReviewForRestaurant(GetUserReviewForRestaurant event, Emitter<ReviewState> emit) async {
    final result = await getUserReviewForRestaurantUseCase(GetUserReviewForRestaurantParams(
      restaurantId: event.restaurantId,
      userId: event.userId,
    ));

    result.fold(
      (failure) => emit(ReviewError(
        message: failure.message,
        code: failure.code,
      )),
      (review) => emit(UserReviewLoaded(
        userReview: review,
        restaurantId: event.restaurantId,
        userId: event.userId,
      )),
    );
  }

  Future<void> _onChangeReviewOrder(ChangeReviewOrder event, Emitter<ReviewState> emit) async {
    if (_currentRestaurantId != null) {
      add(LoadReviews(
        restaurantId: _currentRestaurantId!,
        orderBy: event.orderBy,
      ));
    }
  }

  Future<void> _onSelectImages(SelectImages event, Emitter<ReviewState> emit) async {
    if (state is ReviewImagePickerState) {
      final currentState = state as ReviewImagePickerState;
      final allImages = [...currentState.selectedImages, ...event.images];
      
      if (allImages.length > AppConstants.maxImagesPerReview) {
        emit(currentState.copyWith(
          error: 'Không được chọn quá ${AppConstants.maxImagesPerReview} hình ảnh',
        ));
        return;
      }
      
      emit(currentState.copyWith(
        selectedImages: allImages,
        error: null,
      ));
    } else {
      emit(ReviewImagePickerState(
        selectedImages: event.images.take(AppConstants.maxImagesPerReview).toList(),
      ));
    }
  }

  Future<void> _onRemoveSelectedImage(RemoveSelectedImage event, Emitter<ReviewState> emit) async {
    if (state is ReviewImagePickerState) {
      final currentState = state as ReviewImagePickerState;
      final updatedImages = List<File>.from(currentState.selectedImages);
      
      if (event.index >= 0 && event.index < updatedImages.length) {
        updatedImages.removeAt(event.index);
        emit(currentState.copyWith(
          selectedImages: updatedImages,
          error: null,
        ));
      }
    }
  }

  Future<void> _onClearSelectedImages(ClearSelectedImages event, Emitter<ReviewState> emit) async {
    if (state is ReviewImagePickerState) {
      final currentState = state as ReviewImagePickerState;
      emit(currentState.copyWith(
        selectedImages: [],
        error: null,
      ));
    } else {
      emit(const ReviewImagePickerState());
    }
  }

  Future<void> _onResetReviewForm(ResetReviewForm event, Emitter<ReviewState> emit) async {
    emit(const ReviewFormState());
  }

  List<Review>? _getCurrentReviews() {
    if (state is ReviewsLoaded) {
      return (state as ReviewsLoaded).reviews;
    }
    return null;
  }
}