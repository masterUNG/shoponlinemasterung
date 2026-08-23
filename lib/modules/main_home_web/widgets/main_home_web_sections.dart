import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shoponlinemasterung/core/app_snackbar.dart';
import 'package:shoponlinemasterung/core/app_constant.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shoponlinemasterung/model/order_model.dart';
import 'package:shoponlinemasterung/model/product_model.dart';

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
                          productsBuilder: () =>
                              controller.products.take(4).toList(),
                          title: 'สินค้าล่าสุด',
                          subtitle: 'ดูสินค้า ปรับราคา และจัดการสถานะการขาย',
                          buttonLabel: 'ดูทั้งหมด',
                          onTrailingPressed: () => controller.changeSection(
                            MainHomeWebSection.products,
                          ),
                          onManagePressed: () => controller.changeSection(
                            MainHomeWebSection.products,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AdminOrdersPanel(
                          controller: controller,
                          ordersBuilder: () =>
                              controller.orders.take(3).toList(),
                          title: 'รายการสั่งซื้อล่าสุด',
                          subtitle: 'ติดตามสถานะออเดอร์รับที่ร้านของวันนี้',
                          onViewAllPressed: () => controller.changeSection(
                            MainHomeWebSection.orders,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        _QuickActionsPanel(controller: controller),
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
                _QuickActionsPanel(controller: controller),
                const SizedBox(height: 20),
                _StockAlertPanel(controller: controller),
                const SizedBox(height: 20),
                AdminProductsPanel(
                  controller: controller,
                  productsBuilder: () => controller.products.take(4).toList(),
                  title: 'สินค้าล่าสุด',
                  subtitle: 'ดูสินค้า ปรับราคา และจัดการสถานะการขาย',
                  buttonLabel: 'ดูทั้งหมด',
                  onTrailingPressed: () =>
                      controller.changeSection(MainHomeWebSection.products),
                  onManagePressed: () =>
                      controller.changeSection(MainHomeWebSection.products),
                ),
                const SizedBox(height: 20),
                AdminOrdersPanel(
                  controller: controller,
                  ordersBuilder: () => controller.orders.take(3).toList(),
                  title: 'รายการสั่งซื้อล่าสุด',
                  subtitle: 'ติดตามสถานะออเดอร์รับที่ร้านของวันนี้',
                  onViewAllPressed: () =>
                      controller.changeSection(MainHomeWebSection.orders),
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
          accent: AppConstant.appColorSoft,
          onActionPressed: () => _showAddProductDialog(context),
        ),
        const SizedBox(height: 20),
        AdminProductsPanel(
          controller: controller,
          productsBuilder: () => controller.filteredProducts,
          title: 'รายการสินค้าทั้งหมด',
          subtitle: 'ตัวอย่างข้อมูลจาก model Product ที่พร้อมต่อ backend',
          buttonLabel: 'Export',
          onTrailingPressed: () => controller.clearSearch(),
          onManagePressed: () => _showAddProductDialog(context),
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
        _SectionIntroCard(
          title: 'จัดการสต๊อก',
          subtitle:
              'โฟกัสกับสินค้าที่เหลือน้อยและสินค้าที่หยุดขายชั่วคราว เพื่อให้เติมของและอัปเดตสถานะได้ไว',
          actionLabel: 'ปรับสต๊อก',
          icon: Icons.layers_rounded,
          accent: const Color(0xFFFFF1DA),
          onActionPressed: controller.clearSearch,
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
                      productsBuilder: () =>
                          controller.filteredLowStockProducts,
                      title: 'สินค้าใกล้หมด',
                      subtitle: 'รายการที่ควรเติมของก่อนเพื่อไม่ให้เสียยอดขาย',
                      buttonLabel: 'เติมสต๊อก',
                      onTrailingPressed: controller.clearSearch,
                      onManagePressed: controller.clearSearch,
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
                  productsBuilder: () => controller.filteredLowStockProducts,
                  title: 'สินค้าใกล้หมด',
                  subtitle: 'รายการที่ควรเติมของก่อนเพื่อไม่ให้เสียยอดขาย',
                  buttonLabel: 'เติมสต๊อก',
                  onTrailingPressed: controller.clearSearch,
                  onManagePressed: controller.clearSearch,
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
              'ใช้ติดตามออเดอร์รับที่ร้าน ตั้งแต่รอร้านรับ กำลังเตรียม พร้อมรับ ไปจนถึงสำเร็จหรือยกเลิก',
          actionLabel: 'ดูออเดอร์ใหม่',
          icon: Icons.receipt_long_rounded,
          accent: Color(0xFFE9FBF2),
        ),
        const SizedBox(height: 20),
        AdminOrdersPanel(
          controller: controller,
          ordersBuilder: () => controller.filteredOrders,
          title: 'รายการสั่งซื้อทั้งหมด',
          subtitle: 'ข้อมูลจริงจาก Firestore collection orders',
          onViewAllPressed: controller.clearSearch,
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
          colors: [
            AppConstant.appColorDark,
            AppConstant.appColor,
            AppConstant.appColorLight,
          ],
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
                'โครงนี้ใช้ Product และ Order จาก Firestore แล้ว ทำให้จัดการสินค้าและออเดอร์ได้จากฐานข้อมูลเดียวกัน',
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
                    label: 'ติดตามออเดอร์รับที่ร้าน',
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
              color: AppConstant.appColorDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          const _TaskTile(
            title: 'เพิ่มสินค้าใหม่',
            subtitle: 'เพิ่มชื่อ ราคา หมวดหมู่ และจำนวนคงเหลือ',
            color: AppConstant.appColorSoft,
            icon: Icons.inventory_2_rounded,
          ),
          const SizedBox(height: 12),
          _TaskTile(
            title: 'เช็กออเดอร์รับที่ร้าน',
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
              subtitle: controller.salesComparisonLabel,
              icon: Icons.paid_rounded,
              accent: const Color(0xFF0F8A66),
              surface: const Color(0xFFE8FBF3),
            ),
            AdminStatCard(
              title: 'ออเดอร์ใหม่',
              value: controller.newOrdersLabel,
              subtitle: '${controller.openOrders.length} รายการยังเปิดอยู่',
              icon: Icons.shopping_bag_rounded,
              accent: AppConstant.appColor,
              surface: AppConstant.appColorSoft,
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
    required this.productsBuilder,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.onTrailingPressed,
    this.onManagePressed,
    super.key,
  });

  final MainHomeWebController controller;
  final List<AdminProductModel> Function() productsBuilder;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback? onTrailingPressed;
  final VoidCallback? onManagePressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Obx(() {
      final bool isLoading = controller.isProductsLoading.value;
      final List<AdminProductModel> currentProducts = productsBuilder();

      return LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 940;

          return AdminPanelShell(
            title: title,
            subtitle: subtitle,
            trailing: FilledButton.icon(
              onPressed: onTrailingPressed ?? () {},
              style: FilledButton.styleFrom(
                backgroundColor: AppConstant.appColorDark,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.tune_rounded),
              label: Text(buttonLabel),
            ),
            child: Column(
              children: [
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (currentProducts.isEmpty)
                  _EmptyProductsState(theme: theme)
                else if (compact)
                  ...currentProducts.map(
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
                  ...currentProducts.map(
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
                      'ทั้งหมด ${currentProducts.length} รายการ',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppConstant.appColorMuted,
                      ),
                    ),
                    TextButton(
                      onPressed: onManagePressed ?? () {},
                      child: const Text('จัดการสินค้า'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    });
  }
}

class _EmptyProductsState extends StatelessWidget {
  const _EmptyProductsState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppConstant.appColorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConstant.appColorBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppConstant.appColorSoft,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: AppConstant.appColorDark,
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'ยังไม่มีสินค้าในระบบ',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppConstant.appColorDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เพิ่มสินค้าใหม่จาก dialog แล้วรายการจะถูกดึงจาก Firestore collection product มาแสดงที่หน้านี้ทันที',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppConstant.appColorMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminOrdersPanel extends StatelessWidget {
  const AdminOrdersPanel({
    required this.controller,
    required this.ordersBuilder,
    required this.title,
    required this.subtitle,
    this.onViewAllPressed,
    super.key,
  });

  final MainHomeWebController controller;
  final List<AdminOrderModel> Function() ordersBuilder;
  final String title;
  final String subtitle;
  final VoidCallback? onViewAllPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Obx(() {
      final bool isLoading = controller.isOrdersLoading.value;
      final List<AdminOrderModel> currentOrders = ordersBuilder();

      return AdminPanelShell(
        title: title,
        subtitle: subtitle,
        trailing: OutlinedButton.icon(
          onPressed: onViewAllPressed ?? () {},
          icon: const Icon(Icons.visibility_rounded),
          label: const Text('ดูทั้งหมด'),
        ),
        child: Column(
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (currentOrders.isEmpty)
              _EmptyOrdersState(theme: theme)
            else
              ...currentOrders.map(
                (order) => _OrderCard(controller: controller, order: order),
              ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Flow: pending -> accepted -> preparing -> ready -> completed หรือ cancelled',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppConstant.appColorMuted,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _EmptyOrdersState extends StatelessWidget {
  const _EmptyOrdersState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppConstant.appColorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppConstant.appColorBorder),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE9FBF2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF16805A),
              size: 32,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'ยังไม่มีออเดอร์ในระบบ',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppConstant.appColorDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เมื่อลูกค้ากด Order สินค้า รายการจาก collection orders จะแสดงที่นี่ทันที',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppConstant.appColorMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsPanel extends StatelessWidget {
  const _QuickActionsPanel({required this.controller});

  final MainHomeWebController controller;

  @override
  Widget build(BuildContext context) {
    return AdminPanelShell(
      title: 'เมนูลัด',
      subtitle: 'ปุ่มสำหรับงานที่ใช้บ่อยในร้านขนาดเล็ก',
      child: Column(
        children: [
          _QuickActionTile(
            icon: Icons.add_business_rounded,
            title: 'เพิ่มสินค้าใหม่',
            subtitle: 'เปิดฟอร์มกรอกสินค้า ราคา และจำนวน',
            accent: AppConstant.appColorSoft,
            onTap: () => _showAddProductDialog(context),
          ),
          const SizedBox(height: 12),
          _QuickActionTile(
            icon: Icons.edit_note_rounded,
            title: 'แก้ไขราคา',
            subtitle: 'ปรับราคาสินค้าที่มีโปรโมชันหรืออัปเดตต้นทุน',
            accent: const Color(0xFFFFF1DA),
            onTap: () => controller.changeSection(MainHomeWebSection.products),
          ),
          const SizedBox(height: 12),
          _QuickActionTile(
            icon: Icons.inventory_2_outlined,
            title: 'ปรับสต๊อก',
            subtitle: 'เพิ่มของเข้า หรือแก้ไขจำนวนคงเหลือ',
            accent: const Color(0xFFE9F9EF),
            onTap: () => controller.changeSection(MainHomeWebSection.stock),
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
        border: Border.all(color: AppConstant.appColorBorder),
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
              child: Icon(icon, color: AppConstant.appColorDark, size: 30),
            ),
            const SizedBox(width: 16, height: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: AppConstant.appColorDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppConstant.appColorMuted,
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
        border: Border.all(color: AppConstant.appColorBorder),
        boxShadow: [
          BoxShadow(
            color: AppConstant.appColorDark.withValues(alpha: 0.06),
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
                      color: AppConstant.appColorDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppConstant.appColorMuted,
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
        border: Border.all(color: AppConstant.appColorBorder),
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
                  color: AppConstant.appColorMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: AppConstant.appColorDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppConstant.appColorMuted,
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
                    color: AppConstant.appColorMuted,
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
        border: Border(bottom: BorderSide(color: AppConstant.appColorSoft)),
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
                  clipBehavior: Clip.antiAlias,
                  child: _ProductImage(product: product, accent: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppConstant.appColorDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.sku} • ${product.category}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppConstant.appColorMuted,
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
                color: AppConstant.appColorDeep,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${product.stock} ${product.unit}',
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
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ActionButton(
                  icon: Icons.edit_rounded,
                  label: 'แก้ไข',
                  color: AppConstant.appColorSoft,
                  onTap: () => _showEditProductDialog(context, product),
                ),
                if (controller.canDeleteProducts)
                  _ActionButton(
                    icon: Icons.delete_outline_rounded,
                    label: 'ลบ',
                    color: const Color(0xFFFFE7E7),
                    onTap: () => _showDeleteProductDialog(
                      context,
                      product,
                      controller.formatCurrency(product.price),
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
        color: AppConstant.appColorSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppConstant.appColorBorder),
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
                clipBehavior: Clip.antiAlias,
                child: _ProductImage(product: product, accent: accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppConstant.appColorDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.sku} • ${product.category}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppConstant.appColorMuted,
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
                color: AppConstant.appColorDark,
              ),
              _StatusBadge(
                label: '${product.stock} ${product.unit}',
                color: accent,
              ),
              _StatusBadge(
                label: _productStatusLabel(product.status),
                color: accent,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ActionButton(
                icon: Icons.edit_rounded,
                label: 'แก้ไข',
                color: AppConstant.appColorSoft,
                onTap: () => _showEditProductDialog(context, product),
              ),
              if (controller.canDeleteProducts)
                _ActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'ลบ',
                  color: const Color(0xFFFFE7E7),
                  onTap: () => _showDeleteProductDialog(
                    context,
                    product,
                    controller.formatCurrency(product.price),
                  ),
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
        color: AppConstant.appColorSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppConstant.appColorBorder),
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
                      order.orderNo,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppConstant.appColorDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    _StatusBadge(
                      label: _orderStatusLabel(order.status),
                      color: color,
                    ),
                    _StatusBadge(
                      label: controller.paymentStatusLabel(
                        order.paymentStatus,
                        paymentMethod: order.paymentMethod,
                      ),
                      color: _paymentStatusColor(order.paymentStatus),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${order.customerName} • ${controller.formatOrderCount(order.itemCount)} • ${controller.formatCurrency(order.total)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppConstant.appColorMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  order.note,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppConstant.appColorMuted,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => _showOrderDetailDialog(
                    context,
                    controller: controller,
                    order: order,
                  ),
                  icon: const Icon(Icons.info_outline_rounded, size: 18),
                  label: const Text('รายละเอียด'),
                ),
                const SizedBox(height: 10),
                _OrderActionRow(controller: controller, order: order),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderActionRow extends StatelessWidget {
  const _OrderActionRow({required this.controller, required this.order});

  final MainHomeWebController controller;
  final AdminOrderModel order;

  @override
  Widget build(BuildContext context) {
    final List<AdminOrderStatus> nextStatuses = controller.nextOrderStatuses(
      order.status,
    );

    if (nextStatuses.isEmpty) {
      return Align(
        alignment: Alignment.centerLeft,
        child: _StatusBadge(
          label: order.status == AdminOrderStatus.completed
              ? 'ปิดออเดอร์แล้ว'
              : 'ออเดอร์ถูกยกเลิก',
          color: _orderColor(order.status),
        ),
      );
    }

    if (order.paymentStatus == 'waiting_verify') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PaymentVerifyActions(controller: controller, order: order),
          const SizedBox(height: 8),
          _CancelOrderButton(controller: controller, order: order),
        ],
      );
    }

    if (!order.isCashPayment && order.paymentStatus != 'paid') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _StatusBadge(
            label: 'รอลูกค้าอัปโหลดสลิป',
            color: _paymentStatusColor(order.paymentStatus),
          ),
          _CancelOrderButton(controller: controller, order: order),
        ],
      );
    }

    return Obx(() {
      final bool isUpdating = controller.updatingOrderId.value == order.id;
      final bool anotherOrderIsUpdating =
          controller.updatingOrderId.value.isNotEmpty && !isUpdating;

      final List<AdminOrderStatus> allowedStatuses = nextStatuses
          .where(
            (status) =>
                status != AdminOrderStatus.completed ||
                order.paymentStatus == 'paid',
          )
          .toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (order.isCashPayment && order.paymentStatus == 'unpaid') ...[
            _CashPaymentActions(controller: controller, order: order),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allowedStatuses.map((status) {
              final bool isCancel = status == AdminOrderStatus.cancelled;
              return isCancel
                  ? _CancelOrderButton(
                      controller: controller,
                      order: order,
                      disabled: isUpdating || anotherOrderIsUpdating,
                    )
                  : FilledButton.icon(
                      onPressed: isUpdating || anotherOrderIsUpdating
                          ? null
                          : () => controller.updateOrderStatus(
                              order: order,
                              status: status,
                            ),
                      style: FilledButton.styleFrom(
                        backgroundColor: _orderColor(status),
                        foregroundColor: Colors.white,
                      ),
                      icon: isUpdating
                          ? const SizedBox.square(
                              dimension: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Icon(_orderIcon(status), size: 18),
                      label: Text(_orderActionLabel(status)),
                    );
            }).toList(),
          ),
        ],
      );
    });
  }
}

class _CashPaymentActions extends StatelessWidget {
  const _CashPaymentActions({required this.controller, required this.order});

  final MainHomeWebController controller;
  final AdminOrderModel order;

  @override
  Widget build(BuildContext context) {
    final bool isUpdating = controller.updatingPaymentOrderId.value == order.id;
    final bool anotherPaymentIsUpdating =
        controller.updatingPaymentOrderId.value.isNotEmpty && !isUpdating;
    final bool orderIsUpdating = controller.updatingOrderId.value.isNotEmpty;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _StatusBadge(
          label: 'รอรับเงินสด ${controller.formatCurrency(order.total)}',
          color: const Color(0xFFB36B00),
        ),
        FilledButton.icon(
          onPressed: isUpdating || anotherPaymentIsUpdating || orderIsUpdating
              ? null
              : () => _confirmCashPayment(
                  context,
                  controller: controller,
                  order: order,
                ),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF16805A),
            foregroundColor: Colors.white,
          ),
          icon: isUpdating
              ? const SizedBox.square(
                  dimension: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.payments_rounded, size: 18),
          label: const Text('ได้รับเงินสดแล้ว'),
        ),
      ],
    );
  }
}

class _CancelOrderButton extends StatelessWidget {
  const _CancelOrderButton({
    required this.controller,
    required this.order,
    this.disabled = false,
  });

  final MainHomeWebController controller;
  final AdminOrderModel order;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isUpdating = controller.updatingOrderId.value == order.id;
      final bool anotherOrderIsUpdating =
          controller.updatingOrderId.value.isNotEmpty && !isUpdating;
      final bool paymentIsUpdating =
          controller.updatingPaymentOrderId.value.isNotEmpty;

      return OutlinedButton.icon(
        onPressed:
            disabled ||
                isUpdating ||
                anotherOrderIsUpdating ||
                paymentIsUpdating
            ? null
            : () => _confirmCancelOrder(
                context,
                controller: controller,
                order: order,
              ),
        icon: isUpdating
            ? const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.cancel_rounded, size: 18),
        label: const Text('ยกเลิกออเดอร์'),
      );
    });
  }
}

class _PaymentVerifyActions extends StatelessWidget {
  const _PaymentVerifyActions({required this.controller, required this.order});

  final MainHomeWebController controller;
  final AdminOrderModel order;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isUpdating =
          controller.updatingPaymentOrderId.value == order.id;
      final bool anotherOrderIsUpdating =
          controller.updatingPaymentOrderId.value.isNotEmpty && !isUpdating;
      final bool orderIsUpdating = controller.updatingOrderId.value.isNotEmpty;

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          OutlinedButton.icon(
            onPressed: order.hasPaymentSlip
                ? () => _showPaymentSlipDialog(
                    context,
                    controller: controller,
                    order: order,
                  )
                : null,
            icon: const Icon(Icons.receipt_long_rounded, size: 18),
            label: const Text('ดูสลิป'),
          ),
          FilledButton.icon(
            onPressed: isUpdating || anotherOrderIsUpdating || orderIsUpdating
                ? null
                : () => controller.verifyOrderPayment(order),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF16805A),
              foregroundColor: Colors.white,
            ),
            icon: isUpdating
                ? const SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.verified_rounded, size: 18),
            label: const Text('ยืนยันสลิป'),
          ),
          OutlinedButton.icon(
            onPressed: isUpdating || anotherOrderIsUpdating || orderIsUpdating
                ? null
                : () => controller.rejectOrderPayment(order),
            icon: const Icon(Icons.close_rounded, size: 18),
            label: const Text('ปฏิเสธ'),
          ),
        ],
      );
    });
  }
}

