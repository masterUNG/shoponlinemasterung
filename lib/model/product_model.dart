import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  const ProductModel({
    required this.name,
    required this.description,
    required this.base64Image,
    required this.unit,
    required this.price,
    required this.stock,
    required this.timestamp,
  });

  final String name;
  final String description;
  final String base64Image;
  final String unit;
  final num price;
  final num stock;
  final Timestamp timestamp;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'description': description,
      'base64Image': base64Image,
      'unit': unit,
      'price': price,
      'stock': stock,
      'timestamp': timestamp,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      name: (map['name'] ?? '') as String,
      description: (map['description'] ?? '') as String,
      base64Image: (map['base64Image'] ?? '') as String,
      unit: (map['unit'] ?? '') as String,
      price: (map['price'] ?? 0) as num,
      stock: (map['stock'] ?? 0) as num,
      timestamp: (map['timestamp'] ?? Timestamp.now()) as Timestamp,
    );
  }
}
