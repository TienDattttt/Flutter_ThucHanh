import 'package:eshop/core/error/failures.dart';
import 'package:eshop/core/network/network_info.dart';
import 'package:eshop/core/usecases/usecase.dart';
import 'package:eshop/data/data_sources/local/delivery_info_local_data_source.dart';
import 'package:eshop/data/data_sources/remote/firestore_delivery_info_data_source.dart';
import 'package:eshop/data/repositories/delivery_info_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../fixtures/constant_objects.dart';

class MockFirestoreDeliveryInfoDataSource extends Mock
    implements FirestoreDeliveryInfoDataSource {}

class MockLocalDataSource extends Mock implements DeliveryInfoLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  late DeliveryInfoRepositoryImpl repository;
  late MockFirestoreDeliveryInfoDataSource mockRemoteDataSource;
  late MockLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockFirestoreDeliveryInfoDataSource();
    mockLocalDataSource = MockLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = DeliveryInfoRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('DeliveryInfoRepository - Firestore', () {
    group('getRemoteDeliveryInfo', () {
      test(
        'should return remote data when the call to Firestore is successful',
        () async {
          /// Arrange
          when(() => mockRemoteDataSource.getDeliveryInfo())
              .thenAnswer((_) async => [tDeliveryInfoModel]);
          when(() => mockLocalDataSource.saveDeliveryInfo([tDeliveryInfoModel]))
              .thenAnswer((invocation) => Future<void>.value());

          /// Act
          final actualResult = await repository.getRemoteDeliveryInfo();

          /// Assert
          actualResult.fold(
            (left) => fail('test failed'),
            (right) {
              verify(() =>
                  mockLocalDataSource.saveDeliveryInfo([tDeliveryInfoModel]));
              expect(right, [tDeliveryInfoModel]);
            },
          );
        },
      );

      test(
        'should return server failure when Firestore call fails',
        () async {
          /// Arrange
          when(() => mockRemoteDataSource.getDeliveryInfo())
              .thenThrow(ServerFailure());

          /// Act
          final result = await repository.getRemoteDeliveryInfo();

          /// Assert
          result.fold(
            (left) => expect(left, ServerFailure()),
            (right) => fail('test failed'),
          );
        },
      );
    });

    group('getLocalDeliveryInfo', () {
      test(
        'should return local cached data when available',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.getDeliveryInfo())
              .thenAnswer((_) async => [tDeliveryInfoModel]);

          /// Act
          final actualResult = await repository.getLocalDeliveryInfo();

          /// Assert
          actualResult.fold(
            (left) => fail('test failed'),
            (right) => expect(right, [tDeliveryInfoModel]),
          );
        },
      );

      test(
        'should return CacheFailure when local data is not available',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.getDeliveryInfo())
              .thenThrow(CacheFailure());

          /// Act
          final actualResult = await repository.getLocalDeliveryInfo();

          /// Assert
          actualResult.fold(
            (left) => expect(left, CacheFailure()),
            (right) => fail('test failed'),
          );
        },
      );
    });

    group('addDeliveryInfo', () {
      test(
        'should add delivery info to Firestore and update local storage',
        () async {
          /// Arrange
          when(() => mockRemoteDataSource.addDeliveryInfo(tDeliveryInfoModel))
              .thenAnswer((_) async => tDeliveryInfoModel);
          when(() => mockLocalDataSource.updateDeliveryInfo(tDeliveryInfoModel))
              .thenAnswer((_) => Future<void>.value());

          /// Act
          final actualResult =
              await repository.addDeliveryInfo(tDeliveryInfoModel);

          /// Assert
          actualResult.fold(
            (left) => fail('test failed'),
            (right) => expect(right, tDeliveryInfoModel),
          );
          verify(() =>
              mockLocalDataSource.updateDeliveryInfo(tDeliveryInfoModel));
        },
      );
    });

    group('editDeliveryInfo', () {
      test(
        'should edit delivery info in Firestore and update local storage',
        () async {
          /// Arrange
          when(() => mockRemoteDataSource.editDeliveryInfo(tDeliveryInfoModel))
              .thenAnswer((_) async => tDeliveryInfoModel);
          when(() => mockLocalDataSource.updateDeliveryInfo(tDeliveryInfoModel))
              .thenAnswer((_) => Future<void>.value());

          /// Act
          final actualResult =
              await repository.editDeliveryInfo(tDeliveryInfoModel);

          /// Assert
          actualResult.fold(
            (left) => fail('test failed'),
            (right) => expect(right, tDeliveryInfoModel),
          );
          verify(() =>
              mockLocalDataSource.updateDeliveryInfo(tDeliveryInfoModel));
        },
      );
    });

    group('selectDeliveryInfo', () {
      test(
        'should update selected delivery info in local storage',
        () async {
          /// Arrange
          when(() => mockLocalDataSource
                  .updateSelectedDeliveryInfo(tDeliveryInfoModel))
              .thenAnswer((_) => Future<void>.value());

          /// Act
          await repository.selectDeliveryInfo(tDeliveryInfoModel);

          /// Assert
          verify(() => mockLocalDataSource
              .updateSelectedDeliveryInfo(tDeliveryInfoModel));
        },
      );
    });

    group('getSelectedDeliveryInfo', () {
      test(
        'should get selected delivery info from local storage',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.getSelectedDeliveryInfo())
              .thenAnswer((_) async => tDeliveryInfoModel);

          /// Act
          await repository.getSelectedDeliveryInfo();

          /// Assert
          verify(() => mockLocalDataSource.getSelectedDeliveryInfo());
        },
      );
    });

    group('deleteLocalDeliveryInfo', () {
      test(
        'should clear local delivery info',
        () async {
          /// Arrange
          when(() => mockLocalDataSource.clearDeliveryInfo())
              .thenAnswer((_) => Future<void>.value());

          /// Act
          final result = await repository.deleteLocalDeliveryInfo();

          /// Assert
          result.fold(
            (left) => fail('test failed'),
            (right) => expect(right, NoParams()),
          );
          verify(() => mockLocalDataSource.clearDeliveryInfo());
        },
      );
    });
  });
}
