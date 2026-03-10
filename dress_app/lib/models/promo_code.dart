class PromoCode {
  final String id;
  final String code;
  final String discountType; // fixed or percentage
  final double discountValue;
  final double minOrderAmount;

  PromoCode({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.minOrderAmount = 0.0,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['id'] as String,
      code: json['code'] as String? ?? '',
      discountType: json['discount_type'] as String? ?? 'fixed',
      discountValue: (json['discount_value'] as num?)?.toDouble() ?? 0.0,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
