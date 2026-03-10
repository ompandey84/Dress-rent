class EarlyPickupRequest {
  final String id;
  final String orderId;
  final String userId;
  final String reason;
  final String additionalNotes;
  final String status;
  final DateTime createdAt;

  EarlyPickupRequest({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.reason,
    this.additionalNotes = '',
    required this.status,
    required this.createdAt,
  });

  factory EarlyPickupRequest.fromJson(Map<String, dynamic> json) {
    return EarlyPickupRequest(
      id: json['id'] as String,
      orderId: json['order_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      additionalNotes: json['additional_notes'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
