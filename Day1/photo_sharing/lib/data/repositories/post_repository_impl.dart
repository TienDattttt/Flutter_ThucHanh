import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/firebase_post_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final FirebasePostDataSource _ds;

  PostRepositoryImpl(this._ds);

  @override
  Stream<List<Post>> getPostsStream() => _ds.getPostsStream();

  @override
  Future<void> createPost({
    required String imagePath,
    required String caption,
  }) =>
      _ds.createPost(imagePath: imagePath, caption: caption);
}
