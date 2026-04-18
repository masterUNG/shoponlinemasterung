import 'package:get/get.dart';

import '../../modules/login/bindings/login_binding.dart';
import '../../modules/login/views/login_view.dart';
import 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.login;

  static final routes = <GetPage<dynamic>>[
    GetPage<LoginView>(
      name: Routes.login,
      page: LoginView.new,
      binding: LoginBinding(),
    ),
  ];
}
