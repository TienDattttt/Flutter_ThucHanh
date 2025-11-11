import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/review.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userEmail;
  final String restaurantId;
  final String content;
  final double rating;
  final String? imageUrl;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.restaurantId,
    required this.content,
    required this.rating,
    this.imageUrl,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime created;
    final rawCreated = map['createdAt'];
    if (rawCreated is Timestamp) {
      created = rawCreated.toDate();
    } else if (rawCreated is int) {
      created = DateTime.fromMillisecondsSinceEpoch(rawCreated);
    } else {
      created = DateTime.now();
    }

    return ReviewModel(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '', // ✅ lấy email
      restaurantId: map['restaurantId'] ?? '',
      content: map['content'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      imageUrl: map['imageUrl'],
      createdAt: created,
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userEmail': userEmail,
    'restaurantId': restaurantId,
    'content': content,
    'rating': rating,
    'imageUrl': imageUrl,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Review toEntity() => Review(
    id: id,
    userId: userId,
    userEmail: userEmail, // ✅ chuyển sang entity
    restaurantId: restaurantId,
    content: content,
    rating: rating,
    imageUrl: imageUrl,
    createdAt: createdAt,
  );
}
