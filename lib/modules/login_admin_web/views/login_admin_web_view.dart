import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/login_admin_web_controller.dart';

class LoginAdminWebView extends GetView<LoginAdminWebController> {
  const LoginAdminWebView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'login_admin_web',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
