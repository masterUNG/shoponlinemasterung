import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shoponlinemasterung/model/order_model.dart';
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
        return 'ติดตามรายการสั่งซื้อและสถานะรับที่ร้าน';
    }
  }
}

class MainHomeWebController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final Rx<MainHomeWebSection> selectedSection =
      MainHomeWebSection.dashboard.obs;
  final RxList<AdminProductModel> _products = <AdminProductModel>[].obs;
  final RxList<AdminOrderModel> _orders = <AdminOrderModel>[].obs;
  final RxBool isProductsLoading = true.obs;
  final RxBool isOrdersLoading = true.obs;
  final RxString updatingOrderId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _products.bindStream(_productStream());
    _orders.bindStream(_orderStream());
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
  int get newOrdersCount => openOrders.length;
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

  Future<void> updateOrderStatus({
    required AdminOrderModel order,
    required AdminOrderStatus status,
  }) async {
    if (updatingOrderId.value.isNotEmpty || order.status.isClosed) {
      return;
    }

    updatingOrderId.value = order.id;
    _replaceOrder(order.copyWith(status: status));

    try {
      await _firestore.collection('orders').doc(order.id).update({
        'status': status.firestoreValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      _replaceOrder(order);
      Get.snackbar(
        'อัปเดตออเดอร์ไม่สำเร็จ',
        'กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      updatingOrderId.value = '';
    }
  }

  List<AdminOrderStatus> nextOrderStatuses(AdminOrderStatus status) {
    return switch (status) {
      AdminOrderStatus.pending => <AdminOrderStatus>[
        AdminOrderStatus.accepted,
        AdminOrderStatus.cancelled,
      ],
      AdminOrderStatus.accepted => <AdminOrderStatus>[
        AdminOrderStatus.preparing,
        AdminOrderStatus.cancelled,
      ],
      AdminOrderStatus.preparing => <AdminOrderStatus>[
        AdminOrderStatus.ready,
        AdminOrderStatus.cancelled,
      ],
      AdminOrderStatus.ready => <AdminOrderStatus>[
        AdminOrderStatus.completed,
        AdminOrderStatus.cancelled,
      ],
      AdminOrderStatus.completed ||
      AdminOrderStatus.cancelled => <AdminOrderStatus>[],
    };
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

  String formatDateTime(DateTime dateTime) {
    if (dateTime.millisecondsSinceEpoch == 0) {
      return '-';
    }

    return '${_twoDigits(dateTime.day)}/${_twoDigits(dateTime.month)}/${dateTime.year} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
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

  Stream<List<AdminOrderModel>> _orderStream() {
    return _firestore.collection('orders').snapshots().map((snapshot) {
      isOrdersLoading.value = false;
      final List<AdminOrderModel> orders = snapshot.docs
          .map(_mapOrderDocument)
          .toList();
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
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
      imageBytes: product.imageBytes,
    );
  }

  AdminOrderModel _mapOrderDocument(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final OrderModel order = OrderModel.fromDocument(doc);
    final String customerName = order.userName.trim().isEmpty
        ? order.userId
        : order.userName.trim();
    final String orderNo = order.orderNo.trim().isEmpty
        ? doc.id
        : order.orderNo;

    return AdminOrderModel(
      id: doc.id,
      orderNo: orderNo,
      customerName: customerName,
      itemCount: order.totalQuantity,
      total: order.grandTotal.toDouble(),
      status: _orderStatusFromText(order.status),
      createdAt:
          order.createdAt?.toDate() ?? DateTime.fromMillisecondsSinceEpoch(0),
      note: _buildOrderNote(order),
      paymentStatus: order.paymentStatus,
      items: order.items,
      pickupInfo: order.pickupInfo,
      subtotal: order.subtotal.toDouble(),
      discount: order.discount.toDouble(),
    );
  }

  void _replaceOrder(AdminOrderModel order) {
    final int index = _orders.indexWhere((item) => item.id == order.id);
    if (index == -1) {
      return;
    }

    _orders[index] = order;
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

  AdminOrderStatus _orderStatusFromText(String status) {
    return switch (status) {
      'accepted' => AdminOrderStatus.accepted,
      'preparing' => AdminOrderStatus.preparing,
      'ready' => AdminOrderStatus.ready,
      'completed' => AdminOrderStatus.completed,
      'cancelled' => AdminOrderStatus.cancelled,
      _ => AdminOrderStatus.pending,
    };
  }

  String _buildOrderNote(OrderModel order) {
    final String payment = order.paymentStatus == 'paid'
        ? 'ชำระเงินแล้ว'
        : 'ยังไม่ชำระเงิน';
    final String pickupName = order.pickupInfo.pickupName.trim();
    final String pickupPhone = order.pickupInfo.pickupPhone.trim();
    final String note = order.pickupInfo.note.trim();
    final String pickup = [
      if (pickupName.isNotEmpty) pickupName,
      if (pickupPhone.isNotEmpty) pickupPhone,
    ].join(' • ');

    return [
      'รับที่ร้าน',
      payment,
      if (pickup.isNotEmpty) pickup,
      if (note.isNotEmpty) note,
    ].join(' • ');
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
