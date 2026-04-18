import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.toggle();
  }

  Future<void> login() async {
    FocusManager.instance.primaryFocus?.unfocus();
    isLoading.value = true;

    await Future<void>.delayed(const Duration(seconds: 1));

    isLoading.value = false;

    Get.snackbar(
      'Login Success',
      'Welcome back, ${emailController.text.isEmpty ? 'user' : emailController.text}',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
