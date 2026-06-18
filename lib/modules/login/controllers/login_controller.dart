import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../model/app_user_model.dart';
import '../../../services/reviewer_mode_service.dart';

class LoginController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();

  final isLoading = false.obs;
  final registerBase64Avatar = ''.obs;
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  final registerDisplayNameController = TextEditingController();
  final registerPhoneController = TextEditingController();
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  ReviewerModeService get _reviewerMode => Get.find<ReviewerModeService>();

  @override
  void onReady() {
    super.onReady();
    if (_firebaseAuth.currentUser != null) {
      Get.offAllNamed(Routes.mainHome);
    }
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerDisplayNameController.dispose();
    registerPhoneController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    super.onClose();
  }

  Future<void> loginWithEmailPassword() async {
    if (isLoading.value) {
      return;
    }

    final String email = loginEmailController.text.trim();
    final String password = loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'กรอกข้อมูลไม่ครบ',
        'กรุณากรอก email และ password ให้ครบถ้วน',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;

    try {
      final UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'missing-firebase-user',
          message: 'Firebase did not return the signed-in user.',
        );
      }

      await _createUserDocumentIfMissing(user);
      _reviewerMode.leaveGuestReviewerMode();

      final String displayName = user.displayName ?? user.email ?? 'Customer';

      Get.offAllNamed(Routes.mainHome);
      Get.snackbar(
        'เข้าสู่ระบบสำเร็จ',
        'ยินดีต้อนรับ, $displayName',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (error) {
      Get.snackbar(
        'เข้าสู่ระบบไม่สำเร็จ',
        _firebaseAuthMessage(error),
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

  Future<void> pickRegisterAvatar() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 72,
      maxWidth: 600,
    );

    if (image == null) {
      return;
    }

    final bytes = await image.readAsBytes();
    registerBase64Avatar.value = base64Encode(bytes);
  }

  void clearRegisterForm() {
    registerDisplayNameController.clear();
    registerPhoneController.clear();
    registerEmailController.clear();
    registerPasswordController.clear();
    registerBase64Avatar.value = '';
  }

  Future<void> registerWithEmailPassword() async {
    if (isLoading.value) {
      return;
    }

    final String displayName = registerDisplayNameController.text.trim();
    final String phone = registerPhoneController.text.trim();
    final String email = registerEmailController.text.trim();
    final String password = registerPasswordController.text;

    if (displayName.isEmpty ||
        phone.isEmpty ||
        registerBase64Avatar.value.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      Get.snackbar(
        'กรอกข้อมูลไม่ครบ',
        'กรุณากรอก display name, เบอร์โทร, avatar, email และ password ให้ครบถ้วน',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    if (!_isValidPhone(phone)) {
      Get.snackbar(
        'เบอร์โทรไม่ถูกต้อง',
        'กรุณากรอกเบอร์โทรอย่างน้อย 8 หลัก เพื่อให้ร้านติดต่อเรื่องออเดอร์ได้',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    isLoading.value = true;

    try {
      final UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      final User? user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'missing-firebase-user',
          message: 'Firebase did not return the registered user.',
        );
      }

      await user.updateDisplayName(displayName);
      await _createUserDocumentIfMissing(
        user,
        displayName: displayName,
        base64Avatar: registerBase64Avatar.value,
        phone: phone,
      );
      _reviewerMode.leaveGuestReviewerMode();

      Get.back();
      Get.offAllNamed(Routes.mainHome);
      Get.snackbar(
        'สมัครสมาชิกสำเร็จ',
        'ยินดีต้อนรับ, $displayName',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (error) {
      Get.snackbar(
        'สมัครสมาชิกไม่สำเร็จ',
        _firebaseAuthMessage(error),
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'สมัครสมาชิกไม่สำเร็จ',
        'เกิดข้อผิดพลาดบางอย่าง กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> enterGuestReviewerMode() async {
    final bool? accepted = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Guest reviewer mode'),
        content: const Text(
          'โหมดนี้เปิดให้ทีมรีวิวดูสินค้า ดูรายละเอียดสินค้า และทดลองใส่ตะกร้าด้วยข้อมูลตัวอย่าง โดยไม่สร้างออเดอร์จริง ไม่ชำระเงินจริง และไม่บันทึกข้อมูลลงบัญชีผู้ใช้',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('เข้าโหมดรีวิว'),
          ),
        ],
      ),
    );

    if (accepted != true) {
      return;
    }

    _reviewerMode.enterGuestReviewerMode();
    Get.offAllNamed(Routes.mainHome);
  }

  Future<void> _createUserDocumentIfMissing(
    User user, {
    String? displayName,
    String? base64Avatar,
    String? phone,
  }) async {
    final DocumentReference<Map<String, dynamic>> userDocument = _firestore
        .collection('users')
        .doc(user.uid);
    final DocumentSnapshot<Map<String, dynamic>> existingUser =
        await userDocument.get();

    if (existingUser.exists) {
      return;
    }

    final AppUserModel appUser = AppUserModel(
      displayName: displayName ?? user.displayName ?? user.email ?? 'Customer',
      base64Avatar: base64Avatar ?? '',
      uid: user.uid,
      phone: phone ?? '',
    );

    await userDocument.set(appUser.toMap());
  }

  bool _isValidPhone(String phone) {
    final String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return digits.length >= 8 && digits.length <= 15;
  }

  String _firebaseAuthMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'รูปแบบ email ไม่ถูกต้อง';
      case 'user-disabled':
        return 'บัญชีนี้ถูกระงับการใช้งาน';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'email หรือ password ไม่ถูกต้อง';
      case 'email-already-in-use':
        return 'email นี้ถูกใช้งานแล้ว';
      case 'weak-password':
        return 'password ต้องมีความปลอดภัยมากกว่านี้';
      case 'operation-not-allowed':
        return 'ระบบยังไม่ได้เปิดใช้งาน email/password sign-in';
      default:
        return error.message ?? 'กรุณาลองใหม่อีกครั้ง';
    }
  }
}
