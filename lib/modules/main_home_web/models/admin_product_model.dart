import 'dart:typed_data';

import '../../../model/product_model.dart';

enum AdminProductStatus { active, lowStock, outOfStock, hidden }

class AdminProductModel {
  const AdminProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.shortDescription,
    required this.detailDescription,
    required this.condition,
    required this.base64Image,
    required this.images,
    required this.sku,
    required this.category,
    required this.tags,
    required this.unit,
    required this.price,
    required this.stock,
    required this.isActive,
    required this.isRecommended,
    required this.relatedProductIds,
    required this.soldCount,
    required this.viewCount,
    required this.status,
    required this.updatedAt,
    this.imageBytes,
  });

  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final String detailDescription;
  final String condition;
  final String base64Image;
  final List<ProductImageModel> images;
  final String sku;
  final String category;
  final List<String> tags;
  final String unit;
  final double price;
  final int stock;
  final bool isActive;
  final bool isRecommended;
  final List<String> relatedProductIds;
  final int soldCount;
  final int viewCount;
  final AdminProductStatus status;
  final DateTime updatedAt;
  final Uint8List? imageBytes;

  bool get isLowStock => stock > 0 && stock <= 5;
  bool get isSellable =>
      status == AdminProductStatus.active ||
      status == AdminProductStatus.lowStock;

  String get cardDescription {
    if (shortDescription.trim().isNotEmpty) {
      return shortDescription.trim();
    }

    return description.trim();
  }
}
