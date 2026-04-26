import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.description,
    required this.base64Image,
    required this.unit,
    required this.price,
    required this.quantity,
    required this.total,
  });

  final String productId;
  final String productName;
  final String description;
  final String base64Image;
  final String unit;
  final num price;
  final int quantity;
  final num total;

  Uint8List? get imageBytes {
    if (base64Image.trim().isEmpty) {
      return null;
    }

    try {
      final String normalized = base64Image.contains(',')
          ? base64Image.split(',').last
          : base64Image;
      return base64Decode(normalized);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'productName': productName,
      'description': description,
      'base64Image': base64Image,
      'unit': unit,
      'price': price,
      'quantity': quantity,
      'total': total,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: (map['productId'] ?? '') as String,
      productName: (map['productName'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      base64Image: (map['base64Image'] ?? '') as String,
      unit: (map['unit'] ?? '') as String,
      price: (map['price'] ?? 0) as num,
      quantity: ((map['quantity'] ?? 0) as num).toInt(),
      total: (map['total'] ?? 0) as num,
    );
  }
}

class PickupInfoModel {
  const PickupInfoModel({
    required this.pickupName,
    required this.pickupPhone,
    required this.note,
  });

  final String pickupName;
  final String pickupPhone;
  final String note;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'pickupName': pickupName,
      'pickupPhone': pickupPhone,
      'note': note,
    };
  }

  factory PickupInfoModel.fromMap(Map<String, dynamic> map) {
    return PickupInfoModel(
      pickupName: (map['pickupName'] ?? '') as String,
      pickupPhone: (map['pickupPhone'] ?? '') as String,
      note: (map['note'] ?? '') as String,
    );
  }
}

class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderNo,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.orderType,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.status,
    required this.paymentStatus,
    required this.pickupInfo,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String orderNo;
  final String userId;
  final String userName;
  final String userPhone;
  final String orderType;
  final List<OrderItemModel> items;
  final num subtotal;
  final num discount;
  final num grandTotal;
  final String status;
  final String paymentStatus;
  final PickupInfoModel pickupInfo;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  bool get isCompleteOrCancelled {
    return status == 'completed' || status == 'cancelled';
  }

  int get totalQuantity {
    return items.fold<int>(0, (total, item) => total + item.quantity);
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'orderNo': orderNo,
      'userId': userId,
      'userName': userName,
      'userPhone': userPhone,
      'orderType': orderType,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discount': discount,
      'grandTotal': grandTotal,
      'status': status,
      'paymentStatus': paymentStatus,
      'pickupInfo': pickupInfo.toMap(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory OrderModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final Map<String, dynamic> map = document.data() ?? <String, dynamic>{};
    return OrderModel.fromMap(document.id, map);
  }

  factory OrderModel.fromMap(String id, Map<String, dynamic> map) {
    final List<dynamic> rawItems =
        (map['items'] ?? <dynamic>[]) as List<dynamic>;

    return OrderModel(
      id: id,
      orderNo: (map['orderNo'] ?? '') as String,
      userId: (map['userId'] ?? '') as String,
      userName: (map['userName'] ?? '') as String,
      userPhone: (map['userPhone'] ?? '') as String,
      orderType: (map['orderType'] ?? 'pickup') as String,
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(OrderItemModel.fromMap)
          .toList(),
      subtotal: (map['subtotal'] ?? 0) as num,
      discount: (map['discount'] ?? 0) as num,
      grandTotal: (map['grandTotal'] ?? 0) as num,
      status: (map['status'] ?? 'pending') as String,
      paymentStatus: (map['paymentStatus'] ?? 'unpaid') as String,
      pickupInfo: PickupInfoModel.fromMap(
        (map['pickupInfo'] ?? <String, dynamic>{}) as Map<String, dynamic>,
      ),
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt'] as Timestamp
          : null,
      updatedAt: map['updatedAt'] is Timestamp
          ? map['updatedAt'] as Timestamp
          : null,
    );
  }
}
