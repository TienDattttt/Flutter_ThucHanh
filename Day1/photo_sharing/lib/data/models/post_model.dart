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
    return PostModel(
      id: id,
      imageUrl: map['imageUrl'] ?? '',
      caption: map['caption'] ?? '',
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      createdAt: (map['createdAt'] as DateTime?) ??
          DateTime.fromMillisecondsSinceEpoch(
            (map['createdAt'] as dynamic)?.millisecondsSinceEpoch ??
                DateTime.now().millisecondsSinceEpoch,
          ),
      likes: (map['likes'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'caption': caption,
      'userId': userId,
      'userEmail': userEmail,
      'createdAt': createdAt,
      'likes': likes,
    };
  }
}
