import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/main_home_web_controller.dart';
import '../models/admin_order_model.dart';
import '../models/admin_product_model.dart';

class MainHomeWebSectionContent extends StatelessWidget {
  const MainHomeWebSectionContent({required this.controller, super.key});

  final MainHomeWebController controller;

  @override
  Widget build(BuildContext context) {
    switch (controller.selectedSection.value) {
      case MainHomeWebSection.dashboard:
        return _DashboardSection(controller: controller);
      case MainHomeWebSection.products:
        return _ProductsSection(controller: controller);
      case MainHomeWebSection.stock:
        return _StockSection(controller: controller);
      case MainHomeWebSection.orders:
        return _OrdersSection(controller: controller);
    }
  }
}

class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.controller});

  final MainHomeWebController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _HeroSection(controller: controller),
        const SizedBox(height: 24),
        _StatsSection(controller: controller),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 980;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 7,
                    child: Column(
                      children: [
                        AdminProductsPanel(
                          controller: controller,
                          products: controller.products.take(4).toList(),
                          title: 'สินค้าล่าสุด',
                          subtitle: 'ดูสินค้า ปรับราคา และจัดการสถานะการขาย',
                          buttonLabel: 'ดูทั้งหมด',
                        ),
                        const SizedBox(height: 20),
                        AdminOrdersPanel(
                          controller: controller,
                          orders: controller.orders.take(3).toList(),
                          title: 'รายการสั่งซื้อล่าสุด',
                          subtitle: 'ติดตามสถานะออเดอร์และคิวจัดส่งของวันนี้',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        const _QuickActionsPanel(),
                        const SizedBox(height: 20),
                        _StockAlertPanel(controller: controller),
                      ],
                    ),
                  ),
                ],
              );
            }

            return Column(
              children: [
                const _QuickActionsPanel(),
                const SizedBox(height: 20),
                _StockAlertPanel(controller: controller),
                const SizedBox(height: 20),
                AdminProductsPanel(
                  controller: controller,
                  products: controller.products.take(4).toList(),
                  title: 'สินค้าล่าสุด',
                  subtitle: 'ดูสินค้า ปรับราคา และจัดการสถานะการขาย',
                  buttonLabel: 'ดูทั้งหมด',
                ),
                const SizedBox(height: 20),
                AdminOrdersPanel(
                  controller: controller,
                  orders: controller.orders.take(3).toList(),
                  title: 'รายการสั่งซื้อล่าสุด',
                  subtitle: 'ติดตามสถานะออเดอร์และคิวจัดส่งของวันนี้',
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ProductsSection extends StatelessWidget {
  const _ProductsSection({required this.controller});

  final MainHomeWebController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionIntroCard(
          title: 'จัดการสินค้า',
          subtitle:
              'หน้านี้เหมาะสำหรับต่อฟอร์มเพิ่มสินค้า แก้ไขข้อมูล เปลี่ยนราคา และจัดหมวดหมู่ในขั้นถัดไป',
          actionLabel: 'เพิ่มสินค้าใหม่',
          icon: Icons.inventory_2_rounded,
          accent: Color(0xFFEAF1FF),
          onActionPressed: () => _showAddProductDialog(context),
        ),
        const SizedBox(height: 20),
        AdminProductsPanel(
          controller: controller,
          products: controller.products,
          title: 'รายการสินค้าทั้งหมด',
          subtitle: 'ตัวอย่างข้อมูลจาก model Product ที่พร้อมต่อ backend',
          buttonLabel: 'Export',
        ),
      ],
    );
  }
}

class _StockSection extends StatelessWidget {
  const _StockSection({required this.controller});

