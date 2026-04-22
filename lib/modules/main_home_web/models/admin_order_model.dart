enum AdminOrderStatus { pendingPayment, packing, shipped, completed, cancelled }

class AdminOrderModel {
  const AdminOrderModel({
    required this.id,
    required this.customerName,
    required this.itemCount,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.note,
  });

  final String id;
  final String customerName;
  final int itemCount;
  final double total;
  final AdminOrderStatus status;
  final DateTime createdAt;
  final String note;

  bool get isOpen =>
      status == AdminOrderStatus.pendingPayment ||
      status == AdminOrderStatus.packing ||
      status == AdminOrderStatus.shipped;
}
