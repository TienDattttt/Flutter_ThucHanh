import '../entities/user.dart';

abstract class AuthRepository {
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(String email, String password, String displayName);
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}