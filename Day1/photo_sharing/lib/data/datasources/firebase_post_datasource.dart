import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/post_model.dart';

class FirebasePostDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  FirebasePostDataSource(
      this._firestore,
      this._storage,
      this._auth,
      );

  Stream<List<PostModel>> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList());
  }

  Future<void> createPost({
    required String imagePath,
    required String caption,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    // 1. Upload ảnh lên Storage
    final file = File(imagePath);
    final fileName =
        '${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('posts').child(fileName);

    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    // 2. Lưu metadata vào Firestore
    final post = PostModel(
      id: '',
      imageUrl: downloadUrl,
      caption: caption,
      userId: user.uid,
      userEmail: user.email ?? '',
      createdAt: DateTime.now(),
    );

    await _firestore.collection('posts').add({
      ...post.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
