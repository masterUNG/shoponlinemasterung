import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
