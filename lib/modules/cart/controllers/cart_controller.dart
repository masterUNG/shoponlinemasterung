import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../core/app_constant.dart';
import '../../../model/order_model.dart';
import '../../../services/reviewer_mode_service.dart';
import '../../main_home/controllers/main_home_controller.dart';

enum FulfillmentType { pickup, delivery }

class CartItem {
  const CartItem({required this.id, required this.data});

  final String id;
  final Map<String, dynamic> data;

  String get name => (data['name'] ?? '') as String;
  String get description => (data['description'] ?? '') as String;
  String get shortDescription =>
      (data['shortDescription'] ?? description) as String;
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
  ReviewerModeService get _reviewerMode => Get.find<ReviewerModeService>();

  final RxList<CartItem> cartItems = <CartItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isOrdering = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<FulfillmentType> fulfillmentType = FulfillmentType.pickup.obs;
  final RxString paymentMethod = OrderPaymentMethod.promptPay.obs;
  final Rxn<GeoPoint> customerLocation = Rxn<GeoPoint>();
  final RxnDouble distanceFromShopMeters = RxnDouble();
  final RxString customerPhone = ''.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _cartSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;
  Worker? _demoCartWorker;

  static const double freeDeliveryRadiusMeters = 1000;

  num get totalAmount =>
      cartItems.fold<num>(0, (amount, item) => amount + item.totalPrice);

  int get totalQuantity => cartItems.fold<int>(0, (quantityTotal, item) {
    return quantityTotal + item.quantity;
  });

  bool get canUseDelivery {
    final double? distance = distanceFromShopMeters.value;
    return customerLocation.value != null &&
        distance != null &&
        distance <= freeDeliveryRadiusMeters;
  }

  String get deliveryStatusText {
    if (_reviewerMode.isGuest) {
      return 'Guest reviewer mode ใช้ตะกร้าตัวอย่างเท่านั้น การจัดส่งและออเดอร์จริงต้องเข้าสู่ระบบก่อน';
    }

    final double? distance = distanceFromShopMeters.value;
    if (customerLocation.value == null || distance == null) {
      return 'ส่งฟรีเฉพาะลูกค้าในหมู่บ้าน/รัศมี 1 กม. จากร้าน กรุณาบันทึกพิกัดก่อนเลือกให้ไปส่งฟรี';
    }

    final String distanceText = formatDistance(distance);
    if (canUseDelivery) {
      return 'พิกัดของคุณอยู่ห่างร้าน $distanceText ส่งฟรีเฉพาะในหมู่บ้าน/รัศมี 1 กม. ใช้บริการส่งฟรีได้';
    }

    return 'พิกัดของคุณอยู่ห่างร้าน $distanceText เกินรัศมีส่งฟรี 1 กม. จึงเลือกได้เฉพาะมารับเองที่ร้าน';
  }

  @override
  void onInit() {
    super.onInit();
    _demoCartWorker = ever<List<Map<String, dynamic>>>(
      _reviewerMode.demoCartItems,
      (_) {
        if (_reviewerMode.isGuest) {
          cartItems.assignAll(_buildDemoCartItems());
        }
      },
    );
    listenCartFeed();
    listenUserProfile();
  }

  @override
  void onClose() {
    _cartSubscription?.cancel();
    _userSubscription?.cancel();
    _demoCartWorker?.dispose();
    super.onClose();
  }

  Future<void> refreshCart() async {
    if (_reviewerMode.isGuest) {
      listenCartFeed();
      return;
    }

    await _cartSubscription?.cancel();
    listenCartFeed();
  }

  void listenCartFeed() {
    if (_reviewerMode.isGuest) {
      _cartSubscription?.cancel();
      cartItems.assignAll(_buildDemoCartItems());
      isLoading.value = false;
      errorMessage.value = '';
      return;
    }

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

  void listenUserProfile() {
    if (_reviewerMode.isGuest) {
      customerLocation.value = null;
      distanceFromShopMeters.value = null;
      customerPhone.value = '';
      fulfillmentType.value = FulfillmentType.pickup;
      return;
    }

    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      customerLocation.value = null;
      distanceFromShopMeters.value = null;
      customerPhone.value = '';
      fulfillmentType.value = FulfillmentType.pickup;
      return;
    }

    _userSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((DocumentSnapshot<Map<String, dynamic>> snapshot) {
          final Map<String, dynamic>? userData = snapshot.data();
          customerPhone.value = (userData?['phone'] ?? '').toString();
          final Object? geopoint = userData?['geopoint'];
          if (geopoint is GeoPoint) {
            customerLocation.value = geopoint;
            distanceFromShopMeters.value = Geolocator.distanceBetween(
              AppConstant.shopLocation.latitude,
              AppConstant.shopLocation.longitude,
              geopoint.latitude,
              geopoint.longitude,
            );
          } else {
            customerLocation.value = null;
            distanceFromShopMeters.value = null;
          }

          if (!canUseDelivery) {
            fulfillmentType.value = FulfillmentType.pickup;
          }
        });
  }

