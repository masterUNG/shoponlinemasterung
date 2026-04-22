import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

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
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Rx<MainHomeWebSection> selectedSection =
      MainHomeWebSection.dashboard.obs;

  final List<AdminProductModel> _products = <AdminProductModel>[
    AdminProductModel(
      id: 'P001',
      name: 'เสื้อยืด Oversize สีขาว',
      sku: 'SKU-TSH-001',
      category: 'Apparel',
      price: 390,
      stock: 3,
      status: AdminProductStatus.lowStock,
      updatedAt: DateTime(2026, 4, 22),
    ),
    AdminProductModel(
      id: 'P002',
      name: 'แก้วเก็บความเย็น 890ml',
      sku: 'SKU-CUP-014',
      category: 'Lifestyle',
      price: 259,
      stock: 15,
      status: AdminProductStatus.active,
      updatedAt: DateTime(2026, 4, 21),
    ),
    AdminProductModel(
      id: 'P003',
      name: 'กระเป๋าผ้า Canvas',
      sku: 'SKU-BAG-021',
      category: 'Accessories',
      price: 490,
      stock: 7,
      status: AdminProductStatus.active,
      updatedAt: DateTime(2026, 4, 20),
    ),
    AdminProductModel(
      id: 'P004',
      name: 'หมวกแก๊ปสีกรม',
      sku: 'SKU-CAP-102',
      category: 'Apparel',
      price: 320,
      stock: 0,
      status: AdminProductStatus.outOfStock,
      updatedAt: DateTime(2026, 4, 18),
    ),
    AdminProductModel(
      id: 'P005',
      name: 'สเปรย์น้ำหอมในรถ',
      sku: 'SKU-CAR-030',
      category: 'Home',
      price: 149,
      stock: 24,
      status: AdminProductStatus.active,
      updatedAt: DateTime(2026, 4, 19),
    ),
  ];

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
    _orders.fold<double>(0, (sum, order) => sum + order.total),
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
}
