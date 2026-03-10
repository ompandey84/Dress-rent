class BlackoutDate {
  final String id;
  final String productId;
  final DateTime blockedDate;
  final String reason;

  BlackoutDate({
    required this.id,
    required this.productId,
    required this.blockedDate,
    this.reason = '',
  });

  factory BlackoutDate.fromJson(Map<String, dynamic> json) {
    return BlackoutDate(
      id: json['id'] as String,
      productId: json['product_id'] as String? ?? '',
      blockedDate: DateTime.parse(json['blocked_date'] as String),
      reason: json['reason'] as String? ?? '',
    );
  }
}
