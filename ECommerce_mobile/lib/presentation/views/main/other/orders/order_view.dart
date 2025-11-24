import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constant/images.dart';
import '../../../../blocs/order/order_fetch/order_fetch_cubit.dart';
import '../../../../widgets/order_info_card.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView> {
  @override
  void initState() {
    super.initState();
    // Refresh orders khi vào màn hình
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderFetchCubit>().getOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Đơn hàng"),
      ),
      body: BlocBuilder<OrderFetchCubit, OrderFetchState>(
        builder: (context, state) {
          // Nếu đang loading và chưa có orders, hiển thị skeleton
          if (state is OrderFetchLoading && state.orders.isEmpty) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: 6,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: (10 + MediaQuery.of(context).padding.bottom),
                top: 10,
              ),
              itemBuilder: (context, index) => const OrderInfoCard(),
            );
          }
          
          // Nếu có orders (success hoặc loading với orders cũ), hiển thị danh sách
          if (state.orders.isNotEmpty) {
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: state.orders.length,
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: (10 + MediaQuery.of(context).padding.bottom),
                top: 10,
              ),
              itemBuilder: (context, index) => OrderInfoCard(
                orderDetails: state.orders[index],
              ),
            );
          }
          
          // Nếu không có orders và không loading, hiển thị empty state
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(kOrderDelivery),
              const Text("Chưa có đơn hàng!"),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.1,
              )
            ],
          );
        },
      ),
    );
  }
}
