import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../model/app_user_model.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final userData = Rxn<AppUserModel>();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;

  @override
  void onInit() {
    super.onInit();
    _listenToCurrentUserProfile();
  }

  @override
  void onClose() {
    _userSubscription?.cancel();
    super.onClose();
  }

  User? get currentUser => _firebaseAuth.currentUser;

  Uint8List? get avatarBytes {
    final String base64Avatar = userData.value?.base64Avatar.trim() ?? '';
    if (base64Avatar.isEmpty) {
      return null;
    }

    try {
      final String normalizedBase64 = base64Avatar.contains(',')
          ? base64Avatar.split(',').last
          : base64Avatar;
      return base64Decode(normalizedBase64);
    } catch (_) {
      return null;
    }
  }

  Future<void> reloadProfile() async {
    _userSubscription?.cancel();
    _listenToCurrentUserProfile();
  }

  void _listenToCurrentUserProfile() {
    final User? user = currentUser;
    if (user == null) {
      isLoading.value = false;
      errorMessage.value = 'ยังไม่พบผู้ใช้ที่ล็อกอินอยู่';
      userData.value = null;
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    _userSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
          (DocumentSnapshot<Map<String, dynamic>> snapshot) {
            if (!snapshot.exists || snapshot.data() == null) {
              userData.value = null;
              errorMessage.value = 'ไม่พบข้อมูลผู้ใช้ในระบบ';
            } else {
              userData.value = AppUserModel.fromMap(snapshot.data()!);
              errorMessage.value = '';
            }

            isLoading.value = false;
          },
          onError: (_) {
            userData.value = null;
            errorMessage.value = 'โหลดข้อมูลโปรไฟล์ไม่สำเร็จ';
            isLoading.value = false;
          },
        );
  }
}
