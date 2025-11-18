import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../../../core/utils/error_mapper.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signUpWithEmailAndPassword(
          email: email,
          password: password,
          displayName: displayName,
        );
        return Right(userModel.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return Right(userModel.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(ErrorMapper.mapGenericException(e as Exception));
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser() async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.getCurrentUser();
        return Right(userModel?.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Stream<User?> get authStateChanges {
    return remoteDataSource.authStateChanges.map(
      (userModel) => userModel?.toEntity(),
    );
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.sendPasswordResetEmail(email: email);
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile({
    required String userId,
    String? displayName,
    String? photoUrl,
  }) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = await remoteDataSource.updateUserProfile(
          userId: userId,
          displayName: displayName,
          photoUrl: photoUrl,
        );
        return Right(userModel.toEntity());
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteAccount();
        return const Right(null);
      } on AuthException catch (e) {
        return Left(AuthFailure(message: e.message, code: e.code));
      } catch (e) {
        return Left(ErrorMapper.mapGenericException(e as Exception));
      }
    } else {
      return const Left(NetworkFailure(
        message: 'Không có kết nối internet',
        code: 'no-internet',
      ));
    }
  }
}