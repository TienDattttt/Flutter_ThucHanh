import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../domain/usecases/user/sign_in_usecase.dart';
import '../../../domain/usecases/user/sign_up_usecase.dart';
import '../../models/user/user_model.dart';

abstract class FirebaseAuthDataSource {
  Future<UserModel> signInWithEmailPassword(SignInParams params);
  Future<UserModel> signUpWithEmailPassword(SignUpParams params);
  Future<void> signOut();
  firebase_auth.User? getCurrentUser();
}

class FirebaseAuthDataSourceImpl implements FirebaseAuthDataSource {
  final firebase_auth.FirebaseAuth firebaseAuth;

  FirebaseAuthDataSourceImpl({required this.firebaseAuth});

  @override
  Future<UserModel> signInWithEmailPassword(SignInParams params) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: params.username,
        password: params.password,
      );

      if (credential.user == null) {
        throw CredentialFailure();
      }

      return _userFromFirebase(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw CredentialFailure();
      } else {
        throw ServerException();
      }
    }
  }

  @override
  Future<UserModel> signUpWithEmailPassword(SignUpParams params) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: params.email,
        password: params.password,
      );

      if (credential.user == null) {
        throw ServerException();
      }

      // Cập nhật display name
      await credential.user!.updateDisplayName('${params.firstName} ${params.lastName}');

      return _userFromFirebase(credential.user!);
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw CredentialFailure();
      } else if (e.code == 'email-already-in-use') {
        throw CredentialFailure();
      } else {
        throw ServerException();
      }
    }
  }

  @override
  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }

  @override
  firebase_auth.User? getCurrentUser() {
    return firebaseAuth.currentUser;
  }

  UserModel _userFromFirebase(firebase_auth.User user) {
    final displayName = user.displayName ?? '';
    final nameParts = displayName.split(' ');
    
    return UserModel(
      id: user.uid,
      firstName: nameParts.isNotEmpty ? nameParts.first : '',
      lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
      email: user.email ?? '',
    );
  }
}
