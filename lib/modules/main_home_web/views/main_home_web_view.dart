import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/main_home_web_controller.dart';

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

class _DashboardContent extends StatelessWidget {
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
    return SingleChildScrollView(
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
              _TopBar(theme: theme),
              const SizedBox(height: 24),
              const _HeroSection(),
              const SizedBox(height: 24),
              const _StatsSection(),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool isWide = constraints.maxWidth >= 980;

                  if (isWide) {
                    return const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 7,
                          child: Column(
                            children: [
                              _ProductsPanel(),
                              SizedBox(height: 20),
                              _OrdersPanel(),
                            ],
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              _QuickActionsPanel(),
                              SizedBox(height: 20),
                              _StockAlertPanel(),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return const Column(
                    children: [
                      _QuickActionsPanel(),
                      SizedBox(height: 20),
                      _StockAlertPanel(),
                      SizedBox(height: 20),
                      _ProductsPanel(),
                      SizedBox(height: 20),
                      _OrdersPanel(),
                    ],
                  );
                },
              ),
            ],
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
          const _MenuTile(
            icon: Icons.space_dashboard_rounded,
            title: 'Dashboard',
            subtitle: 'ภาพรวมของร้าน',
            selected: true,
          ),
          const SizedBox(height: 10),
          const _MenuTile(
            icon: Icons.inventory_2_rounded,
            title: 'Products',
            subtitle: 'เพิ่ม ลบ และแก้ไขสินค้า',
          ),
          const SizedBox(height: 10),
          const _MenuTile(
            icon: Icons.layers_rounded,
            title: 'Stock',
            subtitle: 'ดูคงเหลือและสินค้าใกล้หมด',
          ),
          const SizedBox(height: 10),
          const _MenuTile(
            icon: Icons.receipt_long_rounded,
            title: 'Orders',
            subtitle: 'จัดการรายการสั่งซื้อ',
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
                  'มี 5 ออเดอร์ที่ต้องติดตาม และ 3 สินค้าที่ควรเติมสต๊อก',
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.storefront_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Expanded(
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

class _TopBar extends GetView<MainHomeWebController> {
  const _TopBar({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
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
              'ภาพรวมร้านค้า',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF163A72),
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'จัดการสินค้า ราคา สต๊อก และรายการสั่งซื้อในหน้าเดียว',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF61708E),
              ),
            ),
          ],
        ),
        Container(
          constraints: const BoxConstraints(maxWidth: 460),
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

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF163A72), Color(0xFF1F5AA6), Color(0xFF57A7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool stacked = constraints.maxWidth < 860;

          final Widget summary = Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'SMALL SHOP CONTROL CENTER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'ดูยอดขาย จัดการสต๊อก และตามออเดอร์ได้ง่ายในหน้าหลักเดียว',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'โครงนี้เหมาะกับร้านเล็กที่ต้องการหลังบ้านเรียบง่าย ใช้งานไว และต่อยอดเชื่อมข้อมูลจริงได้ทีละส่วน',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white.withValues(alpha: 0.86),
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 22),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: const [
                    _HighlightChip(
                      icon: Icons.add_box_rounded,
                      label: 'เพิ่มสินค้าได้เร็ว',
                    ),
                    _HighlightChip(
                      icon: Icons.price_change_rounded,
                      label: 'ปรับราคาได้ทันที',
                    ),
                    _HighlightChip(
                      icon: Icons.local_shipping_rounded,
                      label: 'ติดตามออเดอร์ได้ง่าย',
                    ),
                  ],
                ),
              ],
            ),
          );

          final Widget focusCard = const SizedBox(
            width: 320,
            child: _HeroFocusCard(),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [summary, const SizedBox(height: 20), focusCard],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [summary, const SizedBox(width: 20), focusCard],
          );
        },
      ),
    );
  }
}

