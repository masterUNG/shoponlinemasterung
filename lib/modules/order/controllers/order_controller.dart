import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../model/order_model.dart';

class OrderController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final RxList<OrderModel> orders = <OrderModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final RxString uploadingPaymentOrderId = ''.obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _orderSubscription;
  final ImagePicker _imagePicker = ImagePicker();

  List<OrderModel> get unCompleteOrders {
    return orders.where((order) => !order.isCompleteOrCancelled).toList();
  }

  List<OrderModel> get completeOrCancelOrders {
    return orders.where((order) => order.isCompleteOrCancelled).toList();
  }

  @override
  void onInit() {
    super.onInit();
    listenOrders();
  }

  @override
  void onClose() {
    _orderSubscription?.cancel();
    super.onClose();
  }

  Future<void> refreshOrders() async {
    await _orderSubscription?.cancel();
    listenOrders();
  }

  void listenOrders() {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) {
      orders.clear();
      isLoading.value = false;
      errorMessage.value = 'กรุณาเข้าสู่ระบบก่อนดูออเดอร์';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    _orderSubscription = _firestore
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .listen(
          (QuerySnapshot<Map<String, dynamic>> snapshot) {
            final List<OrderModel> nextOrders = snapshot.docs
                .map(OrderModel.fromDocument)
                .toList();
            nextOrders.sort((a, b) {
              final int aMilliseconds =
                  a.createdAt?.millisecondsSinceEpoch ?? 0;
              final int bMilliseconds =
                  b.createdAt?.millisecondsSinceEpoch ?? 0;
              return bMilliseconds.compareTo(aMilliseconds);
            });

            orders.assignAll(nextOrders);
            isLoading.value = false;
            errorMessage.value = '';
          },
          onError: (_) {
            orders.clear();
            isLoading.value = false;
            errorMessage.value = 'โหลดข้อมูลออเดอร์ไม่สำเร็จ';
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

  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) {
      return '-';
    }

    final DateTime dateTime = timestamp.toDate();
    return '${_twoDigits(dateTime.day)}/${_twoDigits(dateTime.month)}/${dateTime.year} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  String statusLabel(String status) {
    return switch (status) {
      'pending' => 'รอร้านรับออเดอร์',
      'accepted' => 'ร้านรับออเดอร์แล้ว',
      'preparing' => 'กำลังเตรียมสินค้า',
      'ready' => 'พร้อมให้มารับ',
      'completed' => 'รับสินค้าแล้ว',
      'cancelled' => 'ยกเลิกแล้ว',
      _ => status,
    };
  }

  String paymentStatusLabel(String status) {
    return switch (status) {
      'unpaid' => 'ยังไม่ชำระเงิน',
      'waiting_verify' => 'รอร้านตรวจสลิป',
      'paid' => 'ชำระเงินแล้ว',
      'rejected' => 'สลิปไม่ผ่าน',
      _ => status,
    };
  }

  bool canUploadPaymentSlip(OrderModel order) {
    return order.paymentStatus == 'unpaid' || order.paymentStatus == 'rejected';
  }

  Future<void> uploadPaymentSlip(OrderModel order) async {
    if (uploadingPaymentOrderId.value.isNotEmpty ||
        !canUploadPaymentSlip(order)) {
      return;
    }

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        imageQuality: 70,
      );
      if (image == null) {
        return;
      }

      uploadingPaymentOrderId.value = order.id;
      final List<int> bytes = await image.readAsBytes();
      final String slipBase64 = base64Encode(bytes);

      await _firestore.collection('orders').doc(order.id).update({
        'paymentSlipBase64': slipBase64,
        'paymentStatus': 'waiting_verify',
        'paymentSlipUploadedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'ส่งสลิปแล้ว',
        'ร้านจะตรวจสอบการชำระเงินของออเดอร์ ${order.orderNo}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (_) {
      Get.snackbar(
        'อัปโหลดสลิปไม่สำเร็จ',
        'กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      uploadingPaymentOrderId.value = '';
    }
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');
}
