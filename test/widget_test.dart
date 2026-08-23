import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shoponlinemasterung/model/app_user_model.dart';
import 'package:shoponlinemasterung/model/order_model.dart';
import 'package:shoponlinemasterung/model/product_model.dart';

void main() {
  test('ProductModel maps Firestore product data and decodes image bytes', () {
    final Timestamp timestamp = Timestamp.fromDate(DateTime(2026, 4, 25));
    final String base64Image = base64Encode(<int>[1, 2, 3, 4]);

    final ProductModel product = ProductModel.fromMap(<String, dynamic>{
      'name': 'Orange',
      'description': 'Fresh orange',
      'base64Image': 'data:image/png;base64,$base64Image',
      'unit': 'kg',
      'price': 120,
      'stock': 8,
      'shortDescription': 'Sweet orange',
      'detailDescription': 'Fresh orange from the orchard',
      'condition': 'Keep chilled',
      'category': 'Fruit',
      'tags': <String>['fresh', 'recommended'],
      'images': <Map<String, dynamic>>[
        <String, dynamic>{
          'base64Image': base64Image,
          'alt': 'Orange front',
          'sortOrder': 0,
        },
      ],
      'isActive': true,
      'isRecommended': true,
      'relatedProductIds': <String>['product-b'],
      'soldCount': 3,
      'viewCount': 9,
      'timestamp': timestamp,
    });

    expect(product.name, 'Orange');
    expect(product.description, 'Fresh orange');
    expect(product.shortDescription, 'Sweet orange');
    expect(product.fullDescription, 'Fresh orange from the orchard');
    expect(product.condition, 'Keep chilled');
    expect(product.category, 'Fruit');
    expect(product.tags, <String>['fresh', 'recommended']);
    expect(product.displayImages.length, 1);
    expect(product.isRecommended, isTrue);
    expect(product.relatedProductIds, <String>['product-b']);
    expect(product.soldCount, 3);
    expect(product.viewCount, 9);
    expect(product.unit, 'kg');
    expect(product.price, 120);
    expect(product.stock, 8);
    expect(product.timestamp, timestamp);
    expect(product.imageBytes, <int>[1, 2, 3, 4]);
  });

  test('AppUserModel maps customer phone for order contact', () {
    const AppUserModel user = AppUserModel(
      displayName: 'Village Customer',
      base64Avatar: '',
      uid: 'uid-1',
      phone: '0812345678',
      permissions: <String, bool>{'canDeleteProducts': true},
    );

    final Map<String, dynamic> map = user.toMap();
    final AppUserModel parsed = AppUserModel.fromMap(map);

    expect(map['phone'], '0812345678');
    expect(parsed.phone, '0812345678');
    expect(parsed.permissions['canDeleteProducts'], isTrue);
  });

  test('buildStockRestoreQuantities combines duplicate product quantities', () {
    final Map<String, int> quantities =
        buildStockRestoreQuantities(<OrderItemModel>[
          _orderItem(productId: 'product-a', quantity: 2),
          _orderItem(productId: 'product-b', quantity: 1),
          _orderItem(productId: 'product-a', quantity: 3),
        ]);

    expect(quantities, <String, int>{'product-a': 5, 'product-b': 1});
  });

  test('buildStockRestoreQuantities rejects invalid order items', () {
    expect(
      () => buildStockRestoreQuantities(<OrderItemModel>[
        _orderItem(productId: '', quantity: 1),
      ]),
      throwsFormatException,
    );
    expect(
      () => buildStockRestoreQuantities(<OrderItemModel>[
        _orderItem(productId: 'product-a', quantity: 0),
      ]),
      throwsFormatException,
    );
    expect(
      () => buildStockRestoreQuantities(const <OrderItemModel>[]),
      throwsFormatException,
    );
  });

  test('OrderModel keeps legacy orders compatible with PromptPay', () {
    final OrderModel order = OrderModel.fromMap('order-legacy', {
      'orderNo': 'ORD-LEGACY',
      'userId': 'uid-1',
      'userName': 'Customer',
      'userPhone': '0812345678',
      'items': <Map<String, dynamic>>[],
      'pickupInfo': <String, dynamic>{},
    });

    expect(order.paymentMethod, OrderPaymentMethod.promptPay);
    expect(order.isCashPayment, isFalse);
    expect(order.paymentStatus, 'unpaid');
  });

  test('OrderModel maps cash payment audit fields', () {
    final Timestamp paidAt = Timestamp.fromDate(DateTime(2026, 6, 21, 10));
    final OrderModel order = OrderModel.fromMap('order-cash', {
      'orderNo': 'ORD-CASH',
      'userId': 'uid-1',
      'userName': 'Customer',
      'userPhone': '0812345678',
      'items': <Map<String, dynamic>>[],
      'pickupInfo': <String, dynamic>{},
      'paymentMethod': OrderPaymentMethod.cash,
      'paymentStatus': 'paid',
      'cashCollectedAt': paidAt,
      'cashCollectedBy': 'admin-uid',
      'paidAt': paidAt,
    });

    expect(order.isCashPayment, isTrue);
    expect(order.cashCollectedAt, paidAt);
    expect(order.cashCollectedBy, 'admin-uid');
    expect(order.paidAt, paidAt);
  });
}

OrderItemModel _orderItem({required String productId, required int quantity}) {
  return OrderItemModel(
    productId: productId,
    productName: 'Product',
    description: '',
    base64Image: '',
    unit: 'piece',
    price: 10,
    quantity: quantity,
    total: 10 * quantity,
  );
}
