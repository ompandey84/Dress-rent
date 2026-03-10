class Review {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String userAvatar;
  final int overallRating;
  final int? qualityRating;
  final int? fitRating;
  final String comment;
  final DateTime createdAt;
  final String? responseText;
  final DateTime? responseAt;

  Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    required this.userAvatar,
    required this.overallRating,
    this.qualityRating,
    this.fitRating,
    required this.comment,
    required this.createdAt,
    this.responseText,
    this.responseAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    String respText = '';
    DateTime? respAt;

    if (json['review_responses'] != null && (json['review_responses'] as List).isNotEmpty) {
      final responseData = (json['review_responses'] as List).first;
      respText = responseData['response_text'] as String? ?? '';
      respAt = responseData['created_at'] != null ? DateTime.parse(responseData['created_at']) : null;
    }

    return Review(
      id: json['id'] as String,
      productId: json['product_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['profiles'] != null ? json['profiles']['full_name'] as String? ?? 'User' : 'User',
      userAvatar: json['profiles'] != null ? json['profiles']['avatar_url'] as String? ?? '' : '',
      overallRating: json['overall_rating'] as int? ?? 5,
      qualityRating: json['quality_rating'] as int?,
      fitRating: json['fit_rating'] as int?,
      comment: json['comment'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      responseText: respText.isNotEmpty ? respText : null,
      responseAt: respAt,
    );
  }
}
