import '../../../model/order_model.dart';

enum AdminOrderStatus {
  pending,
  accepted,
  preparing,
  ready,
  completed,
  cancelled,
}

extension AdminOrderStatusX on AdminOrderStatus {
  String get firestoreValue {
    return switch (this) {
      AdminOrderStatus.pending => 'pending',
      AdminOrderStatus.accepted => 'accepted',
      AdminOrderStatus.preparing => 'preparing',
      AdminOrderStatus.ready => 'ready',
      AdminOrderStatus.completed => 'completed',
      AdminOrderStatus.cancelled => 'cancelled',
    };
  }

  bool get isClosed {
    return this == AdminOrderStatus.completed ||
        this == AdminOrderStatus.cancelled;
  }
}

class AdminOrderModel {
  const AdminOrderModel({
    required this.id,
    required this.orderNo,
    required this.customerName,
    required this.itemCount,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.note,
    required this.paymentStatus,
    required this.items,
    required this.pickupInfo,
    required this.subtotal,
    required this.discount,
  });

  final String id;
  final String orderNo;
  final String customerName;
  final int itemCount;
  final double total;
  final AdminOrderStatus status;
  final DateTime createdAt;
  final String note;
  final String paymentStatus;
  final List<OrderItemModel> items;
  final PickupInfoModel pickupInfo;
  final double subtotal;
  final double discount;

  bool get isOpen => !status.isClosed;

  AdminOrderModel copyWith({AdminOrderStatus? status}) {
    return AdminOrderModel(
      id: id,
      orderNo: orderNo,
      customerName: customerName,
      itemCount: itemCount,
      total: total,
      status: status ?? this.status,
      createdAt: createdAt,
      note: note,
      paymentStatus: paymentStatus,
      items: items,
      pickupInfo: pickupInfo,
      subtotal: subtotal,
      discount: discount,
    );
  }
}
