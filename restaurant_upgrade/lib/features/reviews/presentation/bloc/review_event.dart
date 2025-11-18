import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ReviewEvent extends Equatable {
  const ReviewEvent();

  @override
  List<Object?> get props => [];
}

class LoadReviews extends ReviewEvent {
  final String restaurantId;
  final String? orderBy;
  final int? limit;

  const LoadReviews({
    required this.restaurantId,
    this.orderBy,
    this.limit,
  });

  @override
  List<Object?> get props => [restaurantId, orderBy, limit];
}

class RefreshReviews extends ReviewEvent {
  final String restaurantId;
  final String? orderBy;
  final int? limit;

  const RefreshReviews({
    required this.restaurantId,
    this.orderBy,
    this.limit,
  });

  @override
  List<Object?> get props => [restaurantId, orderBy, limit];
}

class AddReview extends ReviewEvent {
  final String restaurantId;
  final String userId;
  final String userDisplayName;
  final String? userPhotoUrl;
  final int rating;
  final String comment;
  final List<File>? images;

  const AddReview({
    required this.restaurantId,
    required this.userId,
    required this.userDisplayName,
    this.userPhotoUrl,
    required this.rating,
    required this.comment,
    this.images,
  });

  @override
  List<Object?> get props => [
    restaurantId,
    userId,
    userDisplayName,
    userPhotoUrl,
    rating,
    comment,
    images,
  ];
}

class UpdateReview extends ReviewEvent {
  final String reviewId;
  final int? rating;
  final String? comment;
  final List<File>? newImages;
  final List<String>? imagesToDelete;

  const UpdateReview({
    required this.reviewId,
    this.rating,
    this.comment,
    this.newImages,
    this.imagesToDelete,
  });

  @override
  List<Object?> get props => [
    reviewId,
    rating,
    comment,
    newImages,
    imagesToDelete,
  ];
}

class DeleteReview extends ReviewEvent {
  final String reviewId;

  const DeleteReview({
    required this.reviewId,
  });

  @override
  List<Object> get props => [reviewId];
}

class MarkReviewAsHelpful extends ReviewEvent {
  final String reviewId;
  final String userId;

  const MarkReviewAsHelpful({
    required this.reviewId,
    required this.userId,
  });

  @override
  List<Object> get props => [reviewId, userId];
}

class UnmarkReviewAsHelpful extends ReviewEvent {
  final String reviewId;
  final String userId;

  const UnmarkReviewAsHelpful({
    required this.reviewId,
    required this.userId,
  });

  @override
  List<Object> get props => [reviewId, userId];
}

class GetUserReviewForRestaurant extends ReviewEvent {
  final String restaurantId;
  final String userId;

  const GetUserReviewForRestaurant({
    required this.restaurantId,
    required this.userId,
  });

  @override
  List<Object> get props => [restaurantId, userId];
}

class ChangeReviewOrder extends ReviewEvent {
  final String orderBy;

  const ChangeReviewOrder({
    required this.orderBy,
  });

  @override
  List<Object> get props => [orderBy];
}

class SelectImages extends ReviewEvent {
  final List<File> images;

  const SelectImages({
    required this.images,
  });

  @override
  List<Object> get props => [images];
}

class RemoveSelectedImage extends ReviewEvent {
  final int index;

  const RemoveSelectedImage({
    required this.index,
  });

  @override
  List<Object> get props => [index];
}

class ClearSelectedImages extends ReviewEvent {
  const ClearSelectedImages();
}

class ResetReviewForm extends ReviewEvent {
  const ResetReviewForm();
}