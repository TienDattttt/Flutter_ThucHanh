import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/post.dart';

class PostModel extends Post {
  PostModel({
    required super.id,
    required super.imageUrl,
    required super.caption,
    required super.userId,
    required super.userEmail,
    required super.createdAt,
    super.likes = 0,
  });

  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    final createdAt = map['createdAt'];
    DateTime parsedDate;
    if (createdAt is Timestamp) {
      parsedDate = createdAt.toDate();
    } else if (createdAt is DateTime) {
      parsedDate = createdAt;
    } else {
      parsedDate = DateTime.now();
    }

    return PostModel(
      id: id,
      imageUrl: (map['imageUrl'] ?? '') as String,
      caption: (map['caption'] ?? '') as String,
      userId: (map['userId'] ?? '') as String,
      userEmail: (map['userEmail'] ?? '') as String,
      createdAt: parsedDate,
      likes: (map['likes'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'caption': caption,
      'userId': userId,
      'userEmail': userEmail,
      'createdAt': Timestamp.fromDate(createdAt),
      'likes': likes,
    };
  }
}
