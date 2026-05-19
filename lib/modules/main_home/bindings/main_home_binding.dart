import 'package:get/get.dart';

import '../../../services/reviewer_mode_service.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../mall/controllers/mall_controller.dart';
import '../../order/controllers/order_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../controllers/main_home_controller.dart';

class MainHomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReviewerModeService>()) {
      Get.put<ReviewerModeService>(ReviewerModeService(), permanent: true);
    }
    Get.lazyPut<MainHomeController>(MainHomeController.new);
    Get.lazyPut<MallController>(MallController.new);
    Get.lazyPut<CartController>(CartController.new);
    Get.lazyPut<OrderController>(OrderController.new);
    Get.lazyPut<ProfileController>(ProfileController.new);
  }
}
