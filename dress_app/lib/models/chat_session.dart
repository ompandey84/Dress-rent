import 'package:dress_app/models/chat_message.dart';

class ChatSession {
  final String id;
  final String peerName;
  final String peerAvatar;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.peerName,
    required this.peerAvatar,
    required this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.messages = const [],
  });
}
