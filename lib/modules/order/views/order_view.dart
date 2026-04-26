import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../model/order_model.dart';
import '../controllers/order_controller.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ColoredBox(
        color: const Color(0xFFF5F7FF),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              const _OrderHeader(),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: 'UnComplete'),
                      Tab(text: 'Complete / Cancel'),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.errorMessage.value.isNotEmpty) {
                    return RefreshIndicator(
                      onRefresh: controller.refreshOrders,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          SizedBox(
                            height: MediaQuery.sizeOf(context).height / 5,
                          ),
                          _OrderState(
                            icon: Icons.wifi_off_rounded,
                            title: controller.errorMessage.value,
                            subtitle: 'ดึงลงเพื่อโหลดข้อมูลใหม่อีกครั้ง',
                          ),
                        ],
                      ),
                    );
                  }

                  return TabBarView(
                    children: [
                      _OrderList(
                        orders: controller.unCompleteOrders,
                        emptyTitle: 'ยังไม่มีออเดอร์ที่กำลังดำเนินการ',
                        emptySubtitle:
                            'เมื่อกด Order สินค้า รายการจะแสดงในหน้านี้',
                      ),
                      _OrderList(
                        orders: controller.completeOrCancelOrders,
                        emptyTitle: 'ยังไม่มีประวัติออเดอร์',
                        emptySubtitle:
                            'ออเดอร์ที่สำเร็จหรือยกเลิกแล้วจะแสดงที่นี่',
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderHeader extends GetView<OrderController> {
  const _OrderHeader();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

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
                Icons.receipt_long_rounded,
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
                    'Order',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Obx(
                    () => Text(
                      '${controller.orders.length} ออเดอร์ของคุณ',
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

class _OrderList extends GetView<OrderController> {
  const _OrderList({
    required this.orders,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final List<OrderModel> orders;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshOrders,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 130),
            _OrderState(
              icon: Icons.receipt_long_outlined,
              title: emptyTitle,
              subtitle: emptySubtitle,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: controller.refreshOrders,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemBuilder: (context, index) {
          return _OrderTile(order: orders[index]);
        },
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemCount: orders.length,
      ),
    );
  }
}

class _OrderTile extends GetView<OrderController> {
  const _OrderTile({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final OrderItemModel? firstItem = order.items.firstOrNull;
    final imageBytes = firstItem?.imageBytes;

    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 72,
                    height: 72,
                    child: imageBytes == null
                        ? Container(
                            color: const Color(0xFFE8ECFA),
                            child: const Icon(
                              Icons.image_not_supported_rounded,
                              color: Color(0xFF7D87A8),
                              size: 30,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              order.orderNo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF17224D),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _StatusPill(status: order.status),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        controller.formatDate(order.createdAt),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF687191),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _buildItemSummary(order),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF17224D),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _OrderMeta(
                    label: 'สถานะ',
                    value: controller.statusLabel(order.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OrderMeta(
                    label: 'ชำระเงิน',
                    value: controller.paymentStatusLabel(order.paymentStatus),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'รับที่ร้าน',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF687191),
                    ),
                  ),
                ),
                Text(
                  controller.formatCurrency(order.grandTotal),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF25388F),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _buildItemSummary(OrderModel order) {
    if (order.items.isEmpty) {
      return 'ไม่มีสินค้าในออเดอร์';
    }

    final String firstName = order.items.first.productName;
    final int otherCount = order.items.length - 1;
    final String suffix = otherCount > 0 ? ' +$otherCount รายการ' : '';
    return '$firstName$suffix (${order.totalQuantity} ชิ้น)';
  }
}

class _StatusPill extends GetView<OrderController> {
  const _StatusPill({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final Color color = switch (status) {
      'completed' => const Color(0xFF12805C),
      'cancelled' => const Color(0xFFC0392B),
      'ready' => const Color(0xFF2F66D0),
      _ => const Color(0xFFB36B00),
    };

    return Container(
      constraints: const BoxConstraints(maxWidth: 112),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        controller.statusLabel(status),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _OrderMeta extends StatelessWidget {
  const _OrderMeta({required this.label, required this.value});

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
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF7D87A8),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF17224D),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _OrderState extends StatelessWidget {
  const _OrderState({
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
            Icon(icon, size: 58, color: const Color(0xFF7D87A8)),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFF17224D),
                fontWeight: FontWeight.w800,
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
      ),
    );
  }
}