Future<void> _confirmCancelOrder(
  BuildContext context, {
  required MainHomeWebController controller,
  required AdminOrderModel order,
}) async {
  final bool confirmed =
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('ยกเลิกออเดอร์?'),
          content: Text(
            'ระบบจะยกเลิก ${order.orderNo} และคืนสินค้าทั้งหมดเข้าสต๊อก '
            'การดำเนินการนี้ย้อนกลับไม่ได้',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('กลับ'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC0392B),
                foregroundColor: Colors.white,
              ),
              child: const Text('ยืนยันยกเลิก'),
            ),
          ],
        ),
      ) ??
      false;

  if (!confirmed) {
    return;
  }

  await controller.updateOrderStatus(
    order: order,
    status: AdminOrderStatus.cancelled,
  );
}

Future<void> _confirmCashPayment(
  BuildContext context, {
  required MainHomeWebController controller,
  required AdminOrderModel order,
}) async {
  final bool confirmed =
      await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('ยืนยันการรับเงินสด?'),
          content: Text(
            'ยืนยันว่าได้รับเงินสด ${controller.formatCurrency(order.total)} '
            'สำหรับออเดอร์ ${order.orderNo} แล้ว',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('ยังไม่ได้รับ'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('ยืนยันรับเงิน'),
            ),
          ],
        ),
      ) ??
      false;

  if (confirmed) {
    await controller.confirmCashPayment(order);
  }
}

