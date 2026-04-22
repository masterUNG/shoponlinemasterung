import 'package:get/get.dart';

import '../controllers/main_home_web_controller.dart';

class MainHomeWebBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainHomeWebController>(MainHomeWebController.new);
  }
}
