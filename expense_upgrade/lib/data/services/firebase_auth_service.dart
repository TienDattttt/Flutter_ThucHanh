import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/repositories/auth_repository.dart';
import '../../core/errors/exceptions.dart';
import '../models/user_model.dart';

class FirebaseAuthService implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  
  FirebaseAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Stream<domain.User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return domain.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      );
    });
  }
  
  @override
  domain.User? get currentUser {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;
    
    return domain.User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName ?? '',
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
    );
  }
  
  @override
  Future<domain.User?> signIn(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final firebaseUser = credential.user;
      if (firebaseUser == null) return null;
      
      return domain.User(
        id: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? '',
        createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(_getAuthErrorMessage(e.code));
    } catch (e) {
      throw AuthException('Đã xảy ra lỗi không xác định: ${e.toString()}');
    }
  }
  
  @override
  Future<domain.User?> signUp(String email, String password, String displayName) async {
    try {
      print('DEBUG: FirebaseAuthService.signUp called with email: $email');
      
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('DEBUG: Firebase user created successfully');
      
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        print('DEBUG: Firebase user is null');
        return null;
      }
      
      print('DEBUG: Updating display name to: $displayName');
      // Update display name
      await firebaseUser.updateDisplayName(displayName);
      
      // Create user document in Firestore
      final user = domain.User(
        id: firebaseUser.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );
      
      print('DEBUG: Creating user document in Firestore');
      await _createUserDocument(user);
      print('DEBUG: User document created successfully');
      
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('DEBUG: FirebaseAuthException: ${e.code} - ${e.message}');
      throw AuthException(_getAuthErrorMessage(e.code));
    } on FirestoreException catch (e) {
      print('DEBUG: FirestoreException: ${e.message}');
      throw AuthException('Lỗi tạo tài liệu người dùng: ${e.message}');
    } catch (e, stackTrace) {
      print('DEBUG: General exception in signUp: $e');
      print('DEBUG: Stack trace: $stackTrace');
      throw AuthException('Đã xảy ra lỗi không xác định: ${e.toString()}');
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthException('Không thể đăng xuất: ${e.toString()}');
    }
  }
  
  Future<void> _createUserDocument(domain.User user) async {
    try {
      final userModel = UserModel.fromEntity(user);
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(userModel.toFirestore());
    } catch (e) {
      throw FirestoreException('Không thể tạo tài liệu người dùng: ${e.toString()}');
    }
  }
  
  String _getAuthErrorMessage(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản với email này';
      case 'wrong-password':
        return 'Mật khẩu không chính xác';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng';
      case 'weak-password':
        return 'Mật khẩu quá yếu';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'user-disabled':
        return 'Tài khoản đã bị vô hiệu hóa';
      case 'too-many-requests':
        return 'Quá nhiều yêu cầu. Vui lòng thử lại sau';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng';
      default:
        return 'Đã xảy ra lỗi xác thực: $errorCode';
    }
  }
}