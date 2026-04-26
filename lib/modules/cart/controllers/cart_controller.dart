import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CartItem {
  const CartItem({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;

  String get name => (data['name'] ?? '') as String;
  String get description => (data['description'] ?? '') as String;
  String get base64Image => (data['base64Image'] ?? '') as String;
  String get unit => (data['unit'] ?? '') as String;
  num get price => (data['price'] ?? 0) as num;
  num get stock => (data['stock'] ?? 0) as num;
  int get quantity => ((data['quantity'] ?? 0) as num).toInt();
  num get totalPrice => price * quantity;

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
}

class CartController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _cartSubscription;

  num get totalAmount =>
      cartItems.fold<num>(0, (amount, item) => amount + item.totalPrice);

  int get totalQuantity => cartItems.fold<int>(0, (quantityTotal, item) {
    return quantityTotal + item.quantity;
  });

  @override
  void onInit() {
    super.onInit();
    listenCartFeed();
  }

  @override
  void onClose() {
    _cartSubscription?.cancel();
    super.onClose();
  }

  Future<void> refreshCart() async {
    await _cartSubscription?.cancel();
    listenCartFeed();
  }

  void listenCartFeed() {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      cartItems.clear();
      isLoading.value = false;
      errorMessage.value = 'กรุณาเข้าสู่ระบบก่อนดูตะกร้า';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    _cartSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('cart')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snapshot) {
            cartItems.assignAll(
              snapshot.docs.map(
                (doc) => CartItem(id: doc.id, data: doc.data()),
              ),
            );
            isLoading.value = false;
            errorMessage.value = '';
          },
          onError: (_) {
            cartItems.clear();
            isLoading.value = false;
            errorMessage.value = 'โหลดข้อมูลตะกร้าไม่สำเร็จ';
          },
        );
  }

  String formatCurrency(num amount) {
    final String digits = amount.round().toString();
    final String formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '฿$formatted';
  }

  Future<void> incrementQuantity(CartItem item) async {
    final int stock = item.stock.toInt();
    if (stock <= 0) {
      Get.snackbar(
        'สินค้าหมด',
        '${item.name} ยังไม่มีสินค้าในสต๊อก',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (item.quantity >= stock) {
      Get.snackbar(
        'จำนวนเกินสต๊อก',
        'เลือกจำนวนได้ไม่เกิน $stock ${item.unit}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    await _updateQuantity(item, item.quantity + 1);
  }

  Future<void> decrementQuantity(CartItem item) async {
    if (item.quantity <= 1) {
      return;
    }

    await _updateQuantity(item, item.quantity - 1);
  }

  Future<void> setQuantityToOne(CartItem item) async {
    await _updateQuantity(item, 1);
  }

  Future<void> deleteItem(CartItem item) async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(item.id)
          .delete();
    } catch (_) {
      Get.snackbar(
        'ลบสินค้าไม่สำเร็จ',
        'กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _updateQuantity(CartItem item, int quantity) async {
    final User? user = _firebaseAuth.currentUser;
    if (user == null || quantity < 1) {
      return;
    }

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(item.id)
          .update(<String, dynamic>{'quantity': quantity});
    } catch (_) {
      Get.snackbar(
        'อัปเดตจำนวนไม่สำเร็จ',
        'กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
