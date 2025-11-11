import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/review_model.dart';

class ReviewRemoteDataSource {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// 🔹 Lắng nghe danh sách đánh giá theo nhà hàng
  Stream<List<ReviewModel>> watchReviews(String restaurantId) {
    return _db
        .collection('restaurants')
        .doc(restaurantId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs
        .map((d) => ReviewModel.fromMap(d.id, d.data()))
        .toList());
  }

  /// 🔹 Thêm đánh giá mới vào Firestore
  Future<void> addReview({
    required String restaurantId,
    required String content,
    required double rating,
    String? imageUrl,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Chưa đăng nhập');

    final data = {
      'userId': user.uid,
      'userEmail': user.email, // ✅ thêm email để hiển thị
      'restaurantId': restaurantId,
      'content': content,
      'rating': rating,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    };

    final ref = _db.collection('restaurants').doc(restaurantId);
    await ref.collection('reviews').add(data);

    // ✅ Cập nhật avgRating tự động
    final reviews = await ref.collection('reviews').get();
    if (reviews.docs.isNotEmpty) {
      final total = reviews.docs
          .map((d) => (d.data()['rating'] ?? 0).toDouble())
          .fold<double>(0, (a, b) => a + b);
      final avg = total / reviews.docs.length;
      await ref.update({'avgRating': double.parse(avg.toStringAsFixed(2))});
    }
  }
}
