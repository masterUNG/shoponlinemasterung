import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../app/routes/app_routes.dart';
import '../../profile/controllers/profile_controller.dart';

class MainHomeController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final RxInt indexBody = 0.obs;

  User? get currentUser => _firebaseAuth.currentUser;

  void changeIndexBody(int index) {
    indexBody.value = index;
    if (index == 3 && Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().onProfileOpened();
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
    Get.offAllNamed(Routes.login);
  }
}
