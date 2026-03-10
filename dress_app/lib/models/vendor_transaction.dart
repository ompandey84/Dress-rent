class VendorTransaction {
  final String id;
  final String vendorProfileId;
  final String orderId;
  final String bookingReference;
  final String dressName;
  final double amount;
  final String status;
  final DateTime createdAt;

  VendorTransaction({
    required this.id,
    required this.vendorProfileId,
    required this.orderId,
    required this.bookingReference,
    required this.dressName,
    required this.amount,
    required this.status,
    required this.createdAt,
  });

  factory VendorTransaction.fromJson(Map<String, dynamic> json) {
    return VendorTransaction(
      id: json['id'] as String,
      vendorProfileId: json['vendor_profile_id'] as String? ?? '',
      orderId: json['order_id'] as String? ?? '',
      bookingReference: json['booking_reference'] as String? ?? '',
      dressName: json['dress_name'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