class _HeroFocusCard extends StatelessWidget {
  const _HeroFocusCard();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'สิ่งที่ควรทำต่อ',
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFF14386F),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          const _TaskTile(
            title: 'เพิ่มสินค้าใหม่',
            subtitle: 'เพิ่มชื่อ ราคา หมวดหมู่ และจำนวนคงเหลือ',
            color: Color(0xFFE9F5FF),
            icon: Icons.inventory_2_rounded,
          ),
          const SizedBox(height: 12),
          const _TaskTile(
            title: 'เช็กออเดอร์รอจัดส่ง',
            subtitle: 'มี 5 รายการที่ยังต้องยืนยัน',
            color: Color(0xFFFFF2D9),
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 12),
          const _TaskTile(
            title: 'เติมสต๊อกสินค้าใกล้หมด',
            subtitle: 'สินค้ากลุ่มเสื้อยืดยอดนิยมเริ่มต่ำกว่าเกณฑ์',
            color: Color(0xFFFFE7E7),
            icon: Icons.warning_amber_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int columns = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 700
            ? 2
            : 1;

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: columns == 1 ? 2.7 : 1.95,
          children: const [
            _StatCard(
              title: 'ยอดขายวันนี้',
              value: '฿12,480',
              subtitle: '+18% จากเมื่อวาน',
              icon: Icons.paid_rounded,
              accent: Color(0xFF0F8A66),
              surface: Color(0xFFE8FBF3),
            ),
            _StatCard(
              title: 'ออเดอร์ใหม่',
              value: '24',
              subtitle: '5 รายการรอยืนยัน',
              icon: Icons.shopping_bag_rounded,
              accent: Color(0xFF2667D8),
              surface: Color(0xFFEAF1FF),
            ),
            _StatCard(
              title: 'สินค้าทั้งหมด',
              value: '128',
              subtitle: 'เปิดขายอยู่ 112 รายการ',
              icon: Icons.widgets_rounded,
              accent: Color(0xFF9254DE),
              surface: Color(0xFFF3ECFF),
            ),
            _StatCard(
              title: 'ใกล้หมดสต๊อก',
              value: '9',
              subtitle: 'ควรเติมภายในวันนี้',
              icon: Icons.inventory_rounded,
              accent: Color(0xFFDA7A12),
              surface: Color(0xFFFFF4E4),
            ),
          ],
        );
      },
    );
  }
}

