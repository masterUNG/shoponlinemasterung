import 'package:get/get.dart';

import '../../modules/login/bindings/login_binding.dart';
import '../../modules/login/views/login_view.dart';
import '../../modules/login_admin_web/bindings/login_admin_web_binding.dart';
import '../../modules/login_admin_web/views/login_admin_web_view.dart';
import '../../modules/main_home/bindings/main_home_binding.dart';
import '../../modules/main_home/views/main_home_view.dart';
import '../../modules/main_home_web/bindings/main_home_web_binding.dart';
import '../../modules/main_home_web/views/main_home_web_view.dart';
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
    GetPage<LoginAdminWebView>(
      name: Routes.loginAdminWeb,
      page: LoginAdminWebView.new,
      binding: LoginAdminWebBinding(),
    ),
    GetPage<MainHomeView>(
      name: Routes.mainHome,
      page: MainHomeView.new,
      binding: MainHomeBinding(),
    ),
    GetPage<MainHomeWebView>(
      name: Routes.mainHomeWeb,
      page: MainHomeWebView.new,
      binding: MainHomeWebBinding(),
    ),
  ];
}