  final MainHomeWebController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionIntroCard(
          title: 'จัดการสต๊อก',
          subtitle:
              'โฟกัสกับสินค้าที่เหลือน้อยและสินค้าที่หยุดขายชั่วคราว เพื่อให้เติมของและอัปเดตสถานะได้ไว',
          actionLabel: 'ปรับสต๊อก',
          icon: Icons.layers_rounded,
          accent: Color(0xFFFFF1DA),
        ),
        const SizedBox(height: 20),
        LayoutBuilder(
          builder: (context, constraints) {
            final bool isWide = constraints.maxWidth >= 980;

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 6,
                    child: AdminProductsPanel(
                      controller: controller,
                      products: controller.lowStockProducts,
                      title: 'สินค้าใกล้หมด',
                      subtitle: 'รายการที่ควรเติมของก่อนเพื่อไม่ให้เสียยอดขาย',
                      buttonLabel: 'เติมสต๊อก',
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: _StockAlertPanel(controller: controller),
                  ),
                ],
              );
            }

            return Column(
              children: [
                AdminProductsPanel(
                  controller: controller,
                  products: controller.lowStockProducts,
                  title: 'สินค้าใกล้หมด',
                  subtitle: 'รายการที่ควรเติมของก่อนเพื่อไม่ให้เสียยอดขาย',
                  buttonLabel: 'เติมสต๊อก',
                ),
                const SizedBox(height: 20),
                _StockAlertPanel(controller: controller),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _OrdersSection extends StatelessWidget {
  const _OrdersSection({required this.controller});

  final MainHomeWebController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _SectionIntroCard(
          title: 'จัดการรายการสั่งซื้อ',
          subtitle:
              'ใช้ติดตามออเดอร์รอชำระ รอแพ็ก และจัดส่งแล้ว ก่อนต่อระบบอัปเดตสถานะจริงจาก backend',
          actionLabel: 'ดูออเดอร์ใหม่',
          icon: Icons.receipt_long_rounded,
          accent: Color(0xFFE9FBF2),
        ),
        const SizedBox(height: 20),
        AdminOrdersPanel(
          controller: controller,
          orders: controller.orders,
          title: 'รายการสั่งซื้อทั้งหมด',
          subtitle: 'ตัวอย่างข้อมูลจาก model Order ที่พร้อมเชื่อมกับฐานข้อมูล',
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.controller});

  final MainHomeWebController controller;

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

          final Widget summary = Column(
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
                'โครงนี้ตอนนี้ใช้ model จริงของ Product และ Order ใน controller แล้ว ทำให้ต่อ Firestore หรือ API ภายหลังได้ตรงจุดกว่าเดิม',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.86),
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
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
          );

          final Widget focusCard = SizedBox(
            width: 320,
            child: _HeroFocusCard(controller: controller),
          );

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [summary, const SizedBox(height: 20), focusCard],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: summary),
              const SizedBox(width: 20),
              focusCard,
            ],
          );
        },
      ),
    );
  }
}

class _HeroFocusCard extends StatelessWidget {
  const _HeroFocusCard({required this.controller});

  final MainHomeWebController controller;

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
          _TaskTile(
            title: 'เช็กออเดอร์รอจัดส่ง',
            subtitle:
                'มี ${controller.openOrders.length} รายการที่ยังต้องติดตาม',
            color: const Color(0xFFFFF2D9),
            icon: Icons.receipt_long_rounded,
          ),
          const SizedBox(height: 12),
          _TaskTile(
            title: 'เติมสต๊อกสินค้าใกล้หมด',
            subtitle:
                'ตอนนี้มี ${controller.lowStockCount} รายการที่ควรเติมของ',
            color: const Color(0xFFFFE7E7),
            icon: Icons.warning_amber_rounded,
          ),
        ],
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.controller});

  final MainHomeWebController controller;

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
          childAspectRatio: columns == 1
              ? 2.7
              : columns == 2
              ? 1.8
              : 1.55,
          children: [
            AdminStatCard(
              title: 'ยอดขายวันนี้',
              value: controller.todaySalesLabel,
              subtitle: '+18% จากเมื่อวาน',
              icon: Icons.paid_rounded,
              accent: const Color(0xFF0F8A66),
              surface: const Color(0xFFE8FBF3),
            ),
            AdminStatCard(
              title: 'ออเดอร์ใหม่',
              value: controller.newOrdersLabel,
              subtitle: '${controller.openOrders.length} รายการยังเปิดอยู่',
              icon: Icons.shopping_bag_rounded,
              accent: const Color(0xFF2667D8),
              surface: const Color(0xFFEAF1FF),
            ),
            AdminStatCard(
              title: 'สินค้าทั้งหมด',
              value: controller.totalProductsLabel,
              subtitle: 'เปิดขายอยู่ ${controller.activeProductsCount} รายการ',
              icon: Icons.widgets_rounded,
              accent: const Color(0xFF9254DE),
              surface: const Color(0xFFF3ECFF),
            ),
            AdminStatCard(
              title: 'ใกล้หมดสต๊อก',
              value: controller.lowStockLabel,
              subtitle: 'ควรเติมภายในวันนี้',
              icon: Icons.inventory_rounded,
              accent: const Color(0xFFDA7A12),
              surface: const Color(0xFFFFF4E4),
            ),
          ],
        );
      },
    );
  }
}

