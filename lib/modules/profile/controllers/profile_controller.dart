import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../model/app_user_model.dart';
import '../../../services/reviewer_mode_service.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  ReviewerModeService get _reviewerMode => Get.find<ReviewerModeService>();

  final isLoading = true.obs;
  final errorMessage = ''.obs;
  final isSavingLocation = false.obs;
  final isDeletingAccount = false.obs;
  final userData = Rxn<AppUserModel>();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;
  bool _isLocationDialogOpen = false;
  bool _askedLocationForCurrentProfileVisit = false;

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
    if (_reviewerMode.isGuest) {
      _listenToCurrentUserProfile();
      return;
    }

    _userSubscription?.cancel();
    _listenToCurrentUserProfile();
  }

  void onProfileOpened() {
    if (_reviewerMode.isGuest) {
      _reviewerMode.showLoginRequiredDialog(
        title: 'ต้องเข้าสู่ระบบก่อนดู Profile',
        message:
            'Guest reviewer mode สามารถดูสินค้าและทดลองตะกร้าด้วยข้อมูลตัวอย่างได้ แต่ Profile เป็นข้อมูลบัญชีส่วนตัว กรุณาเข้าสู่ระบบเพื่อดูโปรไฟล์',
      );
      return;
    }

    _askedLocationForCurrentProfileVisit = false;
    _askLocationIfNeeded();
  }

  void _listenToCurrentUserProfile() {
    if (_reviewerMode.isGuest) {
      isLoading.value = false;
      errorMessage.value = 'ต้องเข้าสู่ระบบก่อนดูโปรไฟล์';
      userData.value = null;
      return;
    }

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
            _askLocationIfNeeded();
          },
          onError: (_) {
            userData.value = null;
            errorMessage.value = 'โหลดข้อมูลโปรไฟล์ไม่สำเร็จ';
            isLoading.value = false;
          },
        );
  }

  Future<void> _askLocationIfNeeded() async {
    final AppUserModel? appUser = userData.value;
    final User? user = currentUser;
    if (appUser == null ||
        user == null ||
        appUser.geopoint != null ||
        isLoading.value ||
        isSavingLocation.value ||
        _isLocationDialogOpen ||
        _askedLocationForCurrentProfileVisit) {
      return;
    }

    _askedLocationForCurrentProfileVisit = true;
    _isLocationDialogOpen = true;
    final bool accepted =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text('เปิดใช้ตำแหน่งจัดส่ง'),
            content: const Text(
              'แอปจะใช้พิกัดของคุณเพื่อช่วยคำนวณและเตรียมบริการส่งสินค้าให้ถึงที่ หากไม่บันทึกพิกัด ตอนสั่งซื้อจะไม่มีตัวเลือกส่งสินค้า',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('ไว้ก่อน'),
              ),
              FilledButton(
                onPressed: () => Get.back(result: true),
                child: const Text('อนุญาต'),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;
    _isLocationDialogOpen = false;

    if (!accepted) {
      return;
    }

    await _saveCurrentLocation(user.uid);
  }

  Future<void> _saveCurrentLocation(String uid) async {
    try {
      isSavingLocation.value = true;

      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'ยังไม่ได้เปิด Location',
          'กรุณาเปิด Location Service บนอุปกรณ์ก่อนใช้งานบริการส่งสินค้า',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'ไม่ได้รับสิทธิ์ตำแหน่ง',
          'คุณสามารถเปิดสิทธิ์ตำแหน่งภายหลังได้จากหน้า Settings ของเครื่อง',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      await _firestore.collection('users').doc(uid).update(<String, dynamic>{
        'geopoint': GeoPoint(position.latitude, position.longitude),
      });

      Get.snackbar(
        'บันทึกพิกัดแล้ว',
        'ตอนสั่งซื้อจะสามารถใช้ตัวเลือกส่งสินค้าได้',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'บันทึกพิกัดไม่สำเร็จ',
        'กรุณาลองใหม่อีกครั้งเมื่ออุปกรณ์พร้อมใช้งาน Location',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isSavingLocation.value = false;
    }
  }

  Future<void> confirmDeleteAccount() async {
    if (isDeletingAccount.value) {
      return;
    }

    final bool confirmed =
        await Get.dialog<bool>(
          AlertDialog(
            title: const Text('Delete Account'),
            content: const Text(
              'คุณต้องการลบ account นี้จริงหรือไม่? หลังจากยืนยันแล้ว บัญชีและข้อมูลโปรไฟล์จะถูกลบออกจากระบบ',
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: const Text('ยกเลิก'),
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('ยืนยันลบ'),
              ),
            ],
          ),
          barrierDismissible: false,
        ) ??
        false;

    if (!confirmed) {
      return;
    }

    await _deleteAccount();
  }

  Future<void> _deleteAccount() async {
    final User? user = currentUser;
    if (user == null) {
      Get.snackbar(
        'ลบบัญชีไม่สำเร็จ',
        'กรุณาเข้าสู่ระบบอีกครั้งก่อนลบบัญชี',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    try {
      isDeletingAccount.value = true;
      await _userSubscription?.cancel();

      final CollectionReference<Map<String, dynamic>> cartCollection =
          _firestore.collection('users').doc(user.uid).collection('cart');
      final QuerySnapshot<Map<String, dynamic>> cartSnapshot =
          await cartCollection.get();

      WriteBatch batch = _firestore.batch();
      int batchOperations = 0;
      for (final QueryDocumentSnapshot<Map<String, dynamic>> cartDocument
          in cartSnapshot.docs) {
        batch.delete(cartDocument.reference);
        batchOperations += 1;

        if (batchOperations == 450) {
          await batch.commit();
          batch = _firestore.batch();
          batchOperations = 0;
        }
      }

      batch.delete(_firestore.collection('users').doc(user.uid));
      await batch.commit();

      await user.delete();

      Get.offAllNamed(Routes.login);
      Get.snackbar(
        'ลบบัญชีสำเร็จ',
        'บัญชีของคุณถูกลบออกจากระบบแล้ว',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on FirebaseAuthException catch (error) {
      if (error.code == 'requires-recent-login') {
        Get.snackbar(
          'กรุณาเข้าสู่ระบบใหม่',
          'เพื่อความปลอดภัย กรุณา logout แล้ว login ใหม่ก่อนลบบัญชี',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      } else {
        Get.snackbar(
          'ลบบัญชีไม่สำเร็จ',
          error.message ?? 'กรุณาลองใหม่อีกครั้ง',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
      _listenToCurrentUserProfile();
    } catch (_) {
      Get.snackbar(
        'ลบบัญชีไม่สำเร็จ',
        'เกิดข้อผิดพลาดบางอย่าง กรุณาลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      _listenToCurrentUserProfile();
    } finally {
      isDeletingAccount.value = false;
    }
  }
}
