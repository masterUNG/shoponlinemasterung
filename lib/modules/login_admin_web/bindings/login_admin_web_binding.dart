import 'package:get/get.dart';

import '../controllers/login_admin_web_controller.dart';

class LoginAdminWebBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginAdminWebController>(LoginAdminWebController.new);
  }
}
