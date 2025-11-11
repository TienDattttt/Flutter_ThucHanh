import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/review.dart';
import '../../domain/usecases/get_reviews_for_restaurant.dart';
import '../../domain/usecases/add_review.dart';

class ReviewProvider with ChangeNotifier {
  final GetReviewsForRestaurant getReviews;
  final AddReview addReviewUseCase;

  ReviewProvider({required this.getReviews, required this.addReviewUseCase});

  List<Review> _reviews = [];
  List<Review> get reviews => _reviews;

  void subscribe(String restaurantId) {
    getReviews(restaurantId).listen((list) {
      _reviews = list;
      notifyListeners();
    });
  }

  Future<void> add({
    required String restaurantId,
    required String content,
    required double rating,
    String? imageUrl,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Bạn cần đăng nhập để gửi đánh giá.');

    await addReviewUseCase(
      restaurantId: restaurantId,
      content: content,
      rating: rating,
      imageUrl: imageUrl,
      userId: user.uid, // ✅ thêm uid
    );
  }
}
