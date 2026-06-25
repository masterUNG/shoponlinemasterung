import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shoponlinemasterung/model/order_model.dart';
import 'package:shoponlinemasterung/model/product_model.dart';

import '../../../app/routes/app_routes.dart';
import '../../../services/admin_role_service.dart';
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
  final AdminRoleService _adminRoleService = AdminRoleService();
  final Rx<MainHomeWebSection> selectedSection =
      MainHomeWebSection.dashboard.obs;
  final RxList<AdminProductModel> _products = <AdminProductModel>[].obs;
  final RxList<AdminOrderModel> _orders = <AdminOrderModel>[].obs;
  final RxBool isProductsLoading = true.obs;
  final RxBool isOrdersLoading = true.obs;
  final RxString updatingOrderId = ''.obs;
  final RxString updatingPaymentOrderId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _bindAdminDataIfAllowed();
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
  double get todaySales => _salesForDay(DateTime.now());
  double get yesterdaySales =>
      _salesForDay(DateTime.now().subtract(const Duration(days: 1)));
  String get todaySalesLabel => formatCurrency(todaySales);
  String get salesComparisonLabel {
    final double previousSales = yesterdaySales;
    final double currentSales = todaySales;

    if (previousSales == 0) {
      return currentSales == 0
          ? 'ยอดขายเท่ากับเมื่อวาน'
          : 'เพิ่มขึ้นจากเมื่อวาน';
    }

    final double percentage =
        ((currentSales - previousSales) / previousSales) * 100;
    final String direction = percentage >= 0 ? '+' : '';
    return '$direction${percentage.toStringAsFixed(1)}% จากเมื่อวาน';
  }

  String get totalProductsLabel => '$totalProducts';
  String get newOrdersLabel => '$newOrdersCount';
  String get lowStockLabel => '$lowStockCount';
  bool get canDeleteProducts =>
      _adminRoleService.currentUserCanDeleteProducts();

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    Get.offAllNamed(Routes.loginAdminWeb);
  }

  Future<void> _bindAdminDataIfAllowed() async {
    final bool isAdmin = await _adminRoleService.currentUserIsAdmin();
    if (!isAdmin) {
      await _firebaseAuth.signOut();
      Get.offAllNamed(Routes.loginAdminWeb);
      Get.snackbar(
        'ไม่มีสิทธิ์ผู้ดูแล',
        'กรุณาเข้าสู่ระบบด้วยบัญชี admin',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    _products.bindStream(_productStream());
    _orders.bindStream(_orderStream());
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
      await _firestore.runTransaction((transaction) async {
        final DocumentReference<Map<String, dynamic>> orderRef = _firestore
            .collection('orders')
            .doc(order.id);
        final DocumentSnapshot<Map<String, dynamic>> orderSnapshot =
            await transaction.get(orderRef);

        if (!orderSnapshot.exists) {
          throw StateError('order-not-found');
        }

        final OrderModel latestOrder = OrderModel.fromDocument(orderSnapshot);
        final AdminOrderStatus currentStatus = _orderStatusFromText(
          latestOrder.status,
        );
        if (!nextOrderStatuses(currentStatus).contains(status)) {
          throw StateError('invalid-order-transition');
        }

        if (status == AdminOrderStatus.completed &&
            latestOrder.paymentStatus != 'paid') {
          throw StateError('payment-required');
        }

        if (status != AdminOrderStatus.cancelled) {
          transaction.update(orderRef, <String, dynamic>{
            'status': status.firestoreValue,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          return;
        }

        if (latestOrder.stockRestoredAt != null) {
          throw StateError('stock-already-restored');
        }

        final Map<String, int> restoreQuantities = buildStockRestoreQuantities(
          latestOrder.items,
        );
        final Map<String, DocumentReference<Map<String, dynamic>>> productRefs =
            <String, DocumentReference<Map<String, dynamic>>>{
              for (final String productId in restoreQuantities.keys)
                productId: _firestore.collection('product').doc(productId),
            };

        for (final MapEntry<String, DocumentReference<Map<String, dynamic>>>
            entry
            in productRefs.entries) {
          final DocumentSnapshot<Map<String, dynamic>> productSnapshot =
              await transaction.get(entry.value);
          if (!productSnapshot.exists) {
            throw StateError('product-not-found:${entry.key}');
          }
        }

        for (final MapEntry<String, int> entry in restoreQuantities.entries) {
          transaction.update(productRefs[entry.key]!, <String, dynamic>{
            'stock': FieldValue.increment(entry.value),
          });
        }

        transaction.update(orderRef, <String, dynamic>{
          'status': AdminOrderStatus.cancelled.firestoreValue,
          'stockRestoredAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on StateError catch (error) {
      _replaceOrder(order);
      Get.snackbar(
        'อัปเดตออเดอร์ไม่สำเร็จ',
        _orderUpdateErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FormatException {
      _replaceOrder(order);
      Get.snackbar(
        'ยกเลิกออเดอร์ไม่สำเร็จ',
        'รายการสินค้าในออเดอร์ไม่สมบูรณ์ กรุณาตรวจสอบข้อมูล',
        snackPosition: SnackPosition.BOTTOM,
      );
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

  Future<void> verifyOrderPayment(AdminOrderModel order) async {
    if (updatingPaymentOrderId.value.isNotEmpty ||
        order.paymentStatus != 'waiting_verify') {
      return;
    }

    updatingPaymentOrderId.value = order.id;
    _replaceOrder(order.copyWith(paymentStatus: 'paid'));

    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentReference<Map<String, dynamic>> orderRef = _firestore
            .collection('orders')
            .doc(order.id);
        final DocumentSnapshot<Map<String, dynamic>> snapshot =
            await transaction.get(orderRef);
        _validatePaymentReview(snapshot);

        transaction.update(orderRef, <String, dynamic>{
          'paymentStatus': 'paid',
          'paymentVerifiedAt': FieldValue.serverTimestamp(),
          'paidAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on StateError catch (error) {
      _replaceOrder(order);
      Get.snackbar(
        'ยืนยันสลิปไม่สำเร็จ',
        _paymentUpdateErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      _replaceOrder(order);
      Get.snackbar(
        'ยืนยันสลิปไม่สำเร็จ',
        'กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      updatingPaymentOrderId.value = '';
    }
  }

  Future<void> rejectOrderPayment(AdminOrderModel order) async {
    if (updatingPaymentOrderId.value.isNotEmpty ||
        order.paymentStatus != 'waiting_verify') {
      return;
    }

    updatingPaymentOrderId.value = order.id;
    _replaceOrder(order.copyWith(paymentStatus: 'rejected'));

    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentReference<Map<String, dynamic>> orderRef = _firestore
            .collection('orders')
            .doc(order.id);
        final DocumentSnapshot<Map<String, dynamic>> snapshot =
            await transaction.get(orderRef);
        _validatePaymentReview(snapshot);

        transaction.update(orderRef, <String, dynamic>{
          'paymentStatus': 'rejected',
          'paymentRejectedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });
    } on StateError catch (error) {
      _replaceOrder(order);
      Get.snackbar(
        'ปฏิเสธสลิปไม่สำเร็จ',
        _paymentUpdateErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      _replaceOrder(order);
      Get.snackbar(
        'ปฏิเสธสลิปไม่สำเร็จ',
        'กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      updatingPaymentOrderId.value = '';
    }
  }

  Future<void> confirmCashPayment(AdminOrderModel order) async {
    if (updatingPaymentOrderId.value.isNotEmpty ||
        !order.isCashPayment ||
        order.paymentStatus != 'unpaid' ||
        order.status.isClosed) {
      return;
    }

    updatingPaymentOrderId.value = order.id;
    _replaceOrder(order.copyWith(paymentStatus: 'paid'));

    try {
      await _firestore.runTransaction((transaction) async {
        final DocumentReference<Map<String, dynamic>> orderRef = _firestore
            .collection('orders')
            .doc(order.id);
        final DocumentSnapshot<Map<String, dynamic>> snapshot =
            await transaction.get(orderRef);

        if (!snapshot.exists) {
          throw StateError('order-not-found');
        }

        final OrderModel latestOrder = OrderModel.fromDocument(snapshot);
        if (latestOrder.isCompleteOrCancelled) {
          throw StateError('order-closed');
        }
        if (!latestOrder.isCashPayment ||
            latestOrder.paymentStatus != 'unpaid') {
          throw StateError('cash-payment-already-recorded');
        }

        final FieldValue paidTimestamp = FieldValue.serverTimestamp();
        transaction.update(orderRef, <String, dynamic>{
          'paymentStatus': 'paid',
          'cashCollectedAt': paidTimestamp,
          'cashCollectedBy': currentUser?.uid ?? '',
          'paidAt': paidTimestamp,
          'updatedAt': paidTimestamp,
        });
      });
    } on StateError catch (error) {
      _replaceOrder(order);
      Get.snackbar(
        'บันทึกรับเงินสดไม่สำเร็จ',
        _cashPaymentErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      _replaceOrder(order);
      Get.snackbar(
        'บันทึกรับเงินสดไม่สำเร็จ',
        'กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      updatingPaymentOrderId.value = '';
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

  double _salesForDay(DateTime day) {
    final DateTime start = DateTime(day.year, day.month, day.day);
    final DateTime end = start.add(const Duration(days: 1));

    return _orders
        .where((order) {
          final DateTime recognizedAt = order.paidAt ?? order.createdAt;
          return !recognizedAt.isBefore(start) &&
              recognizedAt.isBefore(end) &&
              order.paymentStatus == 'paid' &&
              order.status != AdminOrderStatus.cancelled;
        })
        .fold<double>(0, (totalAmount, order) => totalAmount + order.total);
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
      description: product.description,
      shortDescription: product.shortDescription,
      detailDescription: product.detailDescription,
      condition: product.condition,
      base64Image: product.base64Image,
      images: product.images,
      sku: _buildSku(doc.id),
      category: product.category,
      tags: product.tags,
      unit: product.unit,
      price: product.price.toDouble(),
      stock: stock,
      isActive: product.isActive,
      isRecommended: product.isRecommended,
      relatedProductIds: product.relatedProductIds,
      soldCount: product.soldCount,
      viewCount: product.viewCount,
      status: product.isActive
          ? _statusFromStock(stock)
          : AdminProductStatus.hidden,
      updatedAt: product.updatedAt?.toDate() ?? product.timestamp.toDate(),
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
      paymentMethod: order.paymentMethod,
      paymentStatus: order.paymentStatus,
      paymentSlipBase64: order.paymentSlipBase64,
      paymentSlipUploadedAt: order.paymentSlipUploadedAt?.toDate(),
      items: order.items,
      pickupInfo: order.pickupInfo,
      orderType: order.orderType,
      deliveryDistanceMeters: order.deliveryDistanceMeters,
      deliveryLatitude: order.deliveryLocation?.latitude,
      deliveryLongitude: order.deliveryLocation?.longitude,
      subtotal: order.subtotal.toDouble(),
      discount: order.discount.toDouble(),
      paidAt: order.paidAt?.toDate(),
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
    final String payment = paymentStatusLabel(
      order.paymentStatus,
      paymentMethod: order.paymentMethod,
    );
    final String pickupName = order.pickupInfo.pickupName.trim();
    final String pickupPhone = order.pickupInfo.pickupPhone.trim();
    final String note = order.pickupInfo.note.trim();
    final String fulfillment = order.orderType == 'delivery'
        ? _buildDeliverySummary(order.deliveryDistanceMeters)
        : 'รับที่ร้าน';
    final String pickup = [
      if (pickupName.isNotEmpty) pickupName,
      if (pickupPhone.isNotEmpty) pickupPhone,
    ].join(' • ');

    return [
      fulfillment,
      payment,
      if (pickup.isNotEmpty) pickup,
      if (note.isNotEmpty) note,
    ].join(' • ');
  }

  String _buildDeliverySummary(num? distanceMeters) {
    if (distanceMeters == null) {
      return 'ส่งฟรีในหมู่บ้าน/รัศมี 1 กม.';
    }

    return 'ส่งฟรี • ระยะ ${formatDistance(distanceMeters)} จากร้าน';
  }

  String formatDistance(num meters) {
    if (meters < 1000) {
      return '${meters.round()} เมตร';
    }

    return '${(meters / 1000).toStringAsFixed(2)} กม.';
  }

  String paymentMethodLabel(String method) {
    return method == OrderPaymentMethod.cash ? 'เงินสด' : 'PromptPay';
  }

  String paymentStatusLabel(
    String status, {
    String paymentMethod = OrderPaymentMethod.promptPay,
  }) {
    return switch (status) {
      'unpaid' when paymentMethod == OrderPaymentMethod.cash => 'รอรับเงินสด',
      'unpaid' => 'ยังไม่ชำระเงิน',
      'waiting_verify' => 'รอตรวจสลิป',
      'paid' when paymentMethod == OrderPaymentMethod.cash => 'รับเงินสดแล้ว',
      'paid' => 'ชำระเงินแล้ว',
      'rejected' => 'สลิปไม่ผ่าน',
      _ => status,
    };
  }

  String _cashPaymentErrorMessage(StateError error) {
    return switch (error.message.toString()) {
      'order-not-found' => 'ไม่พบออเดอร์นี้ในระบบ',
      'order-closed' => 'ออเดอร์ถูกปิดหรือยกเลิกแล้ว',
      'cash-payment-already-recorded' =>
        'ออเดอร์นี้ถูกบันทึกการชำระเงินจากอุปกรณ์อื่นแล้ว',
      _ => 'กรุณาลองใหม่อีกครั้ง',
    };
  }

  String _orderUpdateErrorMessage(StateError error) {
    final String message = error.message.toString();
    if (message == 'order-not-found') {
      return 'ไม่พบออเดอร์นี้ในระบบ';
    }
    if (message == 'invalid-order-transition') {
      return 'สถานะออเดอร์ถูกเปลี่ยนจากอุปกรณ์อื่น กรุณาลองใหม่';
    }
    if (message == 'payment-required') {
      return 'ต้องยืนยันการรับชำระเงินก่อนปิดออเดอร์';
    }
    if (message == 'stock-already-restored') {
      return 'ออเดอร์นี้คืนสต๊อกไปแล้ว';
    }
    if (message.startsWith('product-not-found:')) {
      return 'ไม่สามารถคืนสต๊อกได้ เนื่องจากมีสินค้าบางรายการถูกลบ';
    }
    return 'กรุณาลองใหม่อีกครั้ง';
  }

  void _validatePaymentReview(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    if (!snapshot.exists) {
      throw StateError('order-not-found');
    }

    final OrderModel latestOrder = OrderModel.fromDocument(snapshot);
    if (latestOrder.isCompleteOrCancelled) {
      throw StateError('order-closed');
    }
    if (latestOrder.paymentStatus != 'waiting_verify') {
      throw StateError('payment-already-reviewed');
    }
  }

  String _paymentUpdateErrorMessage(StateError error) {
    return switch (error.message.toString()) {
      'order-not-found' => 'ไม่พบออเดอร์นี้ในระบบ',
      'order-closed' => 'ออเดอร์ถูกปิดหรือยกเลิกแล้ว',
      'payment-already-reviewed' =>
        'สลิปนี้ถูกตรวจจากอุปกรณ์อื่นแล้ว กรุณาตรวจสอบสถานะล่าสุด',
      _ => 'กรุณาลองใหม่อีกครั้ง',
    };
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
