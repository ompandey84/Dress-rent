class ReturnRequest {
  final String id;
  final String orderId;
  final String userId;
  final String reason;
  final String status;
  final DateTime initiatedAt;
  final DateTime? completedAt;

  ReturnRequest({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.reason,
    required this.status,
    required this.initiatedAt,
    this.completedAt,
  });

  factory ReturnRequest.fromJson(Map<String, dynamic> json) {
    return ReturnRequest(
      id: json['id'] as String,
      orderId: json['order_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      initiatedAt: DateTime.parse(json['initiated_at'] as String),
      completedAt: json['completed_at'] != null ? DateTime.parse(json['completed_at'] as String) : null,
    );
  }
}
