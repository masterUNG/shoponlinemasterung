import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';

class MainHomeWebController extends GetxController {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    Get.offAllNamed(Routes.loginAdminWeb);
  }

  String get displayName {
    final User? user = currentUser;
    if (user == null) {
      return 'Admin';
    }

    return user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email ?? 'Admin';
  }

  String get platformLabel => kIsWeb ? 'Flutter Web' : 'Flutter';
}
