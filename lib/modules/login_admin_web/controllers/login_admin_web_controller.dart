import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

class LoginAdminWebController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final obscurePassword = true.obs;

  @override
  void onReady() {
    super.onReady();
    if (_firebaseAuth.currentUser != null) {
      Get.offAllNamed(Routes.mainHomeWeb);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  String? validateEmail(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'กรุณากรอกอีเมล';
    }

    if (!GetUtils.isEmail(text)) {
      return 'รูปแบบอีเมลไม่ถูกต้อง';
    }

    return null;
  }

  String? validatePassword(String? value) {
    final String text = value?.trim() ?? '';

    if (text.isEmpty) {
      return 'กรุณากรอกรหัสผ่าน';
    }

    if (text.length < 6) {
      return 'รหัสผ่านต้องมีอย่างน้อย 6 อักษร';
    }

    return null;
  }

  Future<void> signInWithEmailPassword() async {
    if (isLoading.value) {
      return;
    }

    final FormState? formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    isLoading.value = true;

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      Get.offAllNamed(Routes.mainHomeWeb);
      Get.snackbar(
        'เข้าสู่ระบบสำเร็จ',
        'ยินดีต้อนรับเข้าสู่ระบบผู้ดูแล',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (error) {
      Get.snackbar(
        'เข้าสู่ระบบไม่สำเร็จ',
        _firebaseErrorMessage(error),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'เข้าสู่ระบบไม่สำเร็จ',
        'เกิดข้อผิดพลาดบางอย่าง กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  String _firebaseErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'อีเมลไม่ถูกต้อง';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
      case 'user-disabled':
        return 'บัญชีนี้ถูกปิดการใช้งาน';
      case 'too-many-requests':
        return 'มีการพยายามเข้าสู่ระบบหลายครั้งเกินไป กรุณาลองใหม่ภายหลัง';
      case 'network-request-failed':
        return 'การเชื่อมต่อเครือข่ายมีปัญหา';
      default:
        return error.message ?? 'ไม่สามารถเข้าสู่ระบบได้ในขณะนี้';
    }
  }
}