Future<void> _showOrderDetailDialog(
  BuildContext context, {
  required MainHomeWebController controller,
  required AdminOrderModel order,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) =>
        _OrderDetailDialog(controller: controller, order: order),
  );
}

class _OrderDetailDialog extends StatelessWidget {
  const _OrderDetailDialog({required this.controller, required this.order});

  final MainHomeWebController controller;
  final AdminOrderModel order;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color statusColor = _orderColor(order.status);
    final String pickupName = order.pickupInfo.pickupName.trim().isEmpty
        ? order.customerName
        : order.pickupInfo.pickupName.trim();
    final String pickupPhone = order.pickupInfo.pickupPhone.trim().isEmpty
        ? '-'
        : order.pickupInfo.pickupPhone.trim();
    final String pickupNote = order.pickupInfo.note.trim().isEmpty
        ? '-'
        : order.pickupInfo.note.trim();
    final String deliveryDistance = order.deliveryDistanceMeters == null
        ? '-'
        : controller.formatDistance(order.deliveryDistanceMeters!);
    final String deliveryCoordinate = order.hasDeliveryLocation
        ? '${order.deliveryLatitude!.toStringAsFixed(6)}, ${order.deliveryLongitude!.toStringAsFixed(6)}'
        : '-';

    return AlertDialog(
      insetPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        children: [
          Expanded(
            child: Text(
              order.orderNo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleLarge?.copyWith(
                color: AppConstant.appColorDark,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _StatusBadge(
            label: _orderStatusLabel(order.status),
            color: statusColor,
          ),
        ],
      ),
      content: SizedBox(
        width: 680,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _OrderDetailInfo(
                    label: 'ลูกค้า',
                    value: order.customerName,
                    icon: Icons.person_rounded,
                  ),
                  _OrderDetailInfo(
                    label: 'เวลาสั่ง',
                    value: controller.formatDateTime(order.createdAt),
                    icon: Icons.schedule_rounded,
                  ),
                  _OrderDetailInfo(
                    label: 'วิธีชำระ',
                    value: controller.paymentMethodLabel(order.paymentMethod),
                    icon: order.isCashPayment
                        ? Icons.payments_rounded
                        : Icons.qr_code_2_rounded,
                  ),
                  _OrderDetailInfo(
                    label: 'ชำระเงิน',
                    value: controller.paymentStatusLabel(
                      order.paymentStatus,
                      paymentMethod: order.paymentMethod,
                    ),
                    icon: Icons.payments_rounded,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                order.isDelivery ? 'ข้อมูลส่งฟรี' : 'ข้อมูลรับที่ร้าน',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppConstant.appColorDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (order.isDelivery) ...[
                _OrderDetailLine(
                  label: 'เงื่อนไข',
                  value: 'ส่งฟรีเฉพาะในหมู่บ้าน/รัศมี 1 กม. จากร้าน',
                ),
                _OrderDetailLine(label: 'ระยะจากร้าน', value: deliveryDistance),
                _OrderDetailLine(
                  label: 'พิกัดลูกค้า',
                  value: deliveryCoordinate,
                ),
                _OrderDetailLine(label: 'เบอร์โทร', value: pickupPhone),
                _OrderDetailLine(label: 'หมายเหตุ', value: pickupNote),
              ] else ...[
                _OrderDetailLine(label: 'ชื่อผู้รับ', value: pickupName),
                _OrderDetailLine(label: 'เบอร์โทร', value: pickupPhone),
                _OrderDetailLine(label: 'หมายเหตุ', value: pickupNote),
              ],
              const SizedBox(height: 18),
              Text(
                order.isCashPayment ? 'การชำระเงินสด' : 'สลิปชำระเงิน',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppConstant.appColorDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (order.isCashPayment)
                _StatusBadge(
                  label: order.paymentStatus == 'paid'
                      ? 'บันทึกรับเงินสดแล้ว'
                      : 'รอรับเงินสด ${controller.formatCurrency(order.total)}',
                  color: order.paymentStatus == 'paid'
                      ? const Color(0xFF16805A)
                      : const Color(0xFFB36B00),
                )
              else
                _PaymentSlipPreview(order: order),
              const SizedBox(height: 18),
              Text(
                'สินค้าในออเดอร์',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppConstant.appColorDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              if (order.items.isEmpty)
                Text(
                  'ไม่มีสินค้าในออเดอร์',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppConstant.appColorMuted,
                  ),
                )
              else
                ...order.items.map(
                  (item) =>
                      _OrderDetailItemTile(controller: controller, item: item),
                ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 14),
              _OrderDetailLine(
                label: 'Subtotal',
                value: controller.formatCurrency(order.subtotal),
              ),
              _OrderDetailLine(
                label: 'Discount',
                value: controller.formatCurrency(order.discount),
              ),
              _OrderDetailLine(
                label: 'Grand Total',
                value: controller.formatCurrency(order.total),
                emphasize: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        if (order.isCashPayment && order.paymentStatus == 'unpaid')
          FilledButton(
            onPressed: () {
              _confirmCashPayment(
                context,
                controller: controller,
                order: order,
              );
            },
            child: const Text('ได้รับเงินสดแล้ว'),
          ),
        if (order.paymentStatus == 'waiting_verify') ...[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.rejectOrderPayment(order);
            },
            child: const Text('ปฏิเสธสลิป'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              controller.verifyOrderPayment(order);
            },
            child: const Text('ยืนยันสลิป'),
          ),
        ],
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('ปิด'),
        ),
      ],
    );
  }
}

Future<void> _showPaymentSlipDialog(
  BuildContext context, {
  required MainHomeWebController controller,
  required AdminOrderModel order,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        insetPadding: const EdgeInsets.all(24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(order.orderNo),
        content: SizedBox(
          width: 420,
          child: _PaymentSlipPreview(order: order, large: true),
        ),
        actions: [
          if (order.paymentStatus == 'waiting_verify') ...[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.rejectOrderPayment(order);
              },
              child: const Text('ปฏิเสธ'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                controller.verifyOrderPayment(order);
              },
              child: const Text('ยืนยันสลิป'),
            ),
          ],
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      );
    },
  );
}

