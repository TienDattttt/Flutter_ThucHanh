import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Sign up with email and password
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with email and password
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign out current user
  Future<void> signOut();

  /// Get current authenticated user
  Future<UserModel?> getCurrentUser();

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;

  /// Send password reset email
  Future<void> sendPasswordResetEmail({
    required String email,
  });

  /// Update user profile
  Future<UserModel> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  });

  /// Delete user account
  Future<void> deleteAccount();

  /// Send email verification
  Future<void> sendEmailVerification();

  /// Reload user to get updated information
  Future<void> reloadUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      // Create user with Firebase Auth
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException(
          message: 'Không thể tạo tài khoản',
          code: 'user-creation-failed',
        );
      }

      // Update display name
      await firebaseUser.updateDisplayName(displayName);
      await firebaseUser.reload();

      // Create user document in Firestore
      final userModel = UserModel.fromFirebaseUser(
        firebaseAuth.currentUser!,
        lastLoginAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .set(userModel.toFirestore());

      // Send email verification
      await firebaseUser.sendEmailVerification();

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        message: 'Lỗi không xác định khi tạo tài khoản: ${e.toString()}',
        code: 'unknown-error',
      );
    }
  }

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException(
          message: 'Không thể đăng nhập',
          code: 'sign-in-failed',
        );
      }

      // Update last login time in Firestore
      final userModel = UserModel.fromFirebaseUser(
        firebaseUser,
        lastLoginAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .update({
        'lastLoginAt': Timestamp.now(),
      });

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        message: 'Lỗi không xác định khi đăng nhập: ${e.toString()}',
        code: 'unknown-error',
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw AuthException(
        message: 'Lỗi khi đăng xuất: ${e.toString()}',
        code: 'sign-out-failed',
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      // Get user data from Firestore for complete information
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // If user document doesn't exist in Firestore, create it
        final userModel = UserModel.fromFirebaseUser(firebaseUser);
        await firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .set(userModel.toFirestore());
        return userModel;
      }
    } catch (e) {
      throw AuthException(
        message: 'Lỗi khi lấy thông tin người dùng: ${e.toString()}',
        code: 'get-user-failed',
      );
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;

      try {
        // Get user data from Firestore
        final userDoc = await firestore
            .collection(AppConstants.usersCollection)
            .doc(firebaseUser.uid)
            .get();

        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        } else {
          // Create user document if it doesn't exist
          final userModel = UserModel.fromFirebaseUser(firebaseUser);
          await firestore
              .collection(AppConstants.usersCollection)
              .doc(firebaseUser.uid)
              .set(userModel.toFirestore());
          return userModel;
        }
      } catch (e) {
        // Return basic user model from Firebase Auth if Firestore fails
        return UserModel.fromFirebaseUser(firebaseUser);
      }
    });
  }

  @override
  Future<void> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        message: 'Lỗi khi gửi email đặt lại mật khẩu: ${e.toString()}',
        code: 'password-reset-failed',
      );
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null || firebaseUser.uid != userId) {
        throw const AuthException(
          message: 'Người dùng không được xác thực',
          code: 'user-not-authenticated',
        );
      }

      // Update Firebase Auth profile
      if (displayName != null) {
        await firebaseUser.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await firebaseUser.updatePhotoURL(photoUrl);
      }

      await firebaseUser.reload();

      // Update Firestore document
      final updateData = <String, dynamic>{
        'updatedAt': Timestamp.now(),
      };
      if (displayName != null) updateData['displayName'] = displayName;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update(updateData);

      // Get updated user data
      final userDoc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      return UserModel.fromFirestore(userDoc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        message: 'Lỗi khi cập nhật hồ sơ: ${e.toString()}',
        code: 'profile-update-failed',
      );
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw const AuthException(
          message: 'Người dùng không được xác thực',
          code: 'user-not-authenticated',
        );
      }

      // Delete user document from Firestore
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(firebaseUser.uid)
          .delete();

      // Delete Firebase Auth account
      await firebaseUser.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        message: 'Lỗi khi xóa tài khoản: ${e.toString()}',
        code: 'account-deletion-failed',
      );
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw const AuthException(
          message: 'Người dùng không được xác thực',
          code: 'user-not-authenticated',
        );
      }

      await firebaseUser.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthException(
        message: _getAuthErrorMessage(e.code),
        code: e.code,
      );
    } catch (e) {
      throw AuthException(
        message: 'Lỗi khi gửi email xác thực: ${e.toString()}',
        code: 'email-verification-failed',
      );
    }
  }

  @override
  Future<void> reloadUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw const AuthException(
          message: 'Người dùng không được xác thực',
          code: 'user-not-authenticated',
        );
      }

      await firebaseUser.reload();
    } catch (e) {
      throw AuthException(
        message: 'Lỗi khi tải lại thông tin người dùng: ${e.toString()}',
        code: 'user-reload-failed',
      );
    }
  }

  /// Get localized error message for Firebase Auth error codes
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
      case 'operation-not-allowed':
        return 'Phương thức đăng nhập này không được phép';
      case 'requires-recent-login':
        return 'Thao tác này yêu cầu đăng nhập lại gần đây';
      case 'network-request-failed':
        return 'Lỗi kết nối mạng';
      default:
        return 'Lỗi xác thực không xác định';
    }
  }
}