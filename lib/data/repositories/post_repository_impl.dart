import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/post.dart';
import '../../domain/repositories/post_repository.dart';
import '../datasources/firebase_post_datasource.dart';
import '../datasources/cloudinary_datasource.dart';

class PostRepositoryImpl implements PostRepository {
  final FirebasePostDataSource _firebase;
  final CloudinaryDataSource _cloudinary;

  PostRepositoryImpl(this._firebase) : _cloudinary = CloudinaryDataSource();

  @override
  Stream<List<Post>> getPostsStream() => _firebase.getPostsStream();

  @override
  Future<void> createPost({
    required String imagePath,
    required String caption,
  }) async {
    final file = File(imagePath);
    if (!await file.exists()) throw Exception('Ảnh không tồn tại: $imagePath');

    final imageUrl = await _cloudinary.uploadImage(file);
    if (imageUrl == null) throw Exception('Tải ảnh lên Cloudinary thất bại');

    await _firebase.createPost(
      imageUrl: imageUrl,
      caption: caption,
    );
  }
}
