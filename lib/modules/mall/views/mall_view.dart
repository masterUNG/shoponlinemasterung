import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/mall_controller.dart';

class MallView extends GetView<MallController> {
  const MallView({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ColoredBox(
      color: const Color(0xFFF5F7FF),
      child: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: controller.refreshProducts,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _MallHeader(theme: theme)),
              Obx(() {
                if (controller.isLoading.value) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _MallState(
                      icon: Icons.wifi_off_rounded,
                      title: controller.errorMessage.value,
                      subtitle: 'ดึงลงเพื่อโหลดข้อมูลใหม่อีกครั้ง',
                    ),
                  );
                }

                if (controller.products.isEmpty) {
                  return const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _MallState(
                      icon: Icons.inventory_2_outlined,
                      title: 'ยังไม่มีสินค้า',
                      subtitle: 'เมื่อเพิ่มสินค้าใน Firebase จะแสดงที่นี่ทันที',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  sliver: SliverLayoutBuilder(
                    builder: (context, constraints) {
                      final double width = constraints.crossAxisExtent;
                      final int crossAxisCount = width >= 720 ? 3 : 2;
                      final double aspectRatio = width >= 720 ? 0.76 : 0.64;

                      return SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _ProductCard(
                            item: controller.products[index],
                            priceLabel: controller.formatCurrency(
                              controller.products[index].product.price,
                            ),
                          );
                        }, childCount: controller.products.length),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: aspectRatio,
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _MallHeader extends GetView<MallController> {
  const _MallHeader({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF172B7A),
          borderRadius: BorderRadius.circular(26),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mall',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      '${controller.products.length} สินค้าล่าสุดจากร้าน',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFFDCE5FF),
                      ),
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

class _ProductCard extends GetView<MallController> {
  const _ProductCard({required this.item, required this.priceLabel});

  final MallProductItem item;
  final String priceLabel;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final product = item.product;
    final imageBytes = product.imageBytes;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: InkWell(
        onTap: item.isOutOfStock ? null : () => _showQuantityDialog(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (imageBytes == null)
                    Container(
                      color: const Color(0xFFE8ECFA),
                      child: const Icon(
                        Icons.image_not_supported_rounded,
                        color: Color(0xFF7D87A8),
                        size: 42,
                      ),
                    )
                  else
                    Image.memory(imageBytes, fit: BoxFit.cover),
                  Positioned(left: 10, top: 10, child: _StockBadge(item: item)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF17224D),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    product.description.trim().isEmpty
                        ? 'ไม่มีรายละเอียดสินค้า'
                        : product.description.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.35,
                      color: const Color(0xFF687191),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$priceLabel/${product.unit}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            color: const Color(0xFF25388F),
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        visualDensity: VisualDensity.compact,
                        onPressed: item.isOutOfStock
                            ? null
                            : () => _showQuantityDialog(context),
                        icon: const Icon(Icons.add_shopping_cart_rounded),
                        tooltip: 'Add to cart',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQuantityDialog(BuildContext context) {
    final int maxQuantity = item.product.stock.toInt();
    final imageBytes = item.product.imageBytes;
    int quantity = 1;

    Get.dialog<void>(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              item.product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: AspectRatio(
                    aspectRatio: 16 / 10,
                    child: imageBytes == null
                        ? Container(
                            color: const Color(0xFFE8ECFA),
                            child: const Icon(
                              Icons.image_not_supported_rounded,
                              color: Color(0xFF7D87A8),
                              size: 46,
                            ),
                          )
                        : Image.memory(imageBytes, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '${controller.formatCurrency(item.product.price)}/${item.product.unit}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF25388F),
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'คงเหลือ $maxQuantity ${item.product.unit}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF687191),
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4FF),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton.filledTonal(
                        onPressed: quantity <= 1
                            ? null
                            : () => setState(() => quantity--),
                        icon: const Icon(Icons.remove_rounded),
                        tooltip: 'ลดจำนวน',
                      ),
                      Expanded(
                        child: Text(
                          '$quantity',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: const Color(0xFF17224D),
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                      ),
                      IconButton.filledTonal(
                        onPressed: quantity >= maxQuantity
                            ? null
                            : () => setState(() => quantity++),
                        icon: const Icon(Icons.add_rounded),
                        tooltip: 'เพิ่มจำนวน',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: Get.back, child: const Text('ยกเลิก')),
              Obx(
                () => FilledButton(
                  onPressed: controller.isAddingToCart.value
                      ? null
                      : () async {
                          final bool added = await controller.addToCart(
                            item: item,
                            quantity: quantity,
                          );

                          if (added) {
                            Get.back<void>();
                            Get.snackbar(
                              'เพิ่มลงตะกร้าแล้ว',
                              '${item.product.name} จำนวน $quantity ${item.product.unit}',
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        },
                  child: controller.isAddingToCart.value
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Confirm'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.item});

  final MallProductItem item;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor;
    final Color foregroundColor;
    final String label;

    if (item.isOutOfStock) {
      backgroundColor = const Color(0xFFECEFF5);
      foregroundColor = const Color(0xFF667085);
      label = 'หมด';
    } else if (item.isLowStock) {
      backgroundColor = const Color(0xFFFFE8B3);
      foregroundColor = const Color(0xFF7A4D00);
      label = 'ใกล้หมด';
    } else {
      backgroundColor = const Color(0xFFDDF8E8);
      foregroundColor = const Color(0xFF176B3B);
      label = 'พร้อมขาย';
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            color: foregroundColor,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _MallState extends StatelessWidget {
  const _MallState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: const Color(0xFF7D87A8)),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF17224D),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF687191),
            ),
          ),
        ],
      ),
    );
  }
}
