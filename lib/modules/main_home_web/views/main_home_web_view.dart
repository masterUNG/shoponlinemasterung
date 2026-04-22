import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_home_web_controller.dart';
import '../widgets/main_home_web_sections.dart';

class MainHomeWebView extends GetView<MainHomeWebController> {
  const MainHomeWebView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bool isDesktop = constraints.maxWidth >= 1180;
            final bool isTablet = constraints.maxWidth >= 820;

            if (isDesktop) {
              return Row(
                children: [
                  const SizedBox(width: 292, child: _SideBar()),
                  Expanded(
                    child: _DashboardContent(
                      theme: theme,
                      horizontalPadding: 32,
                      topPadding: 28,
                    ),
                  ),
                ],
              );
            }

            return _DashboardContent(
              theme: theme,
              horizontalPadding: isTablet ? 24 : 16,
              topPadding: isTablet ? 24 : 16,
              mobileHeader: const _CompactHeader(),
            );
          },
        ),
      ),
    );
  }
}

class _DashboardContent extends GetView<MainHomeWebController> {
  const _DashboardContent({
    required this.theme,
    required this.horizontalPadding,
    required this.topPadding,
    this.mobileHeader,
  });

  final ThemeData theme;
  final double horizontalPadding;
  final double topPadding;
  final Widget? mobileHeader;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          topPadding,
          horizontalPadding,
          24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (mobileHeader != null) ...[
                  mobileHeader!,
                  const SizedBox(height: 16),
                ],
                _TopBar(
                  theme: theme,
                  section: controller.selectedSection.value,
                ),
                const SizedBox(height: 18),
                _SectionSwitcher(theme: theme),
                const SizedBox(height: 24),
                MainHomeWebSectionContent(controller: controller),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SideBar extends GetView<MainHomeWebController> {
  const _SideBar();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      color: const Color(0xFF123B7A),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shop Admin',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Small store back office',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.74),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  controller.currentUser?.email ?? 'admin@shoponline.com',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB648),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'พร้อมจัดการสินค้าและออเดอร์',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: const Color(0xFF3F2A00),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
          Obx(
            () => Column(
              children: MainHomeWebSection.values
                  .expand(
                    (section) => <Widget>[
                      _MenuTile(
                        icon: _sectionIcon(section),
                        title: section.title,
                        subtitle: section.subtitle,
                        selected: controller.selectedSection.value == section,
                        onTap: () => controller.changeSection(section),
                      ),
                      if (section != MainHomeWebSection.values.last)
                        const SizedBox(height: 10),
                    ],
                  )
                  .toList(),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ระบบวันนี้',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF153A77),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'มี ${controller.openOrders.length} ออเดอร์ที่ต้องติดตาม และ ${controller.lowStockCount} สินค้าที่ควรเติมสต๊อก',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF5A6689),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: controller.signOut,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF123B7A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactHeader extends StatelessWidget {
  const _CompactHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF123B7A),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Row(
        children: [
          _CompactHeaderIcon(),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shop Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'แดชบอร์ดจัดการร้านค้า',
                  style: TextStyle(color: Color(0xFFD7E3FF), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CompactHeaderIcon extends StatelessWidget {
  const _CompactHeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.storefront_rounded, color: Colors.white),
    );
  }
}

class _TopBar extends GetView<MainHomeWebController> {
  const _TopBar({required this.theme, required this.section});

  final ThemeData theme;
  final MainHomeWebSection section;

  @override
  Widget build(BuildContext context) {
    final double availableWidth = MediaQuery.sizeOf(context).width;
    final double searchWidth = availableWidth < 560 ? availableWidth - 32 : 460;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runAlignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              section.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF163A72),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              section.subtitle,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF61708E),
              ),
            ),
          ],
        ),
        Container(
          width: searchWidth,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFD9E2F1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: Color(0xFF70819E)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ค้นหาสินค้า รหัสสินค้า หรือเลขออเดอร์',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF7C8BA7),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F6FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  controller.platformLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: const Color(0xFF163A72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionSwitcher extends GetView<MainHomeWebController> {
  const _SectionSwitcher({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Wrap(
        spacing: 12,
        runSpacing: 12,
        children: MainHomeWebSection.values.map((section) {
          final bool selected = controller.selectedSection.value == section;

          return InkWell(
            onTap: () => controller.changeSection(section),
            borderRadius: BorderRadius.circular(999),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF163A72) : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF163A72)
                      : const Color(0xFFD8E2F0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _sectionIcon(section),
                    size: 18,
                    color: selected ? Colors.white : const Color(0xFF163A72),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    section.title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: selected ? Colors.white : const Color(0xFF163A72),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color background = selected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.06);
    final Color foreground = selected ? const Color(0xFF14386F) : Colors.white;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFEAF1FF)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: foreground),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: foreground,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: selected
                          ? const Color(0xFF61708E)
                          : Colors.white.withValues(alpha: 0.72),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

IconData _sectionIcon(MainHomeWebSection section) {
  switch (section) {
    case MainHomeWebSection.dashboard:
      return Icons.space_dashboard_rounded;
    case MainHomeWebSection.products:
      return Icons.inventory_2_rounded;
    case MainHomeWebSection.stock:
      return Icons.layers_rounded;
    case MainHomeWebSection.orders:
      return Icons.receipt_long_rounded;
  }
}
