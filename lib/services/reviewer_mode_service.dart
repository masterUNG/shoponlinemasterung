import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../app/routes/app_routes.dart';

class ReviewerModeService extends GetxService {
  final RxBool isGuestReviewer = false.obs;
  final RxList<Map<String, dynamic>> demoCartItems =
      <Map<String, dynamic>>[].obs;

  bool get isGuest => isGuestReviewer.value;

  void enterGuestReviewerMode() {
    isGuestReviewer.value = true;
  }

  void leaveGuestReviewerMode() {
    isGuestReviewer.value = false;
    demoCartItems.clear();
  }

  void addDemoCartItem({
    required String productId,
    required Map<String, dynamic> productData,
    required int quantity,
  }) {
    final int existingIndex = demoCartItems.indexWhere(
      (item) => item['productId'] == productId,
    );
    final int stock = ((productData['stock'] ?? 0) as num).toInt();

    if (existingIndex == -1) {
      demoCartItems.add(<String, dynamic>{
        'productId': productId,
        ...productData,
        'quantity': quantity.clamp(1, stock),
      });
      return;
    }

    final Map<String, dynamic> existing = Map<String, dynamic>.from(
      demoCartItems[existingIndex],
    );
    final int currentQuantity = ((existing['quantity'] ?? 0) as num).toInt();
    existing['quantity'] = (currentQuantity + quantity).clamp(1, stock);
    demoCartItems[existingIndex] = existing;
  }

  void updateDemoCartQuantity(String productId, int quantity) {
    final int existingIndex = demoCartItems.indexWhere(
      (item) => item['productId'] == productId,
    );
    if (existingIndex == -1 || quantity < 1) {
      return;
    }

    final Map<String, dynamic> existing = Map<String, dynamic>.from(
      demoCartItems[existingIndex],
    );
    final int stock = ((existing['stock'] ?? 1) as num).toInt();
    existing['quantity'] = quantity.clamp(1, stock);
    demoCartItems[existingIndex] = existing;
  }

  void deleteDemoCartItem(String productId) {
    demoCartItems.removeWhere((item) => item['productId'] == productId);
  }

  Future<void> showLoginRequiredDialog({
    String title = 'ต้องเข้าสู่ระบบก่อน',
    String message =
        'โหมด Guest reviewer ใช้สำหรับดูตัวอย่างร้านและทดลองตะกร้าด้วยข้อมูลตัวอย่างเท่านั้น กรุณาเข้าสู่ระบบเพื่อใช้งานส่วนบัญชี ออเดอร์จริง หรือการชำระเงินจริง',
  }) async {
    final bool? goToLogin = await Get.dialog<bool>(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('ดูต่อ'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('ไปหน้า Login'),
          ),
        ],
      ),
    );

    if (goToLogin == true) {
      leaveGuestReviewerMode();
      Get.offAllNamed(Routes.login);
    }
  }
}