class _ProductsPanel extends StatelessWidget {
  const _ProductsPanel();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return _PanelShell(
      title: 'สินค้าล่าสุด',
      subtitle: 'ดูสินค้า ปรับราคา และจัดการสถานะการขาย',
      trailing: FilledButton.icon(
        onPressed: () {},
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF163A72),
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('เพิ่มสินค้า'),
      ),
      child: Column(
        children: [
          const _HeaderRow(
            labels: ['สินค้า', 'ราคา', 'สต๊อก', 'สถานะ', 'จัดการ'],
          ),
          const Divider(height: 1),
          ..._mockProducts.map((product) => _ProductRow(product: product)),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(
                'แสดง 4 จาก 128 รายการ',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6B7A95),
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('ดูสินค้าทั้งหมด'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrdersPanel extends StatelessWidget {
  const _OrdersPanel();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return _PanelShell(
      title: 'รายการสั่งซื้อล่าสุด',
      subtitle: 'ติดตามสถานะออเดอร์และคิวจัดส่งของวันนี้',
      trailing: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.visibility_rounded),
        label: const Text('ดูทั้งหมด'),
      ),
      child: Column(
        children: [
          ..._mockOrders.map((order) => _OrderCard(order: order)),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'แนะนำ: ใช้สีสถานะแยก `รอชำระเงิน`, `กำลังแพ็ก`, `จัดส่งแล้ว` เพื่อให้แอดมินสแกนข้อมูลได้เร็ว',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7A95),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel();

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      title: 'เมนูลัด',
      subtitle: 'ปุ่มสำหรับงานที่ใช้บ่อยในร้านขนาดเล็ก',
      child: const Column(
        children: [
          _QuickActionTile(
            icon: Icons.add_business_rounded,
            title: 'เพิ่มสินค้าใหม่',
            subtitle: 'เปิดฟอร์มกรอกสินค้า ราคา และจำนวน',
            accent: Color(0xFFE7F2FF),
          ),
          SizedBox(height: 12),
          _QuickActionTile(
            icon: Icons.edit_note_rounded,
            title: 'แก้ไขราคา',
            subtitle: 'ปรับราคาสินค้าที่มีโปรโมชันหรืออัปเดตต้นทุน',
            accent: Color(0xFFFFF1DA),
          ),
          SizedBox(height: 12),
          _QuickActionTile(
            icon: Icons.inventory_2_outlined,
            title: 'ปรับสต๊อก',
            subtitle: 'เพิ่มของเข้า หรือแก้ไขจำนวนคงเหลือ',
            accent: Color(0xFFE9F9EF),
          ),
        ],
      ),
    );
  }
}

class _StockAlertPanel extends StatelessWidget {
  const _StockAlertPanel();

  @override
  Widget build(BuildContext context) {
    return _PanelShell(
      title: 'สินค้าใกล้หมด',
      subtitle: 'สินค้าที่เหลือน้อยและควรวางแผนเติมสต๊อก',
      child: const Column(
        children: [
          _StockAlertTile(
            title: 'เสื้อยืด Oversize สีขาว',
            remaining: 'เหลือ 3 ชิ้น',
            progress: 0.18,
            color: Color(0xFFD05A2D),
          ),
          SizedBox(height: 14),
          _StockAlertTile(
            title: 'แก้วเก็บความเย็น 890ml',
            remaining: 'เหลือ 5 ชิ้น',
            progress: 0.28,
            color: Color(0xFFE89A1D),
          ),
          SizedBox(height: 14),
          _StockAlertTile(
            title: 'กระเป๋าผ้า Canvas',
            remaining: 'เหลือ 7 ชิ้น',
            progress: 0.36,
            color: Color(0xFF2F7EDB),
          ),
        ],
      ),
    );
  }
}

class _PanelShell extends StatelessWidget {
  const _PanelShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFDDE6F2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF123B7A).withValues(alpha: 0.06),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            runSpacing: 12,
            spacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: const Color(0xFF163A72),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7A95),
                    ),
                  ),
                ],
              ),
              ...(trailing == null ? const <Widget>[] : <Widget>[trailing!]),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.selected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final Color background = selected
        ? Colors.white
        : Colors.white.withValues(alpha: 0.06);
    final Color foreground = selected ? const Color(0xFF14386F) : Colors.white;

    return Container(
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
    );
  }
}

class _HighlightChip extends StatelessWidget {
  const _HighlightChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
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

class _TaskTile extends StatelessWidget {
  const _TaskTile({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: const Color(0xFF153A77)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF153A77),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF5E6C87),
                    fontSize: 13,
                    height: 1.5,
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

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.surface,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDE6F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: accent),
              ),
              const Spacer(),
              Icon(Icons.trending_up_rounded, color: accent),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7A95),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: const Color(0xFF163A72),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7A95),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: labels
            .map(
              (label) => Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF6B7A95),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product});

  final _ProductData product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool lowStock = product.stock <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEDF2F8))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: product.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(product.icon, color: product.accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: const Color(0xFF163A72),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.code,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF7B89A4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              product.price,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1A2B4F),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${product.stock} ชิ้น',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: lowStock
                    ? const Color(0xFFD05A2D)
                    : const Color(0xFF1A2B4F),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: product.statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  product.status,
                  style: TextStyle(
                    color: product.statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'แก้ไข',
                  color: const Color(0xFFEAF1FF),
                ),
                _ActionButton(
                  icon: Icons.tune_rounded,
                  label: 'สต๊อก',
                  color: const Color(0xFFFFF1DA),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF14386F)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF14386F),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final _OrderData order;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAF5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: order.color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(order.icon, color: order.color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      order.id,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF163A72),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: order.color.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        order.status,
                        style: TextStyle(
                          color: order.color,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${order.customer} • ${order.items} • ${order.total}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF60708C),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  order.note,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF72809A),
                    height: 1.5,
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

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: const Color(0xFF14386F)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF14386F),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF62718D),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        ],
      ),
    );
  }
}

