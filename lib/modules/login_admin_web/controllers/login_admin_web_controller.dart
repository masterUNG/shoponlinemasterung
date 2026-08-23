import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/app_snackbar.dart';
import '../../../services/admin_role_service.dart';

class LoginAdminWebController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final AdminRoleService _adminRoleService = AdminRoleService();

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isCheckingAdminRole = false.obs;
  final obscurePassword = true.obs;

  @override
  void onReady() {
    super.onReady();
    _redirectSignedInAdmin();
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

      isCheckingAdminRole.value = true;
      final bool isAdmin = await _adminRoleService.currentUserIsAdmin();
      if (!isAdmin) {
        await _firebaseAuth.signOut();
        AppSnackbar.error(
          'ไม่มีสิทธิ์ผู้ดูแล',
          'บัญชีนี้ยังไม่ได้รับ role admin ใน Firestore',
        );
        return;
      }

      Get.offAllNamed(Routes.mainHomeWeb);
      Get.snackbar(
        'เข้าสู่ระบบสำเร็จ',
        'ยินดีต้อนรับเข้าสู่ระบบผู้ดูแล',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (error) {
      AppSnackbar.error('เข้าสู่ระบบไม่สำเร็จ', _firebaseErrorMessage(error));
    } on FirebaseException {
      AppSnackbar.error(
        'ตรวจสอบสิทธิ์ผู้ดูแลไม่สำเร็จ',
        'เข้าสู่ระบบได้แล้ว แต่ยังอ่าน role admin จาก Firestore ไม่สำเร็จ กรุณาตรวจสอบเครือข่ายแล้วลองใหม่',
      );
    } catch (_) {
      AppSnackbar.error(
        'เข้าสู่ระบบไม่สำเร็จ',
        'เกิดข้อผิดพลาดบางอย่าง กรุณาลองใหม่อีกครั้ง',
      );
    } finally {
      isLoading.value = false;
      isCheckingAdminRole.value = false;
    }
  }

  Future<void> sendPasswordResetEmail() async {
    if (isLoading.value) {
      return;
    }

    final String email = emailController.text.trim();
    final String? validationMessage = validateEmail(email);
    if (validationMessage != null) {
      AppSnackbar.error('กรุณากรอกอีเมล', validationMessage);
      return;
    }

    isLoading.value = true;

    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'ส่งอีเมลรีเซ็ตรหัสผ่านแล้ว',
        'กรุณาตรวจสอบ inbox ของ $email',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (error) {
      AppSnackbar.error('ส่งอีเมลไม่สำเร็จ', _firebaseErrorMessage(error));
    } catch (_) {
      AppSnackbar.error(
        'ส่งอีเมลไม่สำเร็จ',
        'เกิดข้อผิดพลาดบางอย่าง กรุณาลองใหม่อีกครั้ง',
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

  Future<void> _redirectSignedInAdmin() async {
    if (_firebaseAuth.currentUser == null) {
      return;
    }

    isCheckingAdminRole.value = true;
    try {
      final bool isAdmin = await _adminRoleService.currentUserIsAdmin();
      if (isAdmin) {
        Get.offAllNamed(Routes.mainHomeWeb);
      } else {
        await _firebaseAuth.signOut();
      }
    } on FirebaseException {
      AppSnackbar.error(
        'ตรวจสอบสิทธิ์ผู้ดูแลไม่สำเร็จ',
        'ยังอ่าน role admin จาก Firestore ไม่สำเร็จ กรุณาลองเข้าสู่ระบบใหม่',
      );
    } finally {
      isCheckingAdminRole.value = false;
    }
  }
}