class _PaymentSlipPreview extends StatelessWidget {
  const _PaymentSlipPreview({required this.order, this.large = false});

  final AdminOrderModel order;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Uint8List? bytes = _decodeBase64Image(order.paymentSlipBase64);

    if (bytes == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppConstant.appColorSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppConstant.appColorBorder),
        ),
        child: Text(
          'ยังไม่มีสลิปจากลูกค้า',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppConstant.appColorMuted,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: AppConstant.appColorSurface,
        constraints: BoxConstraints(
          maxHeight: large ? 560 : 260,
          minHeight: large ? 320 : 180,
        ),
        child: Image.memory(bytes, fit: BoxFit.contain, width: double.infinity),
      ),
    );
  }
}

class _OrderDetailInfo extends StatelessWidget {
  const _OrderDetailInfo({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstant.appColorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppConstant.appColorBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppConstant.appColorDark),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppConstant.appColorMuted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppConstant.appColorDark,
                    fontWeight: FontWeight.w800,
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

class _OrderDetailLine extends StatelessWidget {
  const _OrderDetailLine({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppConstant.appColorMuted,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: emphasize
                    ? AppConstant.appColorDark
                    : AppConstant.appColorDeep,
                fontWeight: emphasize ? FontWeight.w900 : FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderDetailItemTile extends StatelessWidget {
  const _OrderDetailItemTile({required this.controller, required this.item});

  final MainHomeWebController controller;
  final OrderItemModel item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final imageBytes = item.imageBytes;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppConstant.appColorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppConstant.appColorBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 54,
              height: 54,
              child: imageBytes == null
                  ? Container(
                      color: AppConstant.appColorSoft,
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        color: AppConstant.appColorMuted,
                      ),
                    )
                  : Image.memory(imageBytes, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppConstant.appColorDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${controller.formatCurrency(item.price)}/${item.unit} x ${item.quantity}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppConstant.appColorMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            controller.formatCurrency(item.total),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppConstant.appColorDark,
              fontWeight: FontWeight.w900,
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
            child: Icon(icon, color: AppConstant.appColorDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppConstant.appColorDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppConstant.appColorMuted,
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
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppConstant.appColorDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: AppConstant.appColorDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppConstant.appColorMuted,
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
        ),
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
        color: AppConstant.appColorSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppConstant.appColorBorder),
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
                    color: AppConstant.appColorDark,
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
              backgroundColor: AppConstant.appColorSoft,
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
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: AppConstant.appColorDark),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: AppConstant.appColorDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showEditProductDialog(
  BuildContext context,
  AdminProductModel product,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) => _EditProductDialog(product: product),
  );
}

Future<void> _showDeleteProductDialog(
  BuildContext context,
  AdminProductModel product,
  String priceLabel,
) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (context) =>
        _DeleteProductDialog(product: product, priceLabel: priceLabel),
  );
}

const int _maxProductImages = 4;
const double _productImageMaxDimension = 800;
const int _productImageQuality = 72;

class _PickedProductImage {
  const _PickedProductImage({
    required this.bytes,
    required this.alt,
    required this.sortOrder,
  });

  final Uint8List bytes;
  final String alt;
  final int sortOrder;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'base64Image': base64Encode(bytes),
      'alt': alt,
      'sortOrder': sortOrder,
    };
  }
}

void _setAdminAuditLog({
  required WriteBatch batch,
  required FirebaseFirestore firestore,
  required String action,
  required String targetCollection,
  required String targetId,
  required Map<String, dynamic> data,
}) {
  final User? user = FirebaseAuth.instance.currentUser;
  final DocumentReference<Map<String, dynamic>> auditRef = firestore
      .collection('adminAuditLogs')
      .doc();

  batch.set(auditRef, <String, dynamic>{
    'action': action,
    'targetCollection': targetCollection,
    'targetId': targetId,
    'adminUid': user?.uid ?? '',
    'adminEmail': user?.email ?? '',
    'data': data,
    'createdAt': FieldValue.serverTimestamp(),
  });
}

class _DeleteProductDialog extends StatefulWidget {
  const _DeleteProductDialog({required this.product, required this.priceLabel});

