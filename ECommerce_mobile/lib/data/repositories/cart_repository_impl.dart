import 'package:dartz/dartz.dart';
import 'package:eshop/core/usecases/usecase.dart';

import '../../../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/cart/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../data_sources/local/cart_local_data_source.dart';
import '../data_sources/local/user_local_data_source.dart';
import '../data_sources/remote/cart_remote_data_source.dart';
import '../models/cart/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final CartLocalDataSource localDataSource;
  final UserLocalDataSource userLocalDataSource;
  final NetworkInfo networkInfo;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.userLocalDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<CartItem>>> getLocalCartItems() async {
    try {
      final localProducts = await localDataSource.getCart();
      return Right(localProducts);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> getRemoteCartItems() async {
    // Với Firebase, chỉ cần lấy từ local storage
    // Không cần sync với server vì cart chỉ lưu local
    try {
      final localCartItems = await localDataSource.getCart();
      return Right(localCartItems);
    } on Failure catch (failure) {
      return Left(failure);
    }
  }

  @override
  Future<Either<Failure, CartItem>> addCartItem(CartItem params) async {
    try {
      // Với Firebase, chỉ lưu vào local storage
      await localDataSource.saveCartItem(CartItemModel.fromParent(params));
      return Right(params);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, CartItemModel>> deleteCartItem(CartItem params) async {
    try {
      final cartItem = CartItemModel.fromParent(params);
      await localDataSource.deleteCartItem(cartItem);
      return Right(cartItem);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, NoParams>> deleteCart() async {
    try {
      await localDataSource.deleteCart();
      return Right(NoParams());
    } catch (e) {
      return Left(CacheFailure());
    }
  }
}
