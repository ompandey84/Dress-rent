class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final String? fileUrl;
  final String? fileType;

  ChatMessage({
    required this.id,
    this.roomId = '',
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.fileUrl,
    this.fileType,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      roomId: json['room_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      timestamp: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      fileUrl: json['file_url'] as String?,
      fileType: json['file_type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (roomId.isNotEmpty) 'room_id': roomId,
      'sender_id': senderId,
      'text': text,
      'is_read': isRead,
    };
  }
}
