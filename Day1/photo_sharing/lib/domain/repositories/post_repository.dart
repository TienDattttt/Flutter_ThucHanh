import '../entities/post.dart';

abstract class PostRepository {
  Stream<List<Post>> getPostsStream();
  Future<void> createPost({
    required String imagePath,
    required String caption,
  });
}
