class PaymentCard {
  final String id;
  final String cardholderName;
  final String cardLastFour;
  final String cardBrand;
  final int expiryMonth;
  final int expiryYear;
  final bool isDefault;

  PaymentCard({
    required this.id,
    required this.cardholderName,
    required this.cardLastFour,
    this.cardBrand = 'Visa',
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
  });

  factory PaymentCard.fromJson(Map<String, dynamic> json) {
    return PaymentCard(
      id: json['id'] as String,
      cardholderName: json['cardholder_name'] as String? ?? '',
      cardLastFour: json['card_last_four'] as String? ?? '',
      cardBrand: json['card_brand'] as String? ?? 'Visa',
      expiryMonth: json['expiry_month'] as int? ?? 1,
      expiryYear: json['expiry_year'] as int? ?? 2030,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }
}