  void selectFulfillment(FulfillmentType type) {
    if (_reviewerMode.isGuest && type == FulfillmentType.delivery) {
      Get.snackbar(
        'Guest reviewer mode',
        'โหมดรีวิวใช้ตะกร้าตัวอย่างและไม่บันทึกพิกัดจัดส่งจริง',
        snackPosition: SnackPosition.BOTTOM,
      );
      fulfillmentType.value = FulfillmentType.pickup;
      return;
    }

    if (type == FulfillmentType.delivery && !canUseDelivery) {
      Get.snackbar(
        'ยังใช้บริการส่งไม่ได้',
        deliveryStatusText,
        snackPosition: SnackPosition.BOTTOM,
      );
      fulfillmentType.value = FulfillmentType.pickup;
      return;
    }

    fulfillmentType.value = type;
  }

  void selectPaymentMethod(String method) {
    if (method == OrderPaymentMethod.promptPay ||
        method == OrderPaymentMethod.cash) {
      paymentMethod.value = method;
    }
  }

  String formatCurrency(num amount) {
    final String digits = amount.round().toString();
    final String formatted = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '฿$formatted';
  }

  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} เมตร';
    }

    return '${(meters / 1000).toStringAsFixed(2)} กม.';
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

    if (_reviewerMode.isGuest) {
      _reviewerMode.updateDemoCartQuantity(item.id, item.quantity + 1);
      cartItems.assignAll(_buildDemoCartItems());
      return;
    }

    await _updateQuantity(item, item.quantity + 1);
  }

  Future<void> decrementQuantity(CartItem item) async {
    if (item.quantity <= 1) {
      return;
    }

    if (_reviewerMode.isGuest) {
      _reviewerMode.updateDemoCartQuantity(item.id, item.quantity - 1);
      cartItems.assignAll(_buildDemoCartItems());
      return;
    }

    await _updateQuantity(item, item.quantity - 1);
  }

  Future<void> setQuantityToOne(CartItem item) async {
    if (_reviewerMode.isGuest) {
      _reviewerMode.updateDemoCartQuantity(item.id, 1);
      cartItems.assignAll(_buildDemoCartItems());
      return;
    }

    await _updateQuantity(item, 1);
  }

  Future<void> deleteItem(CartItem item) async {
    if (_reviewerMode.isGuest) {
      _reviewerMode.deleteDemoCartItem(item.id);
      cartItems.assignAll(_buildDemoCartItems());
      return;
    }

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

  Future<void> createOrderFromCart() async {
    if (isOrdering.value || cartItems.isEmpty) {
      return;
    }

    if (_reviewerMode.isGuest) {
      await _reviewerMode.showLoginRequiredDialog(
        title: 'ต้องเข้าสู่ระบบก่อนสั่งซื้อ',
        message:
            'Guest reviewer mode ให้ทดลองเลือกสินค้าและใส่ตะกร้าด้วยข้อมูลตัวอย่างได้ แต่การสร้างออเดอร์ ชำระเงินจริง และบันทึกคำสั่งซื้อต้องเข้าสู่ระบบก่อน',
      );
      return;
    }

    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      Get.snackbar(
        'ยังไม่ได้เข้าสู่ระบบ',
        'กรุณาเข้าสู่ระบบก่อนสั่งสินค้า',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isOrdering.value = true;

    try {
      final String orderPhone = customerPhone.value.trim();
      if (!_isValidPhone(orderPhone)) {
        Get.snackbar(
          'กรุณาเพิ่มเบอร์โทร',
          'ร้านต้องใช้เบอร์โทรเพื่อติดต่อเรื่องออเดอร์และการจัดส่ง กรุณาเพิ่มในหน้า Profile ก่อนสั่งซื้อ',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final FulfillmentType selectedFulfillment = canUseDelivery
          ? fulfillmentType.value
          : FulfillmentType.pickup;
      if (fulfillmentType.value == FulfillmentType.delivery &&
          selectedFulfillment == FulfillmentType.pickup) {
        Get.snackbar(
          'จัดส่งไม่ได้',
          deliveryStatusText,
          snackPosition: SnackPosition.BOTTOM,
        );
      }

      final List<CartItem> orderingItems = List<CartItem>.from(cartItems);
      final DocumentReference<Map<String, dynamic>> orderRef = _firestore
          .collection('orders')
          .doc();
      final String orderNo = _buildOrderNo(orderRef.id);
      final num orderingTotal = orderingItems.fold<num>(
        0,
        (amount, item) => amount + item.totalPrice,
      );

      await _firestore.runTransaction((transaction) async {
        for (final CartItem item in orderingItems) {
          final DocumentReference<Map<String, dynamic>> productRef = _firestore
              .collection('product')
              .doc(item.id);
          final DocumentSnapshot<Map<String, dynamic>> productSnapshot =
              await transaction.get(productRef);
          final int currentStock =
              ((productSnapshot.data()?['stock'] ?? 0) as num).toInt();

          if (!productSnapshot.exists || currentStock < item.quantity) {
            throw StateError('stock-limit:${item.name}');
          }
        }

        final FieldValue serverTimestamp = FieldValue.serverTimestamp();
        final GeoPoint? deliveryLocation =
            selectedFulfillment == FulfillmentType.delivery
            ? customerLocation.value
            : null;
        final double? deliveryDistanceMeters =
            selectedFulfillment == FulfillmentType.delivery
            ? distanceFromShopMeters.value
            : null;
        final List<Map<String, dynamic>> orderItems = orderingItems.map((item) {
          return <String, dynamic>{
            'productId': item.data['productId'] ?? item.id,
            'productName': item.name,
            'description': item.description,
            'shortDescription': item.shortDescription,
            'base64Image': item.base64Image,
            'unit': item.unit,
            'price': item.price,
            'quantity': item.quantity,
            'total': item.totalPrice,
          };
        }).toList();

        transaction.set(orderRef, <String, dynamic>{
          'orderNo': orderNo,
          'userId': user.uid,
          'userName': _resolveUserName(user),
          'userPhone': orderPhone,
          'orderType': selectedFulfillment.name,
          'items': orderItems,
          'subtotal': orderingTotal,
          'discount': 0,
          'deliveryDistanceMeters': ?deliveryDistanceMeters,
          'deliveryLocation': ?deliveryLocation,
          'grandTotal': orderingTotal,
          'status': 'pending',
          'paymentMethod': paymentMethod.value,
          'paymentStatus': 'unpaid',
          'pickupInfo': <String, dynamic>{
            'pickupName': _resolveUserName(user),
            'pickupPhone': orderPhone,
            'note': '',
          },
          'createdAt': serverTimestamp,
          'updatedAt': serverTimestamp,
        });

        for (final CartItem item in orderingItems) {
          transaction.update(_firestore.collection('product').doc(item.id), {
            'stock': FieldValue.increment(-item.quantity),
          });
          transaction.delete(
            _firestore
                .collection('users')
                .doc(user.uid)
                .collection('cart')
                .doc(item.id),
          );
        }
      });

      Get.snackbar(
        'สั่งซื้อสำเร็จ',
        'สร้างออเดอร์ $orderNo แล้ว',
        snackPosition: SnackPosition.BOTTOM,
      );

      if (Get.isRegistered<MainHomeController>()) {
        Get.find<MainHomeController>().changeIndexBody(2);
      }
    } on StateError catch (error) {
      final String itemName = error.message.split(':').skip(1).join(':');
      Get.snackbar(
        'สต๊อกสินค้าไม่พอ',
        itemName.isEmpty
            ? 'มีบางสินค้าในตะกร้าที่สต๊อกไม่พอ'
            : '$itemName มีจำนวนในสต๊อกไม่พอ',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error, stackTrace) {
      debugPrint('createOrderFromCart failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      Get.snackbar(
        'สั่งซื้อไม่สำเร็จ',
        'กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isOrdering.value = false;
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

  String _buildOrderNo(String documentId) {
    final DateTime now = DateTime.now();
    final String date =
        '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}';
    return 'ORD-$date-${documentId.substring(0, 6).toUpperCase()}';
  }

  String _resolveUserName(User user) {
    if (user.displayName?.trim().isNotEmpty == true) {
      return user.displayName!.trim();
    }

    if (user.email?.trim().isNotEmpty == true) {
      return user.email!.trim();
    }

    return user.uid;
  }

  bool _isValidPhone(String phone) {
    final String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 8 && digits.length <= 15;
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  List<CartItem> _buildDemoCartItems() {
    return _reviewerMode.demoCartItems.map((data) {
      final String productId = (data['productId'] ?? '') as String;
      return CartItem(id: productId, data: data);
    }).toList();
  }
}
