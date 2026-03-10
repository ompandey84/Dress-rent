class Transaction {
  final String id;
  final String orderId;
  final double amount;
  final String type;
  final String status;
  final String paymentMethod;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.type,
    required this.status,
    required this.paymentMethod,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      orderId: json['order_id'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      type: json['type'] as String? ?? 'payment',
      status: json['status'] as String? ?? 'completed',
      paymentMethod: json['payment_method'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
