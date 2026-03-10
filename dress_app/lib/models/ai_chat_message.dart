class AiChatMessage {
  final String id;
  final String sessionId;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime createdAt;

  AiChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  factory AiChatMessage.fromJson(Map<String, dynamic> json) {
    return AiChatMessage(
      id: json['id'] as String,
      sessionId: json['session_id'] as String? ?? '',
      role: json['role'] as String? ?? 'user',
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
