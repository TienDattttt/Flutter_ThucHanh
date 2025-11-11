import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/review.dart';
import '../../domain/repositories/review_repository.dart';
import '../models/review_model.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseAuth auth = FirebaseAuth.instance;

  /// 🔹 Thêm đánh giá mới (tự động lấy email người dùng)
  @override
  Future<void> addReview({
    required String restaurantId,
    required String content,
    required double rating,
    String? imageUrl,
    required String userId, // vẫn giữ để tương thích với usecase
  }) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    final review = ReviewModel(
      id: '',
      userId: user.uid,
      userEmail: user.email ?? '', // ✅ thêm email để hiển thị
      restaurantId: restaurantId,
      content: content,
      rating: rating,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );

    await firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .add(review.toMap());

    // ✅ Cập nhật điểm trung bình cho nhà hàng
    final ref = firestore.collection('restaurants').doc(restaurantId);
    final reviews = await ref.collection('reviews').get();
    if (reviews.docs.isNotEmpty) {
      final total = reviews.docs
          .map((d) => (d.data()['rating'] ?? 0).toDouble())
          .fold<double>(0, (a, b) => a + b);
      final avg = total / reviews.docs.length;
      await ref.update({'avgRating': double.parse(avg.toStringAsFixed(2))});
    }
  }

  /// 🔹 Lắng nghe danh sách đánh giá theo nhà hàng
  @override
  Stream<List<Review>> watchReviews(String restaurantId) {
    return firestore
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) =>
          ReviewModel.fromMap(doc.id, doc.data()).toEntity())
          .toList(),
    );
  }
}
