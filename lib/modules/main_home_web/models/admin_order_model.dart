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
    required this.paymentMethod,
    required this.paymentStatus,
    required this.paymentSlipBase64,
    required this.paymentSlipUploadedAt,
    required this.items,
    required this.pickupInfo,
    required this.orderType,
    required this.deliveryDistanceMeters,
    required this.deliveryLatitude,
    required this.deliveryLongitude,
    required this.subtotal,
    required this.discount,
    required this.paidAt,
  });

  final String id;
  final String orderNo;
  final String customerName;
  final int itemCount;
  final double total;
  final AdminOrderStatus status;
  final DateTime createdAt;
  final String note;
  final String paymentMethod;
  final String paymentStatus;
  final String paymentSlipBase64;
  final DateTime? paymentSlipUploadedAt;
  final List<OrderItemModel> items;
  final PickupInfoModel pickupInfo;
  final String orderType;
  final num? deliveryDistanceMeters;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final double subtotal;
  final double discount;
  final DateTime? paidAt;

  bool get isOpen => !status.isClosed;
  bool get hasPaymentSlip => paymentSlipBase64.trim().isNotEmpty;
  bool get isCashPayment => paymentMethod == OrderPaymentMethod.cash;
  bool get isDelivery => orderType == 'delivery';
  bool get hasDeliveryLocation =>
      deliveryLatitude != null && deliveryLongitude != null;

  AdminOrderModel copyWith({
    AdminOrderStatus? status,
    String? paymentStatus,
    String? paymentSlipBase64,
    DateTime? paymentSlipUploadedAt,
  }) {
    return AdminOrderModel(
      id: id,
      orderNo: orderNo,
      customerName: customerName,
      itemCount: itemCount,
      total: total,
      status: status ?? this.status,
      createdAt: createdAt,
      note: note,
      paymentMethod: paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentSlipBase64: paymentSlipBase64 ?? this.paymentSlipBase64,
      paymentSlipUploadedAt:
          paymentSlipUploadedAt ?? this.paymentSlipUploadedAt,
      items: items,
      pickupInfo: pickupInfo,
      orderType: orderType,
      deliveryDistanceMeters: deliveryDistanceMeters,
      deliveryLatitude: deliveryLatitude,
      deliveryLongitude: deliveryLongitude,
      subtotal: subtotal,
      discount: discount,
      paidAt: paidAt,
    );
  }
}
