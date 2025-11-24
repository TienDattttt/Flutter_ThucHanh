import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/error/exceptions.dart';
import '../../../core/error/failures.dart';
import '../../../domain/entities/order/order_details.dart';
import '../../models/order/order_details_model.dart';

abstract class FirestoreOrderDataSource {
  Future<OrderDetailsModel> addOrder(OrderDetails order);
  Future<List<OrderDetailsModel>> getOrders();
}

class FirestoreOrderDataSourceImpl implements FirestoreOrderDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  FirestoreOrderDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  @override
  Future<OrderDetailsModel> addOrder(OrderDetails order) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationFailure();
      }

      // Tạo document reference với auto-generated ID
      final orderRef = firestore.collection('orders').doc();
      
      // Tạo order model với ID từ Firestore
      final orderModel = OrderDetailsModel.fromEntity(order).copyWith(
        id: orderRef.id,
        userId: user.uid,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      // Lưu vào Firestore
      await orderRef.set(orderModel.toFirestore());

      return orderModel;
    } on FirebaseException catch (e) {
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }

  @override
  Future<List<OrderDetailsModel>> getOrders() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        throw AuthenticationFailure();
      }

      final querySnapshot = await firestore
          .collection('orders')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => OrderDetailsModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException();
    } catch (e) {
      throw ServerException();
    }
  }
}
