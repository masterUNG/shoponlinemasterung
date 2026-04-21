import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../cart/views/cart_view.dart';
import '../../mall/views/mall_view.dart';
import '../../order/views/order_view.dart';
import '../../profile/views/profile_view.dart';
import '../controllers/main_home_controller.dart';

class MainHomeView extends GetView<MainHomeController> {
  const MainHomeView({super.key});

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
          title: const Text('Main Home'),
          actions: [
            IconButton(
              onPressed: controller.signOut,
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
