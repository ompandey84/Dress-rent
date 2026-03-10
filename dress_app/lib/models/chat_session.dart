import 'package:dress_app/models/chat_message.dart';

class ChatSession {
  final String id;
  final String peerId;
  final String peerName;
  final String peerAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    this.peerId = '',
    required this.peerName,
    required this.peerAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.messages = const [],
  });

  factory ChatSession.fromJson(Map<String, dynamic> json, String currentUserId) {
    final String p1 = json['participant_1'] as String;
    final String p2 = json['participant_2'] as String;
    final String peer = (p1 == currentUserId) ? p2 : p1;

    // The peer profile details would typically be joined in the query or fetched separately
    return ChatSession(
      id: json['id'] as String,
      peerId: peer,
      peerName: json['peer_name'] as String? ?? 'User',
      peerAvatar: json['peer_avatar'] as String? ?? '',
      lastMessage: json['last_message'] as String? ?? '',
      lastMessageTime: DateTime.parse(json['last_message_at'] as String),
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'last_message': lastMessage,
      'last_message_at': lastMessageTime.toIso8601String(),
    };
  }
}
