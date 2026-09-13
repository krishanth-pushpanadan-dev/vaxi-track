enum OrderStatus {
  pending,
  approved,
  processing,
  dispatched,
  inTransit,
  delivered,
  rejected,
  cancelled,
}

class OrderRequest {
  final String id;
  final String requesterId;
  final String requesterName;
  final String supplierId;
  final String supplierName;
  final String productId;
  final String productName;
  final int quantity;
  final String unit;
  final double totalAmount;
  final String deliveryAddress;
  final DateTime requestedDate;
  final DateTime? expectedDeliveryDate;
  final OrderStatus status;
  final String notes;
  final String trackingId;

  const OrderRequest({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.supplierId,
    required this.supplierName,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.totalAmount,
    required this.deliveryAddress,
    required this.requestedDate,
    this.expectedDeliveryDate,
    required this.status,
    required this.notes,
    required this.trackingId,
  });
}