  final AdminProductModel product;
  final String priceLabel;

  @override
  State<_DeleteProductDialog> createState() => _DeleteProductDialogState();
}

class _DeleteProductDialogState extends State<_DeleteProductDialog> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isDeleting = false;

  Future<void> _deleteProduct() async {
    setState(() => _isDeleting = true);

    try {
      final WriteBatch batch = _firestore.batch();
      batch.delete(_firestore.collection('product').doc(widget.product.id));
      _setAdminAuditLog(
        batch: batch,
        firestore: _firestore,
        action: 'product_deleted',
        targetCollection: 'product',
        targetId: widget.product.id,
        data: <String, dynamic>{
          'name': widget.product.name,
          'price': widget.product.price,
          'stock': widget.product.stock,
        },
      );
      await batch.commit();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ลบสินค้าเรียบร้อย')));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.errorSnackBar('ลบสินค้าไม่สำเร็จ กรุณาลองใหม่'),
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = _productAccentColor(widget.product);
    final Color surface = _productSurfaceColor(widget.product);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
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
                      color: const Color(0xFFFFE7E7),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFB42318),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'ยืนยันการลบสินค้า',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppConstant.appColorDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _isDeleting
                        ? null
                        : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 116,
                    height: 116,
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppConstant.appColorBorder),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: _ProductImage(
                      product: widget.product,
                      accent: accent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DeleteProductInfoRow(
                          label: 'ชื่อ',
                          value: widget.product.name,
                        ),
                        const SizedBox(height: 10),
                        _DeleteProductInfoRow(
                          label: 'ราคา',
                          value: widget.priceLabel,
                        ),
                        const SizedBox(height: 10),
                        _DeleteProductInfoRow(
                          label: 'สต๊อก',
                          value:
                              '${widget.product.stock} ${widget.product.unit}',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'ต้องการลบสินค้านี้ออกจาก Firebase collection product หรือไม่?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppConstant.appColorMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isDeleting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('ยกเลิก'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    onPressed: _isDeleting ? null : _deleteProduct,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFB42318),
                      foregroundColor: Colors.white,
                    ),
                    icon: _isDeleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.delete_outline_rounded),
                    label: Text(_isDeleting ? 'กำลังลบ...' : 'ยืนยันการลบ'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteProductInfoRow extends StatelessWidget {
  const _DeleteProductInfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: AppConstant.appColorMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: AppConstant.appColorDeep,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EditProductDialog extends StatefulWidget {
  const _EditProductDialog({required this.product});

  final AdminProductModel product;

  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _shortDescriptionController;
  late final TextEditingController _detailDescriptionController;
  late final TextEditingController _conditionController;
  late final TextEditingController _categoryController;
  late final TextEditingController _tagsController;
  late final TextEditingController _priceController;
  late final TextEditingController _unitController;
  late final TextEditingController _stockController;

  Uint8List? _selectedImageBytes;
  late final List<_PickedProductImage> _galleryImages;
  String? _selectedImageName;
  bool _isPickingImage = false;
  bool _isPickingGalleryImages = false;
  bool _isSaving = false;
  bool _submitted = false;
  bool _imageEditing = false;
  bool _nameEditing = false;
  bool _descriptionEditing = false;
  bool _advancedEditing = false;
  bool _isActive = true;
  bool _isRecommended = false;
  bool _priceEditing = false;
  bool _unitEditing = false;
  bool _stockEditing = false;

  bool get _hasImage => _selectedImageBytes != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product.name);
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _shortDescriptionController = TextEditingController(
      text: widget.product.shortDescription,
    );
    _detailDescriptionController = TextEditingController(
      text: widget.product.detailDescription,
    );
    _conditionController = TextEditingController(
      text: widget.product.condition,
    );
    _categoryController = TextEditingController(text: widget.product.category);
    _tagsController = TextEditingController(
      text: widget.product.tags.join(', '),
    );
    _priceController = TextEditingController(
      text: _formatNumber(widget.product.price),
    );
    _unitController = TextEditingController(text: widget.product.unit);
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _selectedImageBytes = widget.product.imageBytes;
    _galleryImages =
        widget.product.images
            .map((image) {
              return _PickedProductImage(
                bytes: image.imageBytes ?? Uint8List(0),
                alt: image.alt,
                sortOrder: image.sortOrder,
              );
            })
            .where((image) => image.bytes.isNotEmpty)
            .toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    _isActive = widget.product.isActive;
    _isRecommended = widget.product.isRecommended;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _detailDescriptionController.dispose();
    _conditionController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
      _imageEditing = true;
    });

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: _productImageMaxDimension,
        maxHeight: _productImageMaxDimension,
        imageQuality: _productImageQuality,
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
        AppSnackbar.errorSnackBar('ยังไม่สามารถเลือกรูปภาพได้ในตอนนี้'),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _pickGalleryImages() async {
    final int remainingSlots = _maxProductImages - _galleryImages.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.errorSnackBar('เพิ่มรูปสินค้าได้สูงสุด 4 รูป'),
      );
      return;
    }

    setState(() {
      _isPickingGalleryImages = true;
      _imageEditing = true;
    });

    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: _productImageMaxDimension,
        maxHeight: _productImageMaxDimension,
        imageQuality: _productImageQuality,
      );

      if (pickedFiles.isEmpty) {
        return;
      }

      final List<_PickedProductImage> nextImages = <_PickedProductImage>[
        ..._galleryImages,
      ];
      for (final XFile file in pickedFiles.take(remainingSlots)) {
        final Uint8List bytes = await file.readAsBytes();
        nextImages.add(
          _PickedProductImage(
            bytes: bytes,
            alt: file.name,
            sortOrder: nextImages.length,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _galleryImages
          ..clear()
          ..addAll(_normalizeGalleryImages(nextImages));
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.errorSnackBar('ยังไม่สามารถเลือกรูปภาพได้ในตอนนี้'),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingGalleryImages = false);
      }
    }
  }

  Future<void> _validateAndSubmit() async {
    setState(() => _submitted = true);

    final bool isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || !_hasImage) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final Map<String, dynamic> productData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'shortDescription': _shortDescriptionController.text.trim(),
        'detailDescription': _detailDescriptionController.text.trim(),
        'condition': _conditionController.text.trim(),
        'category': _categoryController.text.trim().isEmpty
            ? 'General'
            : _categoryController.text.trim(),
        'tags': _parseTags(_tagsController.text),
        'base64Image': _selectedImageBytes == null
            ? widget.product.base64Image
            : base64Encode(_selectedImageBytes!),
        'images': _normalizeGalleryImages(
          _galleryImages,
        ).map((image) => image.toMap()).toList(),
        'unit': _unitController.text.trim(),
        'price': num.parse(_priceController.text.trim()),
        'stock': int.parse(_stockController.text.trim()),
        'isActive': _isActive,
        'isRecommended': _isRecommended,
        'relatedProductIds': widget.product.relatedProductIds,
        'soldCount': widget.product.soldCount,
        'viewCount': widget.product.viewCount,
        'lastUpdatedBy': FirebaseAuth.instance.currentUser?.uid ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'timestamp': Timestamp.now(),
      };
      final WriteBatch batch = _firestore.batch();
      batch.update(
        _firestore.collection('product').doc(widget.product.id),
        productData,
      );
      _setAdminAuditLog(
        batch: batch,
        firestore: _firestore,
        action: 'product_updated',
        targetCollection: 'product',
        targetId: widget.product.id,
        data: <String, dynamic>{
          'name': productData['name'],
          'price': productData['price'],
          'stock': productData['stock'],
          'isActive': productData['isActive'],
          'isRecommended': productData['isRecommended'],
        },
      );
      await batch.commit();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('อัปเดตสินค้าเรียบร้อย')));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.errorSnackBar('อัปเดตสินค้าไม่สำเร็จ กรุณาลองใหม่'),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
        constraints: const BoxConstraints(maxWidth: 820),
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(theme),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final bool stacked = constraints.maxWidth < 700;
                    final Widget imageSection = _buildImageSection(theme);
                    final Widget detailSection = _buildDetailSection(theme);

                    if (stacked) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          imageSection,
                          const SizedBox(height: 16),
                          detailSection,
                        ],
                      );
                    }

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: imageSection),
                        const SizedBox(width: 18),
                        Expanded(flex: 6, child: detailSection),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: AppConstant.appColorSoft,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.edit_note_rounded,
            color: AppConstant.appColorDark,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'แก้ไขสินค้า',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppConstant.appColorDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppConstant.appColorMuted,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.of(context).pop(),
          child: const Text('ยกเลิก'),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: _isSaving ? null : _validateAndSubmit,
          icon: _isSaving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.save_outlined),
          label: Text(_isSaving ? 'กำลังบันทึก...' : 'บันทึก'),
        ),
      ],
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return _EditableSection(
      title: 'รูปภาพสินค้า',
      icon: Icons.image_outlined,
      isEditing: _imageEditing,
      onEdit: _isSaving ? null : () => setState(() => _imageEditing = true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: !_submitted || _hasImage
                      ? AppConstant.appColorBorder
                      : theme.colorScheme.error,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: _selectedImageBytes == null
                  ? Icon(
                      Icons.image_not_supported_outlined,
                      color: theme.colorScheme.error,
                      size: 48,
                    )
                  : Image.memory(_selectedImageBytes!, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: !_imageEditing || _isPickingImage || _isSaving
                  ? null
                  : _pickImage,
              icon: _isPickingImage
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_library_outlined),
              label: Text(_hasImage ? 'เปลี่ยนรูป' : 'เลือกรูป'),
            ),
          ),
          if (_selectedImageName != null) ...[
            const SizedBox(height: 8),
            Text(
              _selectedImageName!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppConstant.appColorMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (_submitted && !_hasImage) ...[
            const SizedBox(height: 8),
            Text(
              'กรุณาเลือกรูปสินค้า',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildGalleryEditor(theme),
        ],
      ),
    );
  }

  Widget _buildGalleryEditor(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'รูปเพิ่มเติม ${_galleryImages.length}/$_maxProductImages',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppConstant.appColorDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            IconButton(
              tooltip: 'เพิ่มรูป',
              onPressed:
                  !_imageEditing ||
                      _isSaving ||
                      _isPickingGalleryImages ||
                      _galleryImages.length >= _maxProductImages
                  ? null
                  : _pickGalleryImages,
              icon: _isPickingGalleryImages
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_photo_alternate_outlined),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_galleryImages.isEmpty)
          Text(
            'เพิ่มได้สูงสุด 4 รูป ระบบจะย่อไม่เกิน 800 x 800 ก่อนบันทึก',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppConstant.appColorMuted,
              height: 1.45,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List<Widget>.generate(_galleryImages.length, (index) {
              final _PickedProductImage image = _galleryImages[index];
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.memory(
                      image.bytes,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: InkWell(
                      onTap: !_imageEditing || _isSaving
                          ? null
                          : () {
                              final List<_PickedProductImage> nextImages =
                                  <_PickedProductImage>[..._galleryImages]
                                    ..removeAt(index);
                              setState(() {
                                _galleryImages
                                  ..clear()
                                  ..addAll(_normalizeGalleryImages(nextImages));
                              });
                            },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xCC202020),
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(3),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
      ],
    );
  }

  Widget _buildDetailSection(ThemeData theme) {
    return Column(
      children: [
        _EditableSection(
          title: 'ชื่อสินค้า',
          icon: Icons.inventory_2_outlined,
          isEditing: _nameEditing,
          onEdit: _isSaving ? null : () => setState(() => _nameEditing = true),
          child: _buildTextField(
            controller: _nameController,
            label: 'ชื่อสินค้า',
            hintText: 'เช่น เสื้อยืดคอกลม',
            prefixIcon: Icons.inventory_2_outlined,
            enabled: _nameEditing && !_isSaving,
            validator: _requiredValidator('กรุณากรอกชื่อสินค้า'),
          ),
        ),
        const SizedBox(height: 12),
        _EditableSection(
          title: 'รายละเอียด',
          icon: Icons.notes_rounded,
          isEditing: _descriptionEditing,
          onEdit: _isSaving
              ? null
              : () => setState(() => _descriptionEditing = true),
          child: _buildTextField(
            controller: _descriptionController,
            label: 'รายละเอียดสินค้า',
            hintText: 'อธิบายจุดเด่นของสินค้า วัสดุ หรือขนาด',
            prefixIcon: Icons.notes_rounded,
            enabled: _descriptionEditing && !_isSaving,
            maxLines: 3,
            validator: _requiredValidator('กรุณากรอกรายละเอียดสินค้า'),
          ),
        ),
        const SizedBox(height: 12),
        _EditableSection(
          title: 'ข้อมูลสำหรับหน้า Detail',
          icon: Icons.article_outlined,
          isEditing: _advancedEditing,
          onEdit: _isSaving
              ? null
              : () => setState(() => _advancedEditing = true),
          child: Column(
            children: [
              _buildTextField(
                controller: _shortDescriptionController,
                label: 'คำอธิบายสั้น',
                hintText: 'ข้อความสั้นสำหรับการ์ดสินค้า',
                prefixIcon: Icons.short_text_rounded,
                enabled: _advancedEditing && !_isSaving,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _detailDescriptionController,
                label: 'รายละเอียดเต็ม',
                hintText: 'รายละเอียดสำหรับหน้า Product Detail',
                prefixIcon: Icons.article_outlined,
                enabled: _advancedEditing && !_isSaving,
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _conditionController,
                label: 'เงื่อนไขสินค้า',
                hintText: 'เช่น เก็บในตู้เย็น ควรบริโภคภายใน 3 วัน',
                prefixIcon: Icons.rule_rounded,
                enabled: _advancedEditing && !_isSaving,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _categoryController,
                      label: 'หมวดหมู่',
                      hintText: 'General',
                      prefixIcon: Icons.category_outlined,
                      enabled: _advancedEditing && !_isSaving,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _tagsController,
                      label: 'Tags',
                      hintText: 'ขายดี, โปร, สดใหม่',
                      prefixIcon: Icons.sell_outlined,
                      enabled: _advancedEditing && !_isSaving,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isActive,
                onChanged: !_advancedEditing || _isSaving
                    ? null
                    : (value) => setState(() => _isActive = value),
                title: const Text('เปิดขายสินค้า'),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _isRecommended,
                onChanged: !_advancedEditing || _isSaving
                    ? null
                    : (value) => setState(() => _isRecommended = value),
                title: const Text('สินค้าแนะนำ'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _EditableSection(
                title: 'ราคา',
                icon: Icons.sell_outlined,
                isEditing: _priceEditing,
                onEdit: _isSaving
                    ? null
                    : () => setState(() => _priceEditing = true),
                child: _buildTextField(
                  controller: _priceController,
                  label: 'ราคา',
                  hintText: '0.00',
                  prefixIcon: Icons.sell_outlined,
                  enabled: _priceEditing && !_isSaving,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _priceValidator,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _EditableSection(
                title: 'หน่วย',
                icon: Icons.straighten_outlined,
                isEditing: _unitEditing,
                onEdit: _isSaving
                    ? null
                    : () => setState(() => _unitEditing = true),
                child: _buildTextField(
                  controller: _unitController,
                  label: 'หน่วย',
                  hintText: 'ชิ้น / กล่อง / แพ็ก',
                  prefixIcon: Icons.straighten_outlined,
                  enabled: _unitEditing && !_isSaving,
                  validator: _requiredValidator('กรุณากรอกหน่วย'),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _EditableSection(
          title: 'สต๊อก',
          icon: Icons.warehouse_outlined,
          isEditing: _stockEditing,
          onEdit: _isSaving ? null : () => setState(() => _stockEditing = true),
          child: _buildTextField(
            controller: _stockController,
            label: 'จำนวนสต๊อก',
            hintText: '0',
            prefixIcon: Icons.warehouse_outlined,
            enabled: _stockEditing && !_isSaving,
            keyboardType: TextInputType.number,
            validator: _stockValidator,
          ),
        ),
      ],
    );
  }

  String? Function(String?) _requiredValidator(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }

      return null;
    };
  }

  String? _priceValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกราคา';
    }

    final double? price = double.tryParse(value.trim());
    if (price == null) {
      return 'กรุณากรอกราคาเป็นตัวเลข';
    }

    if (price <= 0) {
      return 'ราคาต้องมากกว่า 0';
    }

    return null;
  }

  String? _stockValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกจำนวนสต๊อก';
    }

    final int? stock = int.tryParse(value.trim());
    if (stock == null) {
      return 'สต๊อกต้องเป็นจำนวนเต็มเท่านั้น';
    }

    if (stock < 0) {
      return 'สต๊อกต้องไม่ติดลบ';
    }

    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    required bool enabled,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: enabled
            ? AppConstant.appColorSurface
            : AppConstant.appColorSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppConstant.appColorBorder),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppConstant.appColorBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppConstant.appColorBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppConstant.appColor, width: 1.3),
        ),
      ),
    );
  }

  String _formatNumber(num value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  List<String> _parseTags(String value) {
    return value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  List<_PickedProductImage> _normalizeGalleryImages(
    List<_PickedProductImage> images,
  ) {
    return List<_PickedProductImage>.generate(images.length, (index) {
      final _PickedProductImage image = images[index];
      return _PickedProductImage(
        bytes: image.bytes,
        alt: image.alt,
        sortOrder: index,
      );
    });
  }
}

class _EditableSection extends StatelessWidget {
  const _EditableSection({
    required this.title,
    required this.icon,
    required this.isEditing,
    required this.child,
    this.onEdit,
  });

  final String title;
  final IconData icon;
  final bool isEditing;
  final Widget child;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppConstant.appColorSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEditing
              ? AppConstant.appColorLight
              : AppConstant.appColorBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppConstant.appColorDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppConstant.appColorDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Tooltip(
                message: isEditing ? 'กำลังแก้ไข' : 'แก้ไขส่วนนี้',
                child: IconButton.filledTonal(
                  onPressed: onEdit,
                  icon: Icon(
                    isEditing ? Icons.check_circle_rounded : Icons.edit_rounded,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product, required this.accent});

  final AdminProductModel product;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final Uint8List? imageBytes = product.imageBytes;

    if (imageBytes == null) {
      return Icon(_productIcon(product), color: accent);
    }

    return Image.memory(
      imageBytes,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) =>
          Icon(_productIcon(product), color: accent),
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
      return AppConstant.appColorMuted;
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
      return AppConstant.appColorSurface;
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
    case AdminOrderStatus.pending:
      return 'รอร้านรับ';
    case AdminOrderStatus.accepted:
      return 'รับออเดอร์แล้ว';
    case AdminOrderStatus.preparing:
      return 'กำลังเตรียม';
    case AdminOrderStatus.ready:
      return 'พร้อมให้รับ';
    case AdminOrderStatus.completed:
      return 'สำเร็จ';
    case AdminOrderStatus.cancelled:
      return 'ยกเลิก';
  }
}

String _orderActionLabel(AdminOrderStatus status) {
  switch (status) {
    case AdminOrderStatus.accepted:
      return 'รับออเดอร์';
    case AdminOrderStatus.preparing:
      return 'เริ่มเตรียม';
    case AdminOrderStatus.ready:
      return 'พร้อมรับ';
    case AdminOrderStatus.completed:
      return 'ลูกค้ารับแล้ว';
    case AdminOrderStatus.cancelled:
      return 'ยกเลิก';
    case AdminOrderStatus.pending:
      return 'รอร้านรับ';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _shortDescriptionController =
      TextEditingController();
  final TextEditingController _detailDescriptionController =
      TextEditingController();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController(
    text: 'General',
  );
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  Uint8List? _selectedImageBytes;
  final List<_PickedProductImage> _galleryImages = <_PickedProductImage>[];
  String? _selectedImageName;
  bool _isPickingImage = false;
  bool _isPickingGalleryImages = false;
  bool _isSaving = false;
  bool _submitted = false;
  String? _imageErrorText;
  bool _isActive = true;
  bool _isRecommended = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _shortDescriptionController.dispose();
    _detailDescriptionController.dispose();
    _conditionController.dispose();
    _categoryController.dispose();
    _tagsController.dispose();
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
        maxWidth: _productImageMaxDimension,
        maxHeight: _productImageMaxDimension,
        imageQuality: _productImageQuality,
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
        _imageErrorText = null;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.errorSnackBar('ยังไม่สามารถเลือกรูปภาพได้ในตอนนี้'),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _pickGalleryImages() async {
    final int remainingSlots = _maxProductImages - _galleryImages.length;
    if (remainingSlots <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.errorSnackBar('เพิ่มรูปสินค้าได้สูงสุด 4 รูป'),
      );
      return;
    }

    setState(() => _isPickingGalleryImages = true);

    try {
      final List<XFile> pickedFiles = await _imagePicker.pickMultiImage(
        maxWidth: _productImageMaxDimension,
        maxHeight: _productImageMaxDimension,
        imageQuality: _productImageQuality,
      );

      if (pickedFiles.isEmpty) {
        return;
      }

      final List<_PickedProductImage> nextImages = <_PickedProductImage>[
        ..._galleryImages,
      ];
      for (final XFile file in pickedFiles.take(remainingSlots)) {
        final Uint8List bytes = await file.readAsBytes();
        nextImages.add(
          _PickedProductImage(
            bytes: bytes,
            alt: file.name,
            sortOrder: nextImages.length,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _galleryImages
          ..clear()
          ..addAll(_normalizeGalleryImages(nextImages));
      });
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.errorSnackBar('ยังไม่สามารถเลือกรูปภาพได้ในตอนนี้'),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingGalleryImages = false);
      }
    }
  }

  Future<void> _validateAndSubmit() async {
    setState(() {
      _submitted = true;
      _imageErrorText = _selectedImageBytes == null
          ? 'กรุณาเลือกรูปสินค้า'
          : null;
    });

    final bool isFormValid = _formKey.currentState?.validate() ?? false;
    final bool hasImage = _selectedImageBytes != null;
    if (!isFormValid || !hasImage) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final String adminUid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final Timestamp now = Timestamp.now();
      final ProductModel product = ProductModel(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        shortDescription: _shortDescriptionController.text.trim(),
        detailDescription: _detailDescriptionController.text.trim(),
        condition: _conditionController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? 'General'
            : _categoryController.text.trim(),
        tags: _parseTags(_tagsController.text),
        base64Image: base64Encode(_selectedImageBytes!),
        images: _normalizeGalleryImages(_galleryImages)
            .map(
              (image) => ProductImageModel(
                base64Image: base64Encode(image.bytes),
                alt: image.alt,
                sortOrder: image.sortOrder,
              ),
            )
            .toList(),
        unit: _unitController.text.trim(),
        price: num.parse(_priceController.text.trim()),
        stock: num.parse(_stockController.text.trim()),
        isActive: _isActive,
        isRecommended: _isRecommended,
        createdAt: now,
        updatedAt: now,
        timestamp: now,
      );

      final DocumentReference<Map<String, dynamic>> productRef = _firestore
          .collection('product')
          .doc();
      final Map<String, dynamic> productData = <String, dynamic>{
        ...product.toMap(),
        'createdBy': adminUid,
        'lastUpdatedBy': adminUid,
      };
      final WriteBatch batch = _firestore.batch();
      batch.set(productRef, productData);
      _setAdminAuditLog(
        batch: batch,
        firestore: _firestore,
        action: 'product_created',
        targetCollection: 'product',
        targetId: productRef.id,
        data: <String, dynamic>{
          'name': product.name,
          'price': product.price,
          'stock': product.stock,
          'isActive': product.isActive,
          'isRecommended': product.isRecommended,
        },
      );
      await batch.commit();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกสินค้าเรียบร้อย')));
      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        AppSnackbar.errorSnackBar('บันทึกสินค้าไม่สำเร็จ กรุณาลองใหม่'),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
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
        child: Form(
          key: _formKey,
          autovalidateMode: _submitted
              ? AutovalidateMode.always
              : AutovalidateMode.disabled,
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
                        color: AppConstant.appColorSoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.add_business_rounded,
                        color: AppConstant.appColorDark,
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
                              color: AppConstant.appColorDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'เตรียม UI สำหรับเลือกรูปภาพและกรอกข้อมูลสินค้า ก่อนเชื่อมต่อ Firebase จริง',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppConstant.appColorMuted,
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
                      onPressed: _isSaving
                          ? null
                          : () => Navigator.of(context).pop(),
                      child: const Text('ยกเลิก'),
                    ),
                    const SizedBox(width: 12),
                    FilledButton.icon(
                      onPressed: _isSaving ? null : _validateAndSubmit,
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save_outlined),
                      label: Text(
                        _isSaving ? 'กำลังบันทึก...' : 'บันทึกสินค้า',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppConstant.appColorSurface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _imageErrorText == null
              ? AppConstant.appColorBorder
              : theme.colorScheme.error,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'รูปสินค้า',
            style: theme.textTheme.titleMedium?.copyWith(
              color: AppConstant.appColorDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เลือกจาก Gallery ระบบจะย่อรูปไม่เกิน 800 x 800 ก่อนบันทึก',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppConstant.appColorMuted,
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
                border: Border.all(color: AppConstant.appColorBorder),
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
                color: AppConstant.appColorMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (_imageErrorText != null) ...[
            const SizedBox(height: 10),
            Text(
              _imageErrorText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  'รูปเพิ่มเติม ${_galleryImages.length}/$_maxProductImages',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: AppConstant.appColorDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'เพิ่มรูป',
                onPressed:
                    _isPickingGalleryImages ||
                        _galleryImages.length >= _maxProductImages
                    ? null
                    : _pickGalleryImages,
                icon: _isPickingGalleryImages
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add_photo_alternate_outlined),
              ),
            ],
          ),
          if (_galleryImages.isEmpty)
            Text(
              'เพิ่มได้สูงสุด 4 รูป',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppConstant.appColorMuted,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List<Widget>.generate(_galleryImages.length, (index) {
                final _PickedProductImage image = _galleryImages[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.memory(
                        image.bytes,
                        width: 68,
                        height: 68,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      right: 2,
                      top: 2,
                      child: InkWell(
                        onTap: _isSaving
                            ? null
                            : () {
                                final List<_PickedProductImage> nextImages =
                                    <_PickedProductImage>[..._galleryImages]
                                      ..removeAt(index);
                                setState(() {
                                  _galleryImages
                                    ..clear()
                                    ..addAll(
                                      _normalizeGalleryImages(nextImages),
                                    );
                                });
                              },
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xCC202020),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(3),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
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
                color: AppConstant.appColorSoft,
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.image_outlined,
                color: AppConstant.appColorDark,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'ยังไม่ได้เลือกรูปสินค้า',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppConstant.appColorDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'รูปจะถูกย่อไม่เกิน 800 x 800 และบันทึกเป็น Base64 ใน Firestore',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppConstant.appColorMuted,
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
          validator: _requiredValidator('กรุณากรอกชื่อสินค้า'),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _descriptionController,
          label: 'รายละเอียดสินค้า',
          hintText: 'อธิบายจุดเด่นของสินค้า วัสดุ หรือขนาด',
          prefixIcon: Icons.notes_rounded,
          maxLines: 4,
          validator: _requiredValidator('กรุณากรอกรายละเอียดสินค้า'),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _shortDescriptionController,
          label: 'คำอธิบายสั้น',
          hintText: 'ข้อความสั้นสำหรับการ์ดสินค้า',
          prefixIcon: Icons.short_text_rounded,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _detailDescriptionController,
          label: 'รายละเอียดเต็ม',
          hintText: 'รายละเอียดสำหรับหน้า Product Detail',
          prefixIcon: Icons.article_outlined,
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _conditionController,
          label: 'เงื่อนไขสินค้า',
          hintText: 'เช่น เก็บในตู้เย็น ควรบริโภคภายใน 3 วัน',
          prefixIcon: Icons.rule_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _categoryController,
                label: 'หมวดหมู่',
                hintText: 'General',
                prefixIcon: Icons.category_outlined,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _tagsController,
                label: 'Tags',
                hintText: 'ขายดี, โปร, สดใหม่',
                prefixIcon: Icons.sell_outlined,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isActive,
          onChanged: _isSaving
              ? null
              : (value) => setState(() => _isActive = value),
          title: const Text('เปิดขายสินค้า'),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          value: _isRecommended,
          onChanged: _isSaving
              ? null
              : (value) => setState(() => _isRecommended = value),
          title: const Text('สินค้าแนะนำ'),
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
                validator: _priceValidator,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTextField(
                controller: _unitController,
                label: 'หน่วย',
                hintText: 'ชิ้น / กล่อง / แพ็ก',
                prefixIcon: Icons.straighten_outlined,
                validator: _requiredValidator('กรุณากรอกหน่วย'),
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
          validator: _stockValidator,
        ),
      ],
    );
  }

  String? Function(String?) _requiredValidator(String message) {
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }

      return null;
    };
  }

  String? _priceValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกราคา';
    }

    final double? price = double.tryParse(value.trim());
    if (price == null) {
      return 'กรุณากรอกราคาเป็นตัวเลข';
    }

    if (price <= 0) {
      return 'ราคาต้องมากกว่า 0';
    }

    return null;
  }

  String? _stockValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'กรุณากรอกจำนวนสต๊อก';
    }

    final int? stock = int.tryParse(value.trim());
    if (stock == null) {
      return 'สต๊อกต้องเป็นจำนวนเต็มเท่านั้น';
    }

    return null;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        alignLabelWithHint: maxLines > 1,
        filled: true,
        fillColor: AppConstant.appColorSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppConstant.appColorBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppConstant.appColorBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppConstant.appColor, width: 1.3),
        ),
      ),
    );
  }

  List<String> _parseTags(String value) {
    return value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  List<_PickedProductImage> _normalizeGalleryImages(
    List<_PickedProductImage> images,
  ) {
    return List<_PickedProductImage>.generate(images.length, (index) {
      final _PickedProductImage image = images[index];
      return _PickedProductImage(
        bytes: image.bytes,
        alt: image.alt,
        sortOrder: index,
      );
    });
  }
}

