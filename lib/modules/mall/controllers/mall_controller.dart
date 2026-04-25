import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../model/product_model.dart';

class MallProductItem {
  const MallProductItem({required this.id, required this.product});

  final String id;
  final ProductModel product;

  bool get isOutOfStock => product.stock <= 0;
  bool get isLowStock => product.stock > 0 && product.stock <= 5;
}

class MallController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final RxList<MallProductItem> products = <MallProductItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isAddingToCart = false.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _productSubscription;

  @override
  void onInit() {
    super.onInit();
    listenProductFeed();
  }

  @override
  void onClose() {
    _productSubscription?.cancel();
    super.onClose();
  }

  Future<void> refreshProducts() async {
    await _productSubscription?.cancel();
    listenProductFeed();
  }

  void listenProductFeed() {
    isLoading.value = true;
    errorMessage.value = '';

    _productSubscription = _firestore
        .collection('product')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snapshot) {
            products.assignAll(
              snapshot.docs.map(
                (doc) => MallProductItem(
                  id: doc.id,
                  product: ProductModel.fromMap(doc.data()),
                ),
              ),
            );
            isLoading.value = false;
            errorMessage.value = '';
          },
          onError: (_) {
            products.clear();
            isLoading.value = false;
            errorMessage.value = 'โหลดข้อมูลสินค้าไม่สำเร็จ';
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

  Future<bool> addToCart({
    required MallProductItem item,
    required int quantity,
  }) async {
    if (isAddingToCart.value) {
      return false;
    }

    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      Get.snackbar(
        'ยังไม่ได้เข้าสู่ระบบ',
        'กรุณาเข้าสู่ระบบก่อนเพิ่มสินค้าลงตะกร้า',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final int availableStock = item.product.stock.toInt();
    if (quantity <= 0 || quantity > availableStock) {
      Get.snackbar(
        'จำนวนสินค้าไม่ถูกต้อง',
        'เลือกจำนวนได้ไม่เกิน $availableStock ${item.product.unit}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    isAddingToCart.value = true;

    try {
      final DocumentReference<Map<String, dynamic>> cartRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('cart')
          .doc(item.id);

      await _firestore.runTransaction((transaction) async {
        final DocumentSnapshot<Map<String, dynamic>> cartSnapshot =
            await transaction.get(cartRef);
        final int currentQuantity =
            (cartSnapshot.data()?['quantity'] ?? 0) as int;
        final int nextQuantity = currentQuantity + quantity;

        if (nextQuantity > availableStock) {
          throw StateError('stock-limit');
        }

        final FieldValue serverTimestamp = FieldValue.serverTimestamp();
        final Map<String, dynamic> cartData = <String, dynamic>{
          'productId': item.id,
          'name': item.product.name,
          'description': item.product.description,
          'base64Image': item.product.base64Image,
          'unit': item.product.unit,
          'price': item.product.price,
          'stock': item.product.stock,
          'quantity': nextQuantity,
          'updatedAt': serverTimestamp,
        };

        if (cartSnapshot.exists) {
          transaction.update(cartRef, cartData);
        } else {
          transaction.set(cartRef, <String, dynamic>{
            ...cartData,
            'addedAt': serverTimestamp,
          });
        }
      });

      return true;
    } on StateError {
      Get.snackbar(
        'จำนวนเกินสต๊อก',
        'สินค้าในตะกร้ารวมกับจำนวนที่เลือกต้องไม่เกิน $availableStock ${item.product.unit}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (_) {
      Get.snackbar(
        'เพิ่มลงตะกร้าไม่สำเร็จ',
        'กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isAddingToCart.value = false;
    }
  }
}
