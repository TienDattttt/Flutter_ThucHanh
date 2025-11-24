import 'package:eshop/core/error/failures.dart';
import 'package:eshop/core/network/network_info.dart';
import 'package:eshop/data/data_sources/local/user_local_data_source.dart';
import 'package:eshop/data/data_sources/remote/firebase_auth_data_source.dart';
import 'package:eshop/data/repositories/user_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/constant_objects.dart';

class MockFirebaseAuthDataSource extends Mock implements FirebaseAuthDataSource {}

class MockLocalDataSource extends Mock implements UserLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late UserRepositoryImpl repository;
  late MockFirebaseAuthDataSource mockFirebaseAuthDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockFirebaseAuthDataSource = MockFirebaseAuthDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = UserRepositoryImpl(
      firebaseAuthDataSource: mockFirebaseAuthDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });

      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      setUp(() {
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });

      body();
    });
  }

  group('getConcreted', () {
    test(
      'should check if the device is online on signIn',
      () async {
        /// Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockFirebaseAuthDataSource.signInWithEmailPassword(tSignInParams)).thenAnswer(
            (invocation) => Future.value(tUserModel));
        when(() => mockLocalDataSource.saveUser(tUserModel))
            .thenAnswer((invocation) => Future.value());

        /// Act
        repository.signIn(tSignInParams);

        /// Assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    test(
      'should check if the device is online on signUp',
      () async {
        /// Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockFirebaseAuthDataSource.signUpWithEmailPassword(tSignUpParams)).thenAnswer(
            (invocation) => Future.value(tUserModel));
        when(() => mockLocalDataSource.saveUser(tUserModel))
            .thenAnswer((invocation) => Future.value());

        /// Act
        repository.signUp(tSignUpParams);

        /// Assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );
  });

  runTestsOnline(() {
    test(
      'should return user data when the call to sign in source is successful',
      () async {
        /// Arrange
        when(() => mockFirebaseAuthDataSource.signInWithEmailPassword(tSignInParams)).thenAnswer(
            (invocation) => Future.value(tUserModel));
        when(() => mockLocalDataSource.saveUser(tUserModel))
            .thenAnswer((invocation) => Future.value());

        /// Act
        final actualResult = await repository.signIn(tSignInParams);

        /// Assert
        actualResult.fold(
          (left) => fail('test failed'),
          (right) => expect(right, tUserModel),
        );
      },
    );

    test(
      'should return user data when the call to sign up source is successful',
      () async {
        /// Arrange
        when(() => mockFirebaseAuthDataSource.signUpWithEmailPassword(tSignUpParams)).thenAnswer(
            (invocation) => Future.value(tUserModel));
        when(() => mockLocalDataSource.saveUser(tUserModel))
            .thenAnswer((invocation) => Future.value());

        /// Act
        final actualResult = await repository.signUp(tSignUpParams);

        /// Assert
        actualResult.fold(
          (left) => fail('test failed'),
          (right) => expect(right, tUserModel),
        );
      },
    );

    test(
      'should cache the user data locally when the call to sign in source is successful',
      () async {
        /// Arrange
        when(() => mockFirebaseAuthDataSource.signInWithEmailPassword(tSignInParams)).thenAnswer(
            (invocation) => Future.value(tUserModel));
        when(() => mockLocalDataSource.saveUser(tUserModel))
            .thenAnswer((invocation) => Future.value());

        /// Act
        await repository.signIn(tSignInParams);

        /// Assert
        verify(() => mockLocalDataSource.saveUser(tUserModel));
      },
    );

    test(
      'should cache the user data locally when the call to sign up source is successful',
      () async {
        /// Arrange
        when(() => mockFirebaseAuthDataSource.signUpWithEmailPassword(tSignUpParams)).thenAnswer(
            (invocation) => Future.value(tUserModel));
        when(() => mockLocalDataSource.saveUser(tUserModel))
            .thenAnswer((invocation) => Future.value());

        /// Act
        await repository.signUp(tSignUpParams);

        /// Assert
        verify(() => mockLocalDataSource.saveUser(tUserModel));
      },
    );

    test(
      'should return server failure when the call to remote sign-in source is unsuccessful',
      () async {
        /// Arrange
        when(() => mockFirebaseAuthDataSource.signInWithEmailPassword(tSignInParams))
            .thenThrow(ServerFailure());

        /// Act
        final result = await repository.signIn(tSignInParams);

        /// Assert
        result.fold(
          (left) => expect(left, ServerFailure()),
          (right) => fail('test failed'),
        );
      },
    );

    test(
      'should return server failure when the call to remote sign-up source is unsuccessful',
      () async {
        /// Arrange
        when(() => mockFirebaseAuthDataSource.signUpWithEmailPassword(tSignUpParams))
            .thenThrow(ServerFailure());

        /// Act
        final result = await repository.signUp(tSignUpParams);

        /// Assert
        result.fold(
          (left) => expect(left, ServerFailure()),
          (right) => fail('test failed'),
        );
      },
    );

    test(
      'should return local cached user-data when the call to local data source is successful',
      () async {
        /// Arrange
        when(() => mockFirebaseAuthDataSource.getCurrentUser())
            .thenReturn(null);
        when(() => mockLocalDataSource.getUser())
            .thenAnswer((_) async => Future.value(tUserModel));

        /// Act
        final actualResult = await repository.getLocalUser();

        /// Assert
        actualResult.fold(
          (left) => expect(left, CacheFailure()),
          (right) => fail('test failed'),
        );
      },
    );

    test(
      'should return [CachedFailure] when the call to local data source is fail',
      () async {
        /// Arrange
        when(() => mockFirebaseAuthDataSource.getCurrentUser())
            .thenReturn(null);
        when(() => mockLocalDataSource.getUser()).thenThrow(CacheFailure());

        /// Act
        final actualResult = await repository.getLocalUser();

        /// Assert
        actualResult.fold(
          (left) => expect(left, CacheFailure()),
          (right) => fail('test failed'),
        );
      },
    );
  });

  runTestsOffline(() {
    test(
      'sign-in method should return network failure when network connection is not available',
      () async {
        /// Act
        final result = await repository.signIn(tSignInParams);

        /// Assert
        verifyZeroInteractions(mockFirebaseAuthDataSource);
        verifyZeroInteractions(mockLocalDataSource);
        result.fold(
          (left) => expect(left, NetworkFailure()),
          (right) => fail('test failed'),
        );
      },
    );

    test(
      'sign-up method should return network failure when network connection is not available',
      () async {
        /// Act
        final result = await repository.signUp(tSignUpParams);

        /// Assert
        verifyZeroInteractions(mockFirebaseAuthDataSource);
        verifyZeroInteractions(mockLocalDataSource);
        result.fold(
          (left) => expect(left, NetworkFailure()),
          (right) => fail('test failed'),
        );
      },
    );

    test(
      'should return CacheFailure when Firebase user is null',
      () async {
        /// Arrange
        when(() => mockFirebaseAuthDataSource.getCurrentUser())
            .thenReturn(null);
        when(() => mockLocalDataSource.getUser())
            .thenAnswer((_) async => Future.value(tUserModel));

        /// Act
        final actualResult = await repository.getLocalUser();

        /// Assert
        actualResult.fold(
          (left) => expect(left, CacheFailure()),
          (right) => fail('test failed'),
        );
      },
    );

    test(
      'should return [CachedFailure] when the call to local data source is fail',
      () async {
        /// Arrange
        when(() => mockFirebaseAuthDataSource.getCurrentUser())
            .thenReturn(null);
        when(() => mockLocalDataSource.getUser()).thenThrow(CacheFailure());

        /// Act
        final actualResult = await repository.getLocalUser();

        /// Assert
        actualResult.fold(
          (left) => expect(left, CacheFailure()),
          (right) => fail('test failed'),
        );
      },
    );
  });
}
