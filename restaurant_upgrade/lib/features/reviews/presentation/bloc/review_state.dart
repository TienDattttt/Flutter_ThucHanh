import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../domain/entities/review.dart';

abstract class ReviewState extends Equatable {
  const ReviewState();

  @override
  List<Object?> get props => [];
}

class ReviewInitial extends ReviewState {
  const ReviewInitial();
}

class ReviewLoading extends ReviewState {
  const ReviewLoading();
}

class ReviewsLoaded extends ReviewState {
  final List<Review> reviews;
  final String? currentOrderBy;
  final bool hasReachedMax;

  const ReviewsLoaded({
    required this.reviews,
    this.currentOrderBy,
    this.hasReachedMax = false,
  });

  @override
  List<Object?> get props => [reviews, currentOrderBy, hasReachedMax];

  ReviewsLoaded copyWith({
    List<Review>? reviews,
    String? currentOrderBy,
    bool? hasReachedMax,
  }) {
    return ReviewsLoaded(
      reviews: reviews ?? this.reviews,
      currentOrderBy: currentOrderBy ?? this.currentOrderBy,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }
}

class ReviewError extends ReviewState {
  final String message;
  final String? code;

  const ReviewError({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class ReviewActionLoading extends ReviewState {
  final String action;
  final List<Review>? currentReviews;

  const ReviewActionLoading({
    required this.action,
    this.currentReviews,
  });

  @override
  List<Object?> get props => [action, currentReviews];
}

class ReviewActionSuccess extends ReviewState {
  final String message;
  final String action;
  final Review? review;
  final List<Review>? reviews;

  const ReviewActionSuccess({
    required this.message,
    required this.action,
    this.review,
    this.reviews,
  });

  @override
  List<Object?> get props => [message, action, review, reviews];
}

class ReviewActionError extends ReviewState {
  final String message;
  final String action;
  final String? code;
  final List<Review>? currentReviews;

  const ReviewActionError({
    required this.message,
    required this.action,
    this.code,
    this.currentReviews,
  });

  @override
  List<Object?> get props => [message, action, code, currentReviews];
}

class UserReviewLoaded extends ReviewState {
  final Review? userReview;
  final String restaurantId;
  final String userId;

  const UserReviewLoaded({
    this.userReview,
    required this.restaurantId,
    required this.userId,
  });

  @override
  List<Object?> get props => [userReview, restaurantId, userId];
}

class ReviewFormState extends ReviewState {
  final int rating;
  final String comment;
  final List<File> selectedImages;
  final bool isValid;
  final String? validationError;

  const ReviewFormState({
    this.rating = 0,
    this.comment = '',
    this.selectedImages = const [],
    this.isValid = false,
    this.validationError,
  });

  @override
  List<Object?> get props => [
    rating,
    comment,
    selectedImages,
    isValid,
    validationError,
  ];

  ReviewFormState copyWith({
    int? rating,
    String? comment,
    List<File>? selectedImages,
    bool? isValid,
    String? validationError,
  }) {
    return ReviewFormState(
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      selectedImages: selectedImages ?? this.selectedImages,
      isValid: isValid ?? this.isValid,
      validationError: validationError ?? this.validationError,
    );
  }
}

class ReviewImagePickerState extends ReviewState {
  final List<File> selectedImages;
  final bool isPickingImage;
  final String? error;

  const ReviewImagePickerState({
    this.selectedImages = const [],
    this.isPickingImage = false,
    this.error,
  });

  @override
  List<Object?> get props => [selectedImages, isPickingImage, error];

  ReviewImagePickerState copyWith({
    List<File>? selectedImages,
    bool? isPickingImage,
    String? error,
  }) {
    return ReviewImagePickerState(
      selectedImages: selectedImages ?? this.selectedImages,
      isPickingImage: isPickingImage ?? this.isPickingImage,
      error: error ?? this.error,
    );
  }
}