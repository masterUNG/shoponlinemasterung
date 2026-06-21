import 'package:flutter/material.dart';
import 'package:shoponlinemasterung/core/app_constant.dart';
import 'package:get/get.dart';

import '../../../model/order_model.dart';
import '../controllers/cart_controller.dart';

class CartView extends GetView<CartController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppConstant.appColorSurface,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _CartHeader(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshCart,
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(height: MediaQuery.sizeOf(context).height / 5),
                        _CartState(
                          icon: Icons.wifi_off_rounded,
                          title: controller.errorMessage.value,
                          subtitle: 'ดึงลงเพื่อโหลดข้อมูลใหม่อีกครั้ง',
                        ),
                      ],
                    );
                  }

                  if (controller.cartItems.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 130),
                        const _CartState(
                          icon: Icons.shopping_cart_outlined,
                          title: 'ตะกร้ายังว่าง',
                          subtitle:
                              'เพิ่มสินค้าจากหน้า Mall แล้วกลับมาดูที่นี่',
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 18),
                    itemBuilder: (context, index) {
                      return _CartItemTile(item: controller.cartItems[index]);
                    },
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemCount: controller.cartItems.length,
                  );
                }),
              ),
            ),
            Obx(
              () => _CartSummary(
                totalItems: controller.totalQuantity,
                totalAmount: controller.formatCurrency(controller.totalAmount),
                enabled: controller.cartItems.isNotEmpty,
                isOrdering: controller.isOrdering.value,
                selectedFulfillment: controller.fulfillmentType.value,
                selectedPaymentMethod: controller.paymentMethod.value,
                canUseDelivery: controller.canUseDelivery,
                deliveryStatusText: controller.deliveryStatusText,
                onFulfillmentChanged: controller.selectFulfillment,
                onPaymentMethodChanged: controller.selectPaymentMethod,
                onOrderPressed: controller.createOrderFromCart,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartHeader extends GetView<CartController> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppConstant.appColorDark,
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
                Icons.shopping_cart_rounded,
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
                    'Cart',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      '${controller.totalQuantity} รายการในตะกร้า',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppConstant.appColorLight,
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

class _CartItemTile extends GetView<CartController> {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final imageBytes = item.imageBytes;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                width: 92,
                height: 92,
                child: imageBytes == null
                    ? Container(
                        color: AppConstant.appColorSoft,
                        child: const Icon(
                          Icons.image_not_supported_rounded,
                          color: AppConstant.appColorMuted,
                          size: 34,
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
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppConstant.appColorDeep,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description.trim().isEmpty
                        ? 'ไม่มีรายละเอียดสินค้า'
                        : item.description.trim(),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      height: 1.35,
                      color: AppConstant.appColorMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${controller.formatCurrency(item.price)}/${item.unit}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppConstant.appColor,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _QuantityButton(
                        icon: Icons.remove_rounded,
                        tooltip: 'ลดจำนวน',
                        onPressed: () => _handleDecrease(context),
                      ),
                      SizedBox(
                        width: 48,
                        child: Text(
                          '${item.quantity}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AppConstant.appColorDeep,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add_rounded,
                        tooltip: 'เพิ่มจำนวน',
                        onPressed: item.quantity >= item.stock.toInt()
                            ? null
                            : () => controller.incrementQuantity(item),
                      ),
                      const Spacer(),
                      Text(
                        controller.formatCurrency(item.totalPrice),
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: AppConstant.appColorDeep,
                          fontWeight: FontWeight.w900,
                        ),
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

  Future<void> _handleDecrease(BuildContext context) async {
    if (item.quantity > 1) {
      await controller.decrementQuantity(item);
      return;
    }

    final bool? shouldDelete = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('ลบสินค้าออกจากตะกร้า?'),
        content: Text(
          'ต้องการลบ ${item.name} จากตะกร้าไหม?',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('ไม่ลบ'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('ลบสินค้า'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await controller.deleteItem(item);
    } else {
      await controller.setQuantityToOne(item);
    }
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 38,
      child: IconButton.filledTonal(
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: Icon(icon),
        tooltip: tooltip,
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.totalItems,
    required this.totalAmount,
    required this.enabled,
    required this.isOrdering,
    required this.selectedFulfillment,
    required this.selectedPaymentMethod,
    required this.canUseDelivery,
    required this.deliveryStatusText,
    required this.onFulfillmentChanged,
    required this.onPaymentMethodChanged,
    required this.onOrderPressed,
  });

  final int totalItems;
  final String totalAmount;
  final bool enabled;
  final bool isOrdering;
  final FulfillmentType selectedFulfillment;
  final String selectedPaymentMethod;
  final bool canUseDelivery;
  final String deliveryStatusText;
  final ValueChanged<FulfillmentType> onFulfillmentChanged;
  final ValueChanged<String> onPaymentMethodChanged;
  final VoidCallback onOrderPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _FulfillmentSelector(
              selectedFulfillment: selectedFulfillment,
              canUseDelivery: canUseDelivery,
              statusText: deliveryStatusText,
              onChanged: onFulfillmentChanged,
            ),
            const SizedBox(height: 14),
            _PaymentMethodSelector(
              selectedPaymentMethod: selectedPaymentMethod,
              onChanged: onPaymentMethodChanged,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'รวม $totalItems รายการ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppConstant.appColorMuted,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        totalAmount,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppConstant.appColorDeep,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: enabled && !isOrdering ? onOrderPressed : null,
                  icon: isOrdering
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.receipt_long_rounded),
                  label: Text(isOrdering ? 'กำลังสั่ง...' : 'Order สินค้า'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodSelector extends StatelessWidget {
  const _PaymentMethodSelector({
    required this.selectedPaymentMethod,
    required this.onChanged,
  });

  final String selectedPaymentMethod;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'วิธีชำระเงิน',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppConstant.appColorDeep,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment<String>(
              value: OrderPaymentMethod.promptPay,
              icon: Icon(Icons.qr_code_2_rounded),
              label: Text('PromptPay'),
            ),
            ButtonSegment<String>(
              value: OrderPaymentMethod.cash,
              icon: Icon(Icons.payments_rounded),
              label: Text('เงินสด'),
            ),
          ],
          selected: <String>{selectedPaymentMethod},
          showSelectedIcon: false,
          onSelectionChanged: (values) => onChanged(values.first),
        ),
        const SizedBox(height: 8),
        Text(
          selectedPaymentMethod == OrderPaymentMethod.cash
              ? 'ชำระเงินสดตอนรับสินค้าที่ร้านหรือเมื่อได้รับสินค้าจากผู้ส่ง'
              : 'ชำระผ่าน QR PromptPay แล้วอัปโหลดสลิปให้ร้านตรวจสอบ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppConstant.appColorMuted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _FulfillmentSelector extends StatelessWidget {
  const _FulfillmentSelector({
    required this.selectedFulfillment,
    required this.canUseDelivery,
    required this.statusText,
    required this.onChanged,
  });

  final FulfillmentType selectedFulfillment;
  final bool canUseDelivery;
  final String statusText;
  final ValueChanged<FulfillmentType> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SegmentedButton<FulfillmentType>(
          segments: [
            const ButtonSegment<FulfillmentType>(
              value: FulfillmentType.pickup,
              icon: Icon(Icons.store_rounded),
              label: Text('มารับเอง'),
            ),
            ButtonSegment<FulfillmentType>(
              value: FulfillmentType.delivery,
              enabled: canUseDelivery,
              icon: const Icon(Icons.local_shipping_rounded),
              label: const Text('ให้ไปส่งฟรี'),
            ),
          ],
          selected: {selectedFulfillment},
          showSelectedIcon: false,
          onSelectionChanged: (Set<FulfillmentType> values) {
            onChanged(values.first);
          },
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              canUseDelivery
                  ? Icons.check_circle_rounded
                  : Icons.info_outline_rounded,
              color: canUseDelivery
                  ? const Color(0xFF12805C)
                  : const Color(0xFFB36B00),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                statusText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppConstant.appColorMuted,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
        if (canUseDelivery) ...[
          const SizedBox(height: 6),
          Text(
            'ร้านจะใช้พิกัดนี้เป็นจุดส่งสินค้า กรุณาตรวจสอบว่าตรงบ้าน/จุดรับของในหมู่บ้าน',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppConstant.appColorMuted,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}

class _CartState extends StatelessWidget {
  const _CartState({
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

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: AppConstant.appColorMuted),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppConstant.appColorDeep,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppConstant.appColorMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
