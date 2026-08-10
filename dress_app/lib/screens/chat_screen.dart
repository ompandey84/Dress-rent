import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/models/chat_session.dart';
import 'package:dress_app/models/chat_message.dart';
import 'package:dress_app/services/auth_service.dart';
import 'package:dress_app/services/support_service.dart';

class ChatScreen extends StatefulWidget {
  final ChatSession session;
  const ChatScreen({Key? key, required this.session}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _messages.addAll(widget.session.messages);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String get _myUserId => AuthService().currentUserId ?? 'me';

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().toString(),
          senderId: _myUserId,
          text: text,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _setMessages(List<ChatMessage> messages) {
    setState(() => _messages = messages);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundImage: widget.session.peerAvatar.isNotEmpty
                  ? CachedNetworkImageProvider(widget.session.peerAvatar)
                  : null,
              backgroundColor: AppTheme.primaryLime,
              child: widget.session.peerAvatar.isEmpty
                  ? Text(
                      widget.session.peerName.isNotEmpty
                          ? widget.session.peerName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w800, color: AppTheme.textDark),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.session.peerName,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Active recently',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(FluentIcons.call_24_regular, color: AppTheme.textDark, size: 20),
            tooltip: 'Call',
            onPressed: () => _showCallOptions(context),
          ),
          IconButton(
            icon: const Icon(FluentIcons.more_vertical_24_regular, color: AppTheme.textDark, size: 20),
            tooltip: 'More',
            onPressed: () => _showMoreOptions(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message.senderId == _myUserId;
                return _buildMessageBubble(message, isMe);
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.textDark : const Color(0xFFF6F8FA),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: isMe ? const Radius.circular(14) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(14),
              ),
            ),
            child: Text(
              message.text,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isMe ? Colors.white : AppTheme.textDark,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            DateFormat('h:mm a').format(message.timestamp),
            style: GoogleFonts.inter(fontSize: 9, color: AppTheme.textLight),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 8 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, -4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(color: Color(0xFFF6F8FA), shape: BoxShape.circle),
            child: const Icon(FluentIcons.add_24_regular, color: AppTheme.textLight, size: 18),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textDark),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.inter(fontSize: 13, color: AppTheme.textLight),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: AppTheme.primaryLime, shape: BoxShape.circle),
              child: const Icon(FluentIcons.send_24_filled, color: AppTheme.textDark, size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

extension _ChatActions on _ChatScreenState {
  Future<void> _showCallOptions(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FluentIcons.call_24_regular, color: AppTheme.textDark, size: 20),
              title: Text('Voice call', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Voice calls are coming soon — use chat for now.')),
                );
              },
            ),
            ListTile(
              leading: const Icon(FluentIcons.video_24_regular, color: AppTheme.textDark, size: 20),
              title: Text('Video call', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Video calls are coming soon — use chat for now.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(FluentIcons.alert_24_regular, color: Colors.red, size: 20),
              title: Text('Report user', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: Colors.white,
                    title: Text('Report ${widget.session.peerName}?', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900)),
                    content: Text('We\'ll review this conversation and take action if needed.', style: GoogleFonts.inter(fontSize: 13)),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Report', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.w900))),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  // Actually file the report.
                  final ok = await SupportService().reportUser(
                    userId: widget.session.id,
                    reason: 'inappropriate',
                    notes: 'Reported from chat',
                  );
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(ok
                          ? 'Thanks — our team will review it.'
                          : 'Could not submit the report. Please try again.'),
                      backgroundColor: ok ? AppTheme.success : Colors.red,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(FluentIcons.delete_24_regular, color: Colors.red, size: 20),
              title: Text('Clear chat history', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _setMessages([]);
              },
            ),
            ListTile(
              leading: const Icon(FluentIcons.dismiss_24_regular, color: AppTheme.textLight, size: 20),
              title: Text('Close', style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textLight)),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
