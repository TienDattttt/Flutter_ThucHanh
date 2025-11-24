import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../domain/entities/order/order_details.dart';
import '../user/delivery_info_model.dart';
import 'order_item_model.dart';

List<OrderDetailsModel> orderDetailsModelListFromJson(String str) =>
    List<OrderDetailsModel>.from(
        json.decode(str).map((x) => OrderDetailsModel.fromJson(x)));

List<OrderDetailsModel> orderDetailsModelListFromLocalJson(String str) =>
    List<OrderDetailsModel>.from(
        json.decode(str).map((x) => OrderDetailsModel.fromJson(x)));

OrderDetailsModel orderDetailsModelFromJson(String str) =>
    OrderDetailsModel.fromJson(json.decode(str));

String orderModelListToJsonBody(List<OrderDetailsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJsonBody())));

String orderModelListToJson(List<OrderDetailsModel> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

String orderDetailsModelToJson(OrderDetailsModel data) =>
    json.encode(data.toJsonBody());

class OrderDetailsModel extends OrderDetails {
  final String? userId;
  final DateTime? createdAt;
  final String? status;

  const OrderDetailsModel({
    required super.id,
    required List<OrderItemModel> super.orderItems,
    required DeliveryInfoModel super.deliveryInfo,
    required super.discount,
    this.userId,
    this.createdAt,
    this.status,
  });

  factory OrderDetailsModel.fromJson(Map<String, dynamic> json) =>
      OrderDetailsModel(
        id: json["_id"],
        orderItems: List<OrderItemModel>.from(
            json["orderItems"].map((x) => OrderItemModel.fromJson(x))),
        deliveryInfo: DeliveryInfoModel.fromJson(json["deliveryInfo"]),
        discount: json["discount"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "orderItems": List<dynamic>.from(
            (orderItems as List<OrderItemModel>).map((x) => x.toJson())),
        "deliveryInfo": (deliveryInfo as DeliveryInfoModel).toJson(),
        "discount": discount,
      };

  Map<String, dynamic> toJsonBody() => {
        "_id": id,
        "orderItems": List<dynamic>.from(
            (orderItems as List<OrderItemModel>).map((x) => x.toJsonBody())),
        "deliveryInfo": deliveryInfo.id,
        "discount": discount,
      };

  factory OrderDetailsModel.fromEntity(OrderDetails entity) =>
      OrderDetailsModel(
        id: entity.id,
        orderItems: entity.orderItems
            .map((orderItem) => OrderItemModel.fromEntity(orderItem))
            .toList(),
        deliveryInfo: DeliveryInfoModel.fromEntity(entity.deliveryInfo),
        discount: entity.discount,
      );

  // Firestore methods
  Map<String, dynamic> toFirestore() => {
        'id': id,
        'userId': userId,
        'orderItems': orderItems
            .map((item) => (item as OrderItemModel).toFirestore())
            .toList(),
        'deliveryInfo': (deliveryInfo as DeliveryInfoModel).toJson(),
        'discount': discount,
        'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
        'status': status ?? 'pending',
      };

  factory OrderDetailsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderDetailsModel(
      id: doc.id,
      userId: data['userId'],
      orderItems: (data['orderItems'] as List)
          .map((item) => OrderItemModel.fromFirestore(item))
          .toList(),
      deliveryInfo: DeliveryInfoModel.fromJson(data['deliveryInfo']),
      discount: data['discount'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      status: data['status'],
    );
  }

  OrderDetailsModel copyWith({
    String? id,
    List<OrderItemModel>? orderItems,
    DeliveryInfoModel? deliveryInfo,
    num? discount,
    String? userId,
    DateTime? createdAt,
    String? status,
  }) {
    return OrderDetailsModel(
      id: id ?? this.id,
      orderItems: orderItems ?? this.orderItems as List<OrderItemModel>,
      deliveryInfo: deliveryInfo ?? this.deliveryInfo as DeliveryInfoModel,
      discount: discount ?? this.discount,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
