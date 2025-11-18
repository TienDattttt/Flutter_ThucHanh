import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/app_constants.dart';

import '../models/review_model.dart';

abstract class ReviewRemoteDataSource {
  /// Get reviews for a specific restaurant
  Stream<List<ReviewModel>> getReviewsForRestaurant({
    required String restaurantId,
    int? limit,
    String? orderBy,
  });

  /// Get reviews by a specific user
  Stream<List<ReviewModel>> getReviewsByUser({
    required String userId,
    int? limit,
  });

  /// Get a specific review by ID
  Future<ReviewModel> getReviewById(String reviewId);

  /// Add a new review
  Future<ReviewModel> addReview(ReviewModel review);

  /// Update an existing review
  Future<ReviewModel> updateReview(ReviewModel review);

  /// Delete a review
  Future<void> deleteReview(String reviewId);

  /// Upload review images
  Future<List<String>> uploadReviewImages({
    required String reviewId,
    required List<File> images,
  });

  /// Delete review images
  Future<void> deleteReviewImages({
    required List<String> imageUrls,
  });

  /// Mark review as helpful
  Future<ReviewModel> markReviewAsHelpful({
    required String reviewId,
    required String userId,
  });

  /// Unmark review as helpful
  Future<ReviewModel> unmarkReviewAsHelpful({
    required String reviewId,
    required String userId,
  });

  /// Get user's own review for a restaurant
  Future<ReviewModel?> getUserReviewForRestaurant({
    required String restaurantId,
    required String userId,
  });
}

