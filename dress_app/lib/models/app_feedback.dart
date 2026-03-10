class AppFeedback {
  final String id;
  final String userId;
  final int rating;
  final String feedbackText;
  final DateTime createdAt;

  AppFeedback({
    required this.id,
    required this.userId,
    required this.rating,
    this.feedbackText = '',
    required this.createdAt,
  });

  factory AppFeedback.fromJson(Map<String, dynamic> json) {
    return AppFeedback(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      rating: json['rating'] as int? ?? 5,
      feedbackText: json['feedback_text'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