class AdminProductsPanel extends StatelessWidget {
  const AdminProductsPanel({
    required this.controller,
    required this.products,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    super.key,
  });

  final MainHomeWebController controller;
  final List<AdminProductModel> products;
  final String title;
  final String subtitle;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool compact = constraints.maxWidth < 940;

        return AdminPanelShell(
          title: title,
          subtitle: subtitle,
          trailing: FilledButton.icon(
            onPressed: () {},
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF163A72),
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.tune_rounded),
            label: Text(buttonLabel),
          ),
          child: Column(
            children: [
              if (compact)
                ...products.map(
                  (product) => _ProductCompactCard(
                    controller: controller,
                    product: product,
                  ),
                )
              else ...[
                const _HeaderRow(
                  labels: ['สินค้า', 'ราคา', 'สต๊อก', 'สถานะ', 'จัดการ'],
                ),
                const Divider(height: 1),
                ...products.map(
                  (product) =>
                      _ProductRow(controller: controller, product: product),
                ),
              ],
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Text(
                    'ทั้งหมด ${products.length} รายการ',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7A95),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('จัดการสินค้า'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class AdminOrdersPanel extends StatelessWidget {
  const AdminOrdersPanel({
    required this.controller,
    required this.orders,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final MainHomeWebController controller;
  final List<AdminOrderModel> orders;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AdminPanelShell(
      title: title,
      subtitle: subtitle,
      trailing: OutlinedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.visibility_rounded),
        label: const Text('ดูทั้งหมด'),
      ),
      child: Column(
        children: [
          ...orders.map(
            (order) => _OrderCard(controller: controller, order: order),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'แนะนำ: ใช้สีสถานะแยก รอชำระเงิน, กำลังแพ็ก, จัดส่งแล้ว เพื่อให้แอดมินสแกนข้อมูลได้เร็ว',
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
    return const AdminPanelShell(
      title: 'เมนูลัด',
      subtitle: 'ปุ่มสำหรับงานที่ใช้บ่อยในร้านขนาดเล็ก',
      child: Column(
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
  const _StockAlertPanel({required this.controller});

  final MainHomeWebController controller;

  @override
  Widget build(BuildContext context) {
    return AdminPanelShell(
      title: 'สินค้าใกล้หมด',
      subtitle: 'สินค้าที่เหลือน้อยและควรวางแผนเติมสต๊อก',
      child: Column(
        children: controller.lowStockProducts
            .map(
              (product) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _StockAlertTile(
                  title: product.name,
                  remaining: 'เหลือ ${product.stock} ชิ้น',
                  progress: product.stock == 0 ? 0.01 : product.stock / 20,
                  color: _productAccentColor(product),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SectionIntroCard extends StatelessWidget {
  const _SectionIntroCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.accent,
    this.onActionPressed,
  });

  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final Color accent;
  final VoidCallback? onActionPressed;

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
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool stacked = constraints.maxWidth < 760;

          final content = <Widget>[
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: const Color(0xFF163A72), size: 30),
            ),
            const SizedBox(width: 16, height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFF163A72),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7A95),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ];

          if (stacked) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: content.take(3).toList()),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: onActionPressed ?? () {},
                  child: Text(actionLabel),
                ),
              ],
            );
          }

          return Row(
            children: [
              ...content,
              const SizedBox(width: 12),
              FilledButton(
                onPressed: onActionPressed ?? () {},
                child: Text(actionLabel),
              ),
            ],
          );
        },
      ),
    );
  }
}

class AdminPanelShell extends StatelessWidget {
  const AdminPanelShell({
    required this.title,
    required this.subtitle,
    required this.child,
    this.trailing,
    super.key,
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

class AdminStatCard extends StatelessWidget {
  const AdminStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.surface,
    super.key,
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
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
  const _ProductRow({required this.controller, required this.product});

  final MainHomeWebController controller;
  final AdminProductModel product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = _productAccentColor(product);
    final Color surface = _productSurfaceColor(product);

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
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(_productIcon(product), color: accent),
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
                        '${product.sku} • ${product.category}',
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
              controller.formatCurrency(product.price),
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
                color: accent,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _StatusBadge(
                label: _productStatusLabel(product.status),
                color: accent,
              ),
            ),
          ),
          const Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'แก้ไข',
                  color: Color(0xFFEAF1FF),
                ),
                _ActionButton(
                  icon: Icons.tune_rounded,
                  label: 'สต๊อก',
                  color: Color(0xFFFFF1DA),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCompactCard extends StatelessWidget {
  const _ProductCompactCard({required this.controller, required this.product});

  final MainHomeWebController controller;
  final AdminProductModel product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = _productAccentColor(product);
    final Color surface = _productSurfaceColor(product);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBFF),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2EAF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(_productIcon(product), color: accent),
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
                      '${product.sku} • ${product.category}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF7B89A4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _StatusBadge(
                label: controller.formatCurrency(product.price),
                color: const Color(0xFF163A72),
              ),
              _StatusBadge(label: '${product.stock} ชิ้น', color: accent),
              _StatusBadge(
                label: _productStatusLabel(product.status),
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                icon: Icons.edit_rounded,
                label: 'แก้ไข',
                color: Color(0xFFEAF1FF),
              ),
              _ActionButton(
                icon: Icons.tune_rounded,
                label: 'สต๊อก',
                color: Color(0xFFFFF1DA),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.controller, required this.order});

  final MainHomeWebController controller;
  final AdminOrderModel order;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = _orderColor(order.status);

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
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(_orderIcon(order.status), color: color),
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
                      '#${order.id}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: const Color(0xFF163A72),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    _StatusBadge(
                      label: _orderStatusLabel(order.status),
                      color: color,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${order.customerName} • ${controller.formatOrderCount(order.itemCount)} • ${controller.formatCurrency(order.total)}',
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
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
              value: progress.clamp(0.0, 1.0),
              backgroundColor: const Color(0xFFE5ECF6),
              valueColor: AlwaysStoppedAnimation<Color>(color),
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

String _productStatusLabel(AdminProductStatus status) {
  switch (status) {
    case AdminProductStatus.active:
      return 'พร้อมขาย';
    case AdminProductStatus.lowStock:
      return 'ใกล้หมด';
    case AdminProductStatus.outOfStock:
      return 'หมดชั่วคราว';
    case AdminProductStatus.hidden:
      return 'ปิดการขาย';
  }
}

Color _productAccentColor(AdminProductModel product) {
  switch (product.status) {
    case AdminProductStatus.active:
      return const Color(0xFF16805A);
    case AdminProductStatus.lowStock:
      return const Color(0xFFD05A2D);
    case AdminProductStatus.outOfStock:
      return const Color(0xFF9254DE);
    case AdminProductStatus.hidden:
      return const Color(0xFF6B7A95);
  }
}

Color _productSurfaceColor(AdminProductModel product) {
  switch (product.status) {
    case AdminProductStatus.active:
      return const Color(0xFFE9FBF2);
    case AdminProductStatus.lowStock:
      return const Color(0xFFFFEFE7);
    case AdminProductStatus.outOfStock:
      return const Color(0xFFF2EAFF);
    case AdminProductStatus.hidden:
      return const Color(0xFFF3F6FB);
  }
}

IconData _productIcon(AdminProductModel product) {
  switch (product.category) {
    case 'Apparel':
      return Icons.checkroom_rounded;
    case 'Lifestyle':
      return Icons.local_cafe_rounded;
    case 'Accessories':
      return Icons.shopping_bag_rounded;
    case 'Home':
      return Icons.home_filled;
  }

  return Icons.inventory_2_rounded;
}

String _orderStatusLabel(AdminOrderStatus status) {
  switch (status) {
    case AdminOrderStatus.pendingPayment:
      return 'รอชำระเงิน';
    case AdminOrderStatus.packing:
      return 'กำลังแพ็ก';
    case AdminOrderStatus.shipped:
      return 'จัดส่งแล้ว';
    case AdminOrderStatus.completed:
      return 'สำเร็จ';
    case AdminOrderStatus.cancelled:
      return 'ยกเลิก';
  }
}

Future<void> _showAddProductDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => const _AddProductDialog(),
  );
}

