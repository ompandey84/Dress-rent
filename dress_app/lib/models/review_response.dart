class ReviewResponse {
  final String id;
  final String reviewId;
  final String vendorId;
  final String responseText;
  final DateTime createdAt;

  ReviewResponse({
    required this.id,
    required this.reviewId,
    required this.vendorId,
    required this.responseText,
    required this.createdAt,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      id: json['id'] as String,
      reviewId: json['review_id'] as String? ?? '',
      vendorId: json['vendor_id'] as String? ?? '',
      responseText: json['response_text'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
