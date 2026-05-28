import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoponlinemasterung/core/app_constant.dart';
import 'package:get/get.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  void _showRegisterSheet(BuildContext context) {
    controller.clearRegisterForm();

    Get.bottomSheet(
      _RegisterBottomSheet(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstant.appColorDark,
              AppConstant.appColor,
              AppConstant.appColorSurface,
            ],
            stops: [0.0, 0.42, 1.0],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: const Text(
                              'UNG SHOP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const _LogoHeroCard(),
                        const SizedBox(height: 24),
                        Text(
                          'Ung Shop',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'ช้อปง่าย ส่งไว ครบจบในที่เดียว',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _InfoChip(
                              icon: Icons.storefront_rounded,
                              label: 'ร้านค้าออนไลน์',
                            ),
                            _InfoChip(
                              icon: Icons.local_shipping_rounded,
                              label: 'ติดตามออเดอร์',
                            ),
                            _InfoChip(
                              icon: Icons.payments_rounded,
                              label: 'ชำระเงินสะดวก',
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: 28),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppConstant.appColorDark.withValues(
                                  alpha: 0.18,
                                ),
                                blurRadius: 28,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'เริ่มต้นใช้งาน',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: AppConstant.appColorDark,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'เข้าสู่ระบบด้วย email และ password เพื่อเลือกซื้อสินค้า ติดตามคำสั่งซื้อ และรับประสบการณ์ร้านค้าออนไลน์ที่สะดวกขึ้น',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 18),
                              _AuthTextField(
                                controller: controller.loginEmailController,
                                label: 'Email',
                                icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 12),
                              _AuthTextField(
                                controller: controller.loginPasswordController,
                                label: 'Password',
                                icon: Icons.lock_rounded,
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),
                              Obx(
                                () => SizedBox(
                                  height: 58,
                                  child: FilledButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : controller.loginWithEmailPassword,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppConstant.appColorDark,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(18),
                                      ),
                                    ),
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.6,
                                            ),
                                          )
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.login_rounded),
                                              SizedBox(width: 10),
                                              Text(
                                                'เข้าสู่ระบบ',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _showRegisterSheet(context),
                                child: const Text('ยังไม่มีบัญชี? สมัครสมาชิก'),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: controller.enterGuestReviewerMode,
                                child: const Text('Guest reviewer mode'),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'เมื่อเข้าสู่ระบบสำเร็จ แอพจะพาไปหน้าหลักอัตโนมัติ',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _LogoHeroCard extends StatelessWidget {
  const _LogoHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppConstant.appColorDeep.withValues(alpha: 0.16),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppConstant.appColorLight,
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFFFE6C7),
                borderRadius: BorderRadius.circular(30),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppConstant.appColorSurface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: AppConstant.appColorBorder),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    size: 16,
                    color: AppConstant.appColor,
                  ),
                  SizedBox(width: 6),
                  Text(
                    'Official Store',
                    style: TextStyle(
                      color: AppConstant.appColorDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppConstant.appColorDeep.withValues(alpha: 0.12),
                      blurRadius: 28,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Image.asset('images/logo.png', fit: BoxFit.contain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: obscureText
          ? TextInputAction.done
          : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
        ),
      ),
    );
  }
}

class _RegisterBottomSheet extends StatelessWidget {
  const _RegisterBottomSheet({required this.controller});

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'สมัครสมาชิกใหม่',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: AppConstant.appColorDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: Obx(() {
                    final String base64Avatar =
                        controller.registerBase64Avatar.value;
                    return InkWell(
                      onTap: controller.pickRegisterAvatar,
                      borderRadius: BorderRadius.circular(52),
                      child: CircleAvatar(
                        radius: 48,
                        backgroundColor: AppConstant.appColorSurface,
                        backgroundImage: base64Avatar.isEmpty
                            ? null
                            : MemoryImage(base64Decode(base64Avatar)),
                        child: base64Avatar.isEmpty
                            ? const Icon(
                                Icons.add_a_photo_rounded,
                                color: AppConstant.appColorDark,
                                size: 32,
                              )
                            : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: controller.pickRegisterAvatar,
                  icon: const Icon(Icons.image_rounded),
                  label: const Text('เลือก image Avatar'),
                ),
                const SizedBox(height: 12),
                _AuthTextField(
                  controller: controller.registerDisplayNameController,
                  label: 'Display Name',
                  icon: Icons.badge_rounded,
                ),
                const SizedBox(height: 12),
                _AuthTextField(
                  controller: controller.registerEmailController,
                  label: 'Email',
                  icon: Icons.alternate_email_rounded,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _AuthTextField(
                  controller: controller.registerPasswordController,
                  label: 'Password',
                  icon: Icons.lock_rounded,
                  obscureText: true,
                ),
                const SizedBox(height: 18),
                Obx(
                  () => SizedBox(
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: controller.isLoading.value
                          ? null
                          : controller.registerWithEmailPassword,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppConstant.appColorDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: controller.isLoading.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.person_add_rounded),
                      label: const Text(
                        'สมัครสมาชิก',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
