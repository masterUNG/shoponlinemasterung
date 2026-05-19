import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../app/routes/app_routes.dart';
import '../../../services/reviewer_mode_service.dart';
import '../../profile/controllers/profile_controller.dart';

class MainHomeController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final RxInt indexBody = 0.obs;
  ReviewerModeService get _reviewerMode => Get.find<ReviewerModeService>();

  User? get currentUser => _firebaseAuth.currentUser;
  bool get isGuestReviewer => _reviewerMode.isGuest;

  void changeIndexBody(int index) {
    if (isGuestReviewer && (index == 2 || index == 3)) {
      _reviewerMode.showLoginRequiredDialog(
        title: index == 2
            ? 'ต้องเข้าสู่ระบบก่อนดู Order'
            : 'ต้องเข้าสู่ระบบก่อนดู Profile',
        message: index == 2
            ? 'Guest reviewer mode สามารถดูสินค้าและทดลองตะกร้าด้วยข้อมูลตัวอย่างได้ แต่ประวัติออเดอร์เป็นข้อมูลส่วนตัว กรุณาเข้าสู่ระบบเพื่อดูออเดอร์จริง'
            : 'Guest reviewer mode สามารถดูสินค้าและทดลองตะกร้าด้วยข้อมูลตัวอย่างได้ แต่ Profile เป็นข้อมูลบัญชีส่วนตัว กรุณาเข้าสู่ระบบเพื่อดูโปรไฟล์',
      );
      return;
    }

    indexBody.value = index;
    if (index == 3 && Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().onProfileOpened();
    }
  }

  Future<void> signOut() async {
    _reviewerMode.leaveGuestReviewerMode();
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    Get.offAllNamed(Routes.login);
  }
}
