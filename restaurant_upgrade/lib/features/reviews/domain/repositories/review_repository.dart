import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/review.dart';

abstract class ReviewRepository {
  /// Get reviews for a specific restaurant
  Stream<Either<Failure, List<Review>>> getReviewsForRestaurant({
    required String restaurantId,
    int? limit,
    String? orderBy,
  });

  /// Get reviews by a specific user
  Stream<Either<Failure, List<Review>>> getReviewsByUser({
    required String userId,
    int? limit,
  });

  /// Get a specific review by ID
  Future<Either<Failure, Review>> getReviewById(String reviewId);

  /// Add a new review
  Future<Either<Failure, Review>> addReview({
    required String restaurantId,
    required String userId,
    required String userDisplayName,
    String? userPhotoUrl,
    required int rating,
    required String comment,
    List<File>? images,
  });

  /// Update an existing review
  Future<Either<Failure, Review>> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
    List<File>? newImages,
    List<String>? imagesToDelete,
  });

  /// Delete a review
  Future<Either<Failure, void>> deleteReview(String reviewId);

  /// Upload review images
  Future<Either<Failure, List<String>>> uploadReviewImages({
    required String reviewId,
    required List<File> images,
  });

  /// Delete review images
  Future<Either<Failure, void>> deleteReviewImages({
    required List<String> imageUrls,
  });

  /// Mark review as helpful
  Future<Either<Failure, Review>> markReviewAsHelpful({
    required String reviewId,
    required String userId,
  });

  /// Unmark review as helpful
  Future<Either<Failure, Review>> unmarkReviewAsHelpful({
    required String reviewId,
    required String userId,
  });

  /// Get user's own review for a restaurant
  Future<Either<Failure, Review?>> getUserReviewForRestaurant({
    required String restaurantId,
    required String userId,
  });
}