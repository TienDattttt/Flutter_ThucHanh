import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _ds;

  AuthRepositoryImpl(this._ds);

  @override
  Stream<User?> authStateChanges() => _ds.authStateChanges();

  @override
  Future<User?> signIn(String email, String password) =>
      _ds.signIn(email, password);

  @override
  Future<User?> signUp(String email, String password) =>
      _ds.signUp(email, password);

  @override
  Future<void> signOut() => _ds.signOut();

  @override
  User? getCurrentUser() => _ds.getCurrentUser();
}
