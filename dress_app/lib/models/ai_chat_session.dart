class AiChatSession {
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;

  AiChatSession({
    required this.id,
    required this.userId,
    this.title = 'AI Stylist',
    required this.createdAt,
  });

  factory AiChatSession.fromJson(Map<String, dynamic> json) {
    return AiChatSession(
      id: json['id'] as String,
      userId: json['user_id'] as String? ?? '',
      title: json['title'] as String? ?? 'AI Stylist',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