class _AddProductDialog extends StatefulWidget {
  const _AddProductDialog();

  @override
  State<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<_AddProductDialog> {
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  bool _isPickingImage = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 480,
        maxHeight: 480,
        imageQuality: 90,
      );

      if (pickedFile == null) {
        return;
      }

      final Uint8List bytes = await pickedFile.readAsBytes();
      if (!mounted) {
        return;
      }

      setState(() {
        _selectedImageBytes = bytes;
        _selectedImageName = pickedFile.name;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ยังไม่สามารถเลือกรูปภาพได้ในตอนนี้')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF1FF),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.add_business_rounded,
                      color: Color(0xFF163A72),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เพิ่มสินค้าใหม่',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: const Color(0xFF163A72),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'เตรียม UI สำหรับเลือกรูปภาพและกรอกข้อมูลสินค้า ก่อนเชื่อมต่อ Firebase จริง',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF6B7A95),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final bool stacked = constraints.maxWidth < 640;

                  final imageSection = _buildImageSection(theme);
                  final formSection = _buildFormSection(theme);

                  if (stacked) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        imageSection,
                        const SizedBox(height: 20),
                        formSection,
                      ],
                    );
                  }

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: imageSection),
                      const SizedBox(width: 20),
                      Expanded(flex: 5, child: formSection),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('บันทึกสินค้า'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDDE6F2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'รูปสินค้า',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF163A72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เลือกจาก Gallery ด้วย image_picker ขนาดสูงสุด 480 x 480',
            style: theme.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF6B7A95),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD7E3F2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(23),
                child: _selectedImageBytes == null
                    ? _buildImagePlaceholder(theme)
                    : Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isPickingImage ? null : _pickImage,
              icon: _isPickingImage
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_library_outlined),
              label: Text(
                _selectedImageBytes == null
                    ? 'เลือกรูปจาก Gallery'
                    : 'เลือกรูปใหม่',
              ),
            ),
          ),
          if (_selectedImageName != null) ...[
            const SizedBox(height: 10),
            Text(
              _selectedImageName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF4A5C7A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: Color(0xFF163A72),
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่ได้เลือกรูปสินค้า',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: const Color(0xFF163A72),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'เมื่อเชื่อม backend แล้ว ส่วนนี้จะพร้อมต่ออัปโหลดไป Firebase Storage',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF6B7A95),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'ชื่อสินค้า',
          hintText: 'เช่น เสื้อยืดคอกลม',
          prefixIcon: Icons.inventory_2_outlined,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'รายละเอียดสินค้า',
          hintText: 'อธิบายจุดเด่นของสินค้า วัสดุ หรือขนาด',
          prefixIcon: Icons.notes_rounded,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _priceController,
                label: 'ราคา',
                hintText: '0.00',
                prefixIcon: Icons.sell_outlined,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _unitController,
                label: 'หน่วย',
                hintText: 'ชิ้น / กล่อง / แพ็ก',
                prefixIcon: Icons.straighten_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _stockController,
          label: 'จำนวนสต๊อก',
          hintText: '0',
          prefixIcon: Icons.warehouse_outlined,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: const Color(0xFFF8FAFD),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD7E3F2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFD7E3F2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF3C69C8), width: 1.3),
        ),
      ),
    );
  }
}

Color _orderColor(AdminOrderStatus status) {
  switch (status) {
    case AdminOrderStatus.pendingPayment:
      return const Color(0xFFDA7A12);
    case AdminOrderStatus.packing:
      return const Color(0xFF2667D8);
    case AdminOrderStatus.shipped:
      return const Color(0xFF16805A);
    case AdminOrderStatus.completed:
      return const Color(0xFF6B7A95);
    case AdminOrderStatus.cancelled:
      return const Color(0xFFD05A2D);
  }
}

IconData _orderIcon(AdminOrderStatus status) {
  switch (status) {
    case AdminOrderStatus.pendingPayment:
      return Icons.payments_rounded;
    case AdminOrderStatus.packing:
      return Icons.inventory_2_rounded;
    case AdminOrderStatus.shipped:
      return Icons.local_shipping_rounded;
    case AdminOrderStatus.completed:
      return Icons.verified_rounded;
    case AdminOrderStatus.cancelled:
      return Icons.cancel_rounded;
  }
}
