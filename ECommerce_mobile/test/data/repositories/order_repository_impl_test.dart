import 'package:eshop/core/error/failures.dart';
import 'package:eshop/core/network/network_info.dart';
import 'package:eshop/core/usecases/usecase.dart';
import 'package:eshop/data/data_sources/local/order_local_data_source.dart';
import 'package:eshop/data/data_sources/remote/firestore_order_data_source.dart';
import 'package:eshop/data/repositories/order_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/constant_objects.dart';

class MockFirestoreOrderDataSource extends Mock implements FirestoreOrderDataSource {}

class MockLocalDataSource extends Mock implements OrderLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late OrderRepositoryImpl repository;
  late MockFirestoreOrderDataSource mockFirestoreOrderDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockFirestoreOrderDataSource = MockFirestoreOrderDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = OrderRepositoryImpl(
      firestoreOrderDataSource: mockFirestoreOrderDataSource,
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

  group('getRemoteOrders', () {
    test(
      'should check if the device is online',
      () async {
        /// Arrange
        when(() => mockNetworkInfo.isConnected).thenAnswer((_) async => true);
        when(() => mockFirestoreOrderDataSource.getOrders())
            .thenAnswer((_) async => [tOrderDetailsModel]);
        when(() => mockLocalDataSource.saveOrders([tOrderDetailsModel]))
            .thenAnswer((invocation) => Future<void>.value());

        /// Act
        repository.getRemoteOrders();

        /// Assert
        verify(() => mockNetworkInfo.isConnected);
      },
    );

    runTestsOnline(() {
      test(
        'should return remote data when the call to Firestore is successful',
        () async {
          /// Arrange
          when(() => mockFirestoreOrderDataSource.getOrders())
              .thenAnswer((_) async => [tOrderDetailsModel]);
          when(() => mockLocalDataSource.saveOrders([tOrderDetailsModel]))
              .thenAnswer((invocation) => Future<void>.value());

          /// Act
          final actualResult = await repository.getRemoteOrders();

          /// Assert
          actualResult.fold(
            (left) => fail('test failed'),
            (right) {
              verify(() => mockFirestoreOrderDataSource.getOrders());
              expect(right, [tOrderDetailsModel]);
            },
          );
        },
      );

      test(
        'should cache the data locally when the call to Firestore is successful',
        () async {
          /// Arrange
          when(() => mockFirestoreOrderDataSource.getOrders())
              .thenAnswer((_) async => [tOrderDetailsModel]);
          when(() => mockLocalDataSource.saveOrders([tOrderDetailsModel]))
              .thenAnswer((invocation) => Future<void>.value());

          /// Act
          await repository.getRemoteOrders();

          /// Assert
          verify(() => mockFirestoreOrderDataSource.getOrders());
          verify(() => mockLocalDataSource.saveOrders([tOrderDetailsModel]));
        },
      );

      test(
        'should return server failure when the call to Firestore is unsuccessful',
        () async {
          /// Arrange
          when(() => mockFirestoreOrderDataSource.getOrders())
              .thenThrow(ServerFailure());

          /// Act
          final result = await repository.getRemoteOrders();

          /// Assert
          result.fold(
            (left) => expect(left, ServerFailure()),
            (right) => fail('test failed'),
          );
        },
      );
    });

    runTestsOffline(() {
      test(
        'should return network failure when device is offline',
        () async {
          /// Act
          final result = await repository.getRemoteOrders();

          /// Assert
          verifyZeroInteractions(mockFirestoreOrderDataSource);
          verifyZeroInteractions(mockLocalDataSource);
          result.fold(
            (left) => expect(left, NetworkFailure()),
            (right) => fail('test failed'),
          );
        },
      );
    });
  });

  group('getLocalOrders', () {
    test(
      'should return local cached data when the call to local data source is successful',
      () async {
        /// Arrange
        when(() => mockLocalDataSource.getOrders())
            .thenAnswer((_) async => [tOrderDetailsModel]);

        /// Act
        final actualResult = await repository.getLocalOrders();

        /// Assert
        actualResult.fold(
          (left) => fail('test failed'),
          (right) => expect(right, [tOrderDetailsModel]),
        );
      },
    );

    test(
      'should return CacheFailure when the call to local data source fails',
      () async {
        /// Arrange
        when(() => mockLocalDataSource.getOrders()).thenThrow(CacheFailure());

        /// Act
        final actualResult = await repository.getLocalOrders();

        /// Assert
        actualResult.fold(
          (left) => expect(left, CacheFailure()),
          (right) => fail('test failed'),
        );
      },
    );
  });

  group('deleteLocalOrders', () {
    test(
      'should return Right(NoParams) when local source clears data successfully',
      () async {
        /// Arrange
        when(() => mockLocalDataSource.clearOrder())
            .thenAnswer((_) async => Future<void>.value());

        /// Act
        final result = await repository.deleteLocalOrders();

        /// Assert
        result.fold(
          (left) => fail('test failed'),
          (right) => expect(right, NoParams()),
        );
      },
    );

    test(
      'should call clearOrder from local order data source',
      () async {
        /// Arrange
        when(() => mockLocalDataSource.clearOrder())
            .thenAnswer((_) async => Future<void>.value());

        /// Act
        await repository.deleteLocalOrders();

        /// Assert
        verify(() => mockLocalDataSource.clearOrder());
      },
    );

    test(
      'should return Failure when local source fails',
      () async {
        /// Arrange
        when(() => mockLocalDataSource.clearOrder()).thenThrow(CacheFailure());

        /// Act
        final result = await repository.deleteLocalOrders();

        /// Assert
        result.fold(
          (left) => expect(left, CacheFailure()),
          (right) => fail('test failed'),
        );
      },
    );
  });
}
