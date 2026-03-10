class VendorBooking {
  final String id;
  final String bookingReference;
  final String vendorProfileId;
  final String orderId;
  final String productId;
  final String customerName;
  final String rentalDates;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  VendorBooking({
    required this.id,
    required this.bookingReference,
    required this.vendorProfileId,
    required this.orderId,
    required this.productId,
    required this.customerName,
    required this.rentalDates,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VendorBooking.fromJson(Map<String, dynamic> json) {
    return VendorBooking(
      id: json['id'] as String,
      bookingReference: json['booking_reference'] as String? ?? '',
      vendorProfileId: json['vendor_profile_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      productId: json['product_id'] as String? ?? '',
      customerName: json['customer_name'] as String? ?? '',
      rentalDates: json['rental_dates'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