Color _orderColor(AdminOrderStatus status) {
  switch (status) {
    case AdminOrderStatus.pending:
      return const Color(0xFFDA7A12);
    case AdminOrderStatus.accepted:
      return AppConstant.appColor;
    case AdminOrderStatus.preparing:
      return const Color(0xFF9254DE);
    case AdminOrderStatus.ready:
      return const Color(0xFF16805A);
    case AdminOrderStatus.completed:
      return AppConstant.appColorMuted;
    case AdminOrderStatus.cancelled:
      return const Color(0xFFD05A2D);
  }
}

Color _paymentStatusColor(String status) {
  return switch (status) {
    'paid' => const Color(0xFF16805A),
    'waiting_verify' => const Color(0xFFDA7A12),
    'rejected' => const Color(0xFFD05A2D),
    _ => AppConstant.appColorMuted,
  };
}

Uint8List? _decodeBase64Image(String base64Image) {
  if (base64Image.trim().isEmpty) {
    return null;
  }

  try {
    final String normalized = base64Image.contains(',')
        ? base64Image.split(',').last
        : base64Image;
    return base64Decode(normalized);
  } catch (_) {
    return null;
  }
}

IconData _orderIcon(AdminOrderStatus status) {
  switch (status) {
    case AdminOrderStatus.pending:
      return Icons.pending_actions_rounded;
    case AdminOrderStatus.accepted:
      return Icons.task_alt_rounded;
    case AdminOrderStatus.preparing:
      return Icons.inventory_2_rounded;
    case AdminOrderStatus.ready:
      return Icons.storefront_rounded;
    case AdminOrderStatus.completed:
      return Icons.verified_rounded;
    case AdminOrderStatus.cancelled:
      return Icons.cancel_rounded;
  }
}
