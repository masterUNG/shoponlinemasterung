import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';

class ProductImageModel {
  const ProductImageModel({
    required this.base64Image,
    required this.alt,
    required this.sortOrder,
  });

  final String base64Image;
  final String alt;
  final int sortOrder;

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
      'base64Image': base64Image,
      'alt': alt,
      'sortOrder': sortOrder,
    };
  }

  factory ProductImageModel.fromMap(Map<String, dynamic> map) {
    return ProductImageModel(
      base64Image: (map['base64Image'] ?? '') as String,
      alt: (map['alt'] ?? '') as String,
      sortOrder: ((map['sortOrder'] ?? 0) as num).toInt(),
    );
  }
}

class ProductModel {
  const ProductModel({
    required this.name,
    required this.description,
    required this.base64Image,
    required this.unit,
    required this.price,
    required this.stock,
    required this.timestamp,
    this.shortDescription = '',
    this.detailDescription = '',
    this.condition = '',
    this.category = 'General',
    this.tags = const <String>[],
    this.images = const <ProductImageModel>[],
    this.isActive = true,
    this.isRecommended = false,
    this.relatedProductIds = const <String>[],
    this.soldCount = 0,
    this.viewCount = 0,
    this.createdAt,
    this.updatedAt,
  });

  final String name;
  final String description;
  final String base64Image;
  final String unit;
  final num price;
  final num stock;
  final Timestamp timestamp;
  final String shortDescription;
  final String detailDescription;
  final String condition;
  final String category;
  final List<String> tags;
  final List<ProductImageModel> images;
  final bool isActive;
  final bool isRecommended;
  final List<String> relatedProductIds;
  final int soldCount;
  final int viewCount;
  final Timestamp? createdAt;
  final Timestamp? updatedAt;

  String get cardDescription {
    if (shortDescription.trim().isNotEmpty) {
      return shortDescription.trim();
    }

    return description.trim();
  }

  String get fullDescription {
    if (detailDescription.trim().isNotEmpty) {
      return detailDescription.trim();
    }

    return description.trim();
  }

  List<ProductImageModel> get displayImages {
    final List<ProductImageModel> sortedImages = List<ProductImageModel>.from(
      images.where((image) => image.base64Image.trim().isNotEmpty),
    )..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    if (sortedImages.isNotEmpty) {
      return sortedImages;
    }

    if (base64Image.trim().isEmpty) {
      return const <ProductImageModel>[];
    }

    return <ProductImageModel>[
      ProductImageModel(base64Image: base64Image, alt: name, sortOrder: 0),
    ];
  }

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
      'name': name,
      'description': description,
      'shortDescription': shortDescription,
      'detailDescription': detailDescription,
      'condition': condition,
      'category': category,
      'tags': tags,
      'base64Image': base64Image,
      'images': images.map((image) => image.toMap()).toList(),
      'unit': unit,
      'price': price,
      'stock': stock,
      'isActive': isActive,
      'isRecommended': isRecommended,
      'relatedProductIds': relatedProductIds,
      'soldCount': soldCount,
      'viewCount': viewCount,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
      'timestamp': timestamp,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    final String description = (map['description'] ?? '') as String;
    final Timestamp timestamp =
        (map['timestamp'] ?? Timestamp.now()) as Timestamp;
    final List<dynamic> rawTags = (map['tags'] ?? <dynamic>[]) as List<dynamic>;
    final List<dynamic> rawRelatedProductIds =
        (map['relatedProductIds'] ?? <dynamic>[]) as List<dynamic>;
    final List<dynamic> rawImages =
        (map['images'] ?? <dynamic>[]) as List<dynamic>;

    return ProductModel(
      name: (map['name'] ?? '') as String,
      description: description,
      shortDescription: (map['shortDescription'] ?? description) as String,
      detailDescription: (map['detailDescription'] ?? description) as String,
      condition: (map['condition'] ?? '') as String,
      category: (map['category'] ?? 'General') as String,
      tags: rawTags.whereType<String>().toList(),
      base64Image: (map['base64Image'] ?? '') as String,
      images: rawImages
          .whereType<Map<String, dynamic>>()
          .map(ProductImageModel.fromMap)
          .toList(),
      unit: (map['unit'] ?? '') as String,
      price: (map['price'] ?? 0) as num,
      stock: (map['stock'] ?? 0) as num,
      isActive: (map['isActive'] ?? true) as bool,
      isRecommended: (map['isRecommended'] ?? false) as bool,
      relatedProductIds: rawRelatedProductIds.whereType<String>().toList(),
      soldCount: ((map['soldCount'] ?? 0) as num).toInt(),
      viewCount: ((map['viewCount'] ?? 0) as num).toInt(),
      createdAt: map['createdAt'] is Timestamp
          ? map['createdAt'] as Timestamp
          : timestamp,
      updatedAt: map['updatedAt'] is Timestamp
          ? map['updatedAt'] as Timestamp
          : timestamp,
      timestamp: timestamp,
    );
  }
}
