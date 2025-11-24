import 'package:dartz/dartz.dart';
import 'package:eshop/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/order/order_details.dart';
import '../../domain/repositories/order_repository.dart';
import '../data_sources/local/order_local_data_source.dart';
import '../data_sources/remote/firestore_order_data_source.dart';
import '../models/order/order_details_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final FirestoreOrderDataSource firestoreOrderDataSource;
  final OrderLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({
    required this.firestoreOrderDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, OrderDetails>> addOrder(OrderDetails params) async {
    if(!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    
    try {
      final order = await firestoreOrderDataSource.addOrder(params);
      
      // Sau khi tạo order thành công, thêm vào local storage
      try {
        final localOrders = await localDataSource.getOrders();
        localOrders.insert(0, order as OrderDetailsModel);
        await localDataSource.saveOrders(localOrders);
      } catch (e) {
        // Nếu chưa có orders trong local, tạo mới
        await localDataSource.saveOrders([order as OrderDetailsModel]);
      }
      
      return Right(order);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderDetails>>> getRemoteOrders() async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure());
    }
    
    try {
      final orders = await firestoreOrderDataSource.getOrders();
      await localDataSource.saveOrders(orders);
      return Right(orders);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderDetails>>> getLocalOrders() async {
    try {
      final localOrders = await localDataSource.getOrders();
      return Right(localOrders);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, NoParams>> deleteLocalOrders() async {
    try {
      await localDataSource.clearOrder();
      return Right(NoParams());
    } on Failure catch (failure) {
      return Left(failure);
    }
  }
}
