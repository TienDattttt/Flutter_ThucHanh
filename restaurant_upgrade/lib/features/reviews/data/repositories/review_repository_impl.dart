import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_remote_data_source.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  ReviewRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Stream<Either<Failure, List<Review>>> getReviewsForRestaurant({
    required String restaurantId,
    int? limit,
    String? orderBy,
  }) async* {
    if (await networkInfo.isConnected) {
      try {
        yield* remoteDataSource.getReviewsForRestaurant(
          restaurantId: restaurantId,
          limit: limit,
          orderBy: orderBy,
        ).map((reviewModels) {
          final reviews = reviewModels
              .map((model) => model.toEntity())
              .toList();
          return Right<Failure, List<Review>>(reviews);
        }).handleError((error) {
          if (error is ServerException) {
            return Left<Failure, List<Review>>(
              ServerFailure(message: error.message, code: error.code),
            );
          }
          return Left<Failure, List<Review>>(
            ErrorMapper.mapGenericException(error as Exception),
          );
        });
      } catch (e) {
        yield Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      yield const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Stream<Either<Failure, List<Review>>> getReviewsByUser({
    required String userId,
    int? limit,
  }) async* {
    if (await networkInfo.isConnected) {
      try {
        yield* remoteDataSource.getReviewsByUser(
          userId: userId,
          limit: limit,
        ).map((reviewModels) {
          final reviews = reviewModels
              .map((model) => model.toEntity())
              .toList();
          return Right<Failure, List<Review>>(reviews);
        }).handleError((error) {
          if (error is ServerException) {
            return Left<Failure, List<Review>>(
              ServerFailure(message: error.message, code: error.code),
            );
          }
          return Left<Failure, List<Review>>(
            ErrorMapper.mapGenericException(error as Exception),
          );
        });
      } catch (e) {
        yield Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      yield const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, Review>> getReviewById(String reviewId) async {
    if (await networkInfo.isConnected) {
      try {
        final reviewModel = await remoteDataSource.getReviewById(reviewId);
        return Right(reviewModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, Review>> addReview({
    required String restaurantId,
    required String userId,
    required String userDisplayName,
    String? userPhotoUrl,
    required int rating,
    required String comment,
    List<File>? images,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Create review model
        final reviewModel = ReviewModel.create(
          restaurantId: restaurantId,
          userId: userId,
          userDisplayName: userDisplayName,
          userPhotoUrl: userPhotoUrl,
          rating: rating,
          comment: comment,
        );

        // Add review to Firestore first
        final addedReview = await remoteDataSource.addReview(reviewModel);

        // Upload images if provided
        List<String> imageUrls = [];
        if (images != null && images.isNotEmpty) {
          imageUrls = await remoteDataSource.uploadReviewImages(
            reviewId: addedReview.id,
            images: images,
          );

          // Update review with image URLs
          final updatedReview = addedReview.copyWith(imageUrls: imageUrls);
          final finalReview = await remoteDataSource.updateReview(updatedReview);
          return Right(finalReview.toEntity());
        }

        return Right(addedReview.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on StorageException catch (e) {
        return Left(StorageFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, Review>> updateReview({
    required String reviewId,
    int? rating,
    String? comment,
    List<File>? newImages,
    List<String>? imagesToDelete,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        // Get current review
        final currentReview = await remoteDataSource.getReviewById(reviewId);
        
        // Delete specified images
        if (imagesToDelete != null && imagesToDelete.isNotEmpty) {
          await remoteDataSource.deleteReviewImages(imageUrls: imagesToDelete);
        }

        // Upload new images
        List<String> newImageUrls = [];
        if (newImages != null && newImages.isNotEmpty) {
          newImageUrls = await remoteDataSource.uploadReviewImages(
            reviewId: reviewId,
            images: newImages,
          );
        }

        // Update image URLs
        final currentImageUrls = List<String>.from(currentReview.imageUrls);
        if (imagesToDelete != null) {
          currentImageUrls.removeWhere((url) => imagesToDelete.contains(url));
        }
        currentImageUrls.addAll(newImageUrls);

        // Update review
        final updatedReview = currentReview.copyWith(
          rating: rating,
          comment: comment,
          imageUrls: currentImageUrls,
          updatedAt: DateTime.now(),
          isEdited: true,
        );

        final result = await remoteDataSource.updateReview(updatedReview);
        return Right(result.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on StorageException catch (e) {
        return Left(StorageFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReview(String reviewId) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteReview(reviewId);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } on StorageException catch (e) {
        return Left(StorageFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, List<String>>> uploadReviewImages({
    required String reviewId,
    required List<File> images,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final imageUrls = await remoteDataSource.uploadReviewImages(
          reviewId: reviewId,
          images: images,
        );
        return Right(imageUrls);
      } on StorageException catch (e) {
        return Left(StorageFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteReviewImages({
    required List<String> imageUrls,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteReviewImages(imageUrls: imageUrls);
        return const Right(null);
      } on StorageException catch (e) {
        return Left(StorageFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, Review>> markReviewAsHelpful({
    required String reviewId,
    required String userId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final reviewModel = await remoteDataSource.markReviewAsHelpful(
          reviewId: reviewId,
          userId: userId,
        );
        return Right(reviewModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, Review>> unmarkReviewAsHelpful({
    required String reviewId,
    required String userId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final reviewModel = await remoteDataSource.unmarkReviewAsHelpful(
          reviewId: reviewId,
          userId: userId,
        );
        return Right(reviewModel.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, Review?>> getUserReviewForRestaurant({
    required String restaurantId,
    required String userId,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final reviewModel = await remoteDataSource.getUserReviewForRestaurant(
          restaurantId: restaurantId,
          userId: userId,
        );
        return Right(reviewModel?.toEntity());
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }
}