class Post {
  final String id;
  final String imageUrl;
  final String caption;
  final String userId;
  final String userEmail;
  final DateTime createdAt;
  final int likes;

  Post({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.userId,
    required this.userEmail,
    required this.createdAt,
    this.likes = 0,
  });
}
