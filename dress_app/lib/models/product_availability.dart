class ProductAvailability {
  final String id;
  final String productId;
  final DateTime bookedDate;
  final String? orderId;

  ProductAvailability({
    required this.id,
    required this.productId,
    required this.bookedDate,
    this.orderId,
  });

  factory ProductAvailability.fromJson(Map<String, dynamic> json) {
    return ProductAvailability(
      id: json['id'] as String,
      productId: json['product_id'] as String? ?? '',
      bookedDate: DateTime.parse(json['booked_date'] as String),
      orderId: json['order_id'] as String?,
    );
  }
}
