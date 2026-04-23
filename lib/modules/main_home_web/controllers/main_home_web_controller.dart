import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shoponlinemasterung/model/product_model.dart';

import '../../../app/routes/app_routes.dart';
import '../models/admin_order_model.dart';
import '../models/admin_product_model.dart';

enum MainHomeWebSection { dashboard, products, stock, orders }

extension MainHomeWebSectionX on MainHomeWebSection {
  String get title {
    switch (this) {
      case MainHomeWebSection.dashboard:
        return 'Dashboard';
      case MainHomeWebSection.products:
        return 'Products';
      case MainHomeWebSection.stock:
        return 'Stock';
      case MainHomeWebSection.orders:
        return 'Orders';
    }
  }

  String get subtitle {
    switch (this) {
      case MainHomeWebSection.dashboard:
        return 'ภาพรวมยอดขาย สินค้า และงานที่ต้องทำวันนี้';
      case MainHomeWebSection.products:
        return 'เพิ่ม ลบ แก้ไขสินค้า และอัปเดตราคา';
      case MainHomeWebSection.stock:
        return 'ตรวจสอบจำนวนคงเหลือและสินค้าใกล้หมด';
      case MainHomeWebSection.orders:
        return 'ติดตามรายการสั่งซื้อและสถานะการจัดส่ง';
    }
  }
}

class MainHomeWebController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Rx<MainHomeWebSection> selectedSection =
      MainHomeWebSection.dashboard.obs;
  final RxList<AdminProductModel> _products = <AdminProductModel>[].obs;
  final RxBool isProductsLoading = true.obs;

  final List<AdminOrderModel> _orders = <AdminOrderModel>[
    AdminOrderModel(
      id: 'SO-240422-001',
      customerName: 'Nattapong S.',
      itemCount: 2,
      total: 780,
      status: AdminOrderStatus.pendingPayment,
      createdAt: DateTime(2026, 4, 22, 9, 15),
      note: 'ลูกค้าเลือกโอนเงินและส่งหลักฐานภายในวันนี้',
    ),
    AdminOrderModel(
      id: 'SO-240422-002',
      customerName: 'Pimchanok K.',
      itemCount: 1,
      total: 490,
      status: AdminOrderStatus.packing,
      createdAt: DateTime(2026, 4, 22, 10, 40),
      note: 'เตรียมสินค้าเรียบร้อย รอพิมพ์ใบปะหน้าจัดส่ง',
    ),
    AdminOrderModel(
      id: 'SO-240422-003',
      customerName: 'Aekkachai T.',
      itemCount: 3,
      total: 1140,
      status: AdminOrderStatus.shipped,
      createdAt: DateTime(2026, 4, 22, 11, 10),
      note: 'อัปเดตเลขพัสดุแล้ว ลูกค้าสามารถติดตามได้ทันที',
    ),
    AdminOrderModel(
      id: 'SO-240421-014',
      customerName: 'Sasithorn P.',
      itemCount: 1,
      total: 259,
      status: AdminOrderStatus.completed,
      createdAt: DateTime(2026, 4, 21, 15, 55),
      note: 'ลูกค้าได้รับสินค้าแล้วและให้คะแนนรีวิว 5 ดาว',
    ),
  ];

  @override
  void onInit() {
    super.onInit();
    _products.bindStream(_productStream());
  }

  User? get currentUser => _firebaseAuth.currentUser;
  List<AdminProductModel> get products =>
      List<AdminProductModel>.unmodifiable(_products);
  List<AdminOrderModel> get orders =>
      List<AdminOrderModel>.unmodifiable(_orders);

  List<AdminProductModel> get lowStockProducts =>
      _products.where((product) => product.isLowStock).toList();

  List<AdminOrderModel> get openOrders =>
      _orders.where((order) => order.isOpen).toList();

  int get totalProducts => _products.length;
  int get activeProductsCount =>
      _products.where((product) => product.isSellable).length;
  int get lowStockCount => lowStockProducts.length;
  int get newOrdersCount => _orders
      .where((order) => order.status != AdminOrderStatus.completed)
      .length;
  String get todaySalesLabel => formatCurrency(
    _orders.fold<double>(0, (totalAmount, order) => totalAmount + order.total),
  );
  String get totalProductsLabel => '$totalProducts';
  String get newOrdersLabel => '$newOrdersCount';
  String get lowStockLabel => '$lowStockCount';

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    Get.offAllNamed(Routes.loginAdminWeb);
  }

  void changeSection(MainHomeWebSection section) {
    selectedSection.value = section;
  }

  String get displayName {
    final User? user = currentUser;
    if (user == null) {
      return 'Admin';
    }

    return user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email ?? 'Admin';
  }

  String get platformLabel => kIsWeb ? 'Flutter Web' : 'Flutter';

  String formatCurrency(num amount) {
    final String digits = amount.round().toString();
    final String formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '฿$formatted';
  }

  String formatOrderCount(int count) {
    return '$count รายการ';
  }

  Stream<List<AdminProductModel>> _productStream() {
    return _firestore
        .collection('product')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          isProductsLoading.value = false;
          return snapshot.docs.map(_mapProductDocument).toList();
        });
  }

  AdminProductModel _mapProductDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final ProductModel product = ProductModel.fromMap(doc.data());
    final int stock = product.stock.toInt();

    return AdminProductModel(
      id: doc.id,
      name: product.name,
      sku: _buildSku(doc.id),
      category: 'General',
      price: product.price.toDouble(),
      stock: stock,
      status: _statusFromStock(stock),
      updatedAt: product.timestamp.toDate(),
    );
  }

  String _buildSku(String docId) {
    final String normalized = docId.replaceAll('-', '').toUpperCase();
    final String suffix = normalized.length > 8
        ? normalized.substring(0, 8)
        : normalized;
    return 'SKU-$suffix';
  }

  AdminProductStatus _statusFromStock(int stock) {
    if (stock <= 0) {
      return AdminProductStatus.outOfStock;
    }

    if (stock <= 5) {
      return AdminProductStatus.lowStock;
    }

    return AdminProductStatus.active;
  }
}
