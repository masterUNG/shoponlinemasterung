import 'dart:typed_data';

enum AdminProductStatus { active, lowStock, outOfStock, hidden }

class AdminProductModel {
  const AdminProductModel({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.price,
    required this.stock,
    required this.status,
    required this.updatedAt,
    this.imageBytes,
  });

  final String id;
  final String name;
  final String sku;
  final String category;
  final double price;
  final int stock;
  final AdminProductStatus status;
  final DateTime updatedAt;
  final Uint8List? imageBytes;

  bool get isLowStock => stock > 0 && stock <= 5;
  bool get isSellable =>
      status == AdminProductStatus.active ||
      status == AdminProductStatus.lowStock;
}
