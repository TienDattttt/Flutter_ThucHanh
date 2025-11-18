import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  /// Sign up with email and password
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with email and password
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// Sign out current user
  Future<Either<Failure, void>> signOut();

  /// Get current authenticated user
  Future<Either<Failure, User?>> getCurrentUser();

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges;

  /// Send password reset email
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Update user profile
  Future<Either<Failure, User>> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  });

  /// Delete user account
  Future<Either<Failure, void>> deleteAccount();
}