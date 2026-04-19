import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../app/routes/app_routes.dart';

class LoginController extends GetxController {
  static const _serverClientId =
      '247194165705-2rdt0j6gkrsrpl3jr2huraknltu1gjk4.apps.googleusercontent.com';

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  final isLoading = false.obs;
  late final Future<void> _googleInitialization;

  @override
  void onInit() {
    super.onInit();
    _googleInitialization = _googleSignIn.initialize(
      serverClientId: _serverClientId,
    );
  }

  @override
  void onReady() {
    super.onReady();
    if (_firebaseAuth.currentUser != null) {
      Get.offAllNamed(Routes.mainHome);
    }
  }

  Future<void> loginWithGoogle() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;

    try {
      await _googleInitialization;

      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();
      final String? idToken = googleUser.authentication.idToken;

      if (idToken == null || idToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-google-id-token',
          message: 'Google Sign-In did not return an ID token.',
        );
      }

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: idToken,
      );

      final UserCredential userCredential = await _firebaseAuth
          .signInWithCredential(credential);
      final String displayName =
          userCredential.user?.displayName ??
          userCredential.user?.email ??
          'Google User';

      Get.offAllNamed(Routes.mainHome);
      Get.snackbar(
        'Login Success',
        'Welcome, $displayName',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } on GoogleSignInException catch (error) {
      if (error.code != GoogleSignInExceptionCode.canceled) {
        Get.snackbar(
          'Google Sign-In Failed',
          error.description ?? 'Unable to sign in with Google right now.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
      }
    } on FirebaseAuthException catch (error) {
      Get.snackbar(
        'Firebase Login Failed',
        error.message ?? 'Unable to connect your Google account.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'Login Failed',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
