import '../entities/review.dart';
abstract class ReviewRepository {
  Future<void> addReview({
    required String restaurantId,
    required String content,
    required double rating,
    String? imageUrl,
    required String userId,
  });
  Stream<List<Review>> watchReviews(String restaurantId);
}
