class Review {
  final String id;
  final String userId;
  final String userEmail; // ✅ thêm email
  final String restaurantId;
  final String content;
  final double rating;
  final String? imageUrl;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.userId,
    required this.userEmail, // ✅ thêm email
    required this.restaurantId,
    required this.content,
    required this.rating,
    this.imageUrl,
    required this.createdAt,
  });
}
