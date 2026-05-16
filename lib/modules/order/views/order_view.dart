import 'package:flutter/material.dart';
import 'package:shoponlinemasterung/core/app_constant.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';

import '../../../model/order_model.dart';
import '../controllers/order_controller.dart';

class OrderView extends GetView<OrderController> {
  const OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: ColoredBox(
        color: AppConstant.appColorSurface,
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
                        ordersBuilder: () => controller.unCompleteOrders,
                        emptyTitle: 'ยังไม่มีออเดอร์ที่กำลังดำเนินการ',
                        emptySubtitle:
                            'เมื่อกด Order สินค้า รายการจะแสดงในหน้านี้',
                      ),
                      _OrderList(
                        ordersBuilder: () => controller.completeOrCancelOrders,
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

class _OrderList extends GetView<OrderController> {
  const _OrderList({
    required this.ordersBuilder,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  final List<OrderModel> Function() ordersBuilder;
  final String emptyTitle;
  final String emptySubtitle;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final List<OrderModel> currentOrders = ordersBuilder();

      if (currentOrders.isEmpty) {
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
            return _OrderTile(order: currentOrders[index]);
          },
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemCount: currentOrders.length,
        ),
      );
    });
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
                            color: AppConstant.appColorSoft,
                            child: const Icon(
                              Icons.image_not_supported_rounded,
                              color: AppConstant.appColorMuted,
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
                                color: AppConstant.appColorDeep,
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
                          color: AppConstant.appColorMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _buildItemSummary(order),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppConstant.appColorDeep,
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
                    order.orderType == 'delivery'
                        ? _buildDeliveryLabel(order)
                        : 'มารับเองที่ร้าน',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppConstant.appColorMuted,
                    ),
                  ),
                ),
                Text(
                  controller.formatCurrency(order.grandTotal),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppConstant.appColor,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _PaymentSlipAction(order: order),
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

  String _buildDeliveryLabel(OrderModel order) {
    final num? meters = order.deliveryDistanceMeters;
    if (meters == null) {
      return 'ส่งฟรีในหมู่บ้าน/รัศมี 1 กม.';
    }

    if (meters < 1000) {
      return 'ส่งฟรีในหมู่บ้าน (${meters.round()} เมตรจากร้าน)';
    }

    return 'ส่งฟรีในรัศมีร้าน (${(meters / 1000).toStringAsFixed(2)} กม.จากร้าน)';
  }
}

class _PaymentSlipAction extends GetView<OrderController> {
  const _PaymentSlipAction({required this.order});

  final OrderModel order;

  static const String _promptPayAsset = 'images/promptpay.JPG';
  static const String _accountName = 'นาย ชัยวุฒิ พรหมบุตร';
  static const String _accountNumber = 'xxx-x-x2767-x';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool canUpload = controller.canUploadPaymentSlip(order);
    final bool waitingVerify = order.paymentStatus == 'waiting_verify';
    final bool paid = order.paymentStatus == 'paid';

    if (paid) {
      return Column(
        children: [
          _PaymentHint(
            icon: Icons.verified_rounded,
            text: 'ร้านยืนยันการชำระเงินแล้ว',
            color: const Color(0xFF12805C),
          ),
          if (order.paymentSlipBytes != null) ...[
            const SizedBox(height: 8),
            _SlipPreviewButton(order: order),
          ],
        ],
      );
    }