class ReviewRemoteDataSourceImpl implements ReviewRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  final CloudinaryService cloudinaryService;

  ReviewRemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
    CloudinaryService? cloudinaryService,
  }) : cloudinaryService = cloudinaryService ?? CloudinaryService.instance;

  @override
  Stream<List<ReviewModel>> getReviewsForRestaurant({
    required String restaurantId,
    int? limit,
    String? orderBy,
  }) {
    try {
      Query query = firestore
          .collection(AppConstants.reviewsCollection)
          .where('restaurantId', isEqualTo: restaurantId);

      // Apply ordering
      switch (orderBy) {
        case 'rating_desc':
          query = query.orderBy('rating', descending: true);
          break;
        case 'rating_asc':
          query = query.orderBy('rating', descending: false);
          break;
        case 'helpful':
          query = query.orderBy('helpfulCount', descending: true);
          break;
        case 'oldest':
          query = query.orderBy('createdAt', descending: false);
          break;
        default:
          query = query.orderBy('createdAt', descending: true);
      }

      // Apply limit
      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi tải danh sách đánh giá: ${e.toString()}',
        code: 'get-reviews-failed',
      );
    }
  }

  @override
  Stream<List<ReviewModel>> getReviewsByUser({
    required String userId,
    int? limit,
  }) {
    try {
      Query query = firestore
          .collection(AppConstants.reviewsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      if (limit != null && limit > 0) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => ReviewModel.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi tải đánh giá của người dùng: ${e.toString()}',
        code: 'get-user-reviews-failed',
      );
    }
  }

  @override
  Future<ReviewModel> getReviewById(String reviewId) async {
    try {
      final doc = await firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId)
          .get();

      if (!doc.exists) {
        throw const ServerException(
          message: 'Không tìm thấy đánh giá',
          code: 'review-not-found',
        );
      }

      return ReviewModel.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Lỗi khi tải thông tin đánh giá: ${e.toString()}',
        code: 'get-review-failed',
      );
    }
  }

  @override
  Future<ReviewModel> addReview(ReviewModel review) async {
    try {
      // Check if user already has a review for this restaurant
      final existingReview = await getUserReviewForRestaurant(
        restaurantId: review.restaurantId,
        userId: review.userId,
      );

      if (existingReview != null) {
        throw const ServerException(
          message: 'Bạn đã đánh giá nhà hàng này rồi',
          code: 'review-already-exists',
        );
      }

      final docRef = await firestore
          .collection(AppConstants.reviewsCollection)
          .add(review.toFirestore());

      final doc = await docRef.get();
      return ReviewModel.fromFirestore(doc);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Lỗi khi thêm đánh giá: ${e.toString()}',
        code: 'add-review-failed',
      );
    }
  }

  @override
  Future<ReviewModel> updateReview(ReviewModel review) async {
    try {
      await firestore
          .collection(AppConstants.reviewsCollection)
          .doc(review.id)
          .update({
        ...review.toFirestore(),
        'updatedAt': Timestamp.now(),
        'isEdited': true,
      });

      final doc = await firestore
          .collection(AppConstants.reviewsCollection)
          .doc(review.id)
          .get();

      return ReviewModel.fromFirestore(doc);
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi cập nhật đánh giá: ${e.toString()}',
        code: 'update-review-failed',
      );
    }
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    try {
      // Get review to delete associated images
      final review = await getReviewById(reviewId);
      
      // Delete images if any
      if (review.imageUrls.isNotEmpty) {
        await deleteReviewImages(imageUrls: review.imageUrls);
      }

      // Delete review document
      await firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId)
          .delete();
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Lỗi khi xóa đánh giá: ${e.toString()}',
        code: 'delete-review-failed',
      );
    }
  }

  @override
  Future<List<String>> uploadReviewImages({
    required String reviewId,
    required List<File> images,
  }) async {
    try {
      // Use Cloudinary for image upload
      return await cloudinaryService.uploadMultipleImages(
        imageFiles: images,
        folder: '${AppConstants.reviewImagesFolder}/$reviewId',
        tags: {'review': reviewId, 'type': 'review'},
      );
    } catch (e) {
      throw StorageException(
        message: 'Lỗi khi tải lên hình ảnh: ${e.toString()}',
        code: 'upload-review-images-failed',
      );
    }
  }

  @override
  Future<void> deleteReviewImages({
    required List<String> imageUrls,
  }) async {
    try {
      for (final imageUrl in imageUrls) {
        try {
          final publicId = cloudinaryService.extractPublicIdFromUrl(imageUrl);
          if (publicId != null) {
            await cloudinaryService.deleteImage(publicId: publicId);
          }
        } catch (e) {
          // Continue deleting other images even if one fails
          // Log error silently - in production, this should use proper logging
        }
      }
    } catch (e) {
      throw StorageException(
        message: 'Lỗi khi xóa hình ảnh: ${e.toString()}',
        code: 'delete-review-images-failed',
      );
    }
  }

  @override
  Future<ReviewModel> markReviewAsHelpful({
    required String reviewId,
    required String userId,
  }) async {
    try {
      final reviewRef = firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId);

      return await firestore.runTransaction((transaction) async {
        final reviewDoc = await transaction.get(reviewRef);
        
        if (!reviewDoc.exists) {
          throw const ServerException(
            message: 'Không tìm thấy đánh giá',
            code: 'review-not-found',
          );
        }

        final review = ReviewModel.fromFirestore(reviewDoc);
        
        // Check if user is trying to mark their own review
        if (review.userId == userId) {
          throw const ServerException(
            message: 'Không thể đánh dấu đánh giá của chính mình là hữu ích',
            code: 'review-self-helpful-failed',
          );
        }

        // Check if already marked as helpful
        if (review.helpfulUserIds.contains(userId)) {
          throw const ServerException(
            message: 'Bạn đã đánh dấu đánh giá này là hữu ích rồi',
            code: 'review-duplicate-helpful',
          );
        }

        final updatedReview = review.markAsHelpful(userId);
        
        transaction.update(reviewRef, {
          'helpfulUserIds': updatedReview.helpfulUserIds,
          'helpfulCount': updatedReview.helpfulCount,
        });

        return updatedReview;
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Lỗi khi đánh dấu đánh giá hữu ích: ${e.toString()}',
        code: 'mark-review-helpful-failed',
      );
    }
  }

  @override
  Future<ReviewModel> unmarkReviewAsHelpful({
    required String reviewId,
    required String userId,
  }) async {
    try {
      final reviewRef = firestore
          .collection(AppConstants.reviewsCollection)
          .doc(reviewId);

      return await firestore.runTransaction((transaction) async {
        final reviewDoc = await transaction.get(reviewRef);
        
        if (!reviewDoc.exists) {
          throw const ServerException(
            message: 'Không tìm thấy đánh giá',
            code: 'review-not-found',
          );
        }

        final review = ReviewModel.fromFirestore(reviewDoc);
        
        // Check if not marked as helpful
        if (!review.helpfulUserIds.contains(userId)) {
          throw const ServerException(
            message: 'Bạn chưa đánh dấu đánh giá này là hữu ích',
            code: 'review-not-helpful',
          );
        }

        final updatedReview = review.unmarkAsHelpful(userId);
        
        transaction.update(reviewRef, {
          'helpfulUserIds': updatedReview.helpfulUserIds,
          'helpfulCount': updatedReview.helpfulCount,
        });

        return updatedReview;
      });
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(
        message: 'Lỗi khi bỏ đánh dấu đánh giá hữu ích: ${e.toString()}',
        code: 'unmark-review-helpful-failed',
      );
    }
  }

  @override
  Future<ReviewModel?> getUserReviewForRestaurant({
    required String restaurantId,
    required String userId,
  }) async {
    try {
      final querySnapshot = await firestore
          .collection(AppConstants.reviewsCollection)
          .where('restaurantId', isEqualTo: restaurantId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      return ReviewModel.fromFirestore(querySnapshot.docs.first);
    } catch (e) {
      throw ServerException(
        message: 'Lỗi khi tải đánh giá của người dùng: ${e.toString()}',
        code: 'get-user-review-failed',
      );
    }
  }
}