class _StockAlertTile extends StatelessWidget {
  const _StockAlertTile({
    required this.title,
    required this.remaining,
    required this.progress,
    required this.color,
  });

  final String title;
  final String remaining;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2EAF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: const Color(0xFF163A72),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                remaining,
                style: TextStyle(color: color, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: const Color(0xFFE5ECF6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductData {
  const _ProductData({
    required this.name,
    required this.code,
    required this.price,
    required this.stock,
    required this.status,
    required this.statusColor,
    required this.icon,
    required this.surface,
    required this.accent,
  });

  final String name;
  final String code;
  final String price;
  final int stock;
  final String status;
  final Color statusColor;
  final IconData icon;
  final Color surface;
  final Color accent;
}

class _OrderData {
  const _OrderData({
    required this.id,
    required this.customer,
    required this.items,
    required this.total,
    required this.status,
    required this.note,
    required this.color,
    required this.icon,
  });

  final String id;
  final String customer;
  final String items;
  final String total;
  final String status;
  final String note;
  final Color color;
  final IconData icon;
}

const List<_ProductData> _mockProducts = <_ProductData>[
  _ProductData(
    name: 'เสื้อยืด Oversize สีขาว',
    code: 'SKU-TSH-001',
    price: '฿390',
    stock: 3,
    status: 'ใกล้หมด',
    statusColor: Color(0xFFD05A2D),
    icon: Icons.checkroom_rounded,
    surface: Color(0xFFFFEFE7),
    accent: Color(0xFFD05A2D),
  ),
  _ProductData(
    name: 'แก้วเก็บความเย็น 890ml',
    code: 'SKU-CUP-014',
    price: '฿259',
    stock: 15,
    status: 'พร้อมขาย',
    statusColor: Color(0xFF16805A),
    icon: Icons.local_cafe_rounded,
    surface: Color(0xFFE9FBF2),
    accent: Color(0xFF16805A),
  ),
  _ProductData(
    name: 'กระเป๋าผ้า Canvas',
    code: 'SKU-BAG-021',
    price: '฿490',
    stock: 7,
    status: 'พร้อมขาย',
    statusColor: Color(0xFF2667D8),
    icon: Icons.shopping_bag_rounded,
    surface: Color(0xFFEAF1FF),
    accent: Color(0xFF2667D8),
  ),
  _ProductData(
    name: 'หมวกแก๊ปสีกรม',
    code: 'SKU-CAP-102',
    price: '฿320',
    stock: 0,
    status: 'หมดชั่วคราว',
    statusColor: Color(0xFF9254DE),
    icon: Icons.dry_cleaning_rounded,
    surface: Color(0xFFF2EAFF),
    accent: Color(0xFF9254DE),
  ),
];

const List<_OrderData> _mockOrders = <_OrderData>[
  _OrderData(
    id: '#SO-240422-001',
    customer: 'Nattapong S.',
    items: '2 รายการ',
    total: '฿780',
    status: 'รอชำระเงิน',
    note: 'ลูกค้าเลือกโอนเงินและส่งหลักฐานภายในวันนี้',
    color: Color(0xFFDA7A12),
    icon: Icons.payments_rounded,
  ),
  _OrderData(
    id: '#SO-240422-002',
    customer: 'Pimchanok K.',
    items: '1 รายการ',
    total: '฿490',
    status: 'กำลังแพ็ก',
    note: 'เตรียมสินค้าเรียบร้อย รอพิมพ์ใบปะหน้าจัดส่ง',
    color: Color(0xFF2667D8),
    icon: Icons.inventory_2_rounded,
  ),
  _OrderData(
    id: '#SO-240422-003',
    customer: 'Aekkachai T.',
    items: '3 รายการ',
    total: '฿1,140',
    status: 'จัดส่งแล้ว',
    note: 'อัปเดตเลขพัสดุแล้ว ลูกค้าสามารถติดตามได้ทันที',
    color: Color(0xFF16805A),
    icon: Icons.local_shipping_rounded,
  ),
];
