import 'package:get/get.dart';

import '../../../services/reviewer_mode_service.dart';
import '../controllers/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ReviewerModeService>()) {
      Get.put<ReviewerModeService>(ReviewerModeService(), permanent: true);
    }
    Get.lazyPut<LoginController>(LoginController.new);
  }
}
