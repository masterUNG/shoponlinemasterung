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
      'timestamp': timestamp,
    });

    expect(product.name, 'Orange');
    expect(product.description, 'Fresh orange');
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
    );

    final Map<String, dynamic> map = user.toMap();
    final AppUserModel parsed = AppUserModel.fromMap(map);

    expect(map['phone'], '0812345678');
    expect(parsed.phone, '0812345678');
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
