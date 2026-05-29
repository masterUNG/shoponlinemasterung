import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.errorMessage.value.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  controller.errorMessage.value,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: controller.reloadProfile,
                  child: const Text('โหลดใหม่'),
                ),
              ],
            ),
          ),
        );
      }

      final String displayName =
          controller.userData.value?.displayName.trim().isNotEmpty == true
          ? controller.userData.value!.displayName
          : 'ไม่ระบุชื่อผู้ใช้';
      final Uint8List? avatarBytes = controller.avatarBytes;

      return SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            children: [
              CircleAvatar(
                radius: 56,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: avatarBytes != null
                    ? MemoryImage(avatarBytes)
                    : null,
                child: avatarBytes == null
                    ? const Icon(Icons.person_rounded, size: 56)
                    : null,
              ),
              const SizedBox(height: 24),
              Text(
                displayName,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                controller.currentUser?.email ??
                    controller.userData.value?.uid ??
                    '',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              _LocationStatus(controller: controller),
              const SizedBox(height: 32),
              TextButton(
                onPressed: controller.isDeletingAccount.value
                    ? null
                    : controller.confirmDeleteAccount,
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: controller.isDeletingAccount.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Delete Account'),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _LocationStatus extends StatelessWidget {
  const _LocationStatus({required this.controller});

  final ProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool hasLocation = controller.userData.value?.geopoint != null;

      return ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        leading: Icon(
          hasLocation ? Icons.location_on_rounded : Icons.location_off_rounded,
          color: hasLocation ? Colors.green : Colors.orange,
        ),
        title: Text(
          hasLocation ? 'บันทึกพิกัดจัดส่งแล้ว' : 'ยังไม่ได้บันทึกพิกัดจัดส่ง',
        ),
        subtitle: Text(
          hasLocation
              ? 'มีตัวเลือกส่งสินค้าให้ใช้งานตอนสั่งซื้อ'
              : 'ถ้าไม่มีพิกัด จะไม่มีตัวเลือกส่งสินค้าในหน้า order',
        ),
        trailing: controller.isSavingLocation.value
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : null,
      );
    });
  }
}
