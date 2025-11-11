import '../entities/review.dart';
import '../repositories/review_repository.dart';


class GetReviewsForRestaurant {
  final ReviewRepository repo;
  GetReviewsForRestaurant(this.repo);
  Stream<List<Review>> call(String restaurantId) => repo.watchReviews(restaurantId);
}