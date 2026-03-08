import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:provider/provider.dart';
import 'package:dress_app/theme.dart';
import 'package:dress_app/services/app_state.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false;

  final List<String> _suggestedPrompts = [
    'Track my order',
    'Recommend a dress for a wedding',
    'How does the rental process work?',
    'Show me trending dresses',
    'Do you offer any discounts?'
  ];

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add({'sender': 'user', 'text': text});
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      
      String reply = "I'm sorry, I'm just a simulated AI assistant for this prototype. I can't actually do that yet!";
      final lowerText = text.toLowerCase();
      
      if (lowerText.contains('track') || lowerText.contains('order')) {
        reply = "I can help with that. Please go to 'My Orders' in your profile to track your recent rentals, or provide your order ID here.";
      } else if (lowerText.contains('wedding') || lowerText.contains('recommend')) {
        reply = "For a wedding, I highly recommend our premium gowns and traditional wear. Our 'Ethnic' category has some beautiful options arriving this week!";
      } else if (lowerText.contains('discount')) {
        reply = "We currently have a 20% off promotion for first-time renters using the code FIRST20 at checkout.";
      } else if (lowerText.contains('process') || lowerText.contains('how')) {
        reply = "It's simple! Pick a dress, select your dates, wear it, and return it in the prepaid package we provide. We handle all the dry cleaning.";
      }

      setState(() {
        _isTyping = false;
        _messages.add({'sender': 'ai', 'text': reply});
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
      _isTyping = false;
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AppState>().currentUser.name;
    
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(FluentIcons.chevron_left_24_regular, color: AppTheme.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'AI ASSISTANT',
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.textDark),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _clearChat,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.textLight.withOpacity(0.2)),
              ),
              child: const Icon(FluentIcons.delete_24_regular, size: 20, color: AppTheme.textDark),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty ? _buildEmptyState(userName) : _buildChatList(),
            ),
            
            // Bottom Input
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              color: AppTheme.backgroundLight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Listening...', style: GoogleFonts.inter())),
                        );
                      },
                      child: const Icon(FluentIcons.mic_24_regular, color: AppTheme.textLight),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        onSubmitted: _sendMessage,
                        decoration: InputDecoration(
                          hintText: 'Chat with Chatbot',
                          hintStyle: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _sendMessage(_messageController.text),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppTheme.textDark,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(FluentIcons.send_24_filled, color: Colors.white, size: 16),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String userName) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👋 HI ${userName.toUpperCase()},',
            style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w900, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            'How can I help you today?',
            style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textLight),
          ),
          const SizedBox(height: 32),
          
          // Suggested Prompts
          Align(
            alignment: Alignment.centerRight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _suggestedPrompts.map((prompt) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPromptBubble(prompt),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(20),
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length && _isTyping) {
          return _buildTypingIndicator();
        }
        
        final message = _messages[index];
        final isUser = message['sender'] == 'user';
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: isUser ? AppTheme.primaryLime : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 0),
                bottomRight: Radius.circular(isUser ? 0 : 20),
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Text(
              message['text'],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: isUser ? AppTheme.textDark : AppTheme.textDark.withOpacity(0.8),
                height: 1.4,
                fontWeight: isUser ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, double val, child) {
        return Opacity(
          opacity: (val + (index * 0.2)) % 1.0,
          child: Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(color: AppTheme.textLight, shape: BoxShape.circle),
          ),
        );
      },
    );
  }

  Widget _buildPromptBubble(String text) {
    return GestureDetector(
      onTap: () => _sendMessage(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppTheme.textLight.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppTheme.textLight.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textLight,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
