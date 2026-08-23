import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  AppSnackbar._();

  static const Duration errorDuration = Duration(seconds: 10);
  static const Color errorBackgroundColor = Color(0xFFB42318);

  static void error(
    String title,
    String message, {
    SnackPosition snackPosition = SnackPosition.BOTTOM,
    EdgeInsets margin = const EdgeInsets.all(16),
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: snackPosition,
      duration: errorDuration,
      backgroundColor: errorBackgroundColor,
      colorText: Colors.white,
      margin: margin,
    );
  }

  static SnackBar errorSnackBar(String message) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: errorBackgroundColor,
      duration: errorDuration,
    );
  }
}
