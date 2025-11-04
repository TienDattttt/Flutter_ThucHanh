import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';
import '../../domain/entities/post.dart';

class FirebasePostDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirebasePostDataSource(this._firestore, this._auth);

  Future<void> createPost({
    required String imageUrl,      // ✅ nhận URL từ ngoài
    required String caption,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Người dùng chưa đăng nhập');

    final post = PostModel(
      id: '',
      imageUrl: imageUrl,          // ✅ URL Cloudinary
      caption: caption,
      userId: user.uid,
      userEmail: user.email ?? '',
      createdAt: DateTime.now(),
    );

    await _firestore.collection('posts').add(post.toMap());
  }

  Stream<List<Post>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
        snap.docs.map((doc) => PostModel.fromMap(doc.id, doc.data())).toList());
  }
}
