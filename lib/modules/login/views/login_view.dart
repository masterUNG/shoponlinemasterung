import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ms_undraw/ms_undraw.dart';

import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF243B8F), Color(0xFF4C63D2), Color(0xFFF3F5FF)],
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
                              'ช้อปออนไลน์',
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
                        const _HeroIllustrationCard(),
                        const SizedBox(height: 24),
                        Text(
                          'ช้อปง่าย ขายคล่อง ในแอพเดียว',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'เข้าสู่ระบบด้วย Google เพื่อดูสินค้าใหม่ ๆ จัดการคำสั่งซื้อ และเริ่มซื้อขายออนไลน์ได้ทันที',
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
                                color: const Color(
                                  0xFF1E2A78,
                                ).withValues(alpha: 0.18),
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
                                  color: const Color(0xFF1F2F78),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ระบบเดิมของคุณยังทำงานเหมือนเดิม เราปรับเฉพาะหน้าตาให้ใช้งานง่ายและดูเป็นมิตรมากขึ้น',
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Obx(
                                () => SizedBox(
                                  height: 58,
                                  child: FilledButton(
                                    onPressed: controller.isLoading.value
                                        ? null
                                        : controller.loginWithGoogle,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF1F2F78),
                                      elevation: 0,
                                      side: BorderSide(
                                        color: theme.colorScheme.outlineVariant,
                                      ),
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
                                              _GoogleBadge(),
                                              SizedBox(width: 12),
                                              Text(
                                                'เข้าสู่ระบบด้วย Google',
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

class _HeroIllustrationCard extends StatelessWidget {
  const _HeroIllustrationCard();

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
            color: const Color(0xFF101B5B).withValues(alpha: 0.16),
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
                color: const Color(0xFFE2E8FF),
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
            child: Padding(
              padding: EdgeInsets.all(8),
              child: UnDraw(
                illustration: UnDrawIllustration.shopping_app,
                color: Color(0xFF3F51B5),
                placeholder: Center(child: CircularProgressIndicator()),
                errorWidget: Icon(
                  Icons.storefront_rounded,
                  size: 96,
                  color: Color(0xFF3F51B5),
                ),
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

class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Text(
        'G',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          color: Colors.red.shade700,
        ),
      ),
    );
  }
}
