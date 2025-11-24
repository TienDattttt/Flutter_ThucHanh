import 'package:bloc/bloc.dart';
import 'package:eshop/domain/usecases/order/delete_local_order_usecase.dart';
import 'package:flutter/cupertino.dart';

import '../../../../core/usecases/usecase.dart';
import '../../../../domain/entities/order/order_details.dart';
import '../../../../domain/usecases/order/get_local_orders_usecase.dart';
import '../../../../domain/usecases/order/get_remote_orders_usecase.dart';

part 'order_fetch_state.dart';

class OrderFetchCubit extends Cubit<OrderFetchState> {
  final GetRemoteOrdersUseCase _getOrdersUseCase;
  final GetLocalOrdersUseCase _getCachedOrdersUseCase;
  final DeleteLocalOrdersUseCase _clearLocalOrdersUseCase;
  OrderFetchCubit(this._getOrdersUseCase, this._getCachedOrdersUseCase,
      this._clearLocalOrdersUseCase)
      : super(const OrderFetchInitial([]));

  void getOrders() async {
    try {
      emit(OrderFetchLoading(state.orders));
      
      // Lấy từ local cache trước
      final cachedResult = await _getCachedOrdersUseCase(NoParams());
      cachedResult.fold(
        (failure) {
          debugPrint('OrderFetchCubit: Failed to get cached orders - $failure');
        },
        (orders) {
          debugPrint('OrderFetchCubit: Got ${orders.length} cached orders');
          if (orders.isNotEmpty) {
            emit(OrderFetchSuccess(orders));
          }
        },
      );
      
      // Sau đó lấy từ remote
      final remoteResult = await _getOrdersUseCase(NoParams());
      remoteResult.fold(
        (failure) {
          debugPrint('OrderFetchCubit: Failed to get remote orders - $failure');
          // Nếu remote fail nhưng có cache, giữ nguyên state
          // Nếu không có cache, emit fail
          if (state.orders.isEmpty) {
            emit(OrderFetchFail(state.orders));
          }
        },
        (orders) {
          debugPrint('OrderFetchCubit: Got ${orders.length} remote orders');
          emit(OrderFetchSuccess(orders));
        },
      );
    } catch (e) {
      debugPrint('OrderFetchCubit: Exception - $e');
      // Nếu có lỗi, emit fail với orders hiện tại
      emit(OrderFetchFail(state.orders));
    }
  }

  /// clear current user's orders data from both local cache and state
  /// Use when user logout form device
  void clearLocalOrders() async {
    try {
      emit(OrderFetchLoading(state.orders));
      final cachedResult = await _clearLocalOrdersUseCase(NoParams());
      cachedResult.fold(
        (failure) => (),
        (result) => emit(const OrderFetchInitial([])),
      );
    } catch (e) {
      emit(OrderFetchFail(state.orders));
    }
  }
}
