import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../cart/views/cart_view.dart';
import '../../mall/views/mall_view.dart';
import '../../order/views/order_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/main_home_controller.dart';

class MainHomeView extends GetView<MainHomeController> {
  const MainHomeView({super.key});

  Future<void> _confirmSignOut() async {
    final bool? confirmed = await Get.dialog<bool>(
      AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('images/logo.png', width: 96, height: 96),
            const SizedBox(height: 16),
            const Text(
              'ยืนยันการออกจากระบบ',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'คุณต้องการออกจากระบบใช่หรือไม่?',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('ออกจากระบบ'),
          ),
        ],
      ),
      barrierDismissible: true,
    );

    if (confirmed == true) {
      await controller.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bodyList = [
      const MallView(),
      const CartView(),
      const OrderView(),
      const ProfileView(),
    ];

    return Obx(
      () => Scaffold(
        appBar: AppBar(
          title: Text(
            controller.isGuestReviewer ? 'Guest reviewer mode' : 'Main Home',
          ),
          actions: [
            IconButton(
              onPressed: _confirmSignOut,
              tooltip: 'Sign out',
              icon: const Icon(Icons.logout_rounded),
            ),
          ],
        ),
        body: bodyList[controller.indexBody.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.indexBody.value,
          onTap: controller.changeIndexBody,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_rounded),
              label: 'Mall',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart_rounded),
              label: 'Cart',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_rounded),
              label: 'Order',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
