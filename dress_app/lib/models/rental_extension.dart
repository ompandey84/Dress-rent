class RentalExtension {
  final String id;
  final String orderId;
  final String userId;
  final DateTime originalEndDate;
  final DateTime newEndDate;
  final double additionalFee;
  final String status;

  RentalExtension({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.originalEndDate,
    required this.newEndDate,
    this.additionalFee = 0.0,
    required this.status,
  });

  factory RentalExtension.fromJson(Map<String, dynamic> json) {
    return RentalExtension(
      id: json['id'] as String,
      orderId: json['order_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      originalEndDate: DateTime.parse(json['original_end_date'] as String),
      newEndDate: DateTime.parse(json['new_end_date'] as String),
      additionalFee: (json['additional_fee'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'pending',
    );
  }
}
