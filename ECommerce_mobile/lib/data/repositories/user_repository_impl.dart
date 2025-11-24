import 'package:dartz/dartz.dart';
import 'package:eshop/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../data_sources/remote/firebase_auth_data_source.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseAuthDataSource firebaseAuthDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({
    required this.firebaseAuthDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> signIn(params) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final user = await firebaseAuthDataSource.signInWithEmailPassword(params);
      await localDataSource.saveUser(user);
      return Right(user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> signUp(params) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    try {
      final user = await firebaseAuthDataSource.signUpWithEmailPassword(params);
      await localDataSource.saveUser(user);
      return Right(user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, NoParams>> signOut() async {
    try {
      await firebaseAuthDataSource.signOut();
      await localDataSource.clearCache();
      return Right(NoParams());
    } on CacheFailure {
      return Left(CacheFailure());
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getLocalUser() async {
    try {
      // Kiểm tra Firebase user trước
      final firebaseUser = firebaseAuthDataSource.getCurrentUser();
      if (firebaseUser != null) {
        final user = await localDataSource.getUser();
        return Right(user);
      }
      return Left(CacheFailure());
    } on CacheFailure {
      return Left(CacheFailure());
    }
  }
}
