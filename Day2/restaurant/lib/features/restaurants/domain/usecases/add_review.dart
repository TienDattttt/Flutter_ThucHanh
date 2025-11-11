import '../repositories/review_repository.dart';

class AddReview {
  final ReviewRepository repository;
  AddReview(this.repository);

  Future<void> call({
    required String restaurantId,
    required String content,
    required double rating,
    String? imageUrl,
    required String userId,
  }) async {
    await repository.addReview(
      restaurantId: restaurantId,
      content: content,
      rating: rating,
      imageUrl: imageUrl,
      userId: userId,
    );
  }
}