    if (waitingVerify) {
      return Column(
        children: [
          _PaymentHint(
            icon: Icons.hourglass_top_rounded,
            text: 'ส่งสลิปแล้ว รอร้านตรวจสอบ',
            color: const Color(0xFFB36B00),
          ),
          if (order.paymentSlipBytes != null) ...[
            const SizedBox(height: 8),
            _SlipPreviewButton(order: order),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PromptPayPaymentCard(
          amount: controller.formatCurrency(order.grandTotal),
          assetPath: _promptPayAsset,
          accountName: _accountName,
          accountNumber: _accountNumber,
        ),
        const SizedBox(height: 12),
        if (order.paymentSlipBytes != null) ...[
          _SlipPreviewButton(order: order),
          const SizedBox(height: 10),
        ],
        Row(
          children: [
            Expanded(
              child: Text(
                order.paymentStatus == 'rejected'
                    ? 'สลิปเดิมไม่ผ่าน กรุณาอัปโหลดใหม่'
                    : 'ชำระยอด ${controller.formatCurrency(order.grandTotal)} แล้วอัปโหลดสลิป',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppConstant.appColorMuted,
                  height: 1.35,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Obx(() {
              final bool isUploading =
                  controller.uploadingPaymentOrderId.value == order.id;
              final bool anotherOrderUploading =
                  controller.uploadingPaymentOrderId.value.isNotEmpty &&
                  !isUploading;

              return FilledButton.icon(
                onPressed: !canUpload || isUploading || anotherOrderUploading
                    ? null
                    : () => controller.uploadPaymentSlip(order),
                icon: isUploading
                    ? const SizedBox.square(
                        dimension: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.upload_file_rounded, size: 18),
                label: Text(isUploading ? 'กำลังส่ง' : 'อัปโหลดสลิป'),
              );
            }),
          ],
        ),
      ],
    );
  }
}

class _PromptPayPaymentCard extends StatelessWidget {
  const _PromptPayPaymentCard({
    required this.amount,
    required this.assetPath,
    required this.accountName,
    required this.accountNumber,
  });

  final String amount;
  final String assetPath;
  final String accountName;
  final String accountNumber;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConstant.appColorSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppConstant.appColorBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 104,
                  height: 124,
                  color: Colors.white,
                  child: Image.asset(assetPath, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ชำระผ่านพร้อมเพย์',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppConstant.appColorDeep,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _PaymentInfoLine(label: 'ยอดชำระ', value: amount),
                    _PaymentInfoLine(label: 'ชื่อบัญชี', value: accountName),
                    _PaymentInfoLine(label: 'บัญชี', value: accountNumber),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _showPromptPayDialog(
                            context,
                            assetPath: assetPath,
                            amount: amount,
                            accountName: accountName,
                            accountNumber: accountNumber,
                          ),
                          icon: const Icon(Icons.qr_code_2_rounded, size: 18),
                          label: const Text('ดู QR'),
                        ),
                        _SavePromptPayQrButton(assetPath: assetPath),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'สแกน QR แล้วอัปโหลดสลิปในออเดอร์นี้ ร้านจะตรวจสอบยอดก่อนจัดเตรียมสินค้า',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppConstant.appColorMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentInfoLine extends StatelessWidget {
  const _PaymentInfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 58,
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppConstant.appColorMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppConstant.appColorDeep,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlipPreviewButton extends StatelessWidget {
  const _SlipPreviewButton({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: OutlinedButton.icon(
        onPressed: () => _showSlipPreviewDialog(context, order: order),
        icon: const Icon(Icons.receipt_long_rounded, size: 18),
        label: const Text('ดูตัวอย่างสลิป'),
      ),
    );
  }
}

Future<void> _showPromptPayDialog(
  BuildContext context, {
  required String assetPath,
  required String amount,
  required String accountName,
  required String accountNumber,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      final ThemeData theme = Theme.of(context);

      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('QR พร้อมเพย์ร้าน'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(assetPath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 12),
              Text(
                amount,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppConstant.appColor,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$accountName • $accountNumber',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppConstant.appColorMuted,
                ),
              ),
            ],
          ),
        ),
        actions: [
          _SavePromptPayQrButton(assetPath: assetPath),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      );
    },
  );
}

class _SavePromptPayQrButton extends StatefulWidget {
  const _SavePromptPayQrButton({required this.assetPath});

  final String assetPath;

  @override
  State<_SavePromptPayQrButton> createState() => _SavePromptPayQrButtonState();
}

class _SavePromptPayQrButtonState extends State<_SavePromptPayQrButton> {
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _isSaving ? null : _saveQrToGallery,
      icon: _isSaving
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download_rounded, size: 18),
      label: Text(_isSaving ? 'กำลังบันทึก' : 'บันทึก QR'),
    );
  }

  Future<void> _saveQrToGallery() async {
    setState(() => _isSaving = true);

    try {
      final ByteData data = await rootBundle.load(widget.assetPath);
      final Uint8List bytes = data.buffer.asUint8List();
      final Object? result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: 'promptpay_qr_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!_isSaveSuccess(result)) {
        throw StateError('save-gallery-failed');
      }

      Get.snackbar(
        'บันทึก QR แล้ว',
        'เปิดแอพธนาคารแล้วเลือกสแกนจากรูปใน Gallery ได้เลย',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } catch (_) {
      Get.snackbar(
        'บันทึก QR ไม่สำเร็จ',
        'กรุณาตรวจสอบสิทธิ์การเข้าถึงรูปภาพ แล้วลองใหม่อีกครั้ง',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  bool _isSaveSuccess(Object? result) {
    if (result is bool) {
      return result;
    }

    if (result is Map) {
      return result['isSuccess'] == true || result['success'] == true;
    }

    return result != null;
  }
}

Future<void> _showSlipPreviewDialog(
  BuildContext context, {
  required OrderModel order,
}) {
  final Uint8List? bytes = order.paymentSlipBytes;
  if (bytes == null) {
    return Future<void>.value();
  }

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(order.orderNo),
        content: SizedBox(
          width: 360,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.memory(bytes, fit: BoxFit.contain),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ปิด'),
          ),
        ],
      );
    },
  );
}

class _PaymentHint extends StatelessWidget {
  const _PaymentHint({
    required this.icon,
    required this.text,
    required this.color,
  });

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
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
      'ready' => AppConstant.appColor,
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
            color: AppConstant.appColorMuted,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppConstant.appColorDeep,
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